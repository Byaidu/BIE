@echo off
::Ԥ��������
if "%1"=="" goto i
title Start
setlocal EnableDelayedExpansion
path Tool;%SystemRoot%\System32
::�ύ����
::http://tieba.baidu.com/f?kw=bat
set browse=http://www.bathome.net/
::�������httpЭ��
if not "!browse:~0,7!"=="http://" set "browse=http://!browse!"
for /f "tokens=1,2 delims=/" %%a in ("!browse!") do set "host=%%a//%%b"
:replay
cls
title Start
cd.>Temp\queue_a.txt
set mark_a=false
set mark_p=false
set mark_title=false
set info_title=Start
set all_a=0
set all_img=0
set writey=0
::������ҳ
curl -o Temp\read.html "!browse!" >nul 2>nul
for /f "delims=" %%a in (Temp\read.html) do (
  for /l %%b in (1,1,31) do (
    set "readline=%%a"
    call:readline %%b
  )
)
set backlevel=
:cmos
echo ==================================��ҳ�������==================================
echo ============================����������������ģʽ============================
pause>nul
Cmos2 0 1 1
set /a X=!errorlevel:~0,-3!
set /a Y=!errorlevel!-1000*!X!-1
for /f "delims=" %%c in (Temp\queue_a.txt) do (
  for /f "tokens=1,2,3 delims=*" %%d in ("%%c") do (
    if !Y! geq %%e if !Y! leq %%f set "browse=%%d" & goto replay
  )
)
goto cmos

:readline
set skipinfo=no
for /f "tokens=%1 delims=<>" %%a in ("!readline!") do (
  ::�������ݵı�ǩ
  for /f "tokens=1,2,3,4,5,6,7,8" %%b in ("%%a") do (
    if "%%b"=="a" (
      ::�����link_a���Ա�������ǩ����
      set /a all_a+=1
      set mark_a=true
      set "for=%%c"
      if "!for:~0,4!"=="href" (
        if "!for:~6,7!"=="http://" (
          set "link_a=!for:~6,-1!"
        ) else (
          set "link_a=!host!/!for:~6,-1!"
        )
      )
      set skipinfo=yes
    )
    if "%%b"=="img" (
      ::ͼƬ���
      set /a all_img+=1
      set "for=%%c"
      if "!for:~0,3!"=="src" (
        if "!for:~5,7!"=="http://" (
          curl -o Temp\!all_img!.jpg "!for:~5,-1!" >nul 2>nul
        ) else (
          curl -o Temp\!all_img!.jpg "!host!/!for:~5,-1!" >nul 2>nul
        )
      ) else (
        set "for=%%d"
        if "!for:~0,3!"=="src" (
          if "!for:~5,7!"=="http://" (
            curl -o Temp\!all_img!.jpg "!for:~5,-1!" >nul 2>nul
          ) else (
            curl -o Temp\!all_img!.jpg "!host!/!for:~5,-1!" >nul 2>nul
          )
        )
      )
      for /f "tokens=2 delims=:" %%c in ('MediaInfo Temp\!all_img!.jpg^|findstr "Height"') do (
        set Height=%%c
        set Height=!Height:pixels=!
        set Height=!Height: =!
      )
      set "writey_start=!writey!"
      ::����ͼƬ����λ��
      if !writey! lss 25 set /a imagey=writey*16
      set /a remainder=Height%%16
      if "!remainder!"=="0" (
        set /a writey+=Height/16
        if !writey! geq 25 set /a imagey=^(24-Height/16^)*16
      ) else (
        set /a writey+=Height/16+1
        if !writey! geq 25 set /a imagey=^(24-Height/16-1^)*16
      )
      ::�ض�λ��꣬��ֹ��������ָ���ͼƬ
      Cmos 0 0 1 0 !writey!
      GDI "/t:!info_title!" Temp\!all_img!.jpg*0*!imagey!
      set /a writey_end=writey-1
      if "!mark_a!"=="true" (echo.!link_a!*!writey_start!*!writey_end!)>>Temp\queue_a.txt
      set skipinfo=yes
    )
  )
  ::��ͨ��ǩ
  if "%%a"=="/a" (
    echo.!info_a!
    (echo.!link_a!*!writey!*!writey!)>>Temp\queue_a.txt
    set /a writey+=1
    set info_a=
    set link_a=
    set mark_a=false
    set skipinfo=yes
  )
  if "%%a"=="p" (
    set mark_p=true
    set skipinfo=yes
  )
  if "%%a"=="/p" (
    echo.!info_p!
    set /a writey+=1
    set info_p=
    set mark_p=false
    set skipinfo=yes
  )
  if "%%a"=="title" (
    set mark_title=true
    set skipinfo=yes
  )
  if "%%a"=="/title" (
    title !info_title!
    set mark_title=false
    set skipinfo=yes
  )
  ::���ر�ǩ�����info
  if "!skipinfo!"=="no" (
    if "!mark_a!"=="true" set "info_a=%%a"
    if "!mark_p!"=="true" set "info_p=!info_p!%%a "
    if "!mark_title!"=="true" set "info_title=%%a"
  )
)
goto:eof

:i
for /f "tokens=2*" %%i in ('reg query HKEY_CURRENT_USER\Console^|findstr ScreenBufferSize') do set ScreenBufferSize=%%j
echo.yes|reg add HKEY_CURRENT_USER\Console /v ScreenBufferSize /t REG_DWORD /d 0x012c0190 >nul 2>nul
::�������/d��������������������������С�����޸�Ϊ���ձ��е�ʮ��������
start "" %0 done
ping localhost -n 1 >nul
echo.yes|reg add HKEY_CURRENT_USER\Console /v ScreenBufferSize /t REG_DWORD /d %ScreenBufferSize% >nul 2>nul
::�������ʹ�����С�������������Ļ���
exit