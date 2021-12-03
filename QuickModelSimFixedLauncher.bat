@echo off
echo WARNING: this launcher does not run quartus's analysis and elaboration beforehand, so modelsim might not get completely updated information
echo LAUNCHER: running AutoGen.py
python AutoGen.py
echo LAUNCHER: starting auto fixing sideloader for modelsim via quartus
if exist simulation\hijacker_ready.txt del simulation\hijacker_ready.txt
start "" python QuickModelSimSideloaderInternal.py
if exist simulation\modelsim\cookie_run_msim_rtl_verilog.do.bak del simulation\modelsim\cookie_run_msim_rtl_verilog.do.bak
:hijacker_not_ready
if exist simulation\hijacker_ready.txt goto hijacker_ready
goto hijacker_not_ready
:hijacker_ready
del simulation\hijacker_ready.txt
echo LAUNCHER: running modelsim via quartus
"%QUARTUS_ROOTDIR%/bin64/quartus_sh.exe" -t "%QUARTUS_ROOTDIR%/common/tcl/internal/nativelink/qnativesim.tcl" --rtl_sim "cookie" "cookie"
echo Closing this window will close ModelSim, so do not close this window!
exit
@echo on
