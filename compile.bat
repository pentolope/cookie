@echo off
cls
"../cosmic/cosmic.exe" "../cookie/boot.c" -O3 -o "fpga_boot_binary_1.bin"
if errorlevel 1 goto fail
"../cosmic/cosmic.exe" "../cosmic/KCS.c" -O3 -o "fpga_boot_binary_2.bin"
if errorlevel 1 goto fail
"../cosmic/Sim.exe" -fpga1 "fpga_boot_binary_1.bin"
if errorlevel 1 goto fail
"../cosmic/Sim.exe" -fpga2 "fpga_boot_binary_2.bin"
if errorlevel 1 goto fail
python AutoGen.py
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_map.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie --analysis_and_elaboration
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_map.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_fit.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_sta.exe" cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_asm.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_cdb.exe" cookie -c cookie --update_mif
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_asm.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_eda.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
goto succeed
:fail
echo Compilation step failed so progress was halted
goto end
:succeed
echo Compilation succeeded
:end
@echo on