# New API 快速上手文档

🚀 **基于 VitePress 构建的快速上手文档**

## ⚡ 快速开始（30秒）

### Windows 用户
```bash
cd docs
startup.cmd
```

### Mac/Linux 用户
```bash
cd docs
bash startup.sh
```

### 手动启动（所有平台）
```bash
cd docs
npm install
npm run docs:dev
```

访问 http://localhost:5173

---

## 📚 文档内容

### 📖 用户指南 - `/guide/`
- ✅ 快速开始：账户注册、登录、生成 Token
- ✅ 主要功能：令牌、模型、分组、余额、聊天、操练场
- ✅ 常见操作：API 使用、代码示例
- ✅ 最佳实践：安全、成本优化、开发建议
- ✅ 常见问题和故障排查

### 🔌 API 参考 - `/api/`
- ✅ 身份认证详解
- ✅ 用户、模型、聊天、令牌 API
- ✅ 账单和错误处理
- ✅ 多语言代码示例（Python、JavaScript、cURL）

---

## 🛠️ 可用命令

| 命令 | 说明 |
|------|------|
| `npm run docs:dev` | 启动开发服务器（热更新） |
| `npm run docs:build` | 构建生产版本 |
| `npm run docs:preview` | 预览生产版本 |

---

## 📁 文件结构

```
docs/
├── .vitepress/
│   ├── config.js          # 网站配置（导航、菜单等）
│   └── config.mts         # TypeScript 配置
├── guide/                 # 用户指南
│   ├── index.md           # 完整用户指南
│   └── getting-started.md # 快速开始
├── api/                   # API 参考
│   ├── index.md           # 完整 API 文档
│   └── authentication.md  # 身份认证
├── index.md               # 首页
├── package.json           # 项目依赖
├── startup.sh             # Linux/Mac 快速启动脚本
├── startup.cmd            # Windows 快速启动脚本
└── README.md              # 本文件
```

---

## 🔧 编辑文档

### 修改网站信息
编辑 `.vitepress/config.js`：
```javascript
export default {
  title: 'New API',           // 网站标题
  description: '...',         // 描述
  // ...
}
```

### 添加新页面
1. 在 `guide/` 或 `api/` 目录创建 `.md` 文件
2. 在 `config.js` 的 sidebar 中添加菜单项
3. 刷新浏览器查看

### 编辑内容
1. 编辑 Markdown 文件
2. 开发服务器会自动更新
3. 刷新浏览器看到更改

---

## 🌐 部署

### 本地部署
```bash
npm run docs:dev       # 开发环境
npm run docs:preview   # 生产预览
```

### 云服务器部署
```bash
npm run docs:build
scp -r .vitepress/dist/* user@server:/var/www/docs
```

### Nginx 配置
```nginx
server {
    listen 80;
    server_name docs.example.com;
    root /var/www/docs;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

**更多部署选项见 `DEPLOYMENT-GUIDE.md`**

---

## 📝 内容特点

✨ **设计**
- 📱 完全响应式（桌面、平板、手机）
- 🌙 深色模式支持
- ⚡ 极速加载
- 🔍 全文搜索

📚 **内容**
- ✅ 完整的用户指南
- ✅ 详细的 API 文档
- ✅ 实用的代码示例
- ✅ 最佳实践建议
- ✅ 常见问题解答

---

## 🎨 自定义

### 修改主题色
在 `index.md` 或 CSS 中修改：
```css
--vp-c-brand: #667eea;
--vp-c-brand-dark: #764ba2;
```

### 上传 Logo
1. 将 logo 放在 `public/logo.png`
2. 在 `config.js` 中引用：
```javascript
themeConfig: {
  logo: '/logo.png'
}
```

### 修改导航菜单
编辑 `config.js` 中的 `themeConfig.nav` 数组。

---

## 📊 统计信息

| 项目 | 数量 |
|------|------|
| 文档页面 | 5+ |
| API 端点 | 15+ |
| 代码示例 | 20+ |
| 支持语言 | Python、JavaScript、cURL |
| 功能模块 | 6 个 |

---

## ❓ 常见问题

**Q: 如何本地开发？**
```bash
npm run docs:dev
```

**Q: 如何在服务器上部署？**
```bash
npm run docs:build
# 上传 .vitepress/dist 到服务器
```

**Q: 如何添加新页面？**
创建 `.md` 文件，在 config.js 中添加菜单项。

**Q: 支持多语言吗？**
支持。创建多语言文件并配置 locales。

**Q: 可以离线使用吗？**
可以。下载 HTML 文件后在浏览器打开。

---

## 📚 更多资源

- **VitePress 官方**：https://vitepress.dev/
- **部署指南**：查看 `DEPLOYMENT-GUIDE.md`
- **维护指南**：查看 `README-DOCS.md`

---

## 🚀 下一步

1. ✅ **安装依赖**：`npm install`
2. ✅ **启动开发**：`npm run docs:dev`
3. ✅ **编辑内容**：修改 Markdown 文件
4. ✅ **构建发布**：`npm run docs:build`
5. ✅ **部署上线**：上传到服务器

---

## 💡 提示

- 使用 `startup.sh`（Mac/Linux）或 `startup.cmd`（Windows）快速启动
- 开发时使用 `npm run docs:dev` 查看实时更新
- 在 config.js 中配置网站信息
- 检查 `package.json` 查看所有可用命令

---

**版本**: 1.0.0  
**创建**: 2024-01-01  
**维护者**: New API Team  
**许可证**: AGPL-3.0

🎉 开始使用吧！
