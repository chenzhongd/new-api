@echo off
REM New API VitePress 文档快速启动脚本 (Windows)

echo ================================
echo New API 文档快速启动
echo ================================
echo.

REM 检查是否在 docs 目录
if not exist "package.json" (
    echo 错误：请在 docs 目录中运行此脚本
    echo.
    echo 使用方法：
    echo   cd docs
    echo   startup.cmd
    pause
    exit /b 1
)

REM 检查 Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo 错误：未找到 Node.js
    echo 请先安装 Node.js：https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo Node.js 版本：%NODE_VERSION%
echo.

REM 检查包管理器
set PM=npm
where bun >nul 2>&1
if %errorlevel% equ 0 (
    set PM=bun
    echo 检测到 bun，使用 bun 作为包管理器
) else (
    where npm >nul 2>&1
    if %errorlevel% equ 0 (
        echo 检测到 npm，使用 npm 作为包管理器
    ) else (
        echo 错误：未找到包管理器（npm 或 bun）
        pause
        exit /b 1
    )
)

echo.
echo 请选择操作：
echo   1) 安装依赖
echo   2) 启动开发服务器 (localhost:5173)
echo   3) 构建生产版本
echo   4) 预览生产版本 (localhost:4173)
echo   5) 退出
echo.

set /p choice=请输入选项 (1-5): 

if "%choice%"=="1" (
    echo.
    echo 安装依赖中...
    echo.
    if "%PM%"=="bun" (
        bun install
    ) else (
        npm install
    )
    echo.
    echo 依赖安装完成
) else if "%choice%"=="2" (
    echo.
    echo 启动开发服务器...
    echo.
    echo 访问地址：http://localhost:5173
    echo 按 Ctrl+C 停止服务器
    echo.
    if "%PM%"=="bun" (
        bun run docs:dev
    ) else (
        npm run docs:dev
    )
) else if "%choice%"=="3" (
    echo.
    echo 构建生产版本...
    echo.
    if "%PM%"=="bun" (
        bun run docs:build
    ) else (
        npm run docs:build
    )
    echo.
    echo 构建完成！输出目录：.vitepress\dist
) else if "%choice%"=="4" (
    echo.
    echo 预览生产版本...
    echo.
    echo 访问地址：http://localhost:4173
    echo 按 Ctrl+C 停止服务器
    echo.
    if "%PM%"=="bun" (
        bun run docs:preview
    ) else (
        npm run docs:preview
    )
) else if "%choice%"=="5" (
    echo.
    echo 再见！
    exit /b 0
) else (
    echo.
    echo 无效的选项
    pause
    exit /b 1
)

echo.
echo 操作完成
pause
