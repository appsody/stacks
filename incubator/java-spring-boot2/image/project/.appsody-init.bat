if not exist %SystemDrive%%HOMEPATH%\.m2\repository\ (
  mkdir %SystemDrive%%HOMEPATH%\.m2\repository
)
setlocal
set JAVA_FOUND=0
where java >nul 2>nul
if %ERRORLEVEL% EQU 0 set JAVA_FOUND=1
if defined JAVA_HOME set JAVA_FOUND=1
if "%JAVA_FOUND%"==1 mvnw install -q -f ./appsody-boot2-pom.xml

