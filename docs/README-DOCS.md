# New API 快速上手文档

这是基于 VitePress 构建的 New API 快速上手文档，包含用户指南和 API 参考两个主要部分。

## 文档结构

```
docs/
├── index.md                    # 首页
├── guide/                      # 用户指南
│   └── index.md               # 用户指南主页（包含所有指南内容）
├── api/                        # API 参考
│   └── index.md               # API 参考主页（包含所有 API 文档）
├── .vitepress/                # VitePress 配置
│   ├── config.js              # 主配置文件
│   └── config.mts             # TypeScript 配置
└── package.json               # 项目依赖
```

## 快速开始

### 1. 安装依赖

```bash
cd docs
npm install
# 或使用 bun
bun install
```

### 2. 本地开发

```bash
npm run docs:dev
# 或使用 bun
bun run docs:dev
```

然后在浏览器中打开 `http://localhost:5173`（或根据提示的端口）

### 3. 构建生产版本

```bash
npm run docs:build
# 或使用 bun
bun run docs:build
```

生成的静态文件将位于 `docs/.vitepress/dist` 目录中。

### 4. 部署

**本地部署：**
```bash
npm run docs:preview
```

**云服务器部署：**
将 `docs/.vitepress/dist` 目录中的文件上传到服务器，配置 Web 服务器（如 Nginx）指向该目录。

**Nginx 配置示例：**
```nginx
server {
    listen 80;
    server_name api.example.com;

    root /path/to/docs/.vitepress/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

## 文档内容

### 用户指南 (`/guide/`)

完整的用户指南，包含：
- 🚀 快速开始：账户注册、登录、生成 Token
- ✨ 主要功能：令牌管理、模型选择、分组、余额、聊天、操练场
- 🔧 常见操作：API 使用示例、模型切换、OpenAI 库兼容
- 💡 最佳实践：安全建议、成本优化、开发建议
- ❓ 常见问题和故障排查
- 📖 术语表

### API 参考 (`/api/`)

完整的 API 参考文档，包含：
- 🔌 API 介绍和基础信息
- 🔐 身份认证方式
- 👤 用户相关 API（获取信息、更新、分组、模型列表）
- 🤖 模型相关 API（获取模型列表）
- 💬 聊天 API（创建完成、流式响应）
- 🔑 令牌管理 API（生成、列表、删除）
- 💳 账单相关 API（余额、充值、使用日志）
- ❌ 错误处理和常见错误码
- 💻 多语言代码示例（Python、JavaScript、cURL）

## 配置说明

### config.js 主配置

- **title**: 网站标题
- **description**: 网站描述
- **lang**: 语言设置（zh-CN 中文）
- **themeConfig.nav**: 顶部导航菜单
- **themeConfig.sidebar**: 左侧边栏配置
- **themeConfig.footer**: 页脚信息

### 自定义修改

**修改网站标题和描述：**
编辑 `docs/.vitepress/config.js`
```javascript
export default {
  title: 'Your API Name',
  description: 'Your description',
  // ...
}
```

**修改 Logo：**
1. 将 logo 图片放在 `docs/public/logo.png`
2. 在 config.js 中配置：
```javascript
themeConfig: {
  logo: '/logo.png',
}
```

**添加更多页面：**
1. 在 `docs/guide/` 或 `docs/api/` 目录下创建新的 `.md` 文件
2. 在 `config.js` 的 sidebar 配置中添加对应的菜单项

## 功能特性

- ✨ 美观的默认主题
- 📱 完全响应式设计，支持移动设备
- 🔍 全文搜索功能
- 🌙 深色模式支持
- ⚡ 快速加载和构建
- 📦 静态生成，无需服务器端代码
- 🎨 可自定义样式和主题
- 📊 自动生成导航和侧边栏

## 访问文档

### 本地访问
- 开发环境：`http://localhost:5173`
- 生产预览：`npm run docs:preview`

### 云服务器访问
- `https://api.example.com/docs`
- `https://docs.example.com`

根据您的部署配置，使用相应的 URL 访问文档。

## 文档维护

### 添加新的 API 端点文档

在 `docs/api/index.md` 中添加：
```markdown
### 新端点名称

<span class="badge" style="background-color: #49cc90;">POST</span> `/api/endpoint`

端点描述

**请求**
\`\`\`bash
curl -X POST ...
\`\`\`

**响应**
\`\`\`json
{ ... }
\`\`\`
```

### 更新用户指南

在 `docs/guide/index.md` 中相应部分进行编辑。

### 预览更改

使用 `npm run docs:dev` 实时预览所有更改。

## 常见问题

**Q: 如何在已有网站上集成文档？**

A: 将文档部署到子路径：
- Nginx: `location /docs { ... }`
- 配置 base: `export default { base: '/docs/' }`

**Q: 如何添加自定义样式？**

A: 在 `docs/.vitepress/theme/custom.css` 中添加（需自行创建）。

**Q: 文档支持多语言吗？**

A: 支持。在 config.js 中修改 lang，翻译所有 Markdown 文件即可。

**Q: 如何添加搜索功能？**

A: VitePress 默认支持全文搜索，无需额外配置。

## 更多资源

- VitePress 官方文档：https://vitepress.dev/
- 部署指南：https://vitepress.dev/guide/deployment
- 主题配置：https://vitepress.dev/reference/site-config
- Markdown 扩展：https://vitepress.dev/guide/markdown

---

**文档版本**: 1.0.0  
**最后更新**: 2024-01-01  
**维护者**: New API Team
