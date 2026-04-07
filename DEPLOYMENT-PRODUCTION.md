# 🚀 New API 完整部署方案

本文档涵盖了如何将 **New API 后端** 和 **VitePress 文档** 部署到生产环境。

---

## 📋 部署架构概览

```
┌─────────────────────────────────────────────────────────┐
│                     用户浏览器                          │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────────┐        ┌──────▼──────────────┐
│   docs.example.com │        │  api.example.com    │
│   (VitePress 文档)  │        │  (New API 后端)     │
│                    │        │                     │
│  Nginx/静态文件    │        │  Docker/Go 应用     │
└────────────────────┘        └─────────────────────┘
         │                             │
         │                             │
    ┌────▼─────────────────────────────▼────┐
    │         Redis (缓存/会话)               │
    └────────────────────────────────────────┘
             │
    ┌────────▼────────────┐
    │  MySQL/PostgreSQL   │
    │   (数据库)           │
    └─────────────────────┘
```

---

## 🎯 三种部署方案

### 方案 1：单服务器部署（推荐入门）
✅ 成本低  
✅ 配置简单  
⚠️ 高负载时需扩容

### 方案 2：分离部署（推荐生产）
✅ 独立扩展  
✅ 更好的性能  
✅ 便于维护  
⚠️ 配置复杂

### 方案 3：Kubernetes 部署（推荐大规模）
✅ 自动扩展  
✅ 自愈能力  
✅ 灰度发布  
⚠️ 学习曲线陡

---

# 方案 1：单服务器部署（推荐入门）

## 📦 前置要求

```bash
# Ubuntu 20.04 LTS 为例

# 1. 更新系统
sudo apt update && sudo apt upgrade -y

# 2. 安装 Docker 和 Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
docker --version

# 3. 安装 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

## 🐳 使用 Docker Compose 部署

### 第1步：准备文件

在服务器上创建部署目录：

```bash
mkdir -p /opt/new-api
cd /opt/new-api
```

### 第2步：创建 docker-compose.yml

```yaml
version: '3.8'

services:
  # MySQL 数据库
  mysql:
    image: mysql:8.0
    container_name: new-api-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: your_root_password
      MYSQL_DATABASE: new_api
      MYSQL_USER: new_api
      MYSQL_PASSWORD: your_db_password
      TZ: 'Asia/Shanghai'
    volumes:
      - ./data/mysql:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    networks:
      - new-api-network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 5s
      retries: 5

  # Redis 缓存
  redis:
    image: redis:7-alpine
    container_name: new-api-redis
    restart: always
    volumes:
      - ./data/redis:/data
    ports:
      - "6379:6379"
    networks:
      - new-api-network
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      timeout: 5s
      retries: 5

  # New API 后端
  new-api:
    image: your-registry/new-api:latest
    # 或使用本地构建
    # build:
    #   context: .
    #   dockerfile: Dockerfile
    container_name: new-api-backend
    restart: always
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    environment:
      # 数据库配置
      MYSQL_HOST: mysql
      MYSQL_PORT: 3306
      MYSQL_DB: new_api
      MYSQL_USER: new_api
      MYSQL_PASSWORD: your_db_password
      
      # Redis 配置
      REDIS_HOST: redis
      REDIS_PORT: 6379
      
      # 应用配置
      PORT: 3000
      LOG_LEVEL: info
      
      # 其他配置
      GIN_MODE: release
      ENVIRONMENT: production
    ports:
      - "3000:3000"
    volumes:
      - ./data/new-api:/data
    networks:
      - new-api-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/api/user/self"]
      timeout: 5s
      retries: 5

  # Nginx 反向代理
  nginx:
    image: nginx:latest
    container_name: new-api-nginx
    restart: always
    depends_on:
      - new-api
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./docs/dist:/usr/share/nginx/html/docs:ro
    networks:
      - new-api-network

networks:
  new-api-network:
    driver: bridge
```

### 第3步：创建 nginx.conf

```nginx
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
    gzip_types text/plain text/css application/json application/javascript;

    # API 后端
    upstream new_api_backend {
        server new-api:3000;
    }

    server {
        listen 80;
        server_name api.example.com;
        
        # 自动跳转到 HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.example.com;

        # SSL 证书配置
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # API 代理
        location / {
            proxy_pass http://new_api_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket 支持
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;
        }
    }

    server {
        listen 443 ssl http2;
        server_name docs.example.com;

        # SSL 证书配置
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers HIGH:!aNULL:!MD5;

        # 文档静态文件
        root /usr/share/nginx/html;
        
        location / {
            # VitePress 前端路由配置
            try_files $uri $uri/ /docs/index.html;
            expires 30d;
            add_header Cache-Control "public, immutable";
        }

        # 禁止访问敏感文件
        location ~ /\.ht {
            deny all;
        }
    }

    server {
        listen 443 ssl http2;
        server_name example.com www.example.com;

        # SSL 证书配置
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # 重定向到 docs
        return 301 https://docs.example.com$request_uri;
    }

    server {
        listen 80;
        server_name docs.example.com example.com www.example.com;
        return 301 https://$server_name$request_uri;
    }
}
```

### 第4步：准备数据库初始化脚本

创建 `init.sql`：

```sql
-- 创建必要的表
-- 通常 Go 应用会通过 GORM 自动创建表
-- 这里只需要确保数据库存在即可

CREATE DATABASE IF NOT EXISTS new_api;
USE new_api;

-- 表会由应用自动创建
-- 如果需要预加载数据，在这里添加
```

### 第5步：准备 SSL 证书

```bash
# 使用 Let's Encrypt 生成免费证书
sudo apt install certbot python3-certbot-nginx -y

# 为 api.example.com 和 docs.example.com 生成证书
sudo certbot certonly --standalone \
  -d api.example.com \
  -d docs.example.com

# 证书路径：/etc/letsencrypt/live/api.example.com/

# 复制证书到部署目录
mkdir -p /opt/new-api/ssl
sudo cp /etc/letsencrypt/live/api.example.com/fullchain.pem /opt/new-api/ssl/cert.pem
sudo cp /etc/letsencrypt/live/api.example.com/privkey.pem /opt/new-api/ssl/key.pem
sudo chown $USER:$USER /opt/new-api/ssl/*
```

### 第6步：构建和部署 VitePress 文档

```bash
# 进入文档目录
cd /opt/new-api/docs

# 安装依赖
npm install

# 构建静态文件
npm run docs:build

# 输出在 .vitepress/dist/ 中
# docker-compose.yml 会自动挂载这个目录
```

### 第7步：启动服务

```bash
cd /opt/new-api

# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f new-api

# 检查服务状态
docker-compose ps
```

### 第8步：验证部署

```bash
# 检查 API
curl -X GET https://api.example.com/api/user/self \
  -H "Authorization: Bearer your_token"

# 检查文档
curl -X GET https://docs.example.com/
```

---

# 方案 2：分离部署（推荐生产）

将 New API 后端和文档分别部署在不同的服务器上。

## 架构

```
┌──────────────────────┐         ┌──────────────────────┐
│  文档服务器          │         │  应用服务器          │
│  (Ubuntu 20.04)      │         │  (Ubuntu 20.04)      │
│                      │         │                      │
│  ├─ Nginx            │         │  ├─ Docker           │
│  ├─ VitePress        │         │  ├─ New API          │
│  └─ SSL 证书         │         │  └─ Redis            │
└──────────────────────┘         └──────────────────────┘
         │                                  │
         │              ┌──────────────────┘
         │              │
         └──────────────┼──────────────────┐
                        │                   │
                  ┌─────▼─────┐      ┌──────▼──────┐
                  │  MySQL     │      │  文件存储   │
                  │  (shared)  │      │  (S3/NAS)   │
                  └────────────┘      └─────────────┘
```

## 部署步骤

### 应用服务器部署

```bash
# 1. 安装依赖
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
docker-compose

# 2. 创建应用目录
mkdir -p /opt/new-api
cd /opt/new-api

# 3. 创建 docker-compose.yml (仅包含后端)
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: new-api-redis
    restart: always
    volumes:
      - ./data/redis:/data
    ports:
      - "6379:6379"
    networks:
      - new-api-network

  new-api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: new-api-backend
    restart: always
    depends_on:
      - redis
    environment:
      MYSQL_HOST: db.example.com  # 指向数据库服务器
      MYSQL_PORT: 3306
      MYSQL_DB: new_api
      MYSQL_USER: new_api
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
      REDIS_HOST: redis
      REDIS_PORT: 6379
      PORT: 3000
      GIN_MODE: release
    ports:
      - "3000:3000"
    volumes:
      - ./data:/data
    networks:
      - new-api-network

networks:
  new-api-network:
    driver: bridge
EOF

# 4. 创建 Nginx 反向代理配置
cat > nginx.conf << 'EOF'
user nginx;
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    upstream new_api_backend {
        server new-api:3000;
    }

    server {
        listen 80;
        server_name api.example.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.example.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        location / {
            proxy_pass http://new_api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# 5. 启动服务
docker-compose up -d
```

### 文档服务器部署

```bash
# 1. 安装 Nginx
sudo apt install nginx -y

# 2. 构建 VitePress 文档
cd /path/to/new-api/docs
npm install
npm run docs:build

# 3. 配置 Nginx
sudo tee /etc/nginx/sites-available/docs.example.com > /dev/null << 'EOF'
server {
    listen 80;
    server_name docs.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name docs.example.com;

    ssl_certificate /etc/letsencrypt/live/docs.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/docs.example.com/privkey.pem;

    root /var/www/docs;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# 4. 启用站点
sudo ln -s /etc/nginx/sites-available/docs.example.com /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default 2>/dev/null || true

# 5. 复制文档
sudo mkdir -p /var/www/docs
sudo cp -r .vitepress/dist/* /var/www/docs/
sudo chown -R www-data:www-data /var/www/docs

# 6. 获取 SSL 证书
sudo certbot certonly --standalone -d docs.example.com

# 7. 重启 Nginx
sudo systemctl restart nginx
```

### 共享数据库部署

```bash
# 在专用数据库服务器上（或云数据库）

# 1. 安装 MySQL
sudo apt install mysql-server -y

# 2. 创建数据库和用户
sudo mysql << 'EOF'
CREATE DATABASE IF NOT EXISTS new_api;
CREATE USER 'new_api'@'%' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON new_api.* TO 'new_api'@'%';
FLUSH PRIVILEGES;
EOF

# 3. 配置远程访问
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
# 将 bind-address = 127.0.0.1 改为 bind-address = 0.0.0.0

# 4. 重启 MySQL
sudo systemctl restart mysql
```

---

# 方案 3：使用云平台部署

## Vercel 部署（文档）

Vercel 是 VitePress 的完美宿主，提供免费托管。

```bash
# 1. 安装 Vercel CLI
npm install -g vercel

# 2. 进入文档目录
cd docs

# 3. 首次部署
vercel

# 4. 自动化部署
# 将仓库连接到 GitHub，Vercel 会自动部署每次提交

# 配置 vercel.json
cat > vercel.json << 'EOF'
{
  "buildCommand": "npm run docs:build",
  "outputDirectory": ".vitepress/dist"
}
EOF
```

## Docker Hub 部署（后端）

```bash
# 1. 在 Docker Hub 创建账户并创建仓库

# 2. 构建镜像
docker build -t your-username/new-api:latest .

# 3. 登录 Docker Hub
docker login

# 4. 推送镜像
docker push your-username/new-api:latest

# 5. 在 docker-compose.yml 中使用
# image: your-username/new-api:latest
```

## AWS 部署（后端）

```bash
# 1. 使用 ECS Fargate
# 2. 使用 RDS 作为数据库
# 3. 使用 ElastiCache 作为 Redis
# 4. 使用 ALB 作为负载均衡

# 详见 AWS 文档
```

---

# 📝 环境变量配置

## .env 文件示例

```bash
# 数据库
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DB=new_api
MYSQL_USER=new_api
MYSQL_PASSWORD=your_secure_password

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# 应用
PORT=3000
GIN_MODE=release
LOG_LEVEL=info

# API Keys
OPENAI_API_KEY=sk-...
CLAUDE_API_KEY=sk-...

# 其他配置
ENVIRONMENT=production
VERSION=1.0.0
```

---

# 🔒 安全检查清单

部署前必须完成：

- [ ] 更改所有默认密码
- [ ] 启用 HTTPS/SSL
- [ ] 配置防火墙规则
- [ ] 设置数据库备份
- [ ] 配置 Redis 密码
- [ ] 启用日志监控
- [ ] 设置 rate limiting
- [ ] 配置 CORS 策略
- [ ] 启用数据库加密
- [ ] 定期更新依赖

---

# 📊 监控和维护

## 日志查看

```bash
# Docker Compose
docker-compose logs -f new-api

# 文件日志
tail -f /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

## 数据库备份

```bash
# MySQL 自动备份脚本
#!/bin/bash
BACKUP_DIR="/opt/new-api/backups"
MYSQL_USER="new_api"
MYSQL_PASSWORD="your_password"
DATE=$(date +%Y%m%d_%H%M%S)

mysqldump -u $MYSQL_USER -p$MYSQL_PASSWORD new_api > $BACKUP_DIR/new_api_$DATE.sql

# 每天 2 点执行
# 2 * * * * /opt/new-api/backup.sh
```

## 更新应用

```bash
# 更新镜像
docker-compose pull
docker-compose up -d

# 查看更新日志
docker-compose logs -f new-api
```

---

# 🆘 故障排查

## 常见问题

| 问题 | 解决方案 |
|------|--------|
| API 无法访问 | 检查 Nginx 配置、防火墙、DNS |
| 文档加载缓慢 | 检查静态文件缓存、CDN 配置 |
| 数据库连接失败 | 检查网络、密码、授权 |
| 内存不足 | 增加服务器资源或优化应用 |
| SSL 证书过期 | 续期证书：`certbot renew` |

## 监控命令

```bash
# 检查服务状态
docker-compose ps

# 检查磁盘空间
df -h

# 检查内存使用
free -h

# 检查 CPU 使用
top

# 检查网络连接
netstat -an | grep 3000
```

---

# 🎯 性能优化

## Nginx 优化

```nginx
# 启用缓存
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=my_cache:10m;
proxy_cache my_cache;
proxy_cache_valid 200 10m;

# 启用 gzip
gzip on;
gzip_types text/plain text/css application/json;

# 启用 keepalive
keepalive_timeout 65;
```

## 应用优化

在 `main.go` 中配置：

```go
// 启用 gzip 中间件
app.Use(gzip.Gzip(gzip.DefaultCompression))

// 配置 CORS
app.Use(cors.Default())

// 设置最大连接数
http.MaxHeaderBytes = 1 << 20
```

---

# ✅ 部署检查清单

```
前置准备
  [ ] 购买域名
  [ ] 购买服务器
  [ ] 配置 DNS
  [ ] 申请 SSL 证书

系统配置
  [ ] 安装 Docker
  [ ] 安装 Docker Compose
  [ ] 配置防火墙
  [ ] 配置系统资源

应用部署
  [ ] 克隆代码仓库
  [ ] 创建 docker-compose.yml
  [ ] 配置环境变量
  [ ] 启动 Docker 容器

数据库初始化
  [ ] 创建数据库
  [ ] 创建用户和授权
  [ ] 导入初始数据
  [ ] 验证连接

文档部署
  [ ] 构建 VitePress
  [ ] 配置 Nginx
  [ ] 上传静态文件
  [ ] 配置 SSL

验证和监控
  [ ] 测试 API 端点
  [ ] 测试文档访问
  [ ] 检查日志
  [ ] 配置备份
  [ ] 设置监控告警

上线
  [ ] 更新 DNS
  [ ] 发送通知
  [ ] 监控流量
  [ ] 准备回滚方案
```

---

## 🎓 推荐阅读

- [Docker 官方文档](https://docs.docker.com/)
- [Nginx 反向代理指南](https://nginx.org/en/docs/)
- [VitePress 部署指南](https://vitepress.dev/guide/deploy)
- [MySQL 8.0 最佳实践](https://dev.mysql.com/)
- [Let's Encrypt SSL](https://letsencrypt.org/)

---

**Last Updated**: 2024-01-01  
**Status**: Production Ready  
**Version**: 1.0.0
