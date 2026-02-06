@echo off
REM ============================================================
REM  VideoAgent Launcher
REM  Opens Claude Code with the full VideoAgent context loaded.
REM
REM  Usage:
REM    video-agent.bat                     Start a session
REM    video-agent.bat --resume            Resume last session
REM    video-agent.bat --project MyVideo   Set active project
REM    video-agent.bat --comfyui URL       Override ComfyUI URL
REM ============================================================

setlocal enabledelayedexpansion

set "REPO_DIR=C:\Users\kruz7\OneDrive\Documents\Code Repos\MCKRUZ\VideoAgent"
set "CLAUDE_ARGS="
set "ACTIVE_PROJECT="
set "COMFYUI_URL=http://127.0.0.1:8188"

REM Parse arguments
:parse_args
if "%~1"=="" goto :done_args
if /i "%~1"=="--resume" (
    set "CLAUDE_ARGS=--resume"
    shift
    goto :parse_args
)
if /i "%~1"=="--project" (
    set "ACTIVE_PROJECT=%~2"
    shift & shift
    goto :parse_args
)
if /i "%~1"=="--comfyui" (
    set "COMFYUI_URL=%~2"
    shift & shift
    goto :parse_args
)
shift
goto :parse_args
:done_args

REM Write active session config (read by CLAUDE.md)
echo { > "%REPO_DIR%\state\session.json"
echo   "comfyui_url": "%COMFYUI_URL%", >> "%REPO_DIR%\state\session.json"
echo   "active_project": "%ACTIVE_PROJECT%", >> "%REPO_DIR%\state\session.json"
echo   "started": "%date% %time%" >> "%REPO_DIR%\state\session.json"
echo } >> "%REPO_DIR%\state\session.json"

REM Launch Claude Code in the VideoAgent directory
cd /d "%REPO_DIR%"
echo.
echo  VideoAgent Session
echo  ==================
echo  Project dir: %REPO_DIR%
if defined ACTIVE_PROJECT echo  Project:     %ACTIVE_PROJECT%
echo  ComfyUI:     %COMFYUI_URL%
echo.

claude %CLAUDE_ARGS%

endlocal
