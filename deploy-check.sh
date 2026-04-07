#!/bin/bash

# New API 部署前检查脚本
# 用于快速验证部署环境是否满足要求

set -e

echo "🔍 New API 部署前环境检查"
echo "================================"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    local cmd=$1
    local name=$2
    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: 未安装"
        return 1
    fi
}

check_port() {
    local port=$1
    local name=$2
    if nc -z localhost $port 2>/dev/null; then
        echo -e "${YELLOW}⚠${NC} $name (端口 $port): 已被占用"
        return 1
    else
        echo -e "${GREEN}✓${NC} $name (端口 $port): 可用"
        return 0
    fi
}

# 计数器
passed=0
failed=0

# 1. 检查系统信息
echo "📦 系统信息"
echo "---"
os_name=$(uname -s)
kernel=$(uname -r)
echo "操作系统: $os_name"
echo "内核版本: $kernel"
echo ""

# 2. 检查必需的命令
echo "🔧 必需工具检查"
echo "---"

check_command docker "Docker" && ((passed++)) || ((failed++))
check_command docker-compose "Docker Compose" && ((passed++)) || ((failed++))
check_command git "Git" && ((passed++)) || ((failed++))
check_command node "Node.js" && ((passed++)) || ((failed++))
check_command npm "npm" && ((passed++)) || ((failed++))

echo ""

# 3. 检查可选工具
echo "💾 可选工具检查"
echo "---"

if command -v bun &> /dev/null; then
    echo -e "${GREEN}✓${NC} Bun 已安装"
else
    echo -e "${YELLOW}ℹ${NC} Bun 未安装 (可选，但推荐用于前端构建)"
fi

if command -v mysql &> /dev/null; then
    echo -e "${GREEN}✓${NC} MySQL CLI 已安装"
else
    echo -e "${YELLOW}ℹ${NC} MySQL CLI 未安装 (可选，用于数据库管理)"
fi

if command -v redis-cli &> /dev/null; then
    echo -e "${GREEN}✓${NC} Redis CLI 已安装"
else
    echo -e "${YELLOW}ℹ${NC} Redis CLI 未安装 (可选，用于 Redis 管理)"
fi

echo ""

# 4. 检查端口
echo "🌐 端口检查"
echo "---"

check_port 80 "HTTP" && ((passed++)) || ((failed++))
check_port 443 "HTTPS" && ((passed++)) || ((failed++))
check_port 3000 "New API" && ((passed++)) || ((failed++))
check_port 3306 "MySQL" && ((passed++)) || ((failed++))
check_port 6379 "Redis" && ((passed++)) || ((failed++))
check_port 5173 "VitePress" && ((passed++)) || ((failed++))

echo ""

# 5. 检查磁盘空间
echo "💾 磁盘空间检查"
echo "---"

available=$(df / | awk 'NR==2 {print $4}')
available_gb=$((available / 1024 / 1024))

if [ "$available_gb" -gt 10 ]; then
    echo -e "${GREEN}✓${NC} 可用磁盘空间: ${available_gb}GB (充足)"
else
    echo -e "${RED}✗${NC} 可用磁盘空间: ${available_gb}GB (不足，需要至少 10GB)"
    ((failed++))
fi

echo ""

# 6. 检查内存
echo "🧠 内存检查"
echo "---"

total_mem=$(free -g | awk 'NR==2 {print $2}')

if [ "$total_mem" -ge 4 ]; then
    echo -e "${GREEN}✓${NC} 总内存: ${total_mem}GB (充足)"
    ((passed++))
else
    echo -e "${YELLOW}⚠${NC} 总内存: ${total_mem}GB (建议至少 4GB)"
    ((failed++))
fi

echo ""

# 7. 检查网络
echo "🌍 网络检查"
echo "---"

if ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${GREEN}✓${NC} 网络连接: 正常"
    ((passed++))
else
    echo -e "${RED}✗${NC} 网络连接: 失败"
    ((failed++))
fi

echo ""

# 8. 检查文件结构
echo "📂 项目文件结构"
echo "---"

[ -d "./docs" ] && echo -e "${GREEN}✓${NC} 文档目录存在" || echo -e "${RED}✗${NC} 文档目录不存在"
[ -f "./go.mod" ] && echo -e "${GREEN}✓${NC} Go 模块文件存在" || echo -e "${RED}✗${NC} Go 模块文件不存在"
[ -f "./Dockerfile" ] && echo -e "${GREEN}✓${NC} Dockerfile 存在" || echo -e "${RED}✗${NC} Dockerfile 不存在"
[ -f "./docker-compose.yml" ] && echo -e "${GREEN}✓${NC} docker-compose.yml 存在" || echo -e "${RED}✗${NC} docker-compose.yml 不存在"
[ -d "./web" ] && echo -e "${GREEN}✓${NC} 前端目录存在" || echo -e "${RED}✗${NC} 前端目录不存在"

echo ""

# 总结
echo "================================"
echo "📊 检查结果"
echo "---"
echo -e "通过: ${GREEN}${passed}${NC} ✓"
echo -e "警告/失败: ${RED}${failed}${NC} ✗"
echo ""

if [ "$failed" -eq 0 ]; then
    echo -e "${GREEN}✅ 环境检查通过，可以开始部署！${NC}"
    echo ""
    echo "后续步骤:"
    echo "1. 配置 docker-compose.yml 中的环境变量"
    echo "2. 配置 Nginx 反向代理"
    echo "3. 获取 SSL 证书: certbot certonly --standalone -d your-domain.com"
    echo "4. 启动服务: docker-compose up -d"
    echo "5. 验证服务: curl https://api.your-domain.com/api/user/self"
    exit 0
else
    echo -e "${RED}❌ 环境检查失败，请修复上述问题后再部署${NC}"
    echo ""
    echo "需要帮助？查看部署文档: DEPLOYMENT-PRODUCTION.md"
    exit 1
fi
