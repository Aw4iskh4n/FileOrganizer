@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Define default file types based on provided categories
SET Docs=doc,docx,odt,pdf,rtf,tex,txt,wpd
SET Sheets=csv,ods,xls,xlsx
SET Web=asp,aspx,css,htm,html,jsp,php,xml
SET Img=bmp,gif,jpeg,jpg,png,svg,avif,exif,heic,tif,tiff
SET Audio=aac,mp3,wav,flac,m4a
SET Video=mp4,mov,webm
SET Draw=ai,cdr,svg
SET Layout=indd,pub
SET Code=c,cpp,cs,java,py
SET Zip=7z,bz2,gz,rar,tar,zip
SET Media=bin,cue,iso,mdf,nrg
SET DB=accdb,csv,db,json,xml
SET Mail=eml,msg,pst,vcf
SET Exe=exe,app,apk,deb,msi
SET Font=eot,otf,ttf,woff,woff2

:: Get directory to organize
SET /P "DIRECTORY=Enter directory to organize (Default: %USERPROFILE%\Downloads): "
IF "%DIRECTORY%"=="" SET "DIRECTORY=%USERPROFILE%\Downloads"

:: Navigate to the directory
CD /D "%DIRECTORY%"

:mainMenu
echo.
echo Please choose an option:
echo 1. Organize all known file types
echo 2. Organize specific file types
echo 3. Add and organize custom file types
echo 4. Undo last organization
echo 5. Exit
SET /P "CHOICE=Enter your choice (1/2/3/4/5): "

IF "%CHOICE%"=="1" GOTO organizeAll
IF "%CHOICE%"=="2" GOTO specificMenu
IF "%CHOICE%"=="3" GOTO addCustom
IF "%CHOICE%"=="4" GOTO undoOrganize
IF "%CHOICE%"=="5" GOTO end

:specificMenu
echo.
echo Please select a category of files to organize:
echo 1. Document files (Docs)
echo 2. Spreadsheet files (Sheets)
echo 3. Web-related files (Web)
echo 4. Image files (Img)
echo 5. Audio files (Audio)
echo 6. Video files (Video)
echo 7. Draw Program files (Draw)
echo 8. Page Layout files (Layout)
echo 9. Programming files (Code)
echo 10. Compressed files (Zip)
echo 11. Disc and Media files (Media)
echo 12. Data and Database files (DB)
echo 13. E-mail files (Mail)
echo 14. Executable files (Exe)
echo 15. Font files (Font)
echo 16. Return to main menu
SET /P "SPECIFICCHOICE=Enter your choice (1-16): "

FOR %%i IN (Docs Sheets Web Img Audio Video Draw Layout Code Zip Media DB Mail Exe Font) DO (
    CALL SET "selectedExtensions=%%%%i%%"
    FOR %%e IN (!selectedExtensions!) DO (
        IF EXIST *."%%e" (
            SET "folderName=%%i"
            MD "!folderName!" 2>nul
            MOVE *."%%e" "!folderName!\"
            >>organization_log.txt echo *."%%e" "!folderName!\"
        )
    )
)
echo Files have been organized based on the selected type!
GOTO mainMenu

:addCustom
SET /P "CUSTOMEXTENSIONS=Enter custom file extensions (comma separated, e.g. jpg,png,gif): "
SET /P "CUSTOMFOLDER=Enter the name of the folder for these files: "
SET Custom=%CUSTOMEXTENSIONS%
GOTO mainMenu

:organizeAll
FOR %%i IN (Docs Sheets Web Img Audio Video Draw Layout Code Zip Media DB Mail Exe Font) DO (
    CALL SET "selectedExtensions=%%%%i%%"
    SET "folderCreated=0"
    FOR %%e IN (!selectedExtensions!) DO (
        IF EXIST *."%%e" (
            SET "folderName=%%i"
            IF "!folderCreated!"=="0" (
                MD "!folderName!" 2>nul
                SET "folderCreated=1"
            )
            MOVE *."%%e" "!folderName!\"
            >>organization_log.txt echo *."%%e" "!folderName!\"
        )
    )
)

:: Move all unrecognized files to "Other" folder except the log file
MD "Other" 2>nul
FOR %%f IN (*) DO (
    IF "%%~xf" NEQ ".txt" (
        MOVE "%%f" "Other\"
        >>organization_log.txt echo "%%f" "Other\"
    )
)

:: Hide the log file
attrib +h organization_log.txt

echo Files have been organized based on all known types!
GOTO mainMenu

:undoOrganize
IF NOT EXIST "organization_log.txt" (
    echo No log file found. Can't undo.
    GOTO mainMenu
)

attrib -h organization_log.txt

:: Reverse the moves based on the log
FOR /F "tokens=1,2 delims= " %%a IN (organization_log.txt) DO (
    IF EXIST "%%b\%%a" (
        MOVE "%%b\%%a" ".\"
    )
)
DEL "organization_log.txt"
echo Organization has been undone!
GOTO mainMenu

:end
echo Goodbye!
EXIT
