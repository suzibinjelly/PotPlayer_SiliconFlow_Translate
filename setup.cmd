@echo off
set lang=en
for /f "tokens=2 delims==" %%i in ('wmic os get locale^|find "="') do set locale=%%i
if "%locale%"=="0804" set lang=zh
if "%lang%"=="zh" (
    set msg_copying=正在复制文件...
    set msg_done=插件安装完成。
    set msg_exit=按任意键退出...
) else (
    set msg_copying=Copying files...
    set msg_done=Extension setup completed.
    set msg_exit=Press any key to exit...
)
echo %msg_copying%
copy /Y "SubtitleTranslate - ChatGPT.as" "C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate"
copy /Y "SubtitleTranslate - ChatGPT.ico" "C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate"
echo %msg_done%
echo.
echo %msg_exit%
pause >nul
