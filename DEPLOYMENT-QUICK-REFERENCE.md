# 🚀 New API 和 VitePress 部署快速参考

## 三种部署方案对比

| 方案 | 难度 | 成本 | 扩展性 | 维护 | 推荐场景 |
|------|------|------|--------|------|---------|
| **单服务器** | ⭐ | 低 | 受限 | 简单 | 开发/小型项目 |
| **分离部署** | ⭐⭐⭐ | 中 | 好 | 复杂 | 中型生产项目 |
| **Kubernetes** | ⭐⭐⭐⭐⭐ | 高 | 优秀 | 复杂 | 大规模项目 |

---

## 🎯 快速开始（单服务器）

### 1. 前置要求

```bash
# Ubuntu 20.04+ 或 CentOS 8+
# 至少 4GB 内存
# 至少 10GB 磁盘空间
# 公网 IP 和域名

# 登录服务器
ssh root@your-server-ip
```

### 2. 一键部署

```bash
# 在项目根目录执行
bash quick-deploy.sh

# 等待 3-5 分钟，脚本会自动：
# ✅ 检查 Docker 和 Docker Compose
# ✅ 创建部署目录结构
# ✅ 生成环境变量文件 (.env)
# ✅ 生成 docker-compose.yml
# ✅ 启动 MySQL、Redis、New API
# ✅ 验证所有服务是否运行正常
```

### 3. 验证部署

```bash
# 检查服务状态
cd deployment
docker-compose ps

# 测试 API
curl http://localhost:3000/api/status

# 查看日志
docker-compose logs -f new-api
```

### 4. 配置 Nginx 和 HTTPS

```bash
# 方法 1：使用 Nginx Docker 容器（推荐）
docker run -d \
  --name new-api-nginx \
  --network new-api-network \
  -p 80:80 -p 443:443 \
  -v ./deployment/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v ./deployment/ssl:/etc/nginx/ssl:ro \
  nginx:latest

# 方法 2：在主机上安装 Nginx
sudo apt install nginx -y
sudo cp deployment/nginx/nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx

# 方法 3：使用 Caddy（自动 HTTPS）
docker run -d \
  --name caddy \
  --network new-api-network \
  -p 80:80 -p 443:443 \
  -v /path/to/Caddyfile:/etc/caddy/Caddyfile \
  caddy:latest
```

### 5. 获取 SSL 证书

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx -y

# 获取证书
sudo certbot certonly --standalone \
  -d api.example.com \
  -d docs.example.com

# 证书位置: /etc/letsencrypt/live/api.example.com/

# 复制到部署目录
mkdir -p deployment/ssl
sudo cp /etc/letsencrypt/live/api.example.com/fullchain.pem deployment/ssl/cert.pem
sudo cp /etc/letsencrypt/live/api.example.com/privkey.pem deployment/ssl/key.pem
sudo chown $USER:$USER deployment/ssl/*

# 自动续期（每天检查一次）
sudo certbot renew --quiet && systemctl reload nginx
```

### 6. 配置文档

```bash
# 构建 VitePress 文档
cd docs
npm install
npm run docs:build

# 复制到 Nginx
sudo mkdir -p /var/www/docs
sudo cp -r .vitepress/dist/* /var/www/docs/

# 配置 Nginx
sudo nano /etc/nginx/sites-available/docs.example.com

# 添加以下配置:
# server {
#     listen 443 ssl http2;
#     server_name docs.example.com;
#     root /var/www/docs;
#     index index.html;
#     
#     ssl_certificate /etc/letsencrypt/live/docs.example.com/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/docs.example.com/privkey.pem;
#     
#     location / {
#         try_files $uri $uri/ /index.html;
#     }
# }

# 启用站点
sudo ln -s /etc/nginx/sites-available/docs.example.com /etc/nginx/sites-enabled/
sudo systemctl reload nginx
```

---

## 📊 部署检查清单

### 部署前检查
```bash
# 运行预检脚本
bash deploy-check.sh
```

检查项：
- ✅ Docker 已安装
- ✅ Docker Compose 已安装
- ✅ 磁盘空间 > 10GB
- ✅ 内存 >= 4GB
- ✅ 网络连接正常
- ✅ 端口 80, 443, 3000, 3306, 6379 可用

### 部署后检查
```bash
# 1. 检查服务状态
docker-compose ps

# 2. 测试 API
curl -X GET http://localhost:3000/api/status

# 3. 检查日志
docker-compose logs -f

# 4. 检查数据库
docker exec new-api-mysql mysql -u new_api -p -e "SELECT * FROM users LIMIT 1;"

# 5. 检查 Redis
docker exec new-api-redis redis-cli PING

# 6. 测试 HTTPS (配置完毕后)
curl -X GET https://api.example.com/api/status
```

---

## 🌐 常见部署场景

### 场景 1：仅部署 New API 后端

```bash
# 只启动后端服务
cd deployment
docker-compose --profile default up -d mysql redis new-api

# 不需要 Nginx，直接访问 :3000 端口
curl http://localhost:3000/api/status
```

### 场景 2：仅部署文档

```bash
# 只部署文档，使用 Vercel 或 GitHub Pages
cd docs
npm run docs:build

# 推送到 Vercel
vercel --prod

# 或推送到 GitHub Pages
git add . && git commit -m "docs: update" && git push
```

### 场景 3：前后端分离部署

```bash
# 后端服务器（api.example.com）
# 运行本文档的"快速开始"部分

# 文档服务器（docs.example.com）
# 或使用 Vercel/Netlify 自动部署

# 主域名（example.com）
# 配置 DNS 指向文档或后端
```

---

## 📈 性能优化

### 1. 数据库优化

```bash
# 连接到数据库
docker exec -it new-api-mysql mysql -u new_api -p

# 创建索引
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_token_key ON tokens(token_key);

# 清理日志表
DELETE FROM logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### 2. Redis 优化

```bash
# 检查内存使用
docker exec new-api-redis redis-cli INFO memory

# 设置过期策略
docker exec new-api-redis redis-cli CONFIG SET maxmemory-policy allkeys-lru

# 持久化配置
docker exec new-api-redis redis-cli BGSAVE
```

### 3. Nginx 优化

```nginx
# 修改 nginx.conf
worker_connections 2048;        # 增加连接数
keepalive_timeout 120;          # 增加连接超时
client_max_body_size 100m;      # 增加上传限制
proxy_buffer_size 128k;         # 增加缓冲区
```

### 4. 应用优化

```bash
# 在 docker-compose.yml 中增加资源限制
services:
  new-api:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 512M
```

---

## 🔒 安全配置

### 1. 防火墙规则

```bash
# 仅开放必要端口
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable

# 限制特定 IP 访问数据库
sudo ufw allow from 10.0.0.0/8 to any port 3306
```

### 2. 更改默认密码

```bash
# 修改 deployment/.env
MYSQL_PASSWORD=your-strong-password-here
REDIS_PASSWORD=your-strong-password-here

# 重新启动服务
docker-compose down
docker-compose up -d
```

### 3. 启用日志监控

```bash
# 查看实时日志
docker-compose logs -f

# 保存日志到文件
docker-compose logs > deployment/logs/all-$(date +%Y%m%d).log

# 定期清理日志
find deployment/logs -name "*.log" -mtime +30 -delete
```

### 4. 配置备份

```bash
#!/bin/bash
# backup.sh - 每天自动备份

BACKUP_DIR="/opt/new-api/backups"
mkdir -p $BACKUP_DIR

# 备份数据库
docker exec new-api-mysql mysqldump -u new_api -p${MYSQL_PASSWORD} new_api > $BACKUP_DIR/new_api_$(date +%Y%m%d).sql

# 备份 Redis
docker exec new-api-redis redis-cli BGSAVE
docker exec new-api-redis redis-cli --rdb $BACKUP_DIR/redis_$(date +%Y%m%d).rdb

# 保留 30 天的备份
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete
find $BACKUP_DIR -name "*.rdb" -mtime +30 -delete

# 添加到 crontab (每天凌晨 2 点)
# 0 2 * * * /opt/new-api/backup.sh
```

---

## 🆘 故障排查

### 问题 1：无法连接到 API

```bash
# 检查容器是否运行
docker ps

# 查看日志
docker logs new-api

# 检查端口占用
netstat -an | grep 3000

# 重启容器
docker restart new-api
```

### 问题 2：数据库连接失败

```bash
# 检查 MySQL 运行状态
docker exec new-api-mysql mysqladmin ping

# 查看 MySQL 日志
docker logs new-api-mysql

# 检查环境变量
docker exec new-api env | grep MYSQL
```

### 问题 3：内存或磁盘不足

```bash
# 检查磁盘使用
df -h

# 检查内存使用
free -h

# 清理 Docker 缓存
docker system prune -a

# 清理数据库日志
docker exec new-api-mysql mysql -u new_api -p -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 3 DAY);"
```

### 问题 4：SSL 证书过期

```bash
# 续期证书
certbot renew --force-renewal

# 重启 Nginx
systemctl reload nginx
```

---

## 📚 相关文档

| 文档 | 用途 |
|------|------|
| [DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md) | 详细部署指南 |
| [docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md) | VitePress 文档部署 |
| [docs/README.md](docs/README.md) | VitePress 快速参考 |
| [docker-compose.yml](docker-compose.yml) | Docker 配置示例 |

---

## 🎓 推荐资源

- [Docker 官方文档](https://docs.docker.com/)
- [Nginx 配置指南](https://nginx.org/en/docs/)
- [Let's Encrypt 使用指南](https://letsencrypt.org/docs/)
- [MySQL 8.0 文档](https://dev.mysql.com/doc/refman/8.0/en/)
- [Redis 官方文档](https://redis.io/documentation/)

---

## ⏰ 维护计划

### 日常维护（每天）
- ✅ 检查服务状态
- ✅ 查看错误日志
- ✅ 监控资源使用

### 周维护（每周）
- ✅ 更新依赖包
- ✅ 备份数据库
- ✅ 清理过期日志

### 月维护（每月）
- ✅ 更新系统补丁
- ✅ 优化数据库性能
- ✅ 检查 SSL 证书有效期

### 季度维护（每季）
- ✅ 更新应用版本
- ✅ 安全审计
- ✅ 容量规划

---

## 📞 获取帮助

1. **查看日志**：`docker-compose logs -f new-api`
2. **检查文档**：查看 DEPLOYMENT-PRODUCTION.md
3. **运行检查**：`bash deploy-check.sh`
4. **提交问题**：在项目 Issues 中提交问题

---

**Last Updated**: 2024-01-01  
**Version**: 1.0.0  
**Status**: Production Ready
