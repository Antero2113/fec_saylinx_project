transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/cbrt.v}
vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/sqrt.v}
vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/formula.v}
vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/bin_to_bcd_4digit.v}
vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/hex_display.v}
vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/fec_saylinx_board_top.v}

vlog -vlog01compat -work work +incdir+C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example {C:/Users/Admin/Documents/ITMO/schem/lab3/project/fec_saylinx_project_example/tb_fec_saylinx_board_top_modelsim.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_fec_saylinx_board_top_modelsim

add wave *
view structure
view signals
run -all
