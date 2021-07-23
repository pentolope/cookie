@echo off
"%QUARTUS_ROOTDIR%/bin64/quartus_pgm.exe" -c "USB-Blaster [USB-0]" -m JTAG -o P;output_files/cookie.sof
if errorlevel 1 goto failfirst
goto succeed
:failfirst
echo Programming failed once, trying again
"%QUARTUS_ROOTDIR%/bin64/quartus_pgm.exe" -c "USB-Blaster [USB-0]" -m JTAG -o P;output_files/cookie.sof
if errorlevel 1 goto failsecond
goto succeed
:failsecond
echo Programming failed twice, not trying again
goto end
:succeed
echo Programming succeeded
:end
@echo on