clear -all 

check_sec -analyze -sv -spec ../EXERCISE_wocg/01_RTL/SNN_wocg.v
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/GATED_OR.v
check_sec -analyze -sv -imp ../EXERCISE/01_RTL/SNN.v
check_sec -elaborate -spec -top SNN -disable_x_handling -disable_auto_bbox
check_sec -elaborate -imp  -top SNN -disable_x_handling -disable_auto_bbox
check_sec -setup

clock clk -both_edge 
reset ~rst_n

check_sec -gen
check_sec -interface

assume SNN_imp.cg_en==0 
check_sec -waive -waive_signals SNN_imp.cg_en

check_sec -interface


set_sec_autoprove_strategy design_style
set_sec_autoprove_design_style_type clock_gating




check_sec -prove -bg
