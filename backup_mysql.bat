@echo off
setlocal enabledelayedexpansion

:: Definition des variables
set CONFIG_FILE=config.ini
set LOG_FILE=backup_log.txt
set BACKUP_DIR=C:\Users\300133566\Documents\backup
set TIMESTAMP=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%H

REM -%time:~3,2%-%time:~6,2%
:: Verification du fichier de configuration
if not exist %CONFIG_FILE% (
    echo [ERREUR %TIMESTAMP%] Le fichier de configuration %CONFIG_FILE% est introuvable. >> %LOG_FILE%
    echo [ERREUR %TIMESTAMP%]Creez ou configurez ce fichier avant de relancer le script.   >> %LOG_FILE%
	echo [ERREUR %TIMESTAMP%] Le fichier de configuration %CONFIG_FILE% est introuvable.
    echo [ERREUR %TIMESTAMP%]Creez ou configurez ce fichier avant de relancer le script.      
)
:: Chargement des variables depuis config.ini
for /f "tokens=1,2 delims==" %%A in (%CONFIG_FILE%) do set %%A=%%B
:: Verification des variables req	uises
for %%V in (HOST USER PASSWORD DB_NAME MYSQL_PATH zipe) do (
    if "!%%V!"=="" (
        echo [ERREUR %TIMESTAMP%] La variable %%V est absente ou vide dans %CONFIG_FILE%. >> %LOG_FILE%
        echo [ERREUR %TIMESTAMP%]Corrigez le fichier %CONFIG_FILE% puis relancez le script. >> %LOG_FILE%
		echo [ERREUR %TIMESTAMP%] La variable %%V est absente ou vide dans %CONFIG_FILE%. 
        echo [ERREUR %TIMESTAMP%]Corrigez le fichier %CONFIG_FILE% puis relancez le script.
		timeout /t 7
	exit 
       
    )
)
:: Creation du repertoire de sauvegarde si necessaire
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
:: Definition des fichiers de sauvegarde
set BACKUP_FILE=%BACKUP_DIR%\backup_%IP_HOST%_%DB_NAME%_%TIMESTAMP%.sql
set ARCHIVE=%ARCHIVE_FILE%\backup_%IP_HOST%_%DB_NAME%_%TIMESTAMP%.zip

"%MYSQL_PATH%\mysqldump.exe" -h %HOST% -u %USER% -p%PASSWORD% --databases %DB_NAME% > "%BACKUP_FILE%"
if %errorlevel% neq 0 (
    
    echo [ERREUR %TIMESTAMP%] echec de connection de connection a la base MySQL. >> %LOG_FILE%
    echo Corrigez le fichier %CONFIG_FILE% puis relancez le script. >> %LOG_FILE%
	echo [ERREUR %TIMESTAMP%] echec de connection de connection a la base MySQL. 
    echo Corrigez le fichier %CONFIG_FILE% puis relancez le script. 
	timeout /t 7

	exit    
)

echo [INFO %TIMESTAMP%] Sauvegarde MySQL reussie : %BACKUP_FILE% >> %LOG_FILE%

:: Compression avec 7-Zip
"%zipe%\7z.exe" a -mx9 -tzip "%ARCHIVE%" "%BACKUP_FILE%" >nul
if %errorlevel% neq 0 (
	
    echo [ERREUR %TIMESTAMP%] echec de la compression. >> %LOG_FILE%
    echo [ERREUR %TIMESTAMP%] Verifiez si 7-Zip est correctement installe et configure. >> %LOG_FILE%
    echo [ERREUR %TIMESTAMP%] Creez ou configurez le fichier %CONFIG_FILE% avant de relancer le script.   >> %LOG_FILE%
	echo [ERREUR %TIMESTAMP%] Verifiez si 7-Zip est correctement installez et configurez. 
    echo [ERREUR %TIMESTAMP%] Creez ou configurez ce fichier %CONFIG_FILE% avant de relancer le script.  
	timeout /t 7 
	exit
   
)
echo [INFO] Compression reussie : %ARCHIVE% >> %LOG_FILE%

::gegion de lenvoi en reseau

if not exist "%NETWORK_BACKUP%" (      ::Verificationde lexistance du repertoire 
    echo Repertoire non trouve de sauvegarde en ligne non trouver
	echo Repertoire non trouve de sauvegarde en ligne non trouver >> %LOG_FILE%
	echo [ERREUR %TIMESTAMP%] echec du transfert.Un fichier zip dans le rpertoire %BACKUP_DIR% a ete creer    >> %LOG_FILE%
	timeout /t 7
	exit	
) else (
    scp "%ARCHIVE%" "%NETWORK_BACKUP%" 
    if %errorlevel% neq 0 (
        echo [ERREUR %TIMESTAMP%] echec du transfert. Un fichier ziper dans le rpertoire %BACKUP_DIR% a ete creer    >> %LOG_FILE%
		exit
    ) else (
        echo [INFO %TIMESTAMP%] Fichier transfere en ligne avec succes. >> %LOG_FILE%
        del "%ARCHIVE%"
		scp "%LOG_FILE%" "%NETWORK_BACKUP%"
    )
)
:: Suppression du fichier SQL apres compression
del "%BACKUP_FILE%"
echo [INFO %TIMESTAMP%] Fichier SQL temporaire supprime. >> %LOG_FILE%
echo [INFO %TIMESTAMP%] Sauvegarde terminee avec succes. >> %LOG_FILE%
echo ................................................... >> %LOG_FILE%
echo [INFO %TIMESTAMP%] Fichier SQL temporaire supprime. 
echo [INFO %TIMESTAMP%] Sauvegarde terminee avec succes. 
echo [INFO %TIMESTAMP%] Sauvegarde terminee avec succes.
timeout /t 7
exit
:: Pause pour afficher le resultat
pause
