# 📚 New API 部署指南 - 完整总结

## 文档导航

你已经拥有了完整的部署方案文档。根据你的需求选择合适的文档：

```
新手入门？             → DEPLOYMENT-QUICK-REFERENCE.md（快速参考）
详细部署方案？         → DEPLOYMENT-PRODUCTION.md（完整指南）
一键快速部署？         → bash quick-deploy.sh（自动化脚本）
部署前环境检查？       → bash deploy-check.sh（预检脚本）
VitePress 文档部署？   → docs/DEPLOYMENT-GUIDE.md（文档特定指南）
```

---

## 🎯 三步快速部署

### 第 1 步：环境检查（2 分钟）

```bash
# 检查服务器是否满足要求
bash deploy-check.sh
```

**需要满足的条件：**
- Docker 和 Docker Compose 已安装
- 磁盘空间 > 10GB
- 内存 >= 4GB
- 端口 80、443、3000、3306、6379 可用

### 第 2 步：一键部署（5 分钟）

```bash
# 自动化部署所有服务
bash quick-deploy.sh

# 脚本会自动：
# 1. 创建部署目录
# 2. 生成环境变量文件
# 3. 创建 Docker Compose 配置
# 4. 启动 MySQL、Redis、New API
# 5. 验证所有服务
```

### 第 3 步：配置域名和 HTTPS（3 分钟）

```bash
# 1. 获取 SSL 证书
sudo certbot certonly --standalone -d api.example.com -d docs.example.com

# 2. 启动 Nginx
docker run -d \
  --name new-api-nginx \
  --network new-api-network \
  -p 80:80 -p 443:443 \
  -v ./deployment/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v ./deployment/ssl:/etc/nginx/ssl:ro \
  nginx:latest

# 3. 验证部署
curl https://api.example.com/api/status
curl https://docs.example.com/
```

**完成！** ✅ 你的 New API 现在已可在互联网上访问。

---

## 📂 部署文件概览

### 自动生成的文件

部署后你会得到以下目录结构：

```
deployment/
├── docker-compose.yml      # Docker 容器编排配置
├── .env                    # 环境变量（自动生成，含密码）
├── nginx/
│   └── nginx.conf          # Nginx 反向代理配置
├── ssl/
│   ├── cert.pem            # SSL 证书（需手动获取）
│   └── key.pem             # 私钥（需手动获取）
└── data/
    ├── mysql/              # MySQL 数据文件
    ├── redis/              # Redis 数据文件
    └── new-api/            # 应用数据文件
```

### 文档文件

```
new-api/
├── DEPLOYMENT-QUICK-REFERENCE.md   # 快速参考（这个！）
├── DEPLOYMENT-PRODUCTION.md        # 详细生产部署指南
├── deploy-check.sh                 # 预检脚本
├── quick-deploy.sh                 # 一键部署脚本
├── docker-compose.yml              # Docker 配置示例
├── Dockerfile                      # 构建镜像配置
├── docs/
│   ├── DEPLOYMENT-GUIDE.md         # VitePress 部署指南
│   ├── README.md                   # 文档快速参考
│   └── startup.sh                  # 文档开发启动脚本
└── ...
```

---

## 🚀 部署方案选择

### 方案 A：单服务器部署（推荐开发/小型项目）

✅ **优点：**
- 成本最低
- 配置最简单
- 快速上线

❌ **缺点：**
- 高负载时性能受限
- 单点故障风险
- 难以独立扩展

**部署时间：** 10 分钟  
**推荐规模：** < 1000 用户

**步骤：**
```bash
# 1. 运行检查
bash deploy-check.sh

# 2. 一键部署
bash quick-deploy.sh

# 3. 配置 HTTPS
# (参考"第 3 步"部分)

# 完成！
```

---

### 方案 B：分离部署（推荐生产环境）

✅ **优点：**
- 后端和前端独立部署
- 可分别扩展
- 易于维护

❌ **缺点：**
- 配置复杂
- 需要多个服务器
- 网络延迟

**部署时间：** 30 分钟  
**推荐规模：** 1000-100000 用户

**架构：**
```
应用服务器 (api.example.com)
  ├─ Docker (New API)
  ├─ MySQL
  └─ Redis

文档服务器 (docs.example.com)
  ├─ Nginx
  └─ VitePress

数据库服务器 (可选)
  └─ MySQL (共享)
```

**部署步骤：**

1. **应用服务器：**
```bash
# 运行快速部署脚本
bash quick-deploy.sh

# 仅启动后端
cd deployment
docker-compose up -d new-api redis
```

2. **文档服务器：**
```bash
cd docs
npm install
npm run docs:build

# 使用 Vercel（推荐）
npm i -g vercel
vercel --prod

# 或使用 Nginx
sudo apt install nginx
sudo cp -r .vitepress/dist/* /var/www/html/
```

3. **配置域名：**
```
api.example.com  → 应用服务器 IP
docs.example.com → 文档服务器 IP 或 Vercel
```

---

### 方案 C：Kubernetes 部署（推荐大规模）

✅ **优点：**
- 自动扩展
- 自愈能力
- 灰度发布
- 高可用

❌ **缺点：**
- 学习曲线陡峭
- 配置复杂
- 成本高

**部署时间：** 1 小时+  
**推荐规模：** > 100000 用户

**部署步骤：** 参考 DEPLOYMENT-PRODUCTION.md 的 Kubernetes 部分

---

## 🔧 常用命令速查表

### Docker 管理

```bash
# 查看所有运行的容器
docker-compose ps

# 查看特定服务的日志
docker-compose logs -f new-api

# 进入容器执行命令
docker exec -it new-api-mysql mysql -u new_api -p

# 停止所有服务
docker-compose down

# 重启服务
docker-compose restart new-api

# 更新镜像并重启
docker-compose pull && docker-compose up -d
```

### 数据库管理

```bash
# 备份数据库
docker exec new-api-mysql mysqldump -u new_api -p new_api > backup.sql

# 恢复数据库
docker exec -i new-api-mysql mysql -u new_api -p new_api < backup.sql

# 查看数据库大小
docker exec new-api-mysql mysql -u new_api -p -e "SELECT table_schema as database, ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as size_mb FROM information_schema.tables GROUP BY table_schema;"
```

### 监控和日志

```bash
# 查看服务器资源使用
docker stats

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看实时系统日志
tail -f /var/log/syslog

# 查看 Nginx 错误日志
tail -f /var/log/nginx/error.log
```

### 证书管理

```bash
# 查看证书有效期
sudo certbot certificates

# 续期证书
sudo certbot renew

# 强制续期
sudo certbot renew --force-renewal
```

---

## 📈 部署后的优化

### 1. 性能优化

```bash
# 增加 Nginx 工作进程
# 修改 nginx.conf: worker_processes auto;

# 启用 gzip 压缩
# location / { gzip on; }

# 增加 MySQL 缓冲区
# 修改 my.cnf: innodb_buffer_pool_size = 2G
```

### 2. 安全加固

```bash
# 启用防火墙
sudo ufw enable

# 仅开放必要的端口
sudo ufw allow 22,80,443/tcp

# 更新系统
sudo apt update && sudo apt upgrade -y

# 定期更新 Docker 镜像
docker-compose pull && docker-compose up -d
```

### 3. 监控告警

```bash
# 安装监控工具
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus

# 查看容器资源使用
docker stats --no-stream

# 设置日志轮转
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
```

---

## 🆘 常见问题

### Q1: 部署后无法访问 API

**解决方案：**
```bash
# 1. 检查容器是否运行
docker-compose ps

# 2. 检查防火墙规则
sudo ufw status

# 3. 检查 DNS 解析
nslookup api.example.com

# 4. 测试本地连接
curl http://localhost:3000/api/status

# 5. 查看日志找出问题
docker-compose logs -f
```

### Q2: SSL 证书获取失败

**解决方案：**
```bash
# 检查端口是否被占用
netstat -an | grep ":80 "
netstat -an | grep ":443 "

# 如果被占用，关闭占用的服务
sudo systemctl stop nginx

# 重新申请证书
sudo certbot certonly --standalone -d api.example.com

# 启动服务
docker-compose up -d
```

### Q3: 数据库连接超时

**解决方案：**
```bash
# 检查 MySQL 是否运行
docker-compose logs mysql

# 检查网络连接
docker network ls
docker network inspect new-api-network

# 重启 MySQL
docker-compose restart mysql

# 等待 MySQL 完全启动（可能需要 30 秒）
sleep 30
docker-compose ps
```

### Q4: 磁盘空间不足

**解决方案：**
```bash
# 检查磁盘使用
df -h

# 清理 Docker
docker system prune -a

# 清理数据库日志
docker exec new-api-mysql mysql -u new_api -p -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

# 删除旧的日志文件
find ./deployment/data -name "*.log" -mtime +30 -delete
```

---

## ✅ 部署完成检查清单

在任何地方访问应用前，确保完成以下检查：

```
基础设施
  [ ] 服务器已启动，SSH 可连接
  [ ] 域名已购买并配置 DNS
  [ ] 防火墙已配置（开放 22, 80, 443 端口）
  
环境准备
  [ ] Docker 和 Docker Compose 已安装
  [ ] 磁盘空间 > 10GB
  [ ] 内存 >= 4GB
  [ ] 网络连接正常
  
部署
  [ ] 环境检查通过 (bash deploy-check.sh)
  [ ] 一键部署完成 (bash quick-deploy.sh)
  [ ] 所有容器运行正常 (docker-compose ps)
  [ ] 数据库初始化成功
  
HTTPS 配置
  [ ] SSL 证书已获取
  [ ] Nginx 已配置
  [ ] HTTP 自动重定向到 HTTPS
  
验证
  [ ] API 可通过 HTTPS 访问
  [ ] 文档可通过 HTTPS 访问
  [ ] 登录功能正常
  [ ] 数据库连接正常
  
监控
  [ ] 日志输出正常
  [ ] 备份脚本已配置
  [ ] 监控告警已设置
  [ ] 性能指标正常
```

---

## 📞 获取更多帮助

| 需求 | 查看文档 |
|------|--------|
| 快速上手 | DEPLOYMENT-QUICK-REFERENCE.md (本文件) |
| 详细步骤 | DEPLOYMENT-PRODUCTION.md |
| VitePress 部署 | docs/DEPLOYMENT-GUIDE.md |
| 故障排查 | DEPLOYMENT-PRODUCTION.md 的"故障排查"章节 |
| 环境检查 | bash deploy-check.sh |
| 自动部署 | bash quick-deploy.sh |

---

## 🎓 推荐阅读顺序

1. **你在这里** 📍 DEPLOYMENT-QUICK-REFERENCE.md（概览）
2. 运行 `bash deploy-check.sh`（环境检查）
3. 运行 `bash quick-deploy.sh`（自动部署）
4. DEPLOYMENT-PRODUCTION.md（深入学习）
5. docs/DEPLOYMENT-GUIDE.md（文档特定配置）

---

## 🎊 恭喜！

你现在有了完整的部署方案：

✅ 快速参考文档（本文件）  
✅ 详细生产指南（DEPLOYMENT-PRODUCTION.md）  
✅ 自动化部署脚本（quick-deploy.sh）  
✅ 环境检查脚本（deploy-check.sh）  
✅ 文档部署指南（docs/DEPLOYMENT-GUIDE.md）  

选择一个部署方案，按照步骤操作，**10 分钟内** 即可让 New API 和文档上线！

---

**Created**: 2024-01-01  
**Version**: 1.0.0  
**Status**: Production Ready  
**Difficulty**: ⭐ Easy with scripts, ⭐⭐⭐ Manual
