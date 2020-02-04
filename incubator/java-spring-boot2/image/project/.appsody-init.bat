if not exist %SystemDrive%%HOMEPATH%\.m2\repository\ (
  mkdir %SystemDrive%%HOMEPATH%\.m2\repository
)

copy mvnw*.* .. >nul
mkdir ..\.mvn
robocopy .mvn ..\.mvn /e /njh /njs /ndl /nc /ns >nul

where java >nul 2>nul
if %ERRORLEVEL% EQU 0 (
  if defined JAVA_HOME (
    ..\mvnw install -q -f ./{{.stack.parentpomfilename}}
  )
)