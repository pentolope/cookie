

#include <stdint.h>
#include <stdbool.h>

#define FAT16_CLUSTER_FREE         0x0000
#define FAT16_CLUSTER_RESERVED_MIN 0xfff0
#define FAT16_CLUSTER_RESERVED_MAX 0xfff6
#define FAT16_CLUSTER_BAD          0xfff7
#define FAT16_CLUSTER_LAST_MIN     0xfff8
#define FAT16_CLUSTER_LAST_MAX     0xffff

#define FAT32_CLUSTER_FREE         0x00000000
#define FAT32_CLUSTER_RESERVED_MIN 0x0ffffff0
#define FAT32_CLUSTER_RESERVED_MAX 0x0ffffff6
#define FAT32_CLUSTER_BAD          0x0ffffff7
#define FAT32_CLUSTER_LAST_MIN     0x0ffffff8
#define FAT32_CLUSTER_LAST_MAX     0x0fffffff

#define FAT_DIRENTRY_DELETED 0xe5

void memcpy(void* dest, const void* src, size_t size){
	while (size!=0){
		*(uint8_t*)dest = *(uint8_t*)src;
		dest=(void*)((size_t)dest+1);
		src=(const void*)((size_t)src+1);
		--size;
	}
}

void memset(void* dest, uint8_t val, size_t size){
	while (size!=0){
		*(uint8_t*)dest = val;
		dest=(void*)((size_t)dest+1);
		--size;
	}
}

static uint16_t read2(const uint8_t* p){
	return ((uint16_t)p[0] << 0) | ((uint16_t)p[1] << 8);
}
static uint32_t read4(const uint8_t* p){
	return ((uint32_t)p[0] << 0) | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}
static void write2(uint8_t* p, uint16_t v){
	p[0]=v >> 0;p[1]=v >> 8;
}
static void write4(uint8_t* p, uint32_t v){
	p[0]=v >> 0;p[1]=v >> 8;p[2]=v >>16;p[3]=v >>24;
}

// struct Folder_File_Object represents a folder that is targetting a subfolder or file contained inside
struct Folder_File_Object {
	// struct Target_Folder_File represents the target of struct Folder_File_Object
	struct Target_Folder_File {
		uint8_t attributes;
		uint8_t checksum; // checksum is mainly used when generating data for this struct
		uint8_t written_entries_count; // is 0 if no directory entry is written for target in parent folder
		bool is_open_for_writing;
		uint32_t file_size; // is 0 for folders
		uint32_t directory_entry_cluster; // data cluster that holds the directory entry for the target in the parent folder
		uint32_t directory_entry_offset; // is in units of bytes. the offset is at the start of directory entries (LFN makes multiple entries, the offset and cluster point to the first one)
		uint32_t entrance_cluster; // the first cluster that holds the data for target folder/file
		uint32_t walking_cluster; // for the current walking position inside target folder/file
		uint32_t walking_position; // the current walking position inside target folder/file
		uint32_t walking_offset_in_cluster; // equal to `target.walking_position % file_system.cluster_size`
		uint8_t name[256];
	} target;
	uint32_t parent_folder_entrance_cluster; // used primarily when writing a directory entry
	bool is_target_root; // if this is true then what struct Folder_File_Object represents is actually just the root directory of the filesystem. In which case, non of the other information is relevent.
};


struct File_System {
	bool isFAT16;
	uint8_t sectors_per_cluster; // the number of sectors in one cluster

	uint32_t root_dir_cluster; // root_dir_cluster is in units of clusters
	uint32_t data_cluster_count; // data_cluster_count is in units of clusters
	
	uint32_t fat_offset; // fat_offset is in units of sectors
	uint32_t cluster_zero_offset; // cluster_zero_offset is in units of sectors
	uint32_t root_dir_offset; // root_dir_offset is in units of sectors
	
	uint32_t fat16_root_max; // fat16_root_max is in units of bytes and is only applicable for fat16
	uint32_t cluster_size; // cluster_size is in units of bytes
} file_system = {0};

#define CACHE_SIZE 15

#define CACHE_SECTOR_DATA_ADDRESS(index,offset) ((uint8_t*)((unsigned long)(index)*512lu+((0x80000000lu|0x1000000lu|512lu)+(unsigned long)(offset))))

struct Cache {
	uint8_t sector_count;
	uint8_t sector_walk;
	uint32_t sector_addresses[CACHE_SIZE];
	uint8_t sector_io_err_val[CACHE_SIZE];
} cache={0};

static bool card_to_cache(uint8_t index){
	cache.sector_io_err_val[index]=0;
	uint8_t io_err_val=1;
	*((volatile uint8_t*)(0x80000000lu|0x02lu))=1;
	if (*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x04lu))!=4) {goto Fail;}
	*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x00lu))=0;
	*((volatile uint32_t*)(0x80000000lu|0x1000000lu|0x0Clu))=cache.sector_addresses[index];
	*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x08lu))=(index+1) & 15;
	*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x02lu))=1;
	io_err_val=2;
	while (1){
		uint8_t c=*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x04lu));
		if (c==3) break;
		if (c==0 | c==5 | c==6) {goto Fail;}
	}
	*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x02lu))=0;
	io_err_val=3;
	while (1){
		uint8_t c=*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x04lu));
		if (c==4) break;
		if (c!=3) {goto Fail;}
	}
	if (*((volatile uint16_t*)(0x80000000lu|0x1000000lu|0x06lu))!=0) {goto Fail;}
	*((volatile uint8_t*)(0x80000000lu|0x02lu))=0;
	return 0;
	Fail:;
	cache.sector_io_err_val[index]=io_err_val;
	*((volatile uint8_t*)(0x80000000lu|0x04lu))=1;
	return 1;
}

// only needs to be called when that sector is not present in the cache
static bool cache_load(uint32_t sector){
	uint8_t index;
	for (index=0;index<cache.sector_count;index++){
		if (cache.sector_addresses[index]==sector){
			if (cache.sector_io_err_val[index]!=0){
				return card_to_cache(index);
			}
			return 0;
		}
	}
	if (cache.sector_count<CACHE_SIZE){
		index=cache.sector_count++;
	} else {
		index=cache.sector_walk;
		if (++cache.sector_walk>=CACHE_SIZE){
			cache.sector_walk=0;
		}
	}
	cache.sector_addresses[index]=sector;
	return card_to_cache(index);
}

// via_sector is for a 32bit sector number with a 16bit byte offset. Nothing else is added to the address
static bool cache_read_via_sector(uint32_t sector,uint16_t offset,uint32_t size,uint8_t* buffer){
	if (size==0) return 0;
	if (offset>=512u){
		sector+=(unsigned)offset >> 9;
		offset =(unsigned)offset & 511;
	}
	while (1){
		lstart:;
		for (uint8_t i=0;i<cache.sector_count;i++){
			if (sector==cache.sector_addresses[i] & cache.sector_io_err_val[i]==0){
				uint32_t s=512u-offset;
				if (size<s) s=size;
				memcpy(buffer,CACHE_SECTOR_DATA_ADDRESS(i,offset),s);
				size-=s;
				if (size==0) return 0;
				buffer+=s;
				offset=0;
				sector++;
				goto lstart;
			}
		}
		if (cache_load(sector)) return 1;
	}
}

// at_cluster is for a 28bit cluster number with a 32bit byte offset. The header and table area is added to the address, thus it accesses the data of the clusters.
// if the file system is FAT16 and the cluster number is 0, then the root directory table is accessed instead.
// if the file system is FAT32 then the cluster number should never be 0.
// the cluster number should never be 1.
// the conditions stated above are not checked for validity.
static bool cache_read_at_cluster(uint32_t cluster,uint32_t offset_large,uint32_t size,uint8_t* buffer){
	return cache_read_via_sector(
		((file_system.isFAT16 & cluster==0)?file_system.root_dir_offset:((cluster - 2) * file_system.sectors_per_cluster + file_system.cluster_zero_offset)) + (offset_large >> 9),
		(uint16_t)(offset_large & 511),
		size,
		buffer
	);
}

/*
at_table is for a 28bit cluster number. The header area is added to the address, thus it accesses the file allocation table.
no size is given because the size can be assumed.
additionally, read_at_table will set the following bits:
bit 28 if the value is "free cluster"
bit 29 if the value is "reserved cluster"
bit 30 if the value is "bad cluster"
bit 31 if the value is "last cluster"
*/
static bool cache_read_at_table(uint32_t cluster,uint32_t* value){
	uint8_t buffer[4] = {0};
	const uint8_t size=file_system.isFAT16?2:4;
	cluster*=size;
	const uint32_t sector=file_system.fat_offset + (cluster >> 9);
	const uint16_t offset=cluster & 511;
	if (cache_read_via_sector(sector,offset,size,buffer)) return 1;
	// for fat32 the upper 4 bits of a cluster entry should be interpreted as 0
	// this transformation can be done when fat16 as well, because it doesn't make a difference for fat16
	buffer[3] &= 0x0f;
	uint32_t value_local=read4(buffer);
	value_local |= 
		((uint32_t)
			(
				(
					file_system.isFAT16
				)?(
					0x10*((uint16_t)value_local==FAT16_CLUSTER_FREE) |
					0x20*((uint16_t)value_local>=FAT16_CLUSTER_RESERVED_MIN & (uint16_t)value_local<=FAT16_CLUSTER_RESERVED_MAX) |
					0x40*((uint16_t)value_local==FAT16_CLUSTER_BAD) |
					0x80*((uint16_t)value_local>=FAT16_CLUSTER_LAST_MIN & (uint16_t)value_local<=FAT16_CLUSTER_LAST_MAX)
				):(
					0x10*(value_local==FAT32_CLUSTER_FREE) |
					0x20*(value_local>=FAT32_CLUSTER_RESERVED_MIN & value_local<=FAT32_CLUSTER_RESERVED_MAX) |
					0x40*(value_local==FAT32_CLUSTER_BAD) |
					0x80*(value_local>=FAT32_CLUSTER_LAST_MIN & value_local<=FAT32_CLUSTER_LAST_MAX)
				)
			)
		) << 24;
	*value=value_local;
	return 0;
}

// ptr_cluster is read to get the current cluster and written with the value of the next cluster, or is written with 0 if there is no next cluster.
// for fat16, ptr_cluster should still be to a 32bit number, but the upper word will be set to 0
// returns 1 on IO error. Whenever it returns 1, ptr_cluster will have been set to 0
static bool fat_get_next_cluster(uint32_t* ptr_cluster){
	uint32_t cluster=*ptr_cluster;
	*ptr_cluster=0;
	if (cluster < 2) return 0;
	if (cache_read_at_table(cluster,&cluster)) return 1;
	if ((cluster & 0xf0000000)!=0) return 0;
	*ptr_cluster=cluster;
	return 0;
}

static uint8_t fat_calc_8_3_checksum(const uint8_t* file_name){
	uint8_t checksum=file_name[0];
	for (uint16_t i=1;i<11;i++) checksum = ((checksum >> 1) | (checksum << 7)) + file_name[i];
	return checksum;
}


// returns 0 if the next entry needs to be read, returns 1 if a subfolder/file has finished being read
static bool fat_interpret_directory_entry(uint32_t current_cluster,uint32_t offset,const uint8_t* buffer,struct Folder_File_Object* ffo){
	if (buffer[0]==FAT_DIRENTRY_DELETED | buffer[0]==0){
		ffo->target.written_entries_count=0;
		return 0;
	}
	uint8_t* name=ffo->target.name;
	if (buffer[11]==0x0f){
		if (ffo->target.written_entries_count==0 | ffo->target.checksum!=buffer[13]){
			memset(&ffo->target,0,sizeof(struct Target_Folder_File));
			ffo->target.directory_entry_cluster=current_cluster;
			ffo->target.directory_entry_offset=offset;
			ffo->target.checksum=buffer[13];
		}
		ffo->target.written_entries_count+=1;
		const uint8_t char_mapping[13]={ 1, 3, 5, 7, 9, 14, 16, 18, 20, 22, 24, 28, 30 };
		const uint16_t char_offset = ((buffer[0] & 0x1f) - 1) * 13;
		for (uint16_t i=0;i<13;i++){
			uint16_t k=char_offset+i;
			if (k<255) name[k]=buffer[char_mapping[i]];
		}
		return 0;
	} else {
		if (fat_calc_8_3_checksum(buffer)!=ffo->target.checksum | ffo->target.written_entries_count==0 | name[0]==0){
			memset(&ffo->target,0,sizeof(struct Target_Folder_File));
			ffo->target.directory_entry_cluster=current_cluster;
			ffo->target.directory_entry_offset=offset;
			ffo->target.checksum=fat_calc_8_3_checksum(buffer);
			bool change_capitalization=(buffer[12] & 0x08)!=0;
			uint16_t i=0;
			while (i<8){
				const uint8_t c=buffer[i];
				if (c==' ') break;
				name[i++]=c+(change_capitalization & c>='A' & c<='Z')*('a'-'A');
			}
			if (buffer[0]==0x05) name[0]=0xe5;
			if (buffer[8]!=' '){
				change_capitalization=(buffer[12] & 0x10)!=0;
				name[i++]='.';
				uint16_t j=8;
				while (j<11){
					const uint8_t c=buffer[j++];
					if (c==' ') break;
					name[i++]=c+(change_capitalization & c>='A' & c<='Z')*('a'-'A');
				}
			}
		}
		{
			name[255]=0;
			uint16_t i=0;
			uint16_t j=0;
			uint8_t c;
			while ((c=name[i++])){
				if (c!='/' & c!='\\' & c!=':' & c!='*' & c!='?' & c>=32 & c<=126) name[j++]=c;
			}
			name[j]=0;
		}
		if (name[0]==0){
			ffo->target.written_entries_count=0;
			return 0;
		}
		ffo->target.written_entries_count+=1;
		ffo->target.attributes=buffer[11];
		ffo->target.file_size=read4(buffer+28);
		ffo->target.entrance_cluster=read2(buffer+26);
		if (!file_system.isFAT16) ffo->target.entrance_cluster |= ((uint32_t)read2(buffer+20) & 0x0fff) << 16;
		ffo->target.walking_cluster=ffo->target.entrance_cluster;
		return 1;
	}
}

struct Directory_Content_Iterator_Arguments {
	struct Folder_File_Object* ffo;
	uint32_t current_cluster;
	uint32_t current_offset;
	bool had_io_error;
};


// returns 1 if another directory was found. 0 if no more directories exist or there was an io error
static bool fat_directory_content_iterator(struct Directory_Content_Iterator_Arguments* dcia){
	dcia->ffo->target.written_entries_count=0;
	dcia->ffo->is_target_root=0;
	dcia->had_io_error=1;
	uint32_t cluster_size=file_system.cluster_size;
	if (dcia->current_cluster==0){
		if (file_system.isFAT16){
			cluster_size=(file_system.cluster_zero_offset - file_system.root_dir_offset)  * (uint32_t)512;
		} else {
			dcia->current_cluster=file_system.root_dir_cluster;
		}
	}
	uint8_t buffer[32];
	while (1){
		if (dcia->current_offset>=cluster_size){
			dcia->current_offset=0;
			if (fat_get_next_cluster(&dcia->current_cluster)) return 0;
			if (dcia->current_cluster==0){
				// no more directory entries to find
				dcia->had_io_error=0;
				memset(&dcia->ffo->target,0,sizeof(struct Target_Folder_File));
				return 0;
			}
		}
		if (cache_read_at_cluster(dcia->current_cluster,dcia->current_offset,32,buffer)) return 0;
		const bool is_finished=fat_interpret_directory_entry(dcia->current_cluster,dcia->current_offset,buffer,dcia->ffo);
		dcia->current_offset+=32;
		if (is_finished){
			// a directory entry listing is finished being read
			dcia->had_io_error=0;
			return 1;
		}
	}
}

// case insensitive, does not do pattern matching
static bool is_filename_match(const uint8_t* source_name, const uint8_t* test_name, uint16_t length){
	for (uint16_t i=0;i<length;i++){
		uint8_t c0=source_name[i];
		c0+=(c0>='A' & c0<='Z')*('a'-'A');
		uint8_t c1=test_name[i];
		c1+=(c1>='A' & c1<='Z')*('a'-'A');
		if (c0==0 | c1==0 | c0!=c1) return 0;
	}
	return test_name[length]==0;
}

// returns true when boot file was NOT found
static bool fat_find_boot_file(struct Folder_File_Object* ffo){
	memset(ffo,0,sizeof(struct Folder_File_Object));
	struct Directory_Content_Iterator_Arguments dcia = {.ffo = ffo};
	while (fat_directory_content_iterator(&dcia)){
		if (is_filename_match("boot.bin",ffo->target.name,8)){
			return 0;
		}
	}
	return 1;
}

// returns true when an error occured (either io or filesystem corruption)
static bool fat_true_seek(struct Folder_File_Object* ffo){
	ffo->target.walking_cluster = ffo->target.entrance_cluster;
	uint32_t temporary_reversed_position=ffo->target.walking_position;
	while (temporary_reversed_position >= file_system.cluster_size){
		temporary_reversed_position-=file_system.cluster_size;
		if (fat_get_next_cluster(&ffo->target.walking_cluster)) return 1;
		if (ffo->target.walking_cluster==0) return 1;
	}
	ffo->target.walking_offset_in_cluster=temporary_reversed_position;
	return 0;
}


/*
return values:
-1 means end of file was reached (buffer was not filled)
-2 means an error occured
other values are the number of bytes read (up to 512)
*/
static int fat_read_bytes_in_target_file(struct Folder_File_Object* ffo, uint8_t* buffer){
	uint16_t count;
	uint32_t file_left;
	uint32_t temp_walking_offset;
	if (ffo->target.walking_position >= ffo->target.file_size) return -1;
	if (ffo->target.walking_cluster==0){
		// then the walking_cluster needs to be found based on the walking_position
		if (fat_true_seek(ffo)) return -2;
	}
	if (ffo->target.walking_cluster==0) return -2;
	file_left=ffo->target.file_size - ffo->target.walking_position;
	if (file_left > 512){
		count=512;
	} else {
		count=file_left;
	}
	temp_walking_offset=ffo->target.walking_offset_in_cluster;
	if (cache_read_at_cluster(ffo->target.walking_cluster,temp_walking_offset,count,buffer)) return -2;
	ffo->target.walking_position+=count;
	temp_walking_offset+=count;
	if (temp_walking_offset>=file_system.cluster_size){
		temp_walking_offset-=file_system.cluster_size;
		ffo->target.walking_offset_in_cluster=temp_walking_offset;
		if (fat_get_next_cluster(&ffo->target.walking_cluster)){
			ffo->target.walking_cluster = 0;
			return -2;
		}
	} else {
		ffo->target.walking_offset_in_cluster=temp_walking_offset;
	}
	return count;
}



// only open_file_system() should use open_file_system_no_reset_error()
static bool open_file_system_no_reset_error(uint8_t partition_index){
	memset(&file_system,0,sizeof(struct File_System));
	partition_index &= 3; // force range to be correct
	uint8_t buffer[37];
	if (cache_read_via_sector(0,450 + partition_index * 16,12,buffer)){*(volatile uint8_t*)((0x80800000lu+(0u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;}
	if (buffer[0]==0){*(volatile uint8_t*)((0x80800000lu+(1u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;} // no partition at that index
	const uint32_t partition_offset=read4(buffer+4);
	const uint32_t partition_length=read4(buffer+8);
	
	if (cache_read_via_sector(partition_offset,11,37,buffer)){*(volatile uint8_t*)((0x80800000lu+(2u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;}
	{
		const uint16_t bytes_per_sector=read2(buffer);
		if (bytes_per_sector!=512){*(volatile uint8_t*)((0x80800000lu+(3u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;} // this implementation only supports sector sizes of 512 bytes
	}
	file_system.sectors_per_cluster=*(buffer+2);
	if (file_system.sectors_per_cluster==0){*(volatile uint8_t*)((0x80800000lu+(4u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;}
	const uint16_t reserved_sectors=read2(buffer+3);
	const uint8_t fat_copies=*(buffer+5);
	const uint16_t max_root_entries=read2(buffer+6);
	const uint16_t sector_count_16=read2(buffer+8);
	const uint16_t sectors_per_fat16=read2(buffer+11);
	const uint32_t sector_count_32=read4(buffer+21);
	const uint32_t sectors_per_fat32=read4(buffer+25);
	file_system.root_dir_cluster=read4(buffer+33);
	if (
		(sector_count_16==0u & sector_count_32==0u) | // bad volume size
		(sectors_per_fat16!=0u & sectors_per_fat32==0u) // not fat16 or fat32
		) {*(volatile uint8_t*)((0x80800000lu+(5u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;}
	const uint32_t sector_count_final=(sector_count_32==0u)?sector_count_16:sector_count_32;
	const uint32_t sectors_per_fat_final=(sectors_per_fat16!=0u)?sectors_per_fat16:sectors_per_fat32;
	const uint16_t max_root_entry_sectors=((uint32_t)max_root_entries * 32u + 511u) >> 9;
	const uint32_t data_sector_count = sector_count_final - reserved_sectors - sectors_per_fat_final * fat_copies - max_root_entry_sectors;
	file_system.data_cluster_count = data_sector_count / file_system.sectors_per_cluster;
	file_system.fat16_root_max=(uint32_t)max_root_entry_sectors * 512u;
	file_system.fat_offset=partition_offset + reserved_sectors;
	file_system.cluster_size=(uint32_t)file_system.sectors_per_cluster * 512u;
	if (file_system.data_cluster_count < 4085LU){
		*(volatile uint8_t*)((0x80800000lu+(6u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5;
		return 1; // fat12 not supported
	} else if (file_system.data_cluster_count < 65525LU){
		file_system.isFAT16=1;
		file_system.root_dir_offset=file_system.fat_offset + fat_copies * (uint32_t)sectors_per_fat16;
		file_system.cluster_zero_offset=file_system.root_dir_offset + max_root_entry_sectors;
		file_system.root_dir_cluster=0; // for fat16, root_dir_cluster is forced to be 0
	} else {
		file_system.isFAT16=0;
		file_system.root_dir_offset=0;
		file_system.cluster_zero_offset=file_system.fat_offset + fat_copies * sectors_per_fat_final;
		if (file_system.root_dir_cluster==0) {*(volatile uint8_t*)((0x80800000lu+(7u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<5; return 1;} // for fat32, root_dir_cluster should not be 0
	}
	*(volatile uint8_t*)((0x80800000lu+(8u+80u*(7u+(unsigned)partition_index))*3lu)+2u)=7<<2;
	return 0;
}

// returns 1 if the partition could not be opened, otherwise 0
static bool open_file_system(uint8_t partition_index){
	if (open_file_system_no_reset_error(partition_index)){
		memset(&file_system,0,sizeof(struct File_System));
		return 1;
	}
	return 0;
}

// returns 1 on failure, 0 on success
static bool perform_file_system_init(){
	for (uint8_t partition_index=0;partition_index<4;partition_index++){
		if (!open_file_system(partition_index)){
			return 0;
		}
	}
	return 1;
}


// give_message() can only write one message to the screen because it doesn't keep track of the line
static void give_message(const char* s){
	for (uint16_t i=0;i<80;i++){
		uint32_t a;
		if (s[i]==0){
			for (;i<80;i++){
				a=0x80800000lu+(i+80u*7u)*3lu;
				*(volatile uint8_t*)(a+0)=' ';
				*(volatile uint8_t*)(a+1)=255;
				*(volatile uint8_t*)(a+2)=0;
			}
			return;
		} else {
			a=0x80800000lu+(i+80u*7u)*3lu;
			*(volatile uint8_t*)(a+0)=s[i];
			*(volatile uint8_t*)(a+1)=255;
			*(volatile uint8_t*)(a+2)=1;
		}
	}
}

static void _exec_springboard(){
	__FUNCTION_RET_INSTRUCTION_ADDRESS=0x10000lu;
}

static void empty_function(){} // this is used to fulfill requirements about executing modified memory

int main(){
	Start:;
	give_message("Bootloader Starting");
	uint8_t buffer[512];
	struct Folder_File_Object ffo;
	uint8_t tb;
	while ((tb=*((volatile uint8_t*)(0x80000000lu|0x1000000lu|0x04lu)))!=4){
		if (tb==5){
			give_message("Bootloader Error: SD/MMC reader failed to initialize it's card");
			while (1){}
		}
	}
	if (perform_file_system_init()){
		give_message("Bootloader Error: Could not initialize FAT file system");
		while (1){}
	}
	if (fat_find_boot_file(&ffo)){
		give_message("Bootloader Error: Could not find \"BOOT.BIN\" in the root directory");
		while (1){}
	}
	give_message("Bootloader is reading \"BOOT.BIN\" into RAM");
	int v;
	size_t dest=0x10000lu;
	while (1){
		v=fat_read_bytes_in_target_file(&ffo,buffer);
		if (v==-2){
			give_message("Bootloader Error: Failed to read \"BOOT.BIN\"");
			while (1){}
		}
		if (v==-1){
			break;
		}
		memcpy((uint8_t*)dest,buffer,v);
		dest+=v;
	}
	give_message("Bootloader Finished");
	empty_function();
	empty_function();
	empty_function();
	empty_function();
	_exec_springboard();
	goto Start; // this should not be reached
}
