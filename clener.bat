@echo off
title CleanMaster Pro v1.3
color 0A

echo =====================================
echo        CLEANMASTER PRO v1.3
echo =====================================
echo.

:: Cek Hak Akses Administrator Bawaan (Universal)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Harus dijalankan sebagai Administrator!
    echo [!] Silakan klik kanan file ini lalu pilih "Run as administrator".
    pause
    exit
)

echo [1/9] Membersihkan Temporary Files...
rmdir /s /q "%temp%" >nul 2>&1
mkdir "%temp%"
rmdir /s /q "C:\Windows\Temp" >nul 2>&1
mkdir "C:\Windows\Temp"

echo [2/9] Membersihkan Prefetch...
del /s /f /q "C:\Windows\Prefetch\*" >nul 2>&1

echo [3/9] Pembersihan Log Sistem Usang (Lama > 7 Hari)...
:: Menyeleksi dan menghapus file .log yang sudah berumur lebih dari 7 hari agar aman
PowerShell -Command "Get-ChildItem 'C:\Windows' -Filter *.log -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force" >nul 2>&1

echo [4/9] Membersihkan Windows Error Reporting & Delivery Optimization...
:: Menghapus tumpukan laporan eror sistem dan cache distribusi update
rmdir /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportArchive" >nul 2>&1
rmdir /s /q "C:\ProgramData\Microsoft\Windows\WER\ReportQueue" >nul 2>&1
rmdir /s /q "C:\Windows\SoftwareDistribution\DeliveryOptimization" >nul 2>&1

echo [5/9] Membersihkan Windows Update Cache...
net stop wuauserv >nul 2>&1
rmdir /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
mkdir "C:\Windows\SoftwareDistribution\Download"
net start wuauserv >nul 2>&1

echo [6/9] Membersihkan Cache DNS...
ipconfig /flushdns >nul

echo [7/9] Membersihkan Recycle Bin...
PowerShell -Command "Clear-RecycleBin -Force" >nul 2>&1

echo [8/9] Membersihkan Cache Browser (Chrome & Edge)...
taskkill /f /im chrome.exe >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
timeout /t 1 >nul
rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LocalAppData%\Google\Chrome\User Data\Default\Code Cache" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Cache" >nul 2>&1
rmdir /s /q "%LocalAppData%\Microsoft\Edge\User Data\Default\Code Cache" >nul 2>&1

echo [9/9] Menampilkan Informasi RAM Aktif...
PowerShell -Command "$mem = Get-CimInstance Win32_OperatingSystem; [math]::round($mem.TotalVisibleMemorySize / 1024, 2); [math]::round($mem.FreePhysicalMemory / 1024, 2)" > "%temp%\ram.txt"
(
set /p totalRAM=
set /p freeRAM=
) < "%temp%\ram.txt"
del "%temp%\ram.txt" >nul 2>&1
echo Total Kapasitas RAM : %totalRAM% MB
echo Sisa RAM Tersedia   : %freeRAM% MB

echo.
:: Opsi Pengelolaan Startup
set /p "startAns=Apakah ingin memeriksa/mematikan aplikasi Startup lewat Task Manager? (Y/N): "
if /i "%startAns%"=="Y" (
    echo Membuka Task Manager di tab Startup...
    start taskmgr /0 /startup
    echo [!] Silakan matikan program yang berstatus "Enabled" namun tidak penting secara manual.
    pause
)

echo.
:: Pilihan interaktif untuk me-restart Windows Explorer
set /p "ans=Apakah ingin me-restart Windows Explorer? (Y/N): "
if /i "%ans%"=="Y" (
    echo Memuat ulang Explorer...
    taskkill /f /im explorer.exe >nul 2>&1
    timeout /t 2 >nul
    start explorer.exe
)

echo.
echo =====================================
echo        SELESAI DIBERSIHKAN!
echo =====================================
echo.

pause
exit
