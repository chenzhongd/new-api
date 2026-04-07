# 快速开始

## 1. 账户注册与登录

### 注册步骤

1. **访问平台**：打开浏览器访问 New API 平台首页
2. **点击注册**：在首页找到注册按钮
3. **填写信息**：输入邮箱地址和密码
4. **邮箱验证**：检查邮箱收件箱，点击验证链接
5. **账户激活**：验证完成后自动激活

### 登录方式

- 📧 邮箱和密码登录
- 🔗 GitHub OAuth 登录
- 🎮 Discord OAuth 登录
- 🇨🇳 微信登录
- 🌐 其他 OIDC 提供商

---

## 2. 生成 API Token

### 获取 Token

1. 登录平台后，点击**头部用户菜单**
2. 选择**"个人中心"**或**"账户设置"**
3. 找到**"令牌管理"**或**"API Keys"**部分
4. 点击**"生成新令牌"**
5. 输入令牌名称（如 "my-app"）
6. 选择过期时间或永不过期
7. 点击**"生成"**
8. **复制显示的 Token**（仅显示一次！）

### 保管 Token

```bash
# 保存到环境变量
export NEW_API_TOKEN="sk-..."

# 或在 .env 文件中
NEW_API_TOKEN=sk-...
```

::: warning 重要
Token 是您账户的访问凭证，请妥善保管，不要分享给他人。
:::

---

## 3. 选择模型

### 查看可用模型

1. 进入**"控制台"**
2. 找到**"数据看板"**或**"模型列表"**
3. 查看所有可用的模型
4. 了解模型的定价和能力

### 常见模型

| 模型 | 提供商 | 类型 | 用途 |
|------|--------|------|------|
| gpt-4 | OpenAI | 聊天 | 通用 AI 对话 |
| claude-3 | Anthropic | 聊天 | 长文本和分析 |
| gemini-pro | Google | 聊天 | 多模态理解 |
| llama-2 | Meta | 聊天 | 开源模型 |

---

## 4. 第一次 API 调用

### 使用 cURL

```bash
curl -X POST https://api.example.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

### 使用 Python

```python
import requests

response = requests.post(
  "https://api.example.com/v1/chat/completions",
  headers={
    "Authorization": "Bearer YOUR_API_TOKEN",
    "Content-Type": "application/json"
  },
  json={
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }
)

print(response.json())
```

### 使用 OpenAI 库

```python
from openai import OpenAI

client = OpenAI(
  api_key="YOUR_API_TOKEN",
  base_url="https://api.example.com/v1"
)

response = client.chat.completions.create(
  model="gpt-4",
  messages=[{"role": "user", "content": "Hello!"}]
)

print(response.choices[0].message.content)
```

---

## 5. 下一步

- 📖 查看[用户指南](/guide/)了解更多功能
- 🔌 查看[API 参考](/api/)了解所有端点
- 💡 学习[最佳实践](/guide/#最佳实践)
- ❓ 查看[常见问题](/guide/#常见问题)

---

## 常见问题

**Q: Token 丢失了怎么办？**

A: 在"令牌管理"中撤销旧 Token，生成新的即可。旧 Token 将立即失效。

**Q: 如何重置密码？**

A: 在登录页面点击"忘记密码"，按照邮件指引重置。

**Q: 如何启用 2FA？**

A: 进入"安全设置"，按照步骤启用双因素认证。

**Q: 支持哪些编程语言？**

A: 所有支持 HTTP 的编程语言都可以使用（Python、JavaScript、Go、Java 等）。
