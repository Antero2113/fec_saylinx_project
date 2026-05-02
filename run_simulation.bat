@echo off
chcp 65001 >nul 2>&1
REM Скрипт для запуска моделирования тестового окружения
REM Использует iverilog для компиляции и vvp для выполнения

echo ========================================
echo Compilation and test execution
echo ========================================
echo.

REM Проверка наличия необходимых инструментов
where iverilog >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: iverilog not found!
    echo.
    echo Install Icarus Verilog:
    echo   Download from: http://iverilog.icarus.com/
    echo   Or: http://bleyer.org/icarus/
    echo.
    echo After installation, add path to iverilog\bin\ to PATH variable
    echo.
    echo See SIMULATION_SETUP.md for detailed instructions
    pause
    exit /b 1
)

where vvp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: vvp not found!
    echo vvp is usually installed together with iverilog
    pause
    exit /b 1
)

echo [OK] iverilog found
echo [OK] vvp found
echo.

echo.
echo ========================================
echo Test 1: Testing formula module
echo ========================================
echo.

REM Компиляция теста для formula
echo Compiling formula test...
iverilog -g2012 -o tb_formula_simple.exe ^
    tb_formula_simple.v ^
    formula.v ^
    cbrt.v ^
    sqrt.v ^
    mult.v

if %errorlevel% neq 0 (
    echo ERROR: Formula test compilation failed!
    pause
    exit /b 1
)

REM Запуск теста formula
echo Running formula tests...
vvp tb_formula_simple.exe

if %errorlevel% neq 0 (
    echo ERROR: Formula test execution failed!
    pause
    exit /b 1
)

REM Удаление временного файла
if exist tb_formula_simple.exe del tb_formula_simple.exe

echo.
echo ========================================
echo Test 2: Testing fec_saylinx_board_top module
echo ========================================
echo.

REM Компиляция теста для верхнего уровня
echo Compiling top-level test...
iverilog -g2012 -o tb_fec_saylinx_board_top_simple.exe ^
    tb_fec_saylinx_board_top_simple.v ^
    fec_saylinx_board_top.v ^
    formula.v ^
    cbrt.v ^
    sqrt.v ^
    mult.v

if %errorlevel% neq 0 (
    echo ERROR: Top-level test compilation failed!
    pause
    exit /b 1
)

REM Запуск теста верхнего уровня
echo Running top-level tests...
vvp tb_fec_saylinx_board_top_simple.exe

if %errorlevel% neq 0 (
    echo ERROR: Top-level test execution failed!
    pause
    exit /b 1
)

REM Удаление временного файла
if exist tb_fec_saylinx_board_top_simple.exe del tb_fec_saylinx_board_top_simple.exe

echo.
echo ========================================
echo All tests completed!
echo ========================================
echo.
pause

