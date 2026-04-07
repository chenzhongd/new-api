#!/bin/bash

# New API Docker 快速部署脚本
# 一键启动 New API、MySQL、Redis、Nginx

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的信息
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 检查依赖
check_requirements() {
    print_info "检查部署环境..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装"
        echo "请访问 https://docs.docker.com/get-docker/ 安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose 未安装"
        echo "请访问 https://docs.docker.com/compose/install/ 安装 Docker Compose"
        exit 1
    fi
    
    print_success "Docker 和 Docker Compose 已安装"
}

# 创建部署目录
setup_directories() {
    print_info "创建部署目录..."
    
    mkdir -p deployment/data/mysql
    mkdir -p deployment/data/redis
    mkdir -p deployment/data/new-api
    mkdir -p deployment/ssl
    mkdir -p deployment/nginx
    
    print_success "目录创建完成"
}

# 生成环境变量文件
generate_env_file() {
    print_info "生成 .env 文件..."
    
    if [ -f "deployment/.env" ]; then
        print_warning ".env 文件已存在，跳过生成"
        return
    fi
    
    # 生成随机密码
    mysql_password=$(openssl rand -base64 32)
    redis_password=$(openssl rand -base64 32)
    
    cat > deployment/.env << EOF
# ===== Database Configuration =====
MYSQL_ROOT_PASSWORD=${mysql_password}
MYSQL_DATABASE=new_api
MYSQL_USER=new_api
MYSQL_PASSWORD=${mysql_password}
MYSQL_HOST=mysql
MYSQL_PORT=3306

# ===== Redis Configuration =====
REDIS_PASSWORD=${redis_password}
REDIS_HOST=redis
REDIS_PORT=6379

# ===== Application Configuration =====
PORT=3000
GIN_MODE=release
LOG_LEVEL=info
ENVIRONMENT=production

# ===== Domain Configuration =====
API_DOMAIN=api.example.com
DOCS_DOMAIN=docs.example.com

# ===== API Keys (Optional) =====
# OPENAI_API_KEY=sk-...
# CLAUDE_API_KEY=sk-...
EOF
    
    print_success ".env 文件已生成"
    echo "  位置: deployment/.env"
    echo "  请修改其中的密码和域名配置"
}

# 生成 docker-compose.yml
generate_docker_compose() {
    print_info "生成 docker-compose.yml..."
    
    if [ -f "deployment/docker-compose.yml" ]; then
        print_warning "docker-compose.yml 已存在，跳过生成"
        return
    fi
    
    cat > deployment/docker-compose.yml << 'EOF'
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: new-api-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      TZ: 'Asia/Shanghai'
    volumes:
      - ./data/mysql:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - new-api-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 5
    profiles:
      - default

  redis:
    image: redis:7-alpine
    container_name: new-api-redis
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - ./data/redis:/data
    ports:
      - "6379:6379"
    networks:
      - new-api-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      timeout: 5s
      retries: 5
    profiles:
      - default

  new-api:
    build:
      context: ..
      dockerfile: Dockerfile
    container_name: new-api-backend
    restart: always
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      MYSQL_HOST: ${MYSQL_HOST}
      MYSQL_PORT: ${MYSQL_PORT}
      MYSQL_DB: ${MYSQL_DATABASE}
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      REDIS_HOST: ${REDIS_HOST}
      REDIS_PORT: ${REDIS_PORT}
      PORT: ${PORT}
      GIN_MODE: ${GIN_MODE}
      LOG_LEVEL: ${LOG_LEVEL}
    ports:
      - "3000:3000"
    volumes:
      - ./data/new-api:/data
    networks:
      - new-api-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/status"]
      timeout: 10s
      retries: 5
    profiles:
      - default

networks:
  new-api-network:
    driver: bridge
EOF
    
    print_success "docker-compose.yml 已生成"
}

# 生成 Nginx 配置
generate_nginx_config() {
    print_info "生成 Nginx 配置..."
    
    if [ -f "deployment/nginx/nginx.conf" ]; then
        print_warning "nginx.conf 已存在，跳过生成"
        return
    fi
    
    cat > deployment/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    keepalive_timeout 65;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/javascript;

    # API Backend
    upstream new_api_backend {
        server new-api:3000;
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    # HTTPS API Server
    server {
        listen 443 ssl http2;
        server_name api.example.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers on;

        location / {
            proxy_pass http://new_api_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # WebSocket support
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
        }
    }
}
EOF
    
    print_success "Nginx 配置已生成"
}

# 启动服务
start_services() {
    print_info "启动 Docker 服务..."
    
    cd deployment
    
    if docker-compose ps | grep -q "new-api-mysql"; then
        print_warning "服务已在运行"
        return
    fi
    
    docker-compose up -d
    
    print_success "Docker 服务启动成功"
    
    # 等待服务启动
    print_info "等待服务启动... (30 秒)"
    sleep 30
    
    # 检查服务状态
    docker-compose ps
}

# 验证部署
verify_deployment() {
    print_info "验证部署..."
    
    # 检查 MySQL
    if docker exec new-api-mysql mysqladmin ping -u new_api --password=${MYSQL_PASSWORD} &> /dev/null; then
        print_success "MySQL: 运行正常"
    else
        print_error "MySQL: 连接失败"
    fi
    
    # 检查 Redis
    if docker exec new-api-redis redis-cli PING | grep -q "PONG"; then
        print_success "Redis: 运行正常"
    else
        print_error "Redis: 连接失败"
    fi
    
    # 检查 New API
    if curl -f http://localhost:3000/api/status &> /dev/null; then
        print_success "New API: 运行正常 (http://localhost:3000)"
    else
        print_warning "New API: 尚未就绪，请稍候..."
    fi
}

# 显示部署信息
show_deployment_info() {
    echo ""
    echo "================================"
    echo -e "${GREEN}✅ 部署完成${NC}"
    echo "================================"
    echo ""
    echo "📌 重要信息:"
    echo "  - 所有服务已在 Docker 中启动"
    echo "  - 数据保存在: ./deployment/data/"
    echo "  - API 地址: http://localhost:3000"
    echo "  - MySQL 端口: 3306"
    echo "  - Redis 端口: 6379"
    echo ""
    echo "📝 下一步:"
    echo "  1. 查看日志: cd deployment && docker-compose logs -f new-api"
    echo "  2. 配置 Nginx: 修改 deployment/nginx/nginx.conf"
    echo "  3. 获取 SSL: certbot certonly --standalone -d api.example.com"
    echo "  4. 配置域名: 修改 deployment/.env 中的 API_DOMAIN"
    echo ""
    echo "🛠️ 常用命令:"
    echo "  - 启动服务: cd deployment && docker-compose up -d"
    echo "  - 停止服务: cd deployment && docker-compose down"
    echo "  - 查看状态: cd deployment && docker-compose ps"
    echo "  - 查看日志: cd deployment && docker-compose logs -f"
    echo "  - 进入 MySQL: docker exec -it new-api-mysql mysql -u new_api -p"
    echo "  - 进入 Redis: docker exec -it new-api-redis redis-cli"
    echo ""
}

# 主程序
main() {
    echo "╔════════════════════════════════════════╗"
    echo "║  New API Docker 快速部署脚本           ║"
    echo "║  Version 1.0.0                         ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    
    check_requirements
    setup_directories
    generate_env_file
    generate_docker_compose
    generate_nginx_config
    start_services
    verify_deployment
    show_deployment_info
}

# 运行主程序
main
