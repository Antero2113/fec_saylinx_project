# TCL скрипт для запуска тестирования в ModelSim
# Использование: в ModelSim выполните: do run_modelsim.tcl

# Создание библиотеки работы
vlib work
vmap work work

# Компиляция всех модулей
echo "Compiling modules..."

vlog -work work formula.v
vlog -work work cbrt.v
vlog -work work sqrt.v
vlog -work work mult.v
vlog -work work fec_saylinx_board_top.v
vlog -work work tb_fec_saylinx_board_top_modelsim.v

# Запуск симуляции
echo "Starting simulation..."
vsim -t 1ns work.tb_fec_saylinx_board_top_modelsim

# Добавление сигналов в окно Wave (опционально)
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/CLK
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/RST_N
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/KEY2_N
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/GPIO_0_input_pullup
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/GPIO_1_out_zero_value
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/LED
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/dut/formula_enable
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/dut/formula_y
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/dut/formula_done

# Запуск симуляции
run -all

# Остановка симуляции
echo "Simulation completed!"

