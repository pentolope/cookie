python AutoGen.py
"%QUARTUS_ROOTDIR%/bin64/quartus_cdb.exe" cookie -c cookie --update_mif
"%QUARTUS_ROOTDIR%/bin64/quartus_asm.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
