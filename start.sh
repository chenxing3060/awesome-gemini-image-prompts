#!/bin/bash

# Awesome Gemini Image 项目启动脚本
# 这个脚本帮助你快速开始项目开发

echo "🚀 欢迎使用 Awesome Gemini Image 项目！"
echo "=========================================="

# 检查是否在正确的目录
if [ ! -f "README.md" ] || [ ! -f "package.json" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 显示项目信息
echo "📁 项目目录: $(pwd)"
echo "📚 项目名称: Awesome Gemini Image Prompts"
echo "🔧 技术栈: 提示词技巧合集, Markdown, 社区贡献"
echo ""

# 检查 Git 状态
if [ -d ".git" ]; then
    echo "✅ Git 仓库已初始化"
    echo "📝 当前分支: $(git branch --show-current)"
    echo "📊 提交历史:"
    git log --oneline -3
    echo ""
else
    echo "⚠️  Git 仓库未初始化"
fi

# 检查 Node.js 环境
if command -v node &> /dev/null; then
    echo "✅ Node.js 已安装: $(node --version)"
    if command -v npm &> /dev/null; then
        echo "✅ npm 已安装: $(npm --version)"
    fi
else
    echo "⚠️  Node.js 未安装"
fi

# 检查 Python 环境
if command -v python3 &> /dev/null; then
    echo "✅ Python3 已安装: $(python3 --version)"
elif command -v python &> /dev/null; then
    echo "✅ Python 已安装: $(python --version)"
else
    echo "⚠️  Python 未安装"
fi

echo ""
echo "🎯 下一步操作建议："
echo ""

# 如果 Node.js 可用，提供安装依赖选项
if command -v npm &> /dev/null; then
    echo "1. 📦 安装项目依赖:"
    echo "   npm install"
    echo ""
    echo "2. 🚀 启动开发服务器:"
    echo "   npm run dev"
    echo ""
fi

echo "3. 🌐 查看演示页面:"
echo "   在浏览器中打开 demo.html"
echo ""

echo "4. 📖 阅读文档:"
echo "   - README.md - 项目介绍"
echo "   - tutorials/getting_started.md - 快速入门"
echo "   - examples/ - 代码示例"
echo ""

echo "5. 🤝 参与贡献:"
echo "   查看 CONTRIBUTING.md 了解如何贡献"
echo ""

echo "6. 🔍 搜索优化:"
echo "   项目名称: awesome-gemini-image"
echo "   关键词: gemini image, gemini vision, google ai"
echo ""

# 检查是否有远程仓库
if git remote -v | grep -q origin; then
    echo ""
    echo "🌐 远程仓库已配置:"
    git remote -v
else
    echo ""
    echo "📝 配置远程仓库:"
    echo "   git remote add origin <your-repo-url>"
    echo "   git push -u origin main"
fi

echo ""
echo "🎉 项目准备就绪！开始你的 Awesome Gemini Image 之旅吧！"
echo ""
echo "💡 提示："
echo "   - 使用 'git status' 查看仓库状态"
echo "   - 使用 'git log' 查看提交历史"
echo "   - 使用 'git add .' 和 'git commit' 保存更改"
echo ""
