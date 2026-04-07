#!/bin/bash

# New API VitePress 文档快速启动脚本

echo "================================"
echo "New API 文档快速启动"
echo "================================"
echo ""

# 检查是否在 docs 目录
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在 docs 目录中运行此脚本"
    echo ""
    echo "使用方法："
    echo "  cd docs"
    echo "  bash startup.sh"
    exit 1
fi

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误：未找到 Node.js"
    echo "请先安装 Node.js：https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js 版本：$(node -v)"
echo ""

# 选择包管理器
if command -v bun &> /dev/null; then
    PM="bun"
    echo "✅ 检测到 bun，使用 bun 作为包管理器"
elif command -v npm &> /dev/null; then
    PM="npm"
    echo "✅ 检测到 npm，使用 npm 作为包管理器"
else
    echo "❌ 错误：未找到包管理器（npm 或 bun）"
    exit 1
fi

echo ""

# 主菜单
echo "请选择操作："
echo "  1) 安装依赖"
echo "  2) 启动开发服务器 (localhost:5173)"
echo "  3) 构建生产版本"
echo "  4) 预览生产版本 (localhost:4173)"
echo "  5) 退出"
echo ""

read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "📦 安装依赖中..."
        echo ""
        if [ "$PM" == "bun" ]; then
            bun install
        else
            npm install
        fi
        echo ""
        echo "✅ 依赖安装完成"
        ;;
    2)
        echo ""
        echo "🚀 启动开发服务器..."
        echo ""
        echo "访问地址：http://localhost:5173"
        echo "按 Ctrl+C 停止服务器"
        echo ""
        if [ "$PM" == "bun" ]; then
            bun run docs:dev
        else
            npm run docs:dev
        fi
        ;;
    3)
        echo ""
        echo "🔨 构建生产版本..."
        echo ""
        if [ "$PM" == "bun" ]; then
            bun run docs:build
        else
            npm run docs:build
        fi
        echo ""
        echo "✅ 构建完成！输出目录：.vitepress/dist"
        ;;
    4)
        echo ""
        echo "👁️  预览生产版本..."
        echo ""
        echo "访问地址：http://localhost:4173"
        echo "按 Ctrl+C 停止服务器"
        echo ""
        if [ "$PM" == "bun" ]; then
            bun run docs:preview
        else
            npm run docs:preview
        fi
        ;;
    5)
        echo ""
        echo "👋 再见！"
        exit 0
        ;;
    *)
        echo ""
        echo "❌ 无效的选项"
        exit 1
        ;;
esac

echo ""
echo "✅ 操作完成"
