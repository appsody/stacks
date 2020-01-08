setlocal
set JAVA_FOUND=0
where java >nul 2>nul
if %ERRORLEVEL% EQU 0 set JAVA_FOUND=1
if defined JAVA_HOME set JAVA_FOUND=1
if "%JAVA_FOUND%"==1 mvnw install -Denforcer.skip=true