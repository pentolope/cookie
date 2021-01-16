@echo off
echo LAUNCHER: running AutoGen.py
python AutoGen.py
echo LAUNCHER: running quartus analysis and elaboration
"H:/FPGA/program/quartus/bin64/quartus_map.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie --analysis_and_elaboration
echo LAUNCHER: starting auto fixing sideloader for modelsim via quartus
if exist simulation\hijacker_ready.txt del simulation\hijacker_ready.txt
start python ModelSimSideloaderInternal.py
if exist simulation\modelsim\cookie_run_msim_rtl_verilog.do.bak del simulation\modelsim\cookie_run_msim_rtl_verilog.do.bak
:hijacker_not_ready
if exist simulation\hijacker_ready.txt goto hijacker_ready
goto hijacker_not_ready
:hijacker_ready
del simulation\hijacker_ready.txt
echo LAUNCHER: running modelsim via quartus
"H:/FPGA/program/quartus/bin64/quartus_sh.exe" -t "h:/fpga/program/quartus/common/tcl/internal/nativelink/qnativesim.tcl" --rtl_sim "cookie" "cookie"
echo Closing this window will close ModelSim, so do not close this window!
exit
@echo on
