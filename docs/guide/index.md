# 用户指南

## 快速开始

### 什么是 New API？

New API 是一个强大的 AI 网关和资产管理系统，聚合了 40+ 个上游 AI 提供商（包括 OpenAI、Claude、Gemini、Azure、AWS Bedrock 等），为您提供统一的 API 接口。

**核心特性：**
- 🔌 多渠道接入：支持 40+ 个 AI 提供商
- 👥 用户管理：完整的用户系统和权限控制
- 💰 计费管理：灵活的计费方案和成本追踪
- 🛡️ 多种认证：支持 JWT、OAuth、WebAuthn/Passkeys 等
- ⚡ 性能优化：速率限制、缓存、流式传输
- 📊 数据分析：实时数据看板和统计分析

---

## 账户注册与登录

### 注册步骤

1. **访问平台**：打开浏览器访问 New API 平台首页
2. **点击注册**：在首页找到注册按钮
3. **填写信息**：输入邮箱地址和密码
4. **邮箱验证**：检查邮箱收件箱，点击验证链接完成邮箱验证
5. **账户激活**：验证完成后账户自动激活，可以登录使用

### 登录方式

**邮箱登录**
- 输入注册的邮箱地址
- 输入密码
- 点击登录

**第三方登录**
- GitHub OAuth
- Discord OAuth
- 微信登录
- 其他 OIDC 提供商

**安全登录**
- 启用双因素认证 (2FA) 后需要额外验证
- Passkey 无密码登录（推荐）

### 启用双因素认证 (2FA)

1. 登录后进入"个人中心" → "安全设置"
2. 找到"双因素认证"部分，点击"启用"
3. 扫描二维码或手动输入密钥到认证器应用（如 Google Authenticator）
4. 输入验证码确认设置
5. 保存备份码以防认证器丢失

---

## 生成 API Token

### 如何生成 Token？

1. 登录 New API 平台
2. 进入"个人中心" → "令牌管理"
3. 点击"生成新令牌"按钮
4. 输入令牌名称（用于识别用途，如"my-app"）
5. 选择过期时间或永不过期
6. 点击"确定"生成
7. **复制显示的 Token**（仅显示一次，请妥善保管）

### Token 安全建议

- ✅ 仅在创建时显示一次，请立即复制保存
- ✅ 保存在环境变量或密钥管理工具中
- ✅ 不要在公开代码中暴露 Token
- ✅ 定期审查已生成的 Token
- ✅ Token 泄露时立即撤销并生成新的

---

## 主要功能

### 令牌管理

在"令牌管理"页面，您可以：
- **创建新令牌**：为不同应用生成独立的 Token
- **查看令牌**：列表显示所有活跃的令牌及元数据
- **编辑令牌**：修改令牌名称或过期时间
- **撤销令牌**：随时撤销已创建的令牌，立即生效

### 模型选择和管理

**浏览可用模型**
- 进入"控制台" → "数据看板"
- 查看所有可用的 AI 模型列表
- 了解模型特点和定价信息

**模型分类**
- 聊天模型（Chat）：用于对话交互
- 视觉模型（Vision）：支持图像分析
- 音频模型（Audio）：语音转文本、文本转语音
- 嵌入模型（Embedding）：文本向量化
- 图像生成（Image）：AI 绘图
- 其他模型：代码、翻译等特殊用途

**选择建议**
- 根据任务选择合适的模型
- 考虑成本和性能的平衡
- 使用"操练场"测试模型效果

### 用户分组

**创建和管理分组**
- 进入"个人中心" → "分组管理"
- 点击"新建分组"
- 输入分组名称和描述
- 配置分组的权限和速率限制

**分组的作用**
- 组织不同项目的 Token
- 按分组追踪 API 使用成本
- 设置分组级别的权限和限制
- 便于团队协作和权限管理

### 余额管理

**查看和充值余额**
- 在"钱包"页面查看当前余额
- 查看余额变动记录
- 支持的充值方式：
  - 支付宝
  - 微信支付
  - Stripe（国际）
  - 其他第三方支付

**使用和统计**
- "使用日志"显示详细的 API 调用记录
- 按时间、模型、令牌等维度统计费用
- 导出使用报告
- 设置余额预警阈值

### 聊天功能

**Web 端聊天应用**
- 简洁易用的聊天界面
- 实时对话体验

**功能特点**
- 选择任意可用的 AI 模型
- 支持文件上传（支持的模型）
- 自动保存聊天历史
- 导出聊天记录
- 创建多个聊天会话
- 分享聊天链接（可选）

**快速开始**
1. 进入"聊天"页面
2. 选择模型
3. 输入问题或提示词
4. 等待 AI 回复
5. 继续聊天或开始新会话

### 操练场（Playground）

**高级开发工具**
- 适合开发者和技术用户
- 完整的 API 参数控制

**主要功能**
- **JSON 编辑**：直接编辑请求体 JSON
- **参数配置**：
  - Temperature：控制随机性
  - Top P：核采样参数
  - Max Tokens：最大输出长度
  - Frequency Penalty：频率惩罚
  - Presence Penalty：出现惩罚
- **实时调试**：查看完整的请求和响应数据
- **流式传输**：实时查看生成过程
- **配置保存**：保存常用配置快速切换

**使用场景**
- 测试 API 和调整参数
- 调试请求和查看错误信息
- 性能测试和优化
- 了解 API 行为和响应格式

---

## 常见操作

### 如何在应用中使用 API？

**基本示例（cURL）**
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

**Python 示例**
```python
import requests

headers = {
    "Authorization": "Bearer YOUR_API_TOKEN",
    "Content-Type": "application/json"
}

response = requests.post(
    "https://api.example.com/v1/chat/completions",
    headers=headers,
    json={
        "model": "gpt-4",
        "messages": [{"role": "user", "content": "Hello!"}]
    }
)

print(response.json())
```

**JavaScript 示例**
```javascript
const response = await fetch(
  'https://api.example.com/v1/chat/completions',
  {
    method: 'POST',
    headers: {
      'Authorization': 'Bearer YOUR_API_TOKEN',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      model: 'gpt-4',
      messages: [{ role: 'user', content: 'Hello!' }]
    })
  }
);

const data = await response.json();
console.log(data);
```

### 如何切换模型？

1. 在聊天或操练场界面，找到顶部的"模型"下拉菜单
2. 点击下拉菜单查看可用模型列表
3. 选择需要的模型
4. 新的消息将使用选定的模型处理

### 使用 OpenAI 兼容客户端

New API 提供 OpenAI 兼容的 API，可以直接使用 OpenAI 官方客户端库：

**Python OpenAI 库**
```python
from openai import OpenAI

client = OpenAI(
    api_key="your_api_token",
    base_url="https://api.example.com/v1"
)

response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.choices[0].message.content)
```

---

## 最佳实践

### 安全性建议

- ✅ 启用双因素认证 (2FA)
- ✅ 使用强密码（12+ 字符，包含大小写字母、数字和特殊字符）
- ✅ 定期更新密码
- ✅ 不要在代码中硬编码 API Token，使用环境变量
- ✅ 定期审查已生成的 Token，撤销不再使用的
- ✅ 使用专用的密钥管理工具存储 Token
- ✅ 不要分享您的 API Token
- ✅ 对敏感操作启用额外的安全验证

### 成本优化建议

- 💰 为不同项目创建分组，便于成本追踪和分析
- 💰 选择合适的模型，根据任务复杂度选择
- 💰 使用流式 API 响应，实时获取数据无需等待
- 💰 定期检查使用日志，识别异常费用和优化机会
- 💰 为不同团队配置速率限制，防止过量使用
- 💰 利用免费额度和试用期进行测试
- 💰 根据使用量选择合适的计费套餐
- 💰 设置余额预警，防止突然断服

### 开发建议

- 🚀 使用操练场测试 API 和调整参数
- 🚀 在生产环境前充分测试
- 🚀 实现错误处理和重试逻辑
- 🚀 监控 API 响应时间和错误率
- 🚀 使用 API 文档了解各模型的特点和限制
- 🚀 记录 API 请求和响应用于调试
- 🚀 为关键操作实现降级方案
- 🚀 定期更新依赖库和客户端库

---

## 常见问题

**Q: 如何重置密码？**

A: 在登录页面点击"忘记密码"，输入注册邮箱，按照邮件指引重置密码。

**Q: API Token 泄露了怎么办？**

A: 立即进入"令牌管理"，撤销泄露的 Token，生成新的 Token。泄露的 Token 会立即失效。

**Q: 为什么 API 调用返回 401 错误？**

A: 检查是否提供了有效的 API Token，验证 Authorization 标头格式是否正确：`Authorization: Bearer YOUR_API_TOKEN`

**Q: 模型不可用怎么办？**

A: 某些模型可能因配置或权限而不可用。检查"数据看板"了解可用模型，或联系管理员。

**Q: 余额不足怎么办？**

A: 进入"钱包"页面进行充值，或检查是否可以申请试用额度。

**Q: 如何获取发票？**

A: 联系管理员或在"钱包"页面申请，获取详细的费用明细和发票。

**Q: 支持哪些编程语言？**

A: 支持任何可以发送 HTTP 请求的编程语言。推荐使用 OpenAI 官方客户端库或 HTTP 客户端库。

---

## 故障排查

### 获取帮助

1. 📖 查看 API 文档了解详细信息
2. 💬 在"使用日志"中查看错误详情
3. 📧 通过邮件联系支持团队
4. 🐛 向管理员报告 bug 或问题

### 常见问题排查

- **连接超时**：检查网络连接和防火墙设置
- **认证失败**：验证 Token 有效性和 Authorization 标头格式
- **配额限制**：检查余额和速率限制设置
- **模型不可用**：确认模型已启用且有权限使用
- **请求格式错误**：参考 API 文档检查请求体格式

---

## 术语表

| 术语 | 说明 |
|------|------|
| **API Token** | 用于身份验证的密钥，调用 API 时需要提供 |
| **模型** | AI 模型的标识符，如 gpt-4、claude-3 等 |
| **分组** | 用于组织 Token 和追踪成本的逻辑单位 |
| **速率限制** | 限制 API 调用频率的机制，防止滥用 |
| **流式响应** | 实时发送数据的方式，如流式聊天回复 |
| **2FA/MFA** | 双因素/多因素认证，额外的安全认证方式 |
| **OAuth** | 第三方登录方式，如 GitHub、Discord 登录 |
| **Passkey** | 无密码登录方式，使用生物识别或安全密钥 |
| **Token 令牌** | API 密钥，用于调用接口的身份凭证 |
| **操练场** | 高级 API 测试工具，可调整所有参数 |
