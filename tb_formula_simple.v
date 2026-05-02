`timescale 1ns / 1ps

// Простое тестовое окружение для модуля formula
// Проверяет правильность вычисления y = √(a + ∛b)

module tb_formula_simple;

    parameter N = 8;
    
    // Тактовый сигнал
    reg clk;
    
    // Сигнал сброса
    reg rst;
    
    // Сигнал запуска
    reg enable;
    
    // Входные операнды
    reg [N-1:0] a;
    reg [N-1:0] b;
    
    // Выходные сигналы
    wire [N-1:0] y;
    wire done;
    
    // Экземпляр тестируемого модуля
    formula #(.N(N)) dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a(a),
        .b(b),
        .y(y),
        .done(done)
    );
    
    // Генератор тактового сигнала (период 10 нс = 100 МГц)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Тестовые случаи: {a, b, expected_result}
    // expected_result = floor(√(a + ∛b))
    integer test_cases [0:9][0:2];
    integer i;
    integer expected;
    integer actual;
    integer passed;
    integer failed;
    
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
        test_cases[3][0] = 0;  test_cases[3][1] = 0;  test_cases[3][2] = 0;  // √(0 + ∛0) = √0 = 0
        test_cases[4][0] = 16; test_cases[4][1] = 8;  test_cases[4][2] = 4;  // √(16 + ∛8) = √(16 + 2) = √18 ≈ 4
        test_cases[5][0] = 1;  test_cases[5][1] = 1;  test_cases[5][2] = 1;  // √(1 + ∛1) = √(1 + 1) = √2 ≈ 1
        test_cases[6][0] = 25; test_cases[6][1] = 27; test_cases[6][2] = 5;  // √(25 + ∛27) = √(25 + 3) = √28 ≈ 5
        test_cases[7][0] = 12; test_cases[7][1] = 125; test_cases[7][2] = 4; // √(12 + ∛125) = √(12 + 5) = √17 ≈ 4
        test_cases[8][0] = 50; test_cases[8][1] = 1;   test_cases[8][2] = 7;  // √(50 + ∛1) = √(50 + 1) = √51 ≈ 7
        test_cases[9][0] = 100; test_cases[9][1] = 8;  test_cases[9][2] = 10; // √(100 + ∛8) = √(100 + 2) = √102 ≈ 10
        
        // Инициализация
        rst = 1'b1;
        enable = 1'b0;
        a = 0;
        b = 0;
        
        // Сброс
        #100;
        rst = 1'b0;
        #50;
        
        $display("========================================");
        $display("Тестирование модуля formula");
        $display("Формула: y = √(a + ∛b)");
        $display("========================================");
        $display("");
        $display("%-6s | %-6s | %-6s | %-10s | %-10s | %-6s", "Тест", "a", "b", "Ожидается", "Получено", "Результат");
        $display("------------------------------------------------------------");
        
        // Запуск тестов
        for (i = 0; i < 10; i = i + 1) begin
            // Установка входных значений
            a = test_cases[i][0];
            b = test_cases[i][1];
            expected = test_cases[i][2];
            
            #20;
            
            // Запуск вычисления
            enable = 1'b1;
            #10;
            enable = 1'b0;
            
            // Ожидание завершения вычисления
            wait(done == 1);
            #10;
            
            // Получение результата
            actual = y;
            
            // Проверка результата (допускаем погрешность ±1 из-за округления)
            if ((actual == expected) || (actual == expected + 1) || (actual == expected - 1)) begin
                $display("%-6d | %-6d | %-6d | %-10d | %-10d | PASS", 
                         i+1, a, b, expected, actual);
                passed = passed + 1;
            end else begin
                $display("%-6d | %-6d | %-6d | %-10d | %-10d | FAIL", 
                         i+1, a, b, expected, actual);
                $display("  Ошибка: ожидалось %d, получено %d", expected, actual);
                failed = failed + 1;
            end
            
            // Ожидание перед следующим тестом
            #100;
        end
        
        $display("------------------------------------------------------------");
        $display("");
        $display("Итого: PASSED = %d, FAILED = %d", passed, failed);
        $display("");
        
        if (failed == 0) begin
            $display("========================================");
            $display("ВСЕ ТЕСТЫ ПРОЙДЕНЫ УСПЕШНО!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("ОБНАРУЖЕНЫ ОШИБКИ В ТЕСТАХ!");
            $display("========================================");
        end
        
        #100;
        $finish;
    end

endmodule

