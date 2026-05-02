# Инструкция по запуску тестов через EDA Tools Simulation в Quartus Prime

## Описание

Файл `tb_fec_saylinx_board_top_modelsim.v` предназначен для тестирования модуля `fec_saylinx_board_top` через EDA Tools Simulation в Quartus Prime.

## Файлы

- `tb_fec_saylinx_board_top_modelsim.v` - тестовое окружение для ModelSim
- `run_modelsim.tcl` - TCL скрипт для автоматического запуска тестов (опционально)

## Способ 1: Настройка и запуск через EDA Tools Simulation (РЕКОМЕНДУЕТСЯ)

### Шаг 1: Открыть проект в Quartus Prime

1. Откройте Quartus Prime
2. Откройте проект: **File → Open Project...**
3. Выберите файл `fec_saylinx_project.qpf`

### Шаг 2: Настроить EDA Tools Simulation

1. Перейдите: **Assignments → Settings...** (или нажмите `Ctrl+Shift+E`)
2. В левом дереве выберите: **EDA Tool Settings → Simulation**
3. Настройте следующие параметры:

   **Tool name:** `ModelSim-Altera` (или `ModelSim`, в зависимости от установленной версии)
   
   **Format for output netlist:** `Verilog`
   
   **Time scale:** `1 ps`
   
   **Run gate-level simulation automatically after compilation:** (опционально, можно оставить выключенным)
   
   **Compile test bench:** Включите эту опцию
   
   **Test bench name:** `tb_fec_saylinx_board_top_modelsim`
   
   **Test bench and simulation files:**
   - Нажмите кнопку **Test Benches...**
   - В открывшемся окне нажмите **New...**
   - Заполните:
     - **Test bench name:** `tb_fec_saylinx_board_top_modelsim`
     - **Top level module in test bench:** `tb_fec_saylinx_board_top_modelsim`
     - **Design instance name in test bench:** `dut` (имя экземпляра тестируемого модуля)
     - **Simulation period:** `Run until all vector stimuli are used`
   - В разделе **File name** нажмите **Add...**
   - Добавьте файл: `tb_fec_saylinx_board_top_modelsim.v`
   - Нажмите **OK** для сохранения настроек тестового окружения
   - Нажмите **OK** для закрытия окна Test Benches
   
   **NativeLink settings:**
   - **Compile test bench:** Включено
   - **Use script to setup simulation:** (опционально) Можно указать путь к `run_modelsim.tcl`

4. Нажмите **OK** для сохранения всех настроек

### Шаг 3: Компиляция проекта

1. Выполните компиляцию проекта: **Processing → Start Compilation** (или `Ctrl+L`)
2. Дождитесь завершения компиляции
3. Убедитесь, что компиляция прошла успешно (зеленая галочка)

### Шаг 4: Запуск симуляции

1. Перейдите: **Tools → Run Simulation Tool → RTL Simulation**
2. Quartus автоматически запустит ModelSim с правильными настройками
3. ModelSim откроется и автоматически:
   - Создаст библиотеку работы
   - Скомпилирует все необходимые модули
   - Запустит симуляцию тестового окружения

### Шаг 5: Просмотр результатов

1. **Результаты в консоли ModelSim (Transcript):**
   - Откройте окно **Transcript** в ModelSim
   - Там будут выведены результаты тестирования в виде таблицы:
     ```
     Test   | a      | b      | Expected   | Got        | Result
     ------------------------------------------------------------
     1      | 10     | 27     | 3          | 3          | PASS
     ...
     ```

2. **Просмотр сигналов в Wave:**
   - Откройте окно **Wave** в ModelSim
   - Сигналы будут автоматически добавлены (если настроено в скрипте)
   - Или добавьте вручную через меню **Add → Wave → All items in design**

3. **Просмотр структуры проекта:**
   - Откройте окно **Structure** для просмотра иерархии модулей
   - Можно переходить к внутренним сигналам для отладки

## Способ 2: Запуск через ModelSim с TCL скриптом (альтернативный)

Если вы хотите запустить симуляцию напрямую в ModelSim без настроек Quartus:

### Шаг 1: Открыть ModelSim

1. Запустите ModelSim напрямую (не через Quartus)

### Шаг 2: Запустить TCL скрипт

В окне ModelSim выполните:

```tcl
cd <путь_к_проекту>/fec_saylinx_project_example
do run_modelsim.tcl
```

Скрипт автоматически:
- Создаст библиотеку работы
- Скомпилирует все необходимые модули
- Запустит симуляцию
- Добавит сигналы в окно Wave

### Шаг 3: Просмотр результатов

Результаты тестирования будут выведены в окне Transcript (консоль ModelSim).

---

## Способ 3: Ручной запуск в ModelSim (для отладки)

Если нужно выполнить команды вручную для отладки:

### Шаг 1: Создание библиотеки работы

```tcl
vlib work
vmap work work
```

### Шаг 2: Компиляция модулей

```tcl
vlog formula.v
vlog cbrt.v
vlog sqrt.v
vlog mult.v
vlog fec_saylinx_board_top.v
vlog tb_fec_saylinx_board_top_modelsim.v
```

### Шаг 3: Запуск симуляции

```tcl
vsim -t 1ns work.tb_fec_saylinx_board_top_modelsim
```

### Шаг 4: Добавление сигналов в Wave (опционально)

```tcl
add wave -radix hex /tb_fec_saylinx_board_top_modelsim/*
```

### Шаг 5: Запуск симуляции

```tcl
run -all
```

---

## Альтернативный способ: Настройка через .qsf файл

Настройки симуляции можно также добавить напрямую в файл `.qsf` проекта. Добавьте следующие строки в `fec_saylinx_board_top.qsf`:

```tcl
# EDA Tool Settings - Simulation
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera"
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_NAME "tb_fec_saylinx_board_top_modelsim" -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME "tb_fec_saylinx_board_top_modelsim" -section_id eda_simulation
set_global_assignment -name EDA_DESIGN_INSTANCE_NAME "dut" -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_FILE "tb_fec_saylinx_board_top_modelsim.v" -section_id eda_simulation
```

После добавления этих строк в `.qsf` файл, настройки будут автоматически загружены при открытии проекта.

## Что проверяет тест

Тест выполняет 7 тестовых случаев:

1. **a=10, b=27** → ожидается y=3 (√(10+∛27) = √(10+3) = √13 ≈ 3)
2. **a=20, b=64** → ожидается y=4 (√(20+∛64) = √(20+4) = √24 ≈ 4)
3. **a=5, b=8** → ожидается y=2 (√(5+∛8) = √(5+2) = √7 ≈ 2)
4. **a=16, b=8** → ожидается y=4 (√(16+∛8) = √(16+2) = √18 ≈ 4)
5. **a=25, b=27** → ожидается y=5 (√(25+∛27) = √(25+3) = √28 ≈ 5)
6. **a=0, b=0** → ожидается y=0 (√(0+∛0) = √0 = 0)
7. **a=1, b=1** → ожидается y=1 (√(1+∛1) = √(1+1) = √2 ≈ 1)

## Формат вывода

```
========================================
ModelSim Test for fec_saylinx_board_top
Formula: y = sqrt(a + cbrt(b))
========================================

Test   | a      | b      | Expected   | Got        | Result
------------------------------------------------------------
1      | 10     | 27     | 3          | 3          | PASS
2      | 20     | 64     | 4          | 4          | PASS
...
------------------------------------------------------------

Summary: PASSED = 7, FAILED = 0

========================================
ALL TESTS PASSED!
========================================
```

## Особенности теста

1. **Синхронизация с тактовым сигналом** - все операции синхронизированы с `@(posedge CLK)`
2. **Ожидание сигнала done** - тест дожидается завершения вычисления перед проверкой результата
3. **Таймаут** - установлен таймаут 50000 тактов для предотвращения бесконечного ожидания
4. **Допуск погрешности** - допускается погрешность ±1 из-за округления при вычислении корней

## Отладка

Если тесты не проходят:

1. **Проверьте сигналы в окне Wave:**
   - `formula_enable` - должен быть импульс при нажатии KEY2
   - `formula_done` - должен установиться в 1 после завершения
   - `formula_y` - должен содержать результат вычисления

2. **Проверьте GPIO сигналы:**
   - `GPIO_0_input_pullup[15:0]` - должен содержать входные данные (SW)
   - `GPIO_1_out_zero_value[15:0]` - должен содержать результат (инвертированный LEDS)

3. **Проверьте тайминги:**
   - Убедитесь, что кнопка KEY2 нажата достаточно долго для обнаружения фронта
   - Убедитесь, что ожидание завершения достаточно длинное

## Примечания

- Тест использует стандартный синтаксис Verilog для максимальной совместимости
- Все сигналы синхронизированы с тактовым сигналом CLK
- Тест автоматически останавливается после завершения всех проверок (`$stop`)

