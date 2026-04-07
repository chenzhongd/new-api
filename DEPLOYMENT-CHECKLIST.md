# ✅ New API 部署完整清单

## 📋 部署前准备清单

### 1️⃣ 获取资源

- [ ] **服务器**
  - [ ] 购买云服务器（AWS EC2、DigitalOcean、Linode、阿里云 ECS 等）
  - [ ] 或自建服务器（裸金属、VPS）
  - [ ] 推荐配置：4GB 内存，2 核 CPU，50GB 磁盘

- [ ] **域名**
  - [ ] 购买域名（GoDaddy、Namecheap、阿里云等）
  - [ ] 配置 DNS 解析
  - [ ] 添加 A 记录指向服务器 IP
    - `api.example.com` → `192.168.1.100`
    - `docs.example.com` → `192.168.1.100` (或其他文档服务器)

- [ ] **SSL 证书**
  - [ ] 申请免费证书（Let's Encrypt）
    ```bash
    certbot certonly --standalone -d api.example.com -d docs.example.com
    ```
  - [ ] 或购买商业证书

- [ ] **备份存储**
  - [ ] 申请云存储 (AWS S3、阿里云 OSS 等)
  - [ ] 用于数据库和日志备份

---

### 2️⃣ 系统准备

- [ ] **服务器连接**
  - [ ] 通过 SSH 成功连接到服务器
    ```bash
    ssh root@your-server-ip
    ```
  - [ ] 配置 SSH 密钥认证（禁用密码登录）
    ```bash
    ssh-copy-id -i ~/.ssh/id_rsa.pub root@your-server-ip
    ```

- [ ] **系统更新**
  - [ ] 更新系统包
    ```bash
    sudo apt update && sudo apt upgrade -y
    ```
  - [ ] 安装基础工具
    ```bash
    sudo apt install -y curl wget git build-essential
    ```

- [ ] **防火墙配置**
  - [ ] 启用 UFW 防火墙
    ```bash
    sudo ufw enable
    ```
  - [ ] 开放必要端口
    ```bash
    sudo ufw allow 22/tcp   # SSH
    sudo ufw allow 80/tcp   # HTTP
    sudo ufw allow 443/tcp  # HTTPS
    ```
  - [ ] 验证规则
    ```bash
    sudo ufw status
    ```

- [ ] **系统时间**
  - [ ] 设置正确的时区
    ```bash
    sudo timedatectl set-timezone Asia/Shanghai
    ```
  - [ ] 启用 NTP 同步
    ```bash
    sudo systemctl enable systemd-timesyncd
    ```

---

### 3️⃣ 环境检查

- [ ] **运行检查脚本**
  ```bash
  bash deploy-check.sh
  ```

- [ ] **检查结果应显示**
  - [x] Docker 已安装
  - [x] Docker Compose 已安装
  - [x] 磁盘空间 > 10GB
  - [x] 内存 >= 4GB
  - [x] 网络连接正常
  - [x] 所有必要端口可用

---

## 🚀 部署过程清单

### 4️⃣ 一键部署

- [ ] **运行快速部署脚本**
  ```bash
  bash quick-deploy.sh
  ```

- [ ] **脚本执行验证**
  - [ ] 目录已创建
    ```bash
    ls -la deployment/
    ```
  - [ ] .env 文件已生成
    ```bash
    cat deployment/.env
    ```
  - [ ] docker-compose.yml 已生成
    ```bash
    cat deployment/docker-compose.yml
    ```
  - [ ] 所有容器已启动
    ```bash
    docker-compose -f deployment/docker-compose.yml ps
    ```

---

### 5️⃣ 配置数据库

- [ ] **初始化 MySQL**
  ```bash
  # 进入 MySQL 容器
  docker exec -it new-api-mysql mysql -u new_api -p
  
  # 输入密码（在 .env 中）
  
  # 验证数据库存在
  SHOW DATABASES;
  ```

- [ ] **验证数据库连接**
  ```bash
  docker exec new-api-mysql mysqladmin ping -u new_api -p
  ```

- [ ] **验证 Redis 连接**
  ```bash
  docker exec new-api-redis redis-cli PING
  # 应返回 PONG
  ```

---

### 6️⃣ 配置 HTTPS

- [ ] **创建 SSL 目录**
  ```bash
  mkdir -p deployment/ssl
  ```

- [ ] **获取 Let's Encrypt 证书**
  ```bash
  # 关闭 Nginx（如果已启动）
  sudo systemctl stop nginx 2>/dev/null || true
  
  # 获取证书
  sudo certbot certonly --standalone \
    -d api.example.com \
    -d docs.example.com
  
  # 证书位置: /etc/letsencrypt/live/api.example.com/
  ```

- [ ] **复制证书到部署目录**
  ```bash
  sudo cp /etc/letsencrypt/live/api.example.com/fullchain.pem \
    deployment/ssl/cert.pem
  
  sudo cp /etc/letsencrypt/live/api.example.com/privkey.pem \
    deployment/ssl/key.pem
  
  # 修改权限
  sudo chown $USER:$USER deployment/ssl/*
  ```

- [ ] **验证证书**
  ```bash
  ls -la deployment/ssl/
  ```

---

### 7️⃣ 启动 Nginx 反向代理

- [ ] **选择部署方式**

  **方式 1: Docker 容器 (推荐)**
  ```bash
  docker run -d \
    --name new-api-nginx \
    --network new-api-network \
    -p 80:80 -p 443:443 \
    -v $(pwd)/deployment/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v $(pwd)/deployment/ssl:/etc/nginx/ssl:ro \
    -v $(pwd)/docs/dist:/usr/share/nginx/html/docs:ro \
    nginx:latest
  ```

  **方式 2: 主机 Nginx (另选)**
  ```bash
  sudo apt install nginx -y
  sudo cp deployment/nginx/nginx.conf /etc/nginx/nginx.conf
  sudo systemctl restart nginx
  ```

- [ ] **验证 Nginx 运行**
  ```bash
  # Docker 方式
  docker ps | grep nginx
  
  # 主机方式
  systemctl status nginx
  ```

---

### 8️⃣ 配置文档

- [ ] **构建 VitePress 文档**
  ```bash
  cd docs
  npm install
  npm run docs:build
  cd -
  ```

- [ ] **验证构建**
  ```bash
  ls -la docs/.vitepress/dist/
  ```

- [ ] **测试文档访问（本地）**
  ```bash
  cd docs
  npm run docs:dev
  # 访问 http://localhost:5173
  ```

---

## ✨ 部署后验证清单

### 9️⃣ 验证服务状态

- [ ] **检查所有容器**
  ```bash
  docker-compose -f deployment/docker-compose.yml ps
  # 应显示: mysql, redis, new-api 都是 Up 状态
  ```

- [ ] **检查日志**
  ```bash
  docker-compose -f deployment/docker-compose.yml logs --tail=20
  ```

- [ ] **测试 API (本地)**
  ```bash
  curl -X GET http://localhost:3000/api/status
  # 应返回 200 OK
  ```

- [ ] **测试数据库连接**
  ```bash
  docker exec new-api curl -s http://localhost:3000/api/status
  # 应显示包含 database 连接信息
  ```

---

### 🔟 验证 HTTPS 连接

- [ ] **测试 HTTPS API (外部)**
  ```bash
  curl -X GET https://api.example.com/api/status
  # 应返回 200 OK 且证书有效
  ```

- [ ] **验证证书信息**
  ```bash
  openssl s_client -connect api.example.com:443 -brief
  # 应显示证书有效期和发行者
  ```

- [ ] **测试文档访问**
  ```bash
  curl -X GET https://docs.example.com/
  # 应返回 HTML 页面
  ```

- [ ] **检查 SSL 等级**
  访问 https://www.ssllabs.com/ssltest/
  - 输入: `api.example.com`
  - 结果应为: A 或 A+

---

### 1️⃣1️⃣ 验证应用功能

- [ ] **创建测试用户**
  ```bash
  curl -X POST https://api.example.com/api/users/register \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@example.com",
      "password": "TestPassword123!"
    }'
  ```

- [ ] **测试登录**
  ```bash
  curl -X POST https://api.example.com/api/users/login \
    -H "Content-Type: application/json" \
    -d '{
      "email": "test@example.com",
      "password": "TestPassword123!"
    }'
  ```

- [ ] **测试 API 令牌**
  ```bash
  # 获取令牌后测试
  TOKEN="your_token_here"
  curl -X GET https://api.example.com/api/user/self \
    -H "Authorization: Bearer $TOKEN"
  ```

- [ ] **测试文档功能**
  - [ ] 首页加载正常
  - [ ] 搜索功能工作
  - [ ] 所有链接可访问
  - [ ] 暗黑模式切换正常
  - [ ] 响应式设计适配移动端

---

## 🔒 安全性检查清单

### 1️⃣2️⃣ 数据安全

- [ ] **更改默认密码**
  ```bash
  # 修改 deployment/.env
  MYSQL_PASSWORD=your-strong-password
  REDIS_PASSWORD=your-strong-password
  
  # 重启服务
  docker-compose down
  docker-compose up -d
  ```

- [ ] **配置数据库备份**
  ```bash
  # 创建备份脚本
  cat > backup.sh << 'EOF'
  #!/bin/bash
  docker exec new-api-mysql mysqldump -u new_api -p${MYSQL_PASSWORD} new_api > backup_$(date +%Y%m%d).sql
  EOF
  
  chmod +x backup.sh
  
  # 添加到 crontab (每天凌晨 2 点)
  crontab -e
  # 添加: 0 2 * * * /path/to/backup.sh
  ```

- [ ] **配置日志备份**
  ```bash
  # 启用 Docker 日志轮转
  cat > /etc/docker/daemon.json << 'EOF'
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

### 1️⃣3️⃣ 网络安全

- [ ] **验证防火墙规则**
  ```bash
  sudo ufw status
  # 应仅显示 22, 80, 443 开放
  ```

- [ ] **禁用不必要的服务**
  ```bash
  # 禁用 Telnet
  sudo systemctl disable telnetd 2>/dev/null || true
  
  # 禁用 FTP
  sudo systemctl disable vsftpd 2>/dev/null || true
  ```

- [ ] **配置 SSH 安全**
  ```bash
  # 编辑 SSH 配置
  sudo nano /etc/ssh/sshd_config
  
  # 设置:
  # Port 22
  # PermitRootLogin no
  # PasswordAuthentication no
  # PubkeyAuthentication yes
  
  # 重启 SSH
  sudo systemctl restart sshd
  ```

- [ ] **启用 IP 白名单（可选）**
  ```bash
  # 仅允许特定 IP 访问 SSH
  sudo ufw limit from 203.0.113.0 to any port 22 proto tcp
  ```

---

### 1️⃣4️⃣ 应用安全

- [ ] **验证 CORS 配置**
  ```bash
  # 在 New API 配置中检查 CORS 设置
  # 应仅允许信任的域名
  ```

- [ ] **启用速率限制**
  ```bash
  # Nginx 已配置速率限制
  # 验证: grep rate_limit deployment/nginx/nginx.conf
  ```

- [ ] **验证 JWT 令牌**
  ```bash
  # 检查令牌过期时间
  # 应使用强加密算法 (RS256 或 HS256)
  ```

- [ ] **启用审计日志**
  ```bash
  # 所有管理操作应被记录
  docker logs new-api | grep -i "admin\|delete\|update"
  ```

---

## 📈 性能优化清单

### 1️⃣5️⃣ 数据库优化

- [ ] **创建索引**
  ```bash
  docker exec -it new-api-mysql mysql -u new_api -p new_api << 'EOF'
  CREATE INDEX idx_user_email ON users(email);
  CREATE INDEX idx_token_key ON tokens(token_key);
  CREATE INDEX idx_log_user ON logs(user_id);
  EOF
  ```

- [ ] **启用查询缓存**
  ```bash
  docker exec new-api-mysql mysql -u new_api -p -e \
    "SET GLOBAL query_cache_type = ON;"
  ```

- [ ] **优化 MySQL 配置**
  修改 docker-compose.yml:
  ```yaml
  mysql:
    environment:
      MYSQL_INNODB_BUFFER_POOL_SIZE: 2G
      MYSQL_MAX_CONNECTIONS: 1000
  ```

---

### 1️⃣6️⃣ 缓存优化

- [ ] **配置 Redis 持久化**
  ```bash
  docker exec new-api-redis redis-cli CONFIG SET appendonly yes
  ```

- [ ] **设置合理的过期策略**
  ```bash
  docker exec new-api-redis redis-cli \
    CONFIG SET maxmemory-policy allkeys-lru
  ```

- [ ] **监控 Redis 内存**
  ```bash
  docker exec new-api-redis redis-cli INFO memory
  ```

---

### 1️⃣7️⃣ Web 性能优化

- [ ] **启用 Gzip 压缩**
  - 已在 nginx.conf 中配置
  - 验证: `curl -I -H "Accept-Encoding: gzip" https://api.example.com`

- [ ] **配置缓存头**
  - 已在 nginx.conf 中配置
  - 验证: `curl -I https://api.example.com | grep Cache-Control`

- [ ] **启用 HTTP/2**
  - 已在 nginx.conf 中配置
  - 验证: `curl -I --http2 https://api.example.com`

- [ ] **使用 CDN（可选）**
  ```bash
  # 配置 Cloudflare、Akamai 或国内 CDN
  # 更新 DNS CNAME 记录
  ```

---

## 📊 监控和告警清单

### 1️⃣8️⃣ 系统监控

- [ ] **安装监控工具**
  ```bash
  # 选项 1: Prometheus + Grafana
  docker run -d \
    --name prometheus \
    -p 9090:9090 \
    -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
  
  # 选项 2: Datadog / New Relic
  # 按官方文档配置
  ```

- [ ] **配置告警规则**
  ```bash
  # 告警条件:
  # - CPU 使用率 > 80%
  # - 内存使用率 > 85%
  # - 磁盘使用率 > 90%
  # - API 响应时间 > 1s
  # - 数据库连接失败
  ```

- [ ] **设置告警通知**
  ```bash
  # 选择告警方式:
  # - 邮件
  # - 短信
  # - Slack
  # - 钉钉
  # - WeChat
  ```

---

### 1️⃣9️⃣ 日志管理

- [ ] **启用日志聚合**
  ```bash
  # 选项 1: ELK Stack
  # - Elasticsearch (日志存储)
  # - Logstash (日志处理)
  # - Kibana (日志可视化)
  
  # 选项 2: Loki + Grafana
  # 选项 3: Datadog / Splunk
  ```

- [ ] **配置日志轮转**
  ```bash
  # 已在 /etc/docker/daemon.json 中配置
  # 验证: cat /etc/docker/daemon.json | grep log
  ```

- [ ] **设置日志保留政策**
  ```bash
  # 保留 30 天的日志
  find /var/lib/docker/containers -name "*.log" -mtime +30 -delete
  ```

---

## 🔄 定期维护清单

### 📅 每日维护

- [ ] **检查服务状态**
  ```bash
  docker-compose ps
  ```

- [ ] **检查错误日志**
  ```bash
  docker-compose logs | grep -i error
  ```

- [ ] **检查磁盘空间**
  ```bash
  df -h | grep -v tmpfs
  ```

---

### 📆 每周维护

- [ ] **更新系统补丁**
  ```bash
  sudo apt update && sudo apt upgrade -y
  ```

- [ ] **数据库备份验证**
  ```bash
  # 检查备份文件大小是否合理
  ls -lah backup_*.sql
  ```

- [ ] **清理日志文件**
  ```bash
  # 删除 7 天前的日志
  find /var/lib/docker/containers -name "*.log" -mtime +7 -delete
  ```

- [ ] **性能报告**
  - [ ] 检查 CPU 平均使用率
  - [ ] 检查内存平均使用率
  - [ ] 检查 API 响应时间
  - [ ] 检查错误率

---

### 📋 每月维护

- [ ] **更新依赖包**
  ```bash
  # 更新 Docker 镜像
  docker-compose pull
  docker-compose up -d
  
  # 更新文档
  cd docs && npm update && npm run build
  ```

- [ ] **安全审计**
  ```bash
  # 检查系统补丁
  sudo apt list --upgradable
  
  # 检查 Docker 镜像安全
  docker scan new-api:latest
  
  # 检查依赖漏洞
  npm audit
  ```

- [ ] **性能优化**
  - [ ] 分析慢查询日志
  - [ ] 优化数据库索引
  - [ ] 清理过期缓存

---

### 📊 每季度维护

- [ ] **容量规划**
  - [ ] 分析流量趋势
  - [ ] 预测磁盘需求
  - [ ] 评估升级需求

- [ ] **架构评审**
  - [ ] 性能瓶颈分析
  - [ ] 可靠性评估
  - [ ] 扩展能力评估

- [ ] **灾备演练**
  - [ ] 数据恢复测试
  - [ ] 故障转移测试
  - [ ] 更新灾备计划

---

## 🚨 故障恢复清单

### 紧急情况

- [ ] **应用崩溃**
  ```bash
  # 1. 检查日志
  docker logs new-api --tail=50
  
  # 2. 重启应用
  docker restart new-api
  
  # 3. 如果问题持续，恢复备份
  docker-compose down
  docker-compose up -d
  ```

- [ ] **数据库故障**
  ```bash
  # 1. 检查 MySQL 状态
  docker logs new-api-mysql --tail=50
  
  # 2. 检查磁盘空间
  df -h
  
  # 3. 恢复数据库备份
  docker exec -i new-api-mysql mysql -u new_api -p < backup.sql
  ```

- [ ] **磁盘满**
  ```bash
  # 1. 检查哪个目录占用空间
  du -sh deployment/data/*
  
  # 2. 清理日志或旧备份
  rm -f backup_*.sql
  docker system prune -a
  
  # 3. 扩展磁盘
  # 或购买新的磁盘
  ```

---

## ✅ 最终检查

```
□ 所有容器正常运行
□ API 通过 HTTPS 可访问
□ 文档通过 HTTPS 可访问
□ 数据库备份成功
□ SSL 证书有效期 > 30 天
□ 防火墙规则正确配置
□ 日志监控正常
□ 性能指标在预期范围内
□ 用户可以正常注册、登录、使用 API
□ 文档搜索功能正常
```

---

**部署状态**: ✅ 完成  
**最后检查时间**: _______________  
**检查人**: _______________  
**备注**: _______________

---

**相关文档**:
- [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) - 部署快速参考
- [DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md) - 详细部署指南
- [DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md) - 架构详解
- [docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md) - VitePress 文档部署

---

**Created**: 2024-01-01  
**Version**: 1.0.0  
**Status**: Production Ready
