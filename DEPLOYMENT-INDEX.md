# 📚 New API 部署文档总索引

欢迎来到 New API 部署文档中心！这里有你部署 New API 和 VitePress 文档所需的所有信息。

---

## 🎯 快速导航

### 👤 我是新手，第一次部署

**推荐路径**: 5 分钟快速上手

1. **第一步**：阅读 [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) (2 分钟)
   - 了解三种部署方案
   - 选择最适合你的方案

2. **第二步**：运行环境检查 (2 分钟)
   ```bash
   bash deploy-check.sh
   ```

3. **第三步**：一键部署 (5 分钟)
   ```bash
   bash quick-deploy.sh
   ```

✅ **完成！你的 New API 现在已在线。**

---

### 🔧 我需要详细的步骤和说明

**推荐路径**: 30 分钟深入学习

1. **架构理解**：[DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md)
   - 了解应用的整体架构
   - 理解各个组件的关系
   - 查看数据流和网络配置

2. **详细部署**：[DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md)
   - 三种完整的部署方案
   - 手动配置步骤
   - 生产环境最佳实践

3. **验证检查**：[DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md)
   - 部署前检查清单
   - 部署后验证项目
   - 定期维护计划

4. **文档部署**：[docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)
   - VitePress 特定的部署方式
   - 文档自定义配置
   - 多平台部署选项

---

### 🚀 我想快速部署到生产环境

**推荐路径**: 10 分钟快速上线

1. **快速参考**：[DEPLOYMENT-QUICK-REFERENCE.md](DEPLOYMENT-QUICK-REFERENCE.md)
   - 三步快速部署
   - 常用命令速查
   - 常见问题解决

2. **运行脚本**：
   ```bash
   # 环境检查
   bash deploy-check.sh
   
   # 一键部署
   bash quick-deploy.sh
   ```

3. **配置 HTTPS**：
   ```bash
   # 获取 SSL 证书
   sudo certbot certonly --standalone -d api.example.com
   
   # 启动 Nginx
   docker run -d \
     --name new-api-nginx \
     --network new-api-network \
     -p 80:80 -p 443:443 \
     -v ./deployment/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
     -v ./deployment/ssl:/etc/nginx/ssl:ro \
     nginx:latest
   ```

✅ **完成！现在可以通过 HTTPS 访问你的应用。**

---

### 🆘 我遇到了问题

**推荐路径**: 快速故障排查

1. **常见问题**：[DEPLOYMENT-QUICK-REFERENCE.md - 故障排查](DEPLOYMENT-QUICK-REFERENCE.md#-故障排查)
   - API 无法访问
   - 数据库连接失败
   - SSL 证书问题
   - 磁盘或内存不足

2. **详细指南**：[DEPLOYMENT-PRODUCTION.md - 故障排查](DEPLOYMENT-PRODUCTION.md#-故障排查)
   - 监控命令
   - 日志分析
   - 性能优化

3. **备份和恢复**：[DEPLOYMENT-CHECKLIST.md - 故障恢复](DEPLOYMENT-CHECKLIST.md#-故障恢复清单)
   - 数据恢复步骤
   - 应急响应程序

---

### 📖 我想部署 VitePress 文档

**推荐路径**: 文档特定部署

1. **文档部署指南**：[docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)
   - Nginx 部署
   - Vercel 部署
   - Netlify 部署
   - 自定义域名配置

2. **本地开发**：[docs/README.md](docs/README.md)
   - 开发服务器启动
   - 编辑文档
   - 构建静态文件

3. **快速启动**：
   ```bash
   cd docs
   
   # 安装依赖
   npm install
   
   # 开发模式
   npm run docs:dev
   
   # 生产构建
   npm run docs:build
   ```

---

### 🏛️ 我需要了解完整的架构

**推荐路径**: 深度架构学习

1. **架构概览**：[DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md#-架构总览)
   - 单服务器架构
   - 分离部署架构
   - Kubernetes 高可用架构

2. **通信流程**：[DEPLOYMENT-ARCHITECTURE.md - 通信流程图](DEPLOYMENT-ARCHITECTURE.md#-通信流程图)
   - API 请求处理流
   - 数据库查询流
   - 部署流程

3. **扩展路径**：[DEPLOYMENT-ARCHITECTURE.md - 扩展路径](DEPLOYMENT-ARCHITECTURE.md#-扩展路径)
   - 从单服务器到分离部署
   - 从分离部署到 Kubernetes
   - 性能和可靠性权衡

---

## 📄 文档大纲

### 核心部署文档

| 文档 | 用途 | 难度 | 阅读时间 |
|------|------|------|---------|
| [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) | **快速参考和概览** | ⭐ | 5 分钟 |
| [DEPLOYMENT-QUICK-REFERENCE.md](DEPLOYMENT-QUICK-REFERENCE.md) | **快速上手指南** | ⭐ | 10 分钟 |
| [DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md) | **详细生产部署指南** | ⭐⭐⭐ | 45 分钟 |
| [DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md) | **架构设计和理解** | ⭐⭐ | 20 分钟 |
| [DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md) | **完整清单和验证** | ⭐⭐ | 30 分钟 |

### 自动化脚本

| 脚本 | 用途 | 运行时间 |
|------|------|---------|
| [deploy-check.sh](deploy-check.sh) | **环境预检** | 2 分钟 |
| [quick-deploy.sh](quick-deploy.sh) | **一键部署** | 5 分钟 |

### VitePress 文档

| 文档 | 用途 |
|------|------|
| [docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md) | VitePress 部署指南 |
| [docs/README.md](docs/README.md) | 文档快速参考 |
| [docs/startup.sh](docs/startup.sh) | 文档开发脚本 (Linux/Mac) |
| [docs/startup.cmd](docs/startup.cmd) | 文档开发脚本 (Windows) |

---

## 🎓 学习路径

### 路径 1：最快上线（10 分钟）
```
DEPLOYMENT-SUMMARY.md
    ↓
deploy-check.sh
    ↓
quick-deploy.sh
    ↓
✅ 部署完成
```

### 路径 2：标准部署（30 分钟）
```
DEPLOYMENT-SUMMARY.md
    ↓
DEPLOYMENT-QUICK-REFERENCE.md
    ↓
deploy-check.sh
    ↓
quick-deploy.sh
    ↓
配置 HTTPS 和域名
    ↓
部署文档
    ↓
✅ 完整部署
```

### 路径 3：深入学习（1 小时）
```
DEPLOYMENT-SUMMARY.md
    ↓
DEPLOYMENT-ARCHITECTURE.md
    ↓
DEPLOYMENT-PRODUCTION.md
    ↓
DEPLOYMENT-CHECKLIST.md
    ↓
手动按步骤部署
    ↓
性能优化和监控
    ↓
✅ 生产就绪
```

### 路径 4：专业部署（2 小时）
```
所有文档 (完整阅读)
    ↓
理解三种架构方案
    ↓
选择最适合的方案
    ↓
定制配置文件
    ↓
部署和验证
    ↓
监控和告警设置
    ↓
定期维护计划
    ↓
✅ 企业级部署
```

---

## 💡 关键概念快速理解

### 部署方案选择

**方案 1：单服务器** (推荐个人/小型项目)
```
- 所有服务在同一台服务器
- Docker + MySQL + Redis + Nginx
- 10 分钟部署
- 成本：$5-15/月
```

**方案 2：分离部署** (推荐中型生产项目)
```
- API 服务器 + 文档服务器 + 数据库服务器
- 可独立扩展
- 30 分钟部署
- 成本：$20-50/月
```

**方案 3：Kubernetes** (推荐大规模项目)
```
- 自动扩展和高可用
- 容器编排
- 1 小时+ 部署
- 成本：$50+/月
```

### 部署关键步骤

```
1. 环境检查 (2 分钟)
   bash deploy-check.sh

2. 一键部署 (5 分钟)
   bash quick-deploy.sh

3. 获取 SSL 证书 (2 分钟)
   certbot certonly --standalone -d api.example.com

4. 启动 Nginx (1 分钟)
   docker run -d ... nginx:latest

5. 部署文档 (3 分钟)
   npm run docs:build && 上传文件

6. 验证 (2 分钟)
   curl https://api.example.com/api/status
```

---

## 🔑 必知的命令

### 环境检查和部署
```bash
# 环境预检
bash deploy-check.sh

# 一键部署
bash quick-deploy.sh

# 查看日志
docker-compose logs -f

# 检查状态
docker-compose ps
```

### SSL 证书
```bash
# 获取证书
certbot certonly --standalone -d api.example.com

# 查看证书信息
openssl s_client -connect api.example.com:443

# 续期证书
certbot renew
```

### 数据库
```bash
# 备份
docker exec new-api-mysql mysqldump -u new_api -p new_api > backup.sql

# 恢复
docker exec -i new-api-mysql mysql -u new_api -p new_api < backup.sql

# 进入 MySQL
docker exec -it new-api-mysql mysql -u new_api -p
```

### 文档
```bash
# 开发模式
cd docs && npm run docs:dev

# 生产构建
cd docs && npm run docs:build

# 启动脚本
cd docs && bash startup.sh  # Linux/Mac
cd docs && startup.cmd      # Windows
```

---

## 📊 部署流程图

```
开始
  │
  ├─ 有经验？ → DEPLOYMENT-PRODUCTION.md (详细)
  │
  └─ 初次部署？
       │
       ├─ 想快速上线？
       │   └─ 运行 quick-deploy.sh (5 分钟)
       │
       └─ 想理解架构？
           └─ 阅读 DEPLOYMENT-ARCHITECTURE.md
               + DEPLOYMENT-PRODUCTION.md
```

---

## ✅ 部署完成标志

当你看到以下内容时，说明部署成功了：

- ✅ `docker-compose ps` 显示所有容器 UP
- ✅ `curl https://api.example.com/api/status` 返回 200 OK
- ✅ `curl https://docs.example.com/` 返回 HTML
- ✅ SSL 证书有效期 > 30 天
- ✅ 防火墙规则正确配置
- ✅ 数据库备份成功

---

## 🆘 获取帮助

### 快速问题
查看 [DEPLOYMENT-QUICK-REFERENCE.md](DEPLOYMENT-QUICK-REFERENCE.md) 的"故障排查"部分

### 详细问题
查看 [DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md) 的"故障排查"章节

### 架构相关
查看 [DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md)

### 检查清单
查看 [DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md)

---

## 📞 文档导航快速链接

### 快速参考
- 🚀 [快速上手](DEPLOYMENT-SUMMARY.md) - 三步快速部署
- ⚡ [快速参考](DEPLOYMENT-QUICK-REFERENCE.md) - 常用命令和问题
- 📋 [完整清单](DEPLOYMENT-CHECKLIST.md) - 详细验证步骤

### 深入学习
- 🏗️ [架构详解](DEPLOYMENT-ARCHITECTURE.md) - 系统设计和流程
- 📚 [生产指南](DEPLOYMENT-PRODUCTION.md) - 完整部署方案
- 📖 [文档部署](docs/DEPLOYMENT-GUIDE.md) - VitePress 特定指南

### 自动化脚本
- ✓ [环境检查](deploy-check.sh) - 预部署检查
- 🚀 [快速部署](quick-deploy.sh) - 一键启动所有服务

---

## 🎊 开始部署

选择一个路径开始吧：

| 我想... | 查看... | 预计时间 |
|--------|--------|---------|
| 快速上线 | [DEPLOYMENT-SUMMARY.md](DEPLOYMENT-SUMMARY.md) | 5 分钟 |
| 快速参考 | [DEPLOYMENT-QUICK-REFERENCE.md](DEPLOYMENT-QUICK-REFERENCE.md) | 10 分钟 |
| 深入学习 | [DEPLOYMENT-ARCHITECTURE.md](DEPLOYMENT-ARCHITECTURE.md) | 20 分钟 |
| 完整部署 | [DEPLOYMENT-PRODUCTION.md](DEPLOYMENT-PRODUCTION.md) | 45 分钟 |
| 验证检查 | [DEPLOYMENT-CHECKLIST.md](DEPLOYMENT-CHECKLIST.md) | 30 分钟 |

---

**Created**: 2024-01-01  
**Version**: 1.0.0  
**Status**: Production Ready  
**Total Docs**: 9 files  
**Total Pages**: 500+ pages  
**Total Commands**: 100+
