@echo off
rem -------------------------------------  pISA-tree v.0.4.2
rem
rem Create a new Assay tree _A_xxx in current directory
rem ------------------------------------------------------
rem Author: A Blejec <andrej.blejec@nib.si>
rem (c) National Institute of Biology, Ljubljana, Slovenia
rem 2016
rem ------------------------------------------------------
rem cd d:\_X
rem Backup copy if assay folder exists
rem robocopy %1 X-%1 /MIR
rem ------------------------------------------------------
rem
setlocal EnableDelayedExpansion
set LF=^


REM Keep two empty lines above - they are neccessary!!
set "TAB=	"
echo =================================
echo pISA-tree: make ASSAY 
echo ---------------------------------
set hd=---------------------------------/
set hd=%hd%pISA-tree: make ASSAY/
set hd=%hd%---------------------------------/
call:displayhd "%hd%"
set sroot=%cd%
set "iroot=.."
set "proot=..\%iroot%"
set "mroot=..\%proot%"
set "tmpldir=%mroot%\Templates"
rem dir %tmpldir%
rem pause
rem ----------------------------------------------
rem Class: use argument 1 if present
set today=%date:~13,4%-%date:~9,2%-%date:~5,2%
set IDClass=
rem if "%1" EQU "" (
rem echo @
rem set /p IDClass=Enter Assay Class [ Wet/Dry ]: 
rem ) else (
rem set IDClass=%1
rem )
rem Ask for Class, loop if empty
:Ask1
rem if %IDClass% EQU "" set /p IDClass=Enter Assay Class [ Wet/Dry ]: 
rem if %IDClass% EQU "" goto Ask1
rem /I: case insensitive compare
rem if /I %IDClass% EQU dry (set IDClass=Dry)
rem if /I %IDClass% EQU d set IDClass=Dry
rem if /I %IDClass% EQU wet set IDClass=Wet
rem if /I %IDClass% EQU w set IDClass=Wet
SETLOCAL ENABLEDELAYEDEXPANSION
SET "types="
FOR /f "delims=" %%i IN ('dir %tmpldir% /b') DO (
    SET types=!types!%%i/
)
SETLOCAL DISABLEDELAYEDEXPANSION
set "IdClass="
call:getMenu "Select Assay Class" %types% IDClass
set "hd=%hd%Assay Class:		 %~4%IDClass%/"
call:displayhd "%hd%"
rem echo Selected: %IDClass%
rem ----------------------------------------------
rem Supported types
if /I %IDClass% EQU Wet set "types=NGS / RT"
if /I %IDClass% EQU Dry set "types=R / Stat"
SETLOCAL ENABLEDELAYEDEXPANSION
SET "types="
FOR /f "delims=" %%i IN ('dir %tmpldir%\%IDClass% /b') DO (
    SET types=!types!%%i/
)
SETLOCAL DISABLEDELAYEDEXPANSION
set "IDType="
call:getMenu "Select Assay Type" %types% IDType
set "hd=%hd%Assay Type:		 %~4%IDType%/"
call:displayhd "%hd%"
rem echo Selected: %IDType%
rem ----------------------------------------------
rem Type: use argument 2 if present
rem set IDType=""
rem if "%2" EQU "" (
rem set /p IDType=Enter Assay Type [ %types% ]: 
rem ) else (
rem set IDType=%2
rem )
rem dir %IDType%* /B /AD
rem Similar Assay IDs
rem %IDType%* /AD
:Ask2
rem if %IDType% EQU "" set /p IDType=Enter Assay Type [ %types% ]: 
rem if %IDType% EQU "" goto Ask2
rem ----------------------------------------------
rem ID : use argument 3 if present
set IDName=""
if "%3" EQU "" (
set /p IDName=Enter Assay ID: 
) else (
set IDType=%3
)
rem dir %IDType%* /B /AD
rem Similar Assay IDs
rem %IDType%* /AD
:Ask3
if %IDName% EQU "" set /p IDName=Enter Assay ID: 
if %IDName% EQU "" goto Ask3
rem ----------------------------------------------
rem concatenate ID name
set ID=%IDName%-%IDType%
echo %ID%
rem ----------------------------------------------
rem Check existence
IF EXIST %ID% (
REM Dir exists
echo ERROR: Assay named *%ID%* already exists
rem set IDType=""
rem set IDClass=""
set IDName=""
set ID=""
goto Ask3
) ELSE (
REM Continue creating directory
)
set "hd=%hd%Assay ID:		 %~4%ID%/"
call:displayhd "%hd%"
set Adir=_A_%ID%
md %Adir%
cd %Adir%
set aroot=%cd%
set "sroot=.."
set "iroot=..\%sroot%"
set "proot=..\%iroot%"
set "mroot=..\%proot%"
set "tmpldir=%mroot%\Templates"
goto %IDClass%
rem ----------------------------------------------
rem Make new assay directory tree
rem ----------------------------------------------
:dry
REM set IDClass=Dry
md input
md reports
md scripts
md output
md other
rem put something in to force git to add new directories
echo # Assay %ID% >  .\README.MD
echo # Input for assay %ID% >  .\input\README.MD
echo # Reports for assay %ID% >  .\reports\README.MD
echo # Scripts for assas %ID% >  .\scripts\README.MD
echo # Output of assay %ID% >  .\output\README.MD
echo # Other files for assay %ID% >  .\other\README.MD
goto Forall
rem ----------------------------------------------
:wet
REM set IDClass=Wet
echo %cd%
md reports
md output
cd output
md raw
cd ..
md other
rem put something in to force git to add new directories
echo # Assay %ID% >  .\README.MD
echo # Reports for assay %ID% >  .\reports\README.MD
echo # Output of assay %ID% >  .\output\README.MD
echo # Raw output of assay %ID% >  .\output\raw\README.MD
echo # Other files for assay %ID% >  .\other\README.MD
goto Forall
rem ----------------------------------------------
:Forall
rem
setlocal EnableDelayedExpansion
set LF=^


REM Keep two empty lines above - they are neccessary!!
set "TAB=	"
rem -----------------------------------------------
rem -----------------------------------------------
call:getLayer _p_ pname
call:getLayer _I_ iname
call:getLayer _S_ sname
call:getLayer _A_ aname
rem -----------------------------------------------
rem -------------------------------------- make ASSAY_DESCRIPTION
set descFile=".\_ASSAY_METADATA.TXT"
echo project:	%pname%> %descFile%
echo Investigation:	%iname%>> %descFile%
echo Study:	%sname%>> %descFile%
echo Assay:	%Adir%>> %descFile%
echo ### ASSAY>> %descFile%
echo Short Name:	%ID%>> %descFile%
echo Assay Class:	 %IDClass%>> %descFile%
echo Assay Type:	 %IDType%>> %descFile%

rem ECHO ON
  rem set analytesInput=Analytes.txt
  rem if exist ../%analytesInput% ( copy ../%analytesInput% ./%analytesInput% )
  call:inputMeta "Title" aTitle *
  call:inputMeta "Description" aDesc *
rem ---- Type specific fields
if /I "%IDClass%"=="WET" goto Demo
if /I "%IDType%" == "DNAse" goto Demo
if /I "%IDType%" == "RNAisol" goto Demo
if /I "%IDType%" == "Demo" goto Demo
if /I "%IDType%" == "RT" goto Demo
if /I "%IDType%" == "R" goto R
if /I "%IDType%" == "Stat" goto Stat
echo .
echo Warning: Unseen Assay Type: *%IDType%* - will make Generic %IDClass% Assay
echo .
pause
goto Finish
rem
:Demo
REM ------------------------------------------ Demo
rem cd
rem echo tst %tmpldir%\%IDClass%\%IDType%\analytes.ini
rem dir %tmpldir%
rem dir ..\%tmpldir%
set tasdir=%tmpldir%\%IDClass%\%IDType%
rem dir %tasdir%
rem dir %tmpldir%
rem cd
set analytesInput=Analytes.txt
  if exist %sroot%\%analytesInput% ( copy %sroot%\%analytesInput% %aroot%\%analytesInput% )
  set "line1="
  set "line2="
  rem dir %tmpldir%\%IDClass%\%IDType%\
call:processAnalytes %tasdir%\analytes.ini

rem echo tst after processAnalytes: line1 %line1%
rem echo tst after processAnalytes: line2 %line2%
REM
rem PAUSE
  goto Finish
REM ------------------------------------------/Demo
:NGS
REM ------------------------------------------ NGS
  set analytesInput=Analytes.txt
  if exist %sroot%\%analytesInput% ( copy %sroot%\%analytesInput% %aroot%\%analytesInput% )
  set line1=
  set line2=
  call:putMeta2 "RNA ID" a01 RNA XIDX_
  rem set "line1=RNA-ID	ng/ul	260/280	260/230"
  rem set "line2=XIDX_%a01%_%IDType%			"
  set "line2=%line2%_%IDType%"
  call:putMeta2 "ng/ul" a100 Blank
  call:putMeta2 "260/280" a100 Blank
  call:putMeta2 "260/230" a100 Blank
  call:putMeta2 "Homogenisation protocol" a02 fastPrep/slowPrep
  call:putMeta2 "Date Homogenisation" a03 %today%
  call:putMeta2 "Isolation Protocol" a04 Rneasy_Plant
  call:putMeta2 "Date Isolation" a05 %today%
  call:putMeta2 "Storage RNA" a06 CU0369
  call:putMeta2 "Dnase treatment protocol" a7 *
  call:putMeta2 "Dnase ID" a8 DNase XIDX_
  call:putMeta2 "Date DNAse_treatment" a9 %today%
  call:putMeta2 "Storage_DNAse_treated" a10 CU0370
  call:putMeta2 "Operator" a11 "*"
  call:putMeta2 "cDNA ID" a12 cDNA XIDX_
  call:putMeta2 "DateRT" a13 %today%
  call:putMeta2 "Operator" a14 %a11%
  call:putMeta2 "Notes" a15 " "
  call:putMeta2 "Fluidigm_chip" a16 Chip10

  call:writeAnalytes %analytesInput% "%line1%" "%line2%"
REM
  goto Finish
REM ---------------------------------------- /NGS
:RT
REM ---------------------------------------- RT
  set analytesInput=Analytes.txt
  if exist %sroot%\%analytesInput% ( copy %sroot%\%analytesInput% %aroot%\%analytesInput% )
  set line1=
  set line2=
  call:putMeta2 "Dnase ID" a03	DNASE	XIDX_
  call:putMeta2 "RTprotocol" a04 " "
  call:putMeta2 "cDNA ID" a05 cDNA XIDX_
  call:putMeta2 "DateRT" a06 %today%
  call:putMeta2 "Operator" a07 *
  
  call:writeAnalytes %analytesInput% "%line1%" "%line2%"
REM
    goto Finish
REM ---------------------------------------- /RT
:R
REM ---------------------------------------- R
    goto Finish
REM ---------------------------------------- /R
:Stat
REM ---------------------------------------- R
    goto Finish
REM ---------------------------------------- /R
:Finish
echo Data:	>> %descFile%
rem ------------------------------------  include common.ini from project level
copy %descFile%+..\common.ini %descFile% >NUL
echo ASSAY:	%ID%>> ..\_STUDY_METADATA.TXT
copy %sroot%\showTree.bat . >NUL
copy %sroot%\showMetadata.bat . >NUL
copy %sroot%\xcheckMetadata.bat . >NUL

rem
rem  make main readme.md file
rem type README.MD
rem dir .
rem cls
rem type %descFile%
cd ..
rem copy existing files from nonversioned tree (if any)
rem robocopy X-%ID% %ID% /E
rem dir .\%ID% /s/b
echo.
echo ============================== pISA ==
echo.
echo Assay %ID% is ready.
echo .
echo ======================================

PAUSE
goto:eof
rem ====================================== / makeAssay
rem --------------------------------------------------------
rem Functions
:getInput   --- get text from keyboard
::          --- %~1 Input message (what to enter)
::          --- %~2 Variable to get result
::          --- %~3 (optional) missing: empty string is OK
::                             * : can be skipped, return *
::                             ! : input required, no empty string
:: Example: call:getInpt "Type something" xx default
SETLOCAL
:Ask1
echo.
echo =======================================================
echo.
:: Default for typing is is the first item (needed for Other)
set "x=%~3"
set /p x=Enter %~1 [ %x% ]: 
rem if %x% EQU "" set x="%~3"
rem empty answer OK
if "%x%" EQU "" goto done 
if "%x%" EQU "*" goto done
REM Is input required and not entered?
REM Mostly intended for pISA file names
if "%x%" EQU "!" goto Ask1
goto done
REM Check existence/uniqueness
IF EXIST "%x%" (
REM Dir exists
echo ERROR: %~1 *%x%* already exists
set x=""
goto Ask1
) 
:done
(ENDLOCAL
 IF "%~2" NEQ "" set "%~2=%x%"
)
GOTO:EOF
rem -----------------------------------------------------
:putMeta   --- get metadata and append to descFile
::         --- descFile - should be set befor the call
::          --- %~1 Input message (what to enter)
::          --- %~2 Variable to get result
::          --- %~3 (optional) missing: input required
::          ---                * : can be skipped, return *
:: Example: call:putMeta "Type something" xx default
SETLOCAL
rem call:getInput "%~1" xMeta "%~3"
rem Type input or get menu?

call:getMenu "%~1" %~3/getMenu xMeta "%~3"
echo %~1:	%xMeta% >> %descFile%
rem call:writeAnalytes %analytesInput% "%~1" %xMeta% 
rem


rem
(ENDLOCAL
    IF "%~2" NEQ "" set "%~2=%xMeta%"
    set "aEntered=%xMeta%"
    set "hd=%hd%%~1:		 %xMeta%/"
    call:displayhd "%hd%"

)
GOTO:EOF
rem -----------------------------------------------------
:inputMeta   --- get metadata and append to descFile
::         --- descFile - should be set befor the call
::          --- %~1 Input message (what to enter)
::          --- %~2 Variable to get result
::          --- %~3 (optional) missing: no typed input required
::                             * : can be skipped, return *
::                             ! : typed input required
:: Example: call:inputMeta "Type something" xx default
SETLOCAL
rem call:getInput "%~1" xMeta "%~3"
rem Type input or get menu?

call:getInput "%~1" xMeta "%~3"
echo %~1:	%xMeta% >> %descFile%
rem call:writeAnalytes %analytesInput% "%~1" %xMeta% 
rem

    set "spaces=                                           "
    set "line=%~1:%spaces%"
    set "line=%line:~0,25%%~4%xMeta%"
rem
(ENDLOCAL
    IF "%~2" NEQ "" set "%~2=%xMeta%"
    set "aEntered=%xMeta%"
    set "hd=%hd%%line%/"
    rem set "hd=%hd%%~1:		 %xMeta%/"

    )
GOTO:EOF
rem --------------------------------------------------------
:getMenu    --- get menu item
::          --- %~1 Value description
::          --- %~2 String of choices (aa/bb/cc)
::          --- %~3 Variable to get result
::          --- %~4 (optional) missing: input required
::          ---                * : can be skipped, return *
:: Example: call:getMenu "Select input" list/of/choices u
SETLOCAL
rem Make menu function
rem cls
echo.
echo =========================
echo.
echo %~1
echo.
set mn=%~2
rem 
IF NOT "%mn:~-1%"=="/" set mn=%mn%/
set _mn=%mn%
set nl=0
set mch=
rem echo %mn%
rem echo. 
:top
rem if "%mn%"=="" goto :done
set /A "nl=%nl%+1"
set mch=%mch%%nl%
for /F "tokens=1 delims=/" %%H in ("%mn%") DO echo    %nl% %%H
set mn=%mn:*/=%
if NOT "%mn%"=="" goto :top
rem :done
echo. 
choice /C:%mch% /M:Select 
(ENDLOCAL
    for /F "tokens=%errorlevel% delims=/" %%H in ("%_mn%") DO set "%~3=%%H
)
GOTO:EOF
rem -----------------------------------------------------
:putMeta2   --- get metadata and append to descFile
::          --- descFile - should be set befor the call
::          --- %~1 Input message (what to enter)
::          --- %~2 Variable to get result
::          --- %~3 (optional) missing: no typed input required
::                             * : can be skipped, return *
::                             ! : typed input required
::          --- %~4 optional prefix; some values have to be prefixed by SampleID
::                  XIDX will be replaced by SampleID upon writing to file
:: Example: call:putMeta2 "Type something" xx default
rem SETLOCAL
rem FIX: allow text input of empty string
if "%~3"=="*" call:getInput "%~1" xMeta "%~3" & GOTO:next
if "%~3"==""  call:getInput "%~1" xMeta "%~3" & GOTO:next
if "%~3"==" " call:getInput "%~1" xMeta "%~3" & GOTO:next
if /I "%~3"=="Blank" set xMeta="" & GOTO:next
rem call:getInput "%~1" xMeta "%~3"
rem echo.=%~3= rem test
call:getMenu "%~1" "%~3/Other" xMeta "%~3"
set first="."
for /f "tokens=1 delims=/" %%a in ("%~3") do set first=%%a
rem echo =%~3=%first%= REM test
if "%xMeta%"=="Other" call:getInput "%~1" xMeta "%first%"
:next
echo %~1:	%xMeta%%prefix% >> %descFile%
rem call:writeAnalytes %analytesInput% "%~1" %xMeta% 
rem
REM (ENDLOCAL
set "%~2=%xMeta%"
set pf=
if "%~4" NEQ ""  set pf=%postfix%
set "line1=%line1%	%~1"
set "line2=%line2%	%~4%xMeta%%pf%"
endlocal
rem echo tst line1 %line1%
rem echo tst line2 %line2%
rem pause
set "spaces=                                 "
set "line=%~1%spaces%"
set "line=%line:~0,25%%~4%xMeta%"
rem if /I "%~3" NEQ "Blank" set "hd=%hd%%~1:		 %~4%xMeta%/"
if /I "%~3" NEQ "Blank" set "hd=%hd%%line%/"
if /I "%~3" NEQ "Blank" call:displayhd "%hd%"
REM )
GOTO:EOF
rem ---------------------------------------------------
:writeAnalytes  --- write colums to analyte file
::              --- %~1 file to process
::              --- %~2 string for the first line
::              --- %~3 string for other lines
rem SETLOCAL
rem IF EXIST %~1 (

    rem First line
    set /p z= <%~1
    set x2=%~2
    rem uncoment next line to remove blanks in the header line
    rem set x2=%x2: =%
    rem TAB inserted automatically
    echo %z%%x2%  > tmp.txt
    rem Process other lines
    rem Replace $ with sample id from the first field
    rem set "SEARCHTEXT=XIDX"
    set "SEARCHTEXT=$"
    set "line=%~3"
    for /f "skip=1 tokens=1,* delims=	 " %%a in (%~1) do (
    rem echo on
    set "TAB=	"
      	rem echo %%a
      	rem echo %%b
      	rem echo %~3
      	setlocal enabledelayedexpansion
      rem	set "line=!line:%search%=%replace%!"
      SET "modified=!line:%SEARCHTEXT%=%%a!"
      rem echo %searchtext% %modified%
      	rem should replace special token with SampleId before writing
       echo %%a	%%b!modified! >> tmp.txt 
       rem echo Write: %%a	%%b!modified!
       endlocal
       echo off
       )
    copy tmp.txt %~1 >NUL
rem )
rem ENDLOCAL
del tmp.txt
GOTO:EOF
rem --------------------------------------------------
:displayhd  --- clear screen and display header
::          --- %~1 header text, use / as the new line character
:: Example: call:displayhd list/of/choices
set mn=%~1
SETLOCAL
cls
IF NOT "%mn:~-1%"=="/" set mn=%mn%/
:tophd
FOR /F "delims=/" %%i IN ("%mn%") DO echo %%i
set mn=%mn:*/=%
if NOT "%mn%"=="" goto :tophd
ENDLOCAL
goto:EOF
rem --------------------------------------------------
:getDirNames  --- get directory names and prepare / delimited list
::            --- %~1 directory
::            --- %~2 Variable to get result
:: Return:    >>> list of directories DRY/WET/XXX
:: Example: call:getDirNames ..\main\Templates
SETLOCAL ENABLEDELAYEDEXPANSION
echo "Reading from file: %~1"
SET "files="
FOR /f "delims=" %%i IN ('dir %~1 /b') DO (
     SET "files=!files!%%i/"
)
(ENDLOCAL
SET %~2="%files%"
SET %~2=%files:~0,-1%
)
GOTO:EOF
REM ----------------------------------------------------------
:processAnalytes  --- read analytes.ini and loop through lines
::                --- %~1 file path
::                --- %~2 Variable to get result
:: Return:    >>> 
:: Example: call:processAnalytes %tmpldir%\%IDClass%\%IDType%\analytes.ini"
rem first id is prefixed. will be reset to empty after the first line
set postfix=_%IDName%
set "lfn=%~1"
if %lfn%=="" set "lfn=%tmpldir%\%IDClass%\%IDType%\analytes.ini"
SETLOCAL EnableDelayedExpansion
FOR /F "usebackq delims=" %%a in (`"findstr /n ^^ %lfn%"`) do (
    call :processLine "%%a"
    )
 rem echo tst processAnalytes: line1 %line1%
 rem echo tst processAnalytes: line2 %line2%
 rem echo tst %analytesInput%
 rem pause

call:writeAnalytes %analytesInput% "%line1%" "%line2%"
goto :eof
rem ------------------------------------------------------------
:processLine  --- compose metadata menu for a line
::            --- %~1 line from analytes.ini template (two tab delimited strings)
::
:: Example: call:processLine "Descriptor	Option1/Option2"
SET "string=%~1"
REM the line starts with "nn:" - cut off the numbers and colon
set "string=%string:*:=%
REM parse Item/Value line (separetor is TAB) - do not forget to use "..."
set s1=
set s2=
for /f "tokens=1 delims=	" %%a in ("%string%") do set s1=%%a
for /f "tokens=2 delims=	" %%a in ("%string%") do set s2=%%a
for /f "tokens=1 delims=	" %%a in ("%string%") do set s1=%%a
for /f "tokens=2 delims=	" %%a in ("%string%") do set s2=%%a
REM ask for input
rem ECHO call:putMeta2 "%s1%" xxx %s2%
call:putMeta2 "%s1%" xxx "%s2%"
goto :eof

REM ----------------------------------------------------------
:processLine2  --- compose metadata menu for a line
::            --- %~1 line from analytes.ini template (two tab delimited strings)
::
:: Example: call:processLine "Descriptor	Option1/Option2"
SETLOCAL enabledelayedexpansion
SET "string=!%~1!"
rem remove number: added by findstr - not working
rem echo set "string=%!string!:*:=%"
rem set "string=%!%~1!:*:=%"
SET "s2=%string:*	=%"
set "s1=!string:	%s2%=!"
ECHO +%s1%+%s2%+
rem ENDLOCAL
ECHO call:putMeta2 "%s1%" xxx %s2%
call:putMeta2 "%s1%" xxx %s2%
rem ENDLOCAL
goto :eof
rem -----------------------------------
:getLayer  --- get layer name from the current path
::                --- %~1 layer prefix (e.g. _I_)
::                --- %~2 Variable to get result
:: To remove characters from the right hand side of a string is 
:: a two step process and requires the use of a CALL statement
:: e.g.

   SET _test=D:\bla\_p_project\_I_test\_S_moj
   SET _test=%cd%

SETLOCAL EnableDelayedExpansion

   :: To delete everything after the string e.g. '_I_'  
   :: first delete .e.g. '_I_' and everything before it
   SET _test=!_test:*\%~1=%~1! 
   SET _endbit=%_test:*\=%
   REM Echo We dont want: [%_endbit%]

   ::Now remove this from the original string
   CALL SET _result=%%_test:\%_endbit%=%%
   rem echo %_result%
   (endlocal 
   set "%~2=%_result%")
   rem echo %iname%
   endlocal
goto :eof
