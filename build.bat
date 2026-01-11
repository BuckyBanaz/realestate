@echo off
setlocal
chcp 65001 >nul
cls

echo.
echo Yo bro! Welcome to the Build Station 🚉
echo.
echo "Release Mode" locked in! �🚀
echo (Pure Production clean - No Logs)
echo.

echo Bet! Ab bata kya "Build" karna hai? 🧱
echo 1. APK 📱
echo 2. App Bundle 📦
echo 3. Web 🌐
echo.
set /p type="Select kar jaldi (1/2/3): "

set CMD=
if "%type%"=="1" set CMD=apk
if "%type%"=="2" set CMD=appbundle
if "%type%"=="3" set CMD=web

if "%CMD%"=="" (
    echo.
    echo Arey bro, galat option daba diya! 🤦‍♂️
    goto end
)

echo.
echo 🚧 Hold tight! Cooking your build... 🍳
echo Running: flutter build %CMD% --release
echo.

call flutter build %CMD% --release

echo.
if %ERRORLEVEL% EQU 0 (
    echo Sheesh! Build success! Party time! 🎉✨
) else (
    echo Arey yaar! Build fail ho gaya. Logs check kar le. 💀
)

:end
echo.
pause
