@echo off
chcp 65001 >nul
title LocalServer CLI
setlocal enabledelayedexpansion

set ROOT=%~dp0
set ROOT=%ROOT:\=/%
cd /d "%~dp0"

if not exist logs mkdir logs
if not exist conf mkdir conf
if not exist bin/mariadb/data mkdir bin/mariadb/data
if not exist temp mkdir temp
if not exist temp/client_body_temp mkdir temp/client_body_temp
if not exist temp/proxy_temp mkdir temp/proxy_temp
if not exist temp/fastcgi_temp mkdir temp/fastcgi_temp
if not exist temp/uwsgi_temp mkdir temp/uwsgi_temp
if not exist temp/scgi_temp mkdir temp/scgi_temp
if not exist data/filebrowser mkdir data/filebrowser

:MENU
cls
echo.
echo  ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ V1.0
echo  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
echo  ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
echo  ██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
echo  ███████╗ ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
echo  ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
echo ░░░░░░░░░░░░░░░░░░░░ Powered By Fitri HY ░░░░░░░░░░░░░░░░░░░
echo.
echo  1. Start Services
echo  2. Stop Services
echo  3. Status Services
echo  4. Help
echo  5. Exit
echo.

set /p choice=Choose an option [1-5]: 

if "%choice%"=="1" goto START
if "%choice%"=="2" goto STOP
if "%choice%"=="3" goto STATUS
if "%choice%"=="4" goto HELP
if "%choice%"=="5" goto EXIT
goto MENU

:GEN_CONFIG
(
echo [mysqld]
echo basedir=%ROOT%bin/mariadb
echo datadir=%ROOT%bin/mariadb/data
echo port=3307
echo bind-address=127.0.0.1
echo log-error=%ROOT%logs/mysql.log
echo character-set-server=utf8mb4
echo collation-server=utf8mb4_general_ci
echo.
echo [client]
echo port=3307
) > "%ROOT%conf/my.ini"
(
echo worker_processes  1^;
echo.
echo events {
echo     worker_connections  1024^;
echo }
echo.
echo http {
echo     include       mime.types^;
echo     default_type  application/octet-stream^;
echo.
echo     sendfile        on^;
echo     keepalive_timeout  65^;
echo.
echo     client_body_temp_path %ROOT%temp/client_body_temp^;
echo     proxy_temp_path       %ROOT%temp/proxy_temp^;
echo     fastcgi_temp_path     %ROOT%temp/fastcgi_temp^;
echo     uwsgi_temp_path       %ROOT%temp/uwsgi_temp^;
echo     scgi_temp_path        %ROOT%temp/scgi_temp^;
echo.
echo     server {
echo         listen       8080^;
echo         server_name  localhost^;
echo.
echo         root   %ROOT%www^;
echo         index  index.php index.html^;
echo.
echo         location / {
echo             try_files $uri $uri/ =404^;
echo         }
echo.
echo         location ~ \.php$ {
echo             fastcgi_pass   127.0.0.1:9000^;
echo             fastcgi_index  index.php^;
echo             include        fastcgi_params^;
echo             fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name^;
echo         }
echo     }
echo }
) > "%ROOT%conf/nginx.conf"

exit /b

:START
cls
echo.
echo  ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
echo  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
echo  ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
echo  ██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
echo  ███████╗ ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
echo  ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
echo ░░░░░░░░░░░ Starting All Services in Background ░░░░░░░░░░░░
echo.
tasklist | findstr /I "mysqld.exe php-cgi.exe nginx.exe filebrowser.exe" >nul 2>&1
if %ERRORLEVEL%==0 (
    echo [INFO] Stopping existing services...
    taskkill /IM mysqld.exe /F >nul 2>&1
    taskkill /IM php-cgi.exe /F >nul 2>&1
    taskkill /IM nginx.exe /F >nul 2>&1
    taskkill /IM filebrowser.exe /F >nul 2>&1
    timeout /t 1 >nul
)
call :GEN_CONFIG
echo [INFO] Starting MariaDB...
start "" /B "%ROOT%bin/mariadb/bin/mysqld.exe" --defaults-file="%ROOT%conf/my.ini" > "%ROOT%logs/mariadb.log" 2>&1
echo [INFO] Starting PHP-FPM...
start "" /B "%ROOT%bin/php/php-cgi.exe" -b 127.0.0.1:9000 > "%ROOT%logs/php.log" 2>&1
echo [INFO] Starting NGINX...
start "" /B "%ROOT%bin/nginx/nginx.exe" -c "%ROOT%conf/nginx.conf" > "%ROOT%logs/nginx.log" 2>&1
echo [INFO] Starting File Browser...
start "" /B "%ROOT%bin/filebrowser/filebrowser.exe" -a 127.0.0.1 -p 8081 -r "%ROOT%www" -d "%ROOT%data/filebrowser/filebrowser.db" > "%ROOT%logs/filebrowser.log" 2>&1
echo.
echo Press any key to return to menu...
pause >nul
goto MENU

:STOP
cls
echo.
echo  ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
echo  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
echo  ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
echo  ██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
echo  ███████╗ ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
echo  ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
echo ░░░░░░░░░░░░░░░░░░ Stopping All Services ░░░░░░░░░░░░░░░░░░░
echo.
taskkill /IM mysqld.exe /F >nul 2>&1
taskkill /IM php-cgi.exe /F >nul 2>&1
taskkill /IM nginx.exe /F >nul 2>&1
taskkill /IM filebrowser.exe /F >nul 2>&1
echo [SUCCESS] All services stopped!
echo.
echo Press any key to return to menu...
pause >nul
goto MENU

:STATUS
cls
echo.
echo  ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
echo  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
echo  ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
echo  ██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
echo  ███████╗ ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
echo  ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
echo ░░░░░░░░░░░░░░░░░ Checking Service Status ░░░░░░░░░░░░░░░░░░
echo.
tasklist | findstr /I "mysqld.exe php-cgi.exe nginx.exe filebrowser.exe" > temp.txt

for /f %%i in ('type temp.txt ^| find /c /v ""') do set COUNT=%%i

if "%COUNT%"=="0" (
    echo [INFO] No services are running!
) else (
    type temp.txt
)

del temp.txt

echo.
echo Press any key to return to menu...
pause >nul
goto MENU

:HELP
cls
echo.
echo  ██╗      ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
echo  ██║      ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
echo  ██║█████╗███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
echo  ██║╚════╝╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
echo  ███████╗ ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
echo  ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
echo ░░░░░░░░░░░░░░░░░░░░░░░ Usage Help ░░░░░░░░░░░░░░░░░░░░░░░░
echo.
echo File Browser
echo   Username : admin
echo   Password : admin12345678
echo.
echo PHPMyAdmin
echo   Username : root
echo   Password : root
echo.
echo Press any key to return to menu...
pause >nul
goto MENU

:EXIT
echo Exiting...
exit
