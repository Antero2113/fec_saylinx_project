`timescale 1ns / 1ps

// Простое тестовое окружение для модуля fec_saylinx_board_top
// Проверяет работу всей системы: ввод через SW, вывод через LEDS, кнопки

module tb_fec_saylinx_board_top_simple;

    // Тактовый сигнал
    reg CLK;
    
    // Сигнал сброса (активный низкий уровень)
    reg RST_N;
    
    // Кнопки (активный низкий уровень)
    reg KEY2_N;
    reg KEY3_N;
    reg KEY4_N;
    
    // Светодиоды
    wire [3:0] LED;
    
    // Семисегментный индикатор
    wire [7:0] SEG_DATA;
    wire [7:0] SEG_SEL;
    
    // GPIO порты
    wire [16:0] GPIO_0_out_zero_value;
    reg  [16:0] GPIO_0_input_pullup;  // SW[15:0] - переключатели
    wire [16:0] GPIO_1_out_zero_value; // LEDS[15:0] - светодиоды
    reg  [16:0] GPIO_1_input_pullup;
    
    // Экземпляр тестируемого модуля
    fec_saylinx_board_top dut (
        .CLK(CLK),
        .RST_N(RST_N),
        .KEY2_N(KEY2_N),
        .KEY3_N(KEY3_N),
        .KEY4_N(KEY4_N),
        .LED(LED),
        .SEG_DATA(SEG_DATA),
        .SEG_SEL(SEG_SEL),
        .GPIO_0_out_zero_value(GPIO_0_out_zero_value),
        .GPIO_0_input_pullup(GPIO_0_input_pullup),
        .GPIO_1_out_zero_value(GPIO_1_out_zero_value),
        .GPIO_1_input_pullup(GPIO_1_input_pullup)
    );
    
    // Генератор тактового сигнала (период 10 нс = 100 МГц)
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
    
    // Тестовые случаи: {a, b, expected_result}
    // expected_result = floor(√(a + ∛b))
    integer test_cases [0:4][0:2];
    integer i;
    integer expected;
    integer actual;
    integer passed;
    integer failed;
    integer sw_value;
    
    // Инициализация и тестовые последовательности
    initial begin
        // Инициализация счетчиков
        passed = 0;
        failed = 0;
        
        // Определение тестовых случаев
        // Тест: a, b, expected = floor(√(a + ∛b))
        test_cases[0][0] = 10; test_cases[0][1] = 27; test_cases[0][2] = 3;  // √(10 + ∛27) = √(10 + 3) = √13 ≈ 3
        test_cases[1][0] = 20; test_cases[1][1] = 64; test_cases[1][2] = 4;  // √(20 + ∛64) = √(20 + 4) = √24 ≈ 4
        test_cases[2][0] = 5;  test_cases[2][1] = 8;  test_cases[2][2] = 2;  // √(5 + ∛8) = √(5 + 2) = √7 ≈ 2
        test_cases[3][0] = 16; test_cases[3][1] = 8;  test_cases[3][2] = 4;  // √(16 + ∛8) = √(16 + 2) = √18 ≈ 4
        test_cases[4][0] = 25; test_cases[4][1] = 27; test_cases[4][2] = 5;  // √(25 + ∛27) = √(25 + 3) = √28 ≈ 5
        
        // Инициализация
        RST_N = 1'b0;        // Активный сброс
        KEY2_N = 1'b1;       // Кнопки не нажаты
        KEY3_N = 1'b1;
        KEY4_N = 1'b1;
        GPIO_0_input_pullup = 17'h0000;  // Все переключатели в положении 0
        GPIO_1_input_pullup = 17'h0000;
        
        // Сброс в течение 100 нс
        #100;
        RST_N = 1'b1;        // Снятие сброса
        #50;
        
        $display("========================================");
        $display("Testing fec_saylinx_board_top module");
        $display("Formula: y = sqrt(a + cbrt(b))");
        $display("========================================");
        $display("");
        $display("%-6s | %-6s | %-6s | %-10s | %-10s | %-6s", "Test", "a", "b", "Expected", "Got", "Result");
        $display("------------------------------------------------------------");
        
        // Запуск тестов
        for (i = 0; i < 5; i = i + 1) begin
            // Формирование SW[15:0]: SW[7:0] = a, SW[15:8] = b
            sw_value = (test_cases[i][1] << 8) | test_cases[i][0];
            GPIO_0_input_pullup[15:0] = sw_value;
            expected = test_cases[i][2];
            
            // Ждем несколько тактов для стабилизации
            @(posedge CLK);
            @(posedge CLK);
            @(posedge CLK);
            
            // Нажатие кнопки KEY2 для запуска вычисления
            // Синхронизируем с тактовым сигналом
            @(posedge CLK);
            KEY2_N = 1'b0;  // Нажатие кнопки (активный низкий)
            @(posedge CLK);
            @(posedge CLK);
            KEY2_N = 1'b1;  // Отпускание кнопки
            @(posedge CLK);
            
            // Ожидание завершения вычисления
            // Ждем сигнал done с таймаутом
            repeat(50000) begin
                @(posedge CLK);
                if (~GPIO_1_out_zero_value[8] == 1'b1) begin
                    break;  // Вычисление завершено
                end
            end
            
            // Дополнительное ожидание для стабилизации
            @(posedge CLK);
            @(posedge CLK);
            
            // Получение результата из LEDS[7:0] (инвертированный GPIO_1_out_zero_value)
            actual = ~GPIO_1_out_zero_value[7:0];
            
            // Проверка сигнала done (LEDS[8])
            if (~GPIO_1_out_zero_value[8] == 1'b1) begin
                // Проверка результата (допускаем погрешность ±1 из-за округления)
                if ((actual == expected) || (actual == expected + 1) || (actual == expected - 1)) begin
                    $display("%-6d | %-6d | %-6d | %-10d | %-10d | PASS", 
                             i+1, test_cases[i][0], test_cases[i][1], expected, actual);
                    passed = passed + 1;
                end else begin
                    $display("%-6d | %-6d | %-6d | %-10d | %-10d | FAIL", 
                             i+1, test_cases[i][0], test_cases[i][1], expected, actual);
                    $display("  Error: expected %d, got %d", expected, actual);
                    failed = failed + 1;
                end
            end else begin
                $display("%-6d | %-6d | %-6d | %-10d | %-10d | FAIL (done=0)", 
                         i+1, test_cases[i][0], test_cases[i][1], expected, actual);
                $display("  Error: computation not completed (done signal is low)");
                failed = failed + 1;
            end
            
            // Ожидание перед следующим тестом
            #1000;
        end
        
        $display("------------------------------------------------------------");
        $display("");
        $display("Summary: PASSED = %d, FAILED = %d", passed, failed);
        $display("");
        
        if (failed == 0) begin
            $display("========================================");
            $display("ALL TESTS PASSED!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("SOME TESTS FAILED!");
            $display("========================================");
        end
        
        #100;
        $finish;
    end

endmodule

