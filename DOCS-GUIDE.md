# New API VitePress 快速上手文档 - 完整指南

## 📚 文档概览

这是一个基于 **VitePress** 构建的 New API 快速上手文档系统，包含：

### 📖 两个主要部分

1. **用户指南** (`/docs/guide/`)
   - 快速开始和账户设置
   - 主要功能介绍
   - 常见操作和示例
   - 最佳实践和故障排查

2. **API 参考** (`/docs/api/`)
   - API 介绍和基础信息
   - 身份认证详解
   - 所有 API 端点文档
   - 多语言代码示例
   - 错误处理指南

---

## 🚀 快速开始（5分钟）

### 第 1 步：安装依赖

```bash
cd docs
npm install
# 或使用 bun
bun install
```

### 第 2 步：启动开发服务器

```bash
npm run docs:dev
```

打开浏览器访问 `http://localhost:5173`

### 第 3 步：编辑文档

在 `docs/` 目录中编辑 Markdown 文件，刷新浏览器即可看到更改。

### 第 4 步：构建生产版本

```bash
npm run docs:build
```

生成的文件在 `docs/.vitepress/dist/`

---

## 📁 文档结构

```
docs/
├── .vitepress/
│   ├── config.js           # 主配置文件
│   ├── config.mts          # TypeScript 配置
│   └── dist/               # 构建输出目录
├── guide/
│   ├── index.md            # 用户指南主页（所有内容）
│   └── getting-started.md  # 快速开始额外页面
├── api/
│   ├── index.md            # API 参考主页（所有内容）
│   └── authentication.md   # 身份认证详解
├── index.md                # 首页
├── package.json            # 项目依赖
├── .gitignore              # Git 忽略文件
├── README-DOCS.md          # 文档维护说明
└── DEPLOYMENT-GUIDE.md     # 部署指南
```

---

## 🔧 主要文件说明

### config.js - 核心配置

控制网站的标题、导航菜单、侧边栏等：

```javascript
export default {
  title: 'New API',
  description: '...',
  themeConfig: {
    nav: [ /* 导航菜单 */ ],
    sidebar: { /* 侧边栏配置 */ }
  }
}
```

**修改导航：** 编辑 `themeConfig.nav` 数组
**修改菜单：** 编辑 `themeConfig.sidebar` 对象

### 首页 (index.md)

使用 VitePress 的 Home Layout，包含：
- 英雄标题和描述
- 行动按钮
- 功能卡片网格

### 用户指南 (guide/index.md)

完整的用户指南，覆盖：
- ✅ 账户注册和登录
- ✅ Token 生成和管理
- ✅ 模型选择
- ✅ 聊天和操练场
- ✅ 最佳实践
- ✅ 常见问题

### API 参考 (api/index.md)

完整的 API 文档，包含：
- ✅ 身份认证方式
- ✅ 所有 API 端点
- ✅ 请求/响应示例
- ✅ 错误处理
- ✅ 代码示例（Python、JavaScript、cURL）

---

## 📝 编辑和维护

### 添加新页面

1. 在相应目录创建 `.md` 文件
2. 在 `config.js` 的 sidebar 中添加链接
3. 支持子目录：

```javascript
// config.js
{
  text: '新分类',
  items: [
    { text: '新页面', link: '/path/to/page' }
  ]
}
```

### 编辑现有内容

1. 编辑 Markdown 文件
2. 使用开发服务器实时预览
3. 构建后部署

### Markdown 特殊语法

**信息框：**
```markdown
::: info
这是一个信息框
:::

::: warning
这是一个警告框
:::

::: danger
这是一个危险框
:::
```

**代码块：**
```markdown
\`\`\`python
# Python 代码
print("Hello")
\`\`\`
```

**表格：**
```markdown
| 列1 | 列2 |
|-----|-----|
| 内容1 | 内容2 |
```

**链接：**
```markdown
[文字](/path/to/page)
[外部链接](https://example.com)
```

---

## 🌐 部署指南

### 本地部署

```bash
# 开发
npm run docs:dev

# 生产预览
npm run docs:preview
```

### 云服务器部署

**快速部署（使用 Nginx）：**

1. 构建：
   ```bash
   npm run docs:build
   ```

2. 上传到服务器：
   ```bash
   scp -r docs/.vitepress/dist/* user@server:/var/www/docs
   ```

3. 配置 Nginx：
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

### 自动部署（GitHub Actions）

创建 `.github/workflows/deploy.yml` 进行自动部署（详见 DEPLOYMENT-GUIDE.md）

---

## 🎨 自定义

### 修改主题颜色

编辑 CSS 变量（在主题文件或 index.md 中）：

```css
:root {
  --vp-c-brand: #667eea;
  --vp-c-brand-dark: #764ba2;
}
```

### 添加自定义样式

在 `.vitepress/theme/` 中创建 `custom.css`（需自行创建目录）。

### 添加自定义组件

创建 Vue 组件并在 Markdown 中使用。

---

## 📊 文档统计

| 部分 | 页数 | 内容量 |
|------|------|--------|
| 首页 | 1 | 简介 + 功能卡片 |
| 用户指南 | 1+ | 完整指南 + 快速开始 |
| API 参考 | 1+ | 完整 API 文档 + 示例 |
| 部署 | 1 | 部署指南 |
| 维护 | 1 | 维护说明 |
| **总计** | **5+** | **完整覆盖** |

---

## 🔗 访问方式

### 本地开发
```
http://localhost:5173
```

### 部署后
```
https://docs.example.com
https://api.example.com/docs
```

---

## 📚 VitePress 学习资源

- 官方文档：https://vitepress.dev/
- Markdown 指南：https://vitepress.dev/guide/markdown
- 部署指南：https://vitepress.dev/guide/deployment
- 配置参考：https://vitepress.dev/reference/site-config

---

## ✨ 主要特性

- ✅ **美观设计** - 现代化、专业的默认主题
- ✅ **响应式** - 完美适配桌面、平板、手机
- ✅ **全文搜索** - 自动生成搜索索引
- ✅ **暗黑模式** - 智能切换主题
- ✅ **快速加载** - 极致的页面性能
- ✅ **静态生成** - 无需服务器，可部署在任何地方
- ✅ **SEO友好** - 自动生成 sitemap 和 meta 标签
- ✅ **易于维护** - 纯 Markdown 编写，版本控制友好
- ✅ **多语言** - 支持 i18n 国际化
- ✅ **自定义** - 高度可定制的样式和功能

---

## 🆘 常见问题

### Q: 如何在已有网站集成文档？
**A:** 修改 `config.js` 中的 `base` 配置为子路径（如 `/docs/`），然后在 Web 服务器中配置相应的路由。

### Q: 文档支持多语言吗？
**A:** 支持。创建多个语言的 Markdown 文件，配置 `locales` 选项。

### Q: 如何添加自定义页面？
**A:** 创建新的 `.md` 文件，在 `config.js` 中添加导航链接。

### Q: 搜索如何工作？
**A:** VitePress 自动为所有页面生成搜索索引。

### Q: 如何统计访问量？
**A:** 集成 Google Analytics 或其他分析工具。

### Q: 可以离线访问吗？
**A:** 可以。下载 HTML 文件后在本地浏览器打开。

---

## 📞 获取帮助

1. **查看文档**：https://vitepress.dev/
2. **GitHub Issues**：在项目仓库提出问题
3. **社区讨论**：VitePress Discord 社区
4. **官方支持**：联系 VitePress 维护者

---

## 📋 维护清单

定期检查项：

- [ ] 文档内容是否最新
- [ ] API 端点是否有变化
- [ ] 代码示例是否正确
- [ ] 链接是否有效
- [ ] 搜索功能是否正常
- [ ] 移动端显示是否正常
- [ ] 构建是否有错误
- [ ] 部署是否成功

---

## 🎯 下一步

1. ✅ **运行开发服务器** - `npm run docs:dev`
2. ✅ **编辑内容** - 修改 Markdown 文件
3. ✅ **本地测试** - 在浏览器中预览
4. ✅ **构建发布** - `npm run docs:build`
5. ✅ **部署上线** - 上传到服务器
6. ✅ **监控维护** - 定期更新内容

---

**文档版本**: 1.0.0  
**最后更新**: 2024-01-01  
**维护者**: New API Team  
**许可证**: AGPL-3.0
