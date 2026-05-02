# Руководство по симуляции на плате Saylinx в Quartus Prime

## Общая информация

- **Плата:** Saylinx
- **ПЛИС:** ALTERA Cyclone IV EP4CE6F17C8
- **САПР:** Quartus Prime 21.1.1 Lite Edition
- **Проект:** Вычисление формулы y = sqrt(a + cbrt(b))

Данное руководство описывает процесс настройки и запуска проекта на физической плате Saylinx в Quartus Prime, аналогично симуляции в ModelSim.

---

## Предварительные требования

### Windows
- Quartus Prime 21.1.1 Lite Edition или новее
- USB-Blaster драйвер (устанавливается автоматически с Quartus)
- Кабель USB для подключения платы
- USB-Blaster для подключения через JTAG

### Linux
- Quartus Prime 21.1.1 Lite Edition или новее
- Настроенные права доступа к USB-устройствам (см. раздел "Настройка Linux")
- Кабель USB для подключения платы
- USB-Blaster для подключения через JTAG

---

## Настройка Linux (только для Linux)

### 1. Настройка прав доступа к USB-Blaster

Создайте файл правил udev для доступа к USB-Blaster:

```bash
sudo nano /etc/udev/rules.d/51-usbblaster.rules
```

Добавьте следующие строки:

```
# USB-Blaster
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6001", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6002", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="09fb", ATTR{idProduct}=="6003", MODE="0666"
```

Примените правила:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 2. Настройка переменных окружения

Добавьте в `~/.bashrc` или `~/.zshrc`:

```bash
export QUARTUS_ROOTDIR=/path/to/quartus
export PATH=$QUARTUS_ROOTDIR/bin:$PATH
```

---

## Настройка проекта в Quartus Prime

### 1. Открытие проекта

**Windows:**
- Запустите Quartus Prime
- File → Open Project...
- Выберите файл `fec_saylinx_board_top.qpf`

**Linux:**
```bash
cd /path/to/project
quartus fec_saylinx_board_top.qpf
```

### 2. Проверка настроек устройства

1. Assignments → Device...
2. Убедитесь, что выбрано:
   - **Family:** Cyclone IV E
   - **Device:** EP4CE6F17C8
   - **Package:** FBGA256
   - **Speed grade:** 8

### 3. Проверка настроек пинов (Pin Assignments)

Настройки пинов уже должны быть в файле `fec_saylinx_board_top.qsf`. Проверить можно через:

1. Assignments → Pin Planner
2. Или Assignments → Assignment Editor

Основные назначения пинов:

| Сигнал | Пин ПЛИС | Направление | Стандарт I/O |
|--------|----------|-------------|--------------|
| CLK | E1 | Input | 3.3-V LVTTL |
| RST_N | N13 | Input | 3.3-V LVTTL |
| KEY2_N | M15 | Input | 3.3-V LVTTL |
| KEY3_N | M16 | Input | 3.3-V LVTTL |
| KEY4_N | E16 | Input | 3.3-V LVTTL |
| LED[0] | E10 | Output | 3.3-V LVTTL |
| LED[1] | F9 | Output | 3.3-V LVTTL |
| LED[2] | C9 | Output | 3.3-V LVTTL |
| LED[3] | D9 | Output | 3.3-V LVTTL |

Полный список пинов см. в `fec_saylinx_board_top.qsf` или в разделе GPIO файла `README.md`.

### 4. Настройка подтяжек для входных GPIO

Для GPIO_0_input_pullup и GPIO_1_input_pullup необходимо установить подтяжку к высокому уровню:

1. Assignments → Device → Device and Pin Options...
2. Вкладка "Pin Options"
3. Для каждого пина из GPIO_0_input_pullup и GPIO_1_input_pullup:
   - Выберите пин
   - Установите "Weak Pull-Up Resistor" = On

Или добавьте в `.qsf` файл (если еще не добавлено):

```tcl
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to GPIO_0_input_pullup[*]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to GPIO_1_input_pullup[*]
```

### 5. Настройка тактового сигнала

1. Assignments → Settings → Timing Analyzer
2. Убедитесь, что включен Timing Analyzer
3. Assignments → Settings → TimeQuest Timing Analyzer
   - Включите "TimeQuest Timing Analyzer"

Для задания частоты тактового сигнала:

1. Assignments → TimeQuest Timing Analyzer → Create Clock...
2. Имя: `CLK`
3. Период: `10.000 ns` (100 МГц) или другой, в зависимости от генератора на плате
4. Источник: `CLK`

---

## Компиляция проекта

### Windows/Linux (GUI)

1. Processing → Start Compilation
   - Или нажмите `Ctrl+L`
2. Дождитесь завершения компиляции
3. Проверьте отчет компиляции на наличие ошибок и предупреждений

### Linux (командная строка)

```bash
quartus_sh --flow compile fec_saylinx_board_top
```

### Проверка результатов компиляции

После успешной компиляции проверьте:

1. **Fitter Report:**
   - Processing → Compilation Report → Fitter → Resource Usage
   - Убедитесь, что ресурсы ПЛИС используются разумно

2. **Timing Analyzer:**
   - Processing → Compilation Report → TimeQuest Timing Analyzer
   - Проверьте, что нет нарушений временных ограничений

3. **Assembler:**
   - Processing → Compilation Report → Assembler
   - Убедитесь, что файл `.sof` создан успешно

---

## Подключение платы

### Последовательность подключения (ВАЖНО!)

1. **Убедитесь, что переключатель питания в положении OFF**
2. Подключите плату к ПК через mini-USB кабель
3. Подключите USB-Blaster к разъему JTAG на плате
4. Переключите переключатель питания в положение ON
5. Подключите USB-Blaster к ПК

**ВАЖНО:** Не перемещайте включенную плату в руках!

---

## Программирование ПЛИС

### Windows/Linux (GUI)

1. Tools → Programmer
2. Если USB-Blaster не обнаружен:
   - Hardware Setup → Add Hardware...
   - Выберите USB-Blaster
   - Нажмите OK
3. В окне Programmer:
   - Убедитесь, что выбран правильный файл `.sof` (должен быть выбран автоматически)
   - Установите флажок "Program/Configure"
   - Нажмите "Start"

### Linux (командная строка)

```bash
quartus_pgm -c USB-Blaster -m jtag -o "p;output_files/fec_saylinx_board_top.sof"
```

### Проверка подключения

Если USB-Blaster не обнаружен:

**Windows:**
- Проверьте диспетчер устройств
- Убедитесь, что установлен драйвер USB-Blaster
- Попробуйте переподключить USB-Blaster

**Linux:**
- Проверьте права доступа: `lsusb` должен показывать устройство с VID=09fb
- Проверьте правила udev (см. раздел "Настройка Linux")
- Попробуйте запустить Quartus с правами суперпользователя (не рекомендуется)

---

## Тестирование на плате

### Настройка входных данных через GPIO

Входные данные задаются через переключатели на GPIO_0:

- **SW[7:0]** = операнд `a` (младший байт)
- **SW[15:8]** = операнд `b` (старший байт)

Для установки значения:
- **Высокий уровень (1):** оставьте пин без перемычки (подтяжка к 1)
- **Низкий уровень (0):** установите перемычку между соответствующими пинами

Пример для установки `a=10` (0x0A = 00001010):
- SW[0] = 0 (перемычка)
- SW[1] = 1 (без перемычки)
- SW[2] = 0 (перемычка)
- SW[3] = 1 (без перемычки)
- SW[7:4] = 0 (перемычки)

### Запуск вычисления

1. Установите входные данные через переключатели GPIO_0
2. Нажмите кнопку **KEY2** для запуска вычисления
3. Наблюдайте за результатом:
   - **LED[2:0]** - младшие 3 бита результата `y`
   - **LED[3]** - сигнал `done`
   - **GPIO_1_out_zero_value[7:0]** - полный результат `y[7:0]` (через перемычки)

### Чтение результата

Результат выводится на GPIO_1_out_zero_value[7:0]:
- **Низкий уровень (0):** светодиод включен (перемычка установлена)
- **Высокий уровень (1):** светодиод выключен (перемычка не установлена)

Для чтения результата:
- Установите перемычки между пинами GPIO_1_out_zero_value и соответствующими пинами для чтения
- Или используйте светодиоды на плате (если подключены)

---

## Тестовые случаи

Аналогично тестам в ModelSim, можно проверить следующие случаи:

| Тест | a | b | Ожидаемый результат | Описание |
|------|---|---|---------------------|----------|
| 1 | 10 | 27 | 3 | sqrt(10 + cbrt(27)) = sqrt(10 + 3) = sqrt(13) ≈ 3 |
| 2 | 20 | 64 | 4 | sqrt(20 + cbrt(64)) = sqrt(20 + 4) = sqrt(24) ≈ 4 |
| 3 | 5 | 8 | 2 | sqrt(5 + cbrt(8)) = sqrt(5 + 2) = sqrt(7) ≈ 2 |
| 4 | 16 | 8 | 4 | sqrt(16 + cbrt(8)) = sqrt(16 + 2) = sqrt(18) ≈ 4 |
| 5 | 25 | 27 | 5 | sqrt(25 + cbrt(27)) = sqrt(25 + 3) = sqrt(28) ≈ 5 |
| 6 | 0 | 0 | 0 | sqrt(0 + cbrt(0)) = sqrt(0) = 0 |
| 7 | 1 | 1 | 1 | sqrt(1 + cbrt(1)) = sqrt(1 + 1) = sqrt(2) ≈ 1 |

### Процедура тестирования

1. Установите входные данные через переключатели GPIO_0
2. Нажмите KEY2 для запуска
3. Дождитесь установки сигнала `done` (LED[3] загорится)
4. Считайте результат с GPIO_1_out_zero_value[7:0]
5. Сравните с ожидаемым результатом

---

## Отладка

### Проблема: USB-Blaster не обнаружен

**Windows:**
- Проверьте диспетчер устройств
- Переустановите драйвер USB-Blaster
- Попробуйте другой USB-порт

**Linux:**
- Проверьте правила udev: `cat /etc/udev/rules.d/51-usbblaster.rules`
- Проверьте подключение: `lsusb | grep 09fb`
- Попробуйте запустить с sudo (временно для диагностики)

### Проблема: Проект не компилируется

- Проверьте синтаксис Verilog файлов
- Убедитесь, что все файлы добавлены в проект
- Проверьте назначения пинов в Pin Planner

### Проблема: ПЛИС не программируется

- Проверьте подключение USB-Blaster
- Убедитесь, что плата включена
- Проверьте, что выбран правильный файл `.sof`
- Попробуйте переподключить USB-Blaster

### Проблема: Неправильные результаты

- Проверьте правильность установки входных данных через GPIO
- Убедитесь, что перемычки установлены корректно
- Проверьте, что сигнал `done` устанавливается после вычисления
- Используйте Signal Tap Logic Analyzer для отладки (см. ниже)

---

## Использование Signal Tap Logic Analyzer для отладки

Signal Tap позволяет наблюдать внутренние сигналы ПЛИС в реальном времени.

### Настройка Signal Tap

1. Tools → Signal Tap Logic Analyzer
2. File → New → Signal Tap Logic File
3. Настройте параметры:
   - **Clock:** CLK
   - **Sample depth:** 1024 (или больше, в зависимости от доступной памяти)
4. Добавьте сигналы для наблюдения:
   - `formula_inst.state`
   - `formula_inst.a_reg`
   - `formula_inst.b_reg`
   - `formula_y`
   - `formula_done`
   - `formula_inst.enable_sbrt`
   - `formula_inst.done_sbrt`
   - `formula_inst.enable_sqrt`
   - `formula_inst.done_sqrt`
5. File → Save As... → `fec_saylinx_board_top.stp`
6. Добавьте файл в проект: Assignments → Settings → Signal Tap Logic Analyzer

### Компиляция с Signal Tap

1. Processing → Start Compilation
2. После компиляции откройте Signal Tap
3. Подключите USB-Blaster
4. Нажмите "Program Device"
5. Запустите захват сигналов

---

## Различия Windows/Linux

### Пути к файлам

**Windows:**
- Путь к Quartus: `C:\intelFPGA_lite\21.1\quartus\`
- Путь к проекту: `C:\Users\...\fec_saylinx_project_example\`

**Linux:**
- Путь к Quartus: `/opt/intelFPGA_lite/21.1/quartus/`
- Путь к проекту: `/home/.../fec_saylinx_project_example/`

### Запуск из командной строки

**Windows:**
```cmd
cd C:\path\to\project
quartus fec_saylinx_board_top.qpf
```

**Linux:**
```bash
cd /path/to/project
quartus fec_saylinx_board_top.qpf
```

### Права доступа

**Windows:**
- Обычно не требуется дополнительных настроек
- Драйвер USB-Blaster устанавливается автоматически

**Linux:**
- Требуется настройка правил udev (см. раздел "Настройка Linux")
- Может потребоваться добавление пользователя в группу `plugdev`

---

## Дополнительные ресурсы

- [Документация Quartus Prime](https://www.intel.com/content/www/us/en/programmable/documentation/)
- [Saylinx схема подключения](docs/Saylinx_scheme.pdf)
- [Документация ПЛИС EP4CE6F17C8](docs/ALTERA_EP4CE6F17C8_Datasheet.PDF)
- [README проекта](README.md)

---

## Заключение

Данное руководство описывает процесс настройки и запуска проекта на плате Saylinx. Процесс аналогичен симуляции в ModelSim, но выполняется на физическом оборудовании. Основные отличия:

1. Вместо симуляции используется реальная ПЛИС
2. Входные данные задаются через переключатели GPIO
3. Результаты считываются через GPIO или светодиоды
4. Требуется физическое подключение платы через USB-Blaster

При возникновении проблем обращайтесь к разделу "Отладка" или документации Quartus Prime.

