#include <stdint.h>
#include <string.h>

uint32_t total_cycle_counter[2];
uint32_t instruction_run_count[2];
uint32_t cycles_spent_in_cache_fault[2];
uint32_t cache_fault_count;
uint32_t cache_fault_prefetch_nonbusy_on_success_count;
uint32_t cache_fault_prefetch_nonbusy_on_fail_count;
uint32_t cache_fault_prefetch_busy_on_success_count;
uint32_t cache_fault_prefetch_busy_on_fail_count;
uint32_t hyperfetch_success_no_wait_count;
uint32_t hyperfetch_success_with_wait_count;
uint32_t recent_jump_success_count;
uint32_t instruction_prefetch_fail_count;


#define ADDR_IO 0x80000000lu
#define ADDR_STAT (ADDR_IO|0x2000000lu)
#define ACCESS_STAT(type,addr) (*((volatile type*)(ADDR_STAT|addr)))
#define STAT_freeze ACCESS_STAT(uint16_t,0x00)
#define STAT_reset ACCESS_STAT(uint16_t,0x04)
#define STAT_total_cycle_counter {ACCESS_STAT(uint32_t,0x08),ACCESS_STAT(uint32_t,0x0C)}
#define STAT_instruction_run_count {ACCESS_STAT(uint32_t,0x10),ACCESS_STAT(uint32_t,0x14)}
#define STAT_cycles_spent_in_cache_fault {ACCESS_STAT(uint32_t,0x18),ACCESS_STAT(uint32_t,0x1C)}


#define STAT_cache_fault_count ACCESS_STAT(uint32_t,0x20)
#define STAT_cache_fault_prefetch_nonbusy_on_success_count ACCESS_STAT(uint32_t,0x28)
#define STAT_cache_fault_prefetch_nonbusy_on_fail_count ACCESS_STAT(uint32_t,0x30)
#define STAT_cache_fault_prefetch_busy_on_success_count ACCESS_STAT(uint32_t,0x38)
#define STAT_cache_fault_prefetch_busy_on_fail_count ACCESS_STAT(uint32_t,0x40)
#define STAT_hyperfetch_success_no_wait_count ACCESS_STAT(uint32_t,0x48)
#define STAT_hyperfetch_success_with_wait_count ACCESS_STAT(uint32_t,0x50)
#define STAT_recent_jump_success_count ACCESS_STAT(uint32_t,0x58)
#define STAT_instruction_prefetch_fail_count ACCESS_STAT(uint32_t,0x60)

#define PRT_STAT_64(name) printf(#name "\r\n  %04X%04X%04X%04X\r\n",(unsigned)(name[1] >> 16),(unsigned)(name[1] >>  0),(unsigned)(name[0] >> 16),(unsigned)(name[0] >>  0));
#define PRT_STAT_32(name) printf(#name "\r\n  %04X%04X\r\n",(unsigned)(name >> 16),(unsigned)(name >>  0));

void cosmicStatPrint(void){
	STAT_freeze = 1;
	// Throw away some stuff
	STAT_instruction_prefetch_fail_count;
	STAT_instruction_prefetch_fail_count;
	STAT_instruction_prefetch_fail_count;
	STAT_instruction_prefetch_fail_count;
	// Now read it for real
	uint32_t total_cycle_counter_[2] = STAT_total_cycle_counter;
	uint32_t instruction_run_count_[2] = STAT_instruction_run_count;
	uint32_t cycles_spent_in_cache_fault_[2] = STAT_cycles_spent_in_cache_fault;
	total_cycle_counter[0] = total_cycle_counter_[0];
	total_cycle_counter[1] = total_cycle_counter_[1];
	instruction_run_count[0] = instruction_run_count_[0];
	instruction_run_count[1] = instruction_run_count_[1];
	cycles_spent_in_cache_fault[0] = cycles_spent_in_cache_fault_[0];
	cycles_spent_in_cache_fault[1] = cycles_spent_in_cache_fault_[1];
	//memcpy(total_cycle_counter,total_cycle_counter_,sizeof(total_cycle_counter));
	//memcpy(instruction_run_count_,instruction_run_count_,sizeof(instruction_run_count));
	//memcpy(cycles_spent_in_cache_fault_,cycles_spent_in_cache_fault_,sizeof(cycles_spent_in_cache_fault));
	cache_fault_count = STAT_cache_fault_count;
	cache_fault_prefetch_nonbusy_on_success_count = STAT_cache_fault_prefetch_nonbusy_on_success_count;
	cache_fault_prefetch_nonbusy_on_fail_count = STAT_cache_fault_prefetch_nonbusy_on_fail_count;
	cache_fault_prefetch_busy_on_success_count = STAT_cache_fault_prefetch_busy_on_success_count;
	cache_fault_prefetch_busy_on_fail_count = STAT_cache_fault_prefetch_busy_on_fail_count;
	hyperfetch_success_no_wait_count = STAT_hyperfetch_success_no_wait_count;
	hyperfetch_success_with_wait_count = STAT_hyperfetch_success_with_wait_count;
	recent_jump_success_count = STAT_recent_jump_success_count;
	instruction_prefetch_fail_count = STAT_instruction_prefetch_fail_count;
	STAT_reset = 1;
	STAT_freeze = 0;
}

int main(){
	
	
	while (1){
		cosmicStatPrint();
		for (size_t i = 0;i < 100;i++){*(volatile uint16_t*)(i*32);}
	}
}

