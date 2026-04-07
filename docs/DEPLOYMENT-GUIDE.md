# VitePress 文档部署指南

## 本地开发

### 1. 安装依赖

```bash
cd docs
npm install
# 或使用 bun
bun install
```

### 2. 启动开发服务器

```bash
npm run docs:dev
# 或使用 bun
bun run docs:dev
```

访问 `http://localhost:5173`（或根据提示的端口）

## 本地构建

### 1. 构建静态文件

```bash
npm run docs:build
# 或使用 bun
bun run docs:build
```

输出目录：`docs/.vitepress/dist`

### 2. 本地预览

```bash
npm run docs:preview
```

访问 `http://localhost:4173`

## 云服务器部署

### 部署到云服务器

#### 方案 1：直接上传构建结果

1. **本地构建：**
   ```bash
   npm run docs:build
   ```

2. **上传到服务器：**
   ```bash
   scp -r docs/.vitepress/dist/* user@your-server:/path/to/docs
   ```

3. **配置 Nginx**（见下方）

#### 方案 2：使用 CI/CD

**GitHub Actions 示例：**

在项目根目录创建 `.github/workflows/deploy-docs.yml`：

```yaml
name: Deploy Documentation

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install dependencies
        working-directory: ./docs
        run: npm install
      
      - name: Build docs
        working-directory: ./docs
        run: npm run docs:build
      
      - name: Deploy to server
        env:
          DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
          DEPLOY_HOST: ${{ secrets.DEPLOY_HOST }}
          DEPLOY_USER: ${{ secrets.DEPLOY_USER }}
          DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
        run: |
          mkdir -p ~/.ssh
          echo "$DEPLOY_KEY" > ~/.ssh/deploy_key
          chmod 600 ~/.ssh/deploy_key
          ssh-keyscan -H $DEPLOY_HOST >> ~/.ssh/known_hosts
          rsync -avz --delete -e "ssh -i ~/.ssh/deploy_key" \
            ./docs/.vitepress/dist/ \
            $DEPLOY_USER@$DEPLOY_HOST:$DEPLOY_PATH
```

### Nginx 配置

#### 基础配置

```nginx
server {
    listen 80;
    server_name docs.example.com;

    root /path/to/docs/.vitepress/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # 启用压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    
    # 缓存配置
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### HTTPS 配置（使用 Let's Encrypt）

```nginx
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

    root /path/to/docs/.vitepress/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # 启用压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
    
    # 缓存配置
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### 子路径配置

如果文档在子路径 `/docs`：

1. **更新 config.js：**
   ```javascript
   export default {
     base: '/docs/',
     // ...
   }
   ```

2. **重新构建：**
   ```bash
   npm run docs:build
   ```

3. **Nginx 配置：**
   ```nginx
   server {
       listen 80;
       server_name api.example.com;

       root /path/to/website;

       location /docs/ {
           try_files $uri $uri/ /docs/index.html;
       }
   }
   ```

### Docker 部署

**Dockerfile：**

```dockerfile
# 构建阶段
FROM node:18-alpine AS builder
WORKDIR /app
COPY docs/package*.json ./
RUN npm install
COPY docs/ .
RUN npm run docs:build

# 运行阶段
FROM nginx:alpine
COPY --from=builder /app/.vitepress/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf：**

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

**构建和运行：**

```bash
docker build -t new-api-docs:latest .
docker run -p 80:80 new-api-docs:latest
```

### Apache 配置

```apache
<VirtualHost *:80>
    ServerName docs.example.com
    DocumentRoot /path/to/docs/.vitepress/dist

    <Directory /path/to/docs/.vitepress/dist>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # SPA 路由处理
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteBase /
            RewriteRule ^index\.html$ - [L]
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule . /index.html [L]
        </IfModule>
    </Directory>

    # 启用压缩
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/plain
        AddOutputFilterByType DEFLATE text/html
        AddOutputFilterByType DEFLATE text/xml
        AddOutputFilterByType DEFLATE text/css
        AddOutputFilterByType DEFLATE text/javascript
        AddOutputFilterByType DEFLATE application/xml
        AddOutputFilterByType DEFLATE application/xhtml+xml
        AddOutputFilterByType DEFLATE application/rss+xml
        AddOutputFilterByType DEFLATE application/javascript
        AddOutputFilterByType DEFLATE application/x-javascript
    </IfModule>

    # 缓存配置
    <FilesMatch "\.(js|css|png|jpg|jpeg|gif|ico|svg)$">
        Header set Cache-Control "max-age=31536000, public"
    </FilesMatch>
</VirtualHost>
```

## CDN 加速

### Cloudflare 配置

1. 添加域名到 Cloudflare
2. 更新 DNS 指向你的服务器
3. 在 Cloudflare 中启用以下功能：
   - ✅ Caching
   - ✅ Minify
   - ✅ Rocket Loader
   - ✅ Gzip Compression

### 其他 CDN 选项

- **Vercel**：支持 VitePress 一键部署
- **Netlify**：同样支持 VitePress
- **阿里云 CDN**：国内加速
- **七牛云**：国内加速
- **又拍云**：国内加速

## 部署检查清单

- [ ] 本地构建成功，无错误
- [ ] `.vitepress/dist` 目录存在且包含文件
- [ ] 服务器配置正确（Nginx/Apache）
- [ ] HTTPS 证书有效
- [ ] 域名解析正确
- [ ] 访问 URL 可正常打开
- [ ] 搜索功能工作正常
- [ ] 所有链接都可点击
- [ ] 移动端显示正常
- [ ] 响应时间在 2s 以内

## 常见问题

### 部署后 404 错误

**原因：** SPA 路由配置不正确

**解决：** 在 Nginx 中添加 `try_files` 或在 Apache 中启用 mod_rewrite

### 样式没有加载

**原因：** base 路径配置错误

**解决：** 检查 config.js 中的 `base` 配置是否与部署路径一致

### 文件不更新

**原因：** 浏览器缓存

**解决：**
```bash
# 清除浏览器缓存
# 或在 Nginx 中减少缓存时间
```

### 性能优化建议

1. **启用压缩** - 在 Nginx/Apache 中启用 Gzip
2. **设置缓存** - 为静态文件设置长期缓存
3. **使用 CDN** - 加速全球访问
4. **监控性能** - 使用 Lighthouse 检测
5. **定期更新** - 保持依赖最新

## 维护

### 更新文档

```bash
# 编辑文档文件
vim docs/guide/index.md

# 本地测试
npm run docs:dev

# 构建和部署
npm run docs:build
scp -r docs/.vitepress/dist/* user@server:/path/to/docs
```

### 监控

使用以下工具监控文档服务：
- **Uptime Robot** - 监控可用性
- **New Relic** - 性能监控
- **Sentry** - 错误追踪
- **Google Analytics** - 访问统计

---

需要帮助？查看 [VitePress 官方部署文档](https://vitepress.dev/guide/deployment)
