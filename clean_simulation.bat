@echo off
REM Скрипт для очистки папки simulation перед запуском симуляции
REM Решает проблему "permission denied" при удалении msim_transcript

echo Очистка папки simulation...

REM Закрываем все процессы ModelSim, если они запущены
taskkill /F /IM vsim.exe 2>nul
taskkill /F /IM vish.exe 2>nul
taskkill /F /IM msim.exe 2>nul

REM Ждем немного, чтобы процессы закрылись
timeout /t 2 /nobreak >nul

REM Удаляем содержимое папки simulation/modelsim
if exist "simulation\modelsim" (
    echo Удаление содержимого папки simulation\modelsim...
    rd /s /q "simulation\modelsim" 2>nul
    if errorlevel 1 (
        echo Предупреждение: Не удалось полностью удалить папку. Закройте Quartus и ModelSim и попробуйте снова.
    ) else (
        echo Папка успешно очищена.
    )
) else (
    echo Папка simulation\modelsim не существует.
)

REM Создаем пустую папку заново
mkdir "simulation\modelsim" 2>nul

echo Готово! Теперь можно запускать симуляцию в Quartus.
pause

