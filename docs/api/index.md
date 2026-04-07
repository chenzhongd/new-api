# API 参考

## API 介绍

### 基础信息

- **基础 URL**：`https://api.example.com`（根据部署环境调整）
- **API 版本**：`v1`
- **请求格式**：`application/json`
- **响应格式**：`application/json`

### 主要特性

- ✅ 支持 RESTful API 风格
- ✅ 支持 OpenAI 兼容的聊天 API
- ✅ 支持流式响应（Server-Sent Events）
- ✅ 支持多种认证方式
- ✅ 内置速率限制和配额管理
- ✅ 详细的错误信息和日志

---

## 身份认证

### API Token 认证

所有 API 请求都需要在 HTTP 标头中提供有效的 API Token。

**请求标头格式**
```
Authorization: Bearer YOUR_API_TOKEN
```

**cURL 示例**
```bash
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
  https://api.example.com/api/user/self
```

**获取 API Token**

1. 登录 Web 控制台
2. 进入"个人中心" → "令牌管理"
3. 点击"生成新令牌"
4. 输入令牌名称和过期时间
5. 复制显示的令牌（仅显示一次）

::: warning 安全提示
API Token 拥有账户的完全权限，请妥善保管。不要在公开代码中暴露 Token。
:::

---

## 用户 API

### 获取用户信息

<span class="badge">GET</span> `/api/user/self`

获取当前登录用户的信息。

**请求**
```bash
curl -X GET https://api.example.com/api/user/self \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

**响应示例**
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "email": "user@example.com",
    "username": "johndoe",
    "balance": 100.50,
    "created_at": "2024-01-01T00:00:00Z",
    "status": 1,
    "groups": ["default", "premium"]
  }
}
```

### 更新用户信息

<span class="badge" style="background-color: #fca130;">PUT</span> `/api/user/self`

更新当前用户的信息。

**请求体**
```json
{
  "username": "newusername",
  "email": "newemail@example.com"
}
```

**响应**
```json
{
  "success": true,
  "data": {
    "id": "user_123",
    "email": "newemail@example.com",
    "username": "newusername"
  }
}
```

### 获取用户分组

<span class="badge">GET</span> `/api/user/self/groups`

获取当前用户所属的分组列表。

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "group_1",
      "name": "default",
      "description": "默认分组"
    },
    {
      "id": "group_2",
      "name": "premium",
      "description": "高级分组"
    }
  ]
}
```

### 获取可用模型列表

<span class="badge">GET</span> `/api/user/models`

获取当前用户可以使用的所有模型列表。

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "gpt-4",
      "name": "GPT-4",
      "provider": "openai",
      "type": "chat",
      "input_price": 0.03,
      "output_price": 0.06
    },
    {
      "id": "claude-3",
      "name": "Claude 3",
      "provider": "anthropic",
      "type": "chat",
      "input_price": 0.015,
      "output_price": 0.045
    }
  ]
}
```

---

## 模型 API

### 获取所有模型

<span class="badge">GET</span> `/api/models`

获取系统中所有可用的模型列表。

**查询参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| `page` | integer | 页码（默认 1） |
| `page_size` | integer | 每页数量（默认 10，最大 100） |
| `type` | string | 模型类型筛选（chat, vision, audio 等） |

**请求示例**
```bash
curl "https://api.example.com/api/models?page=1&page_size=20" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "gpt-4",
      "name": "GPT-4",
      "provider": "openai",
      "type": "chat",
      "enabled": true,
      "input_price": 0.03,
      "output_price": 0.06
    }
  ]
}
```

---

## 聊天 API

### 创建聊天完成

<span class="badge" style="background-color: #49cc90;">POST</span> `/v1/chat/completions`

发送消息并获取 AI 回应。支持流式和非流式响应。

**请求体参数**

| 参数 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `model` | string | ✅ | 模型 ID，如 gpt-4、claude-3 |
| `messages` | array | ✅ | 消息列表，包含 role 和 content |
| `temperature` | number | | 温度，0-2，默认 1。更高更随机 |
| `max_tokens` | integer | | 最大输出令牌数 |
| `stream` | boolean | | 是否使用流式响应，默认 false |
| `top_p` | number | | 核采样参数，0-1 |

**非流式请求示例**
```bash
curl -X POST https://api.example.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "介绍一下 New API"
      }
    ],
    "temperature": 0.7,
    "max_tokens": 1000
  }'
```

**非流式响应示例**
```json
{
  "id": "chatcmpl_123",
  "object": "chat.completion",
  "created": 1704067200,
  "model": "gpt-4",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "New API 是一个强大的 AI 网关..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 100,
    "total_tokens": 125
  }
}
```

**流式请求示例**
```bash
curl -X POST https://api.example.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {
        "role": "user",
        "content": "Hello"
      }
    ],
    "stream": true
  }'
```

**流式响应示例**
```
data: {"choices":[{"index":0,"delta":{"role":"assistant","content":""}}]}
data: {"choices":[{"index":0,"delta":{"content":"Hello"}}]}
data: {"choices":[{"index":0,"delta":{"content":" there"}}]}
data: [DONE]
```

::: info 流式响应说明
流式响应使用 Server-Sent Events (SSE)，每行数据以 "data: " 开头，以 [DONE] 结束。
:::

---

## 令牌 API

### 生成新令牌

<span class="badge" style="background-color: #49cc90;">POST</span> `/api/user/token`

为当前用户生成新的 API Token。

**请求体**
```json
{
  "name": "my-app",
  "expires_in": 2592000
}
```

**响应示例**
```json
{
  "success": true,
  "data": {
    "id": "token_123",
    "name": "my-app",
    "token": "sk-...",
    "created_at": "2024-01-01T00:00:00Z",
    "expires_at": "2024-02-01T00:00:00Z"
  }
}
```

### 获取令牌列表

<span class="badge">GET</span> `/api/token`

获取当前用户的所有 API Token 列表。

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "token_1",
      "name": "Production API",
      "created_at": "2024-01-01T00:00:00Z",
      "last_used": "2024-01-15T10:30:00Z",
      "expires_at": null
    }
  ]
}
```

### 删除令牌

<span class="badge" style="background-color: #f93e3e;">DELETE</span> `/api/token/:id`

删除指定的 API Token。

**请求**
```bash
curl -X DELETE https://api.example.com/api/token/token_123 \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

**响应**
```json
{
  "success": true,
  "message": "Token deleted successfully"
}
```

---

## 账单 API

### 获取当前余额

<span class="badge">GET</span> `/api/user/self`

在用户信息中包含 `balance` 字段。

### 获取充值信息

<span class="badge">GET</span> `/api/user/self/topup/info`

获取充值方式和金额选项。

**响应示例**
```json
{
  "success": true,
  "data": {
    "current_balance": 100.50,
    "available_methods": [
      {
        "name": "Stripe",
        "provider": "stripe"
      },
      {
        "name": "支付宝",
        "provider": "alipay"
      }
    ],
    "preset_amounts": [10, 50, 100, 500, 1000]
  }
}
```

### 获取使用日志

<span class="badge">GET</span> `/api/console/log`

获取 API 使用日志和费用详情。

**查询参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| `page` | integer | 页码 |
| `page_size` | integer | 每页数量 |
| `start_time` | string | 开始时间 (ISO 8601) |
| `end_time` | string | 结束时间 (ISO 8601) |

**响应示例**
```json
{
  "success": true,
  "data": [
    {
      "id": "log_123",
      "model": "gpt-4",
      "token_id": "token_1",
      "prompt_tokens": 25,
      "completion_tokens": 100,
      "total_tokens": 125,
      "cost": 0.0045,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 10,
    "total": 1000
  }
}
```

---

## 错误处理

### 错误响应格式

```json
{
  "success": false,
  "error": "error_code",
  "message": "Error description"
}
```

### 常见错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|-----------|------|
| `invalid_request` | 400 | 请求参数无效 |
| `unauthorized` | 401 | 未提供有效的认证令牌 |
| `forbidden` | 403 | 无权限访问该资源 |
| `not_found` | 404 | 资源不存在 |
| `rate_limited` | 429 | 请求过于频繁，触发速率限制 |
| `insufficient_quota` | 429 | 余额不足 |
| `server_error` | 500 | 服务器内部错误 |
| `service_unavailable` | 503 | 服务暂时不可用 |

### 错误处理最佳实践

- ✅ 检查 HTTP 状态码
- ✅ 检查 `success` 字段
- ✅ 记录 `error` 和 `message` 以便调试
- ✅ 实现重试逻辑（特别是对于 5xx 错误）
- ✅ 优雅处理 429 错误，实现退避策略

---

## 代码示例

### Python 示例

```python
import requests

API_BASE_URL = "https://api.example.com"
API_TOKEN = "your_api_token"

headers = {
    "Authorization": f"Bearer {API_TOKEN}",
    "Content-Type": "application/json"
}

# 创建聊天完成请求
response = requests.post(
    f"{API_BASE_URL}/v1/chat/completions",
    headers=headers,
    json={
        "model": "gpt-4",
        "messages": [
            {"role": "user", "content": "Hello!"}
        ],
        "temperature": 0.7
    }
)

print(response.json())
```

### Python OpenAI 库

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

### JavaScript 示例

```javascript
const API_BASE_URL = 'https://api.example.com';
const API_TOKEN = 'your_api_token';

async function chat(message) {
  const response = await fetch(
    `${API_BASE_URL}/v1/chat/completions`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [
          { role: 'user', content: message }
        ]
      })
    }
  );
  
  return await response.json();
}

chat('Hello!').then(console.log);
```

### JavaScript 流式响应

```javascript
async function chatStream(message) {
  const response = await fetch(
    'https://api.example.com/v1/chat/completions',
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer YOUR_API_TOKEN`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: 'gpt-4',
        messages: [{ role: 'user', content: message }],
        stream: true
      })
    }
  );

  const reader = response.body.getReader();
  const decoder = new TextDecoder();

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;

    const chunk = decoder.decode(value);
    const lines = chunk.split('\n');
    
    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        if (data === '[DONE]') break;
        
        try {
          const json = JSON.parse(data);
          const content = json.choices[0].delta.content;
          if (content) process.stdout.write(content);
        } catch (e) {
          // 忽略解析错误
        }
      }
    }
  }
}

chatStream('Tell me a story').catch(console.error);
```

### cURL 流式示例

```bash
curl -X POST https://api.example.com/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-4",
    "messages": [
      {"role": "user", "content": "Write a poem"}
    ],
    "stream": true
  }' \
  --no-buffer
```

---

## 速率限制

### 限制规则

- 默认限制：100 请求/分钟
- 超出限制返回 429 状态码
- 响应头包含限制信息：
  - `X-RateLimit-Limit`：限制数
  - `X-RateLimit-Remaining`：剩余请求数
  - `X-RateLimit-Reset`：重置时间戳

### 处理 429 错误

```python
import time
import requests

def call_api_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        response = requests.get(url)
        
        if response.status_code == 429:
            retry_after = int(response.headers.get('Retry-After', 60))
            print(f"Rate limited. Retrying after {retry_after} seconds...")
            time.sleep(retry_after)
            continue
        
        return response
    
    raise Exception("Max retries exceeded")
```

---

## 最佳实践

- ✅ 使用环境变量存储 API Token
- ✅ 实现错误处理和重试逻辑
- ✅ 监控 API 响应时间和错误率
- ✅ 使用流式 API 获取实时数据
- ✅ 缓存频繁请求的结果
- ✅ 定期检查使用日志和费用
- ✅ 为关键操作实现降级方案
- ✅ 使用专用的 Token 用于不同的应用
