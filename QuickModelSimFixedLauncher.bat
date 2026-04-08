@echo off
"../cosmic/cosmic.exe" "../cookie/boot_sim.c" -O3 -o "fpga_boot_binary_1.bin"
"../cosmic/Sim.exe" -fpga1 "fpga_boot_binary_1.bin"
echo LAUNCHER: running AutoGen.py
python AutoGen.py
"%QUARTUS_ROOTDIR%\bin64\quartus_map.exe" --read_settings_files=on --write_settings_files=off cookie -c cookie --analysis_and_elaboration
"%QUARTUS_ROOTDIR%/bin64/quartus_cdb.exe" cookie -c cookie --update_mif
"%QUARTUS_ROOTDIR%/bin64/quartus_sh.exe" -t "%QUARTUS_ROOTDIR%/common/tcl/internal/nativelink/qnativesim.tcl" --rtl_sim "cookie" "cookie"
python QuickModelSimSideloaderInternal.py
echo LAUNCHER: running modelsim
"C:\intelFPGA\20.1\modelsim_ase\win32aloem\modelsim.exe" -do %CD%/simulation/questa/cookie_run_msim_rtl_verilog.do
echo Closing this window may close ModelSim, so do not close this window!

@echo on
