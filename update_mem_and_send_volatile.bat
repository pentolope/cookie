@echo off
python AutoGen.py
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_cdb.exe" cookie -c cookie --update_mif
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_asm.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie
if errorlevel 1 goto fail
"%QUARTUS_ROOTDIR%/bin64/quartus_pgm.exe" -c "USB-Blaster [USB-0]" -m JTAG -o P;output_files/cookie.sof
if errorlevel 1 goto failfirst
goto succeed
:failfirst
echo Programming failed once, trying again
"%QUARTUS_ROOTDIR%/bin64/quartus_pgm.exe" -c "USB-Blaster [USB-0]" -m JTAG -o P;output_files/cookie.sof
if errorlevel 1 goto failsecond
goto succeed
:failsecond
echo Update memory content succeeded but programming failed twice, not trying again
goto end
:fail
echo Update memory content step failed so progress was halted
goto end
:succeed
echo Programming succeeded
:end
@echo on