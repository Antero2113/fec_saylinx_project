#!/bin/bash
# Скрипт для запуска моделирования тестового окружения
# Использует iverilog для компиляции и vvp для выполнения

set -e

# Цвета для читаемого вывода
GREEN="\033[1;32m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
RESET="\033[0m"

echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}Компиляция и запуск тестового окружения${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo

# Проверка наличия необходимых инструментов
if ! command -v iverilog &> /dev/null; then
    echo -e "${RED}ОШИБКА: iverilog не найден!${RESET}"
    echo -e "${YELLOW}Установите Icarus Verilog:${RESET}"
    echo -e "  Windows: http://iverilog.icarus.com/"
    echo -e "  Linux: sudo apt-get install iverilog"
    echo -e "  Mac: brew install icarus-verilog"
    echo
    echo -e "См. SIMULATION_SETUP.md для подробных инструкций"
    exit 1
fi

if ! command -v vvp &> /dev/null; then
    echo -e "${RED}ОШИБКА: vvp не найден!${RESET}"
    echo -e "${YELLOW}vvp обычно устанавливается вместе с iverilog${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ iverilog найден: $(which iverilog)${RESET}"
echo -e "${GREEN}✓ vvp найден: $(which vvp)${RESET}"
echo

echo
echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}Test 1: Testing formula module${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo

# Компиляция теста для formula
echo -e "${CYAN}Compiling formula test...${RESET}"
iverilog -g2012 -o tb_formula_simple \
    tb_formula_simple.v \
    formula.v \
    cbrt.v \
    sqrt.v \
    mult.v

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Formula test compilation failed!${RESET}"
    exit 1
fi

# Запуск теста formula
echo -e "${CYAN}Running formula tests...${RESET}"
vvp tb_formula_simple

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Formula test execution failed!${RESET}"
    exit 1
fi

# Удаление временного файла
rm -f tb_formula_simple

echo
echo -e "${CYAN}========================================${RESET}"
echo -e "${CYAN}Test 2: Testing fec_saylinx_board_top module${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo

# Компиляция теста для верхнего уровня
echo -e "${CYAN}Compiling top-level test...${RESET}"
iverilog -g2012 -o tb_fec_saylinx_board_top_simple \
    tb_fec_saylinx_board_top_simple.v \
    fec_saylinx_board_top.v \
    formula.v \
    cbrt.v \
    sqrt.v \
    mult.v

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Top-level test compilation failed!${RESET}"
    exit 1
fi

# Запуск теста верхнего уровня
echo -e "${CYAN}Running top-level tests...${RESET}"
vvp tb_fec_saylinx_board_top_simple

if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: Top-level test execution failed!${RESET}"
    exit 1
fi

# Удаление временного файла
rm -f tb_fec_saylinx_board_top_simple

echo
echo -e "${GREEN}========================================${RESET}"
echo -e "${GREEN}All tests completed!${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo

