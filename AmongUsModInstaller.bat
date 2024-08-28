@echo off
setlocal enabledelayedexpansion

REM Foldery i pliki do zainstalowania
set "FOLDERS_TO_COPY=BepInEx dotnet"
set "FILES_TO_COPY=steam_appid.txt winhttp.dll changelog.txt doorstop_config.ini .doorstop_version"
set ITEMCOUNT=0
for %%A in (%FOLDERS_TO_COPY%) do set /a ITEMCOUNT+=1
for %%A in (%FILES_TO_COPY%) do set /a ITEMCOUNT+=1
set PROGRESS=0

echo Szukanie lokalizacji pulpitow...

set "DESKTOP_COUNT=0"
for /f "tokens=*" %%A in ('dir /b /ad "C:\Users" 2^>nul') do (
    if exist "C:\Users\%%A\Desktop" (
        set /a DESKTOP_COUNT+=1
        set "DESKTOP_!DESKTOP_COUNT!=C:\Users\%%A\Desktop"
        echo !DESKTOP_COUNT!. C:\Users\%%A\Desktop
    )
    if exist "C:\Users\%%A\OneDrive\Desktop" (
        set /a DESKTOP_COUNT+=1
        set "DESKTOP_!DESKTOP_COUNT!=C:\Users\%%A\OneDrive\Desktop"
        echo !DESKTOP_COUNT!. C:\Users\%%A\OneDrive\Desktop
    )
    if exist "C:\Users\%%A\Pulpit" (
        set /a DESKTOP_COUNT+=1
        set "DESKTOP_!DESKTOP_COUNT!=C:\Users\%%A\Pulpit"
        echo !DESKTOP_COUNT!. C:\Users\%%A\Pulpit
    )
    if exist "C:\Users\%%A\OneDrive\Pulpit" (
        set /a DESKTOP_COUNT+=1
        set "DESKTOP_!DESKTOP_COUNT!=C:\Users\%%A\OneDrive\Pulpit"
        echo !DESKTOP_COUNT!. C:\Users\%%A\OneDrive\Pulpit
    )
)

:CHOOSE_DESKTOP
set /p DESKTOP_CHOICE="Choose the desktop location (1-%DESKTOP_COUNT%): "
if %DESKTOP_CHOICE% leq 0 goto CHOOSE_DESKTOP
if %DESKTOP_CHOICE% gtr %DESKTOP_COUNT% goto CHOOSE_DESKTOP

set "CHOSEN_DESKTOP=!DESKTOP_%DESKTOP_CHOICE%!"
echo Wybrano pulpit: %CHOSEN_DESKTOP%

:MENU
cls
echo Instalator/Deinstalator Mod'ow do Among Us !!!UWAGA!!! TYLKO WERSJA V2024.8.13s (build num. 4431) ^|^| Autorstwa Mikolaj Blangiewicz
echo 1. Zainstaluj Moda
echo 2. Odinstaluj Moda
echo 3. Wyjdz
set /p CHOICE="Wprowadz swoj wybor (1-3): "
if "%CHOICE%"=="1" goto INSTALL
if "%CHOICE%"=="2" goto UNINSTALL
if "%CHOICE%"=="3" exit
goto MENU

:INSTALL
call :FIND_STEAM_FOLDER
if not defined STEAM_FOLDER goto MANUAL_PATH
set "AMONG_US_FOLDER=%STEAM_FOLDER%\steamapps\common\Among Us"
if not exist "%AMONG_US_FOLDER%" goto MANUAL_PATH
goto COPY_FOLDER

:FIND_STEAM_FOLDER
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\Program Files (x86)\Steam" (
        set "STEAM_FOLDER=%%D:\Program Files (x86)\Steam"
        exit /b
    )
)
exit /b

:MANUAL_PATH
echo Nie znaleziono automatycznie folderu Among Us.
set /p AMONG_US_FOLDER="Wprowadz sciezke do folderu Among Us (np. C:\Program Files (x86)\Steam\steamapps\common\Among Us): "
if not exist "%AMONG_US_FOLDER%" (
    echo Nie znaleziono folderu. Sprobuj ponownie.
    goto MANUAL_PATH
)

:COPY_FOLDER
echo Kopiowanie folderu Among Us...
set "MOD_FOLDER=%CHOSEN_DESKTOP%\Town of Us"
xcopy /E /I /Y "%AMONG_US_FOLDER%" "%MOD_FOLDER%" >nul 2>&1
call :smoothProgressBar 33 "Kopiowanie folderu Among Us"

echo Kopiowanie plikow i folderow moda...
for %%A in (%FOLDERS_TO_COPY%) do (
    if exist "%~dp0%%A" (
        xcopy /E /I /Y "%~dp0%%A" "%MOD_FOLDER%\%%A" >nul 2>&1
    )
)
for %%A in (%FILES_TO_COPY%) do (
    if exist "%~dp0%%A" (
        copy /Y "%~dp0%%A" "%MOD_FOLDER%\" >nul 2>&1
    )
)
call :smoothProgressBar 66 "Kopiowanie plikow i folderow moda"

echo Tworzenie skrotu Town of Us...
echo Set oWS = WScript.CreateObject("WScript.Shell") > CreateShortcut.vbs
echo sLinkFile = "%CHOSEN_DESKTOP%\Town of Us.lnk" >> CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> CreateShortcut.vbs
echo oLink.TargetPath = "%MOD_FOLDER%\Among Us.exe" >> CreateShortcut.vbs
echo oLink.WorkingDirectory = "%MOD_FOLDER%" >> CreateShortcut.vbs
echo oLink.Save >> CreateShortcut.vbs
cscript //nologo CreateShortcut.vbs >nul 2>&1
del CreateShortcut.vbs >nul 2>&1
call :smoothProgressBar 100 "Tworzenie skrotu Town of Us"

echo Mod Town of Us zostal pomyslnie zainstalowany!
echo Uruchom gre uzywajac skrotu "Town of Us" na pulpicie.
echo.
echo Lokalizacja folderu moda: %MOD_FOLDER%
echo Lokalizacja skrotu: %CHOSEN_DESKTOP%\Town of Us.lnk
pause
goto MENU

:UNINSTALL
echo Usuwanie moda Town of Us...
set "MOD_FOLDER=%CHOSEN_DESKTOP%\Town of Us"
if exist "%MOD_FOLDER%" (
    rmdir /S /Q "%MOD_FOLDER%" >nul 2>&1
    call :smoothProgressBar 50 "Usuwanie folderu moda"
)
if exist "%CHOSEN_DESKTOP%\Town of Us.lnk" (
    del "%CHOSEN_DESKTOP%\Town of Us.lnk" >nul 2>&1
    call :smoothProgressBar 100 "Usuwanie skrotu"
)
echo Mod Town of Us zostal pomyslnie usuniety!
pause
goto MENU

:smoothProgressBar targetPercent text
setlocal enabledelayedexpansion
set /a start=%progress%
set /a end=%~1
set "text=%~2"
set /a steps=!end! - !start!
set /a sleepTime=300 / !steps!
for /l %%i in (!start! 1 !end!) do (
    call :drawProgressBar %%i "!text!"
    ping localhost -n 1 -w 100 > nul
)
set /a progress=%end%
endlocal & set "progress=%progress%"
exit /b

:drawProgressBar value [text]
    if "%~1"=="" goto :eof
    if not defined pb.barArea call :initProgressBar
    setlocal enableextensions enabledelayedexpansion
    set /a "pb.value=%~1 %% 101", "pb.filled=pb.value*pb.barArea/100", "pb.dotted=pb.barArea-pb.filled", "pb.pct=1000+pb.value"
    set "pb.pct=%pb.pct:~-3%"
    if "%~2"=="" ( set "pb.text=" ) else ( 
        set "pb.text=%~2%pb.back%" 
        set "pb.text=!pb.text:~0,%pb.textArea%!"
    )
    <nul set /p "pb.prompt=[!pb.fill:~0,%pb.filled%!!pb.dots:~0,%pb.dotted%!][ %pb.pct% ] %pb.text%!pb.cr!"
    endlocal
    exit /b

:initProgressBar [fillChar] [dotChar]
    if defined pb.cr call :finalizeProgressBar
    for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
    if "%~1"=="" ( set "pb.fillChar=#" ) else ( set "pb.fillChar=%~1" )
    if "%~2"=="" ( set "pb.dotChar=." ) else ( set "pb.dotChar=%~2" )
    set "pb.console.columns="
    for /f "tokens=2 skip=4" %%f in ('mode con') do if not defined pb.console.columns set "pb.console.columns=%%f"
    set /a "pb.barArea=pb.console.columns/2-2", "pb.textArea=pb.barArea-9"
    set "pb.fill="
    setlocal enableextensions enabledelayedexpansion
    for /l %%p in (1 1 %pb.barArea%) do set "pb.fill=!pb.fill!%pb.fillChar%"
    set "pb.fill=!pb.fill:~0,%pb.barArea%!"
    set "pb.dots=!pb.fill:%pb.fillChar%=%pb.dotChar%!"
    set "pb.back=!pb.fill:~0,%pb.textArea%!
    set "pb.back=!pb.back:%pb.fillChar%= !"
    endlocal & set "pb.fill=%pb.fill%" & set "pb.dots=%pb.dots%" & set "pb.back=%pb.back%"
    goto :eof

:finalizeProgressBar [erase]
    if defined pb.cr (
        if not "%~1"=="" (
            setlocal enabledelayedexpansion
            set "pb.back="
            for /l %%p in (1 1 %pb.console.columns%) do set "pb.back=!pb.back! "
            <nul set /p "pb.prompt=!pb.cr!!pb.back:~1!!pb.cr!"
            endlocal
        )
    )
    for /f "tokens=1 delims==" %%v in ('set pb.') do set "%%v="
    goto :eof