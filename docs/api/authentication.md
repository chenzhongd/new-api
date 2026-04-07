# 身份认证

## API Token 认证

所有 API 请求都需要在 HTTP 标头中提供有效的 API Token。

### 请求格式

```
Authorization: Bearer YOUR_API_TOKEN
```

### 完整请求示例

```bash
curl -X GET https://api.example.com/api/user/self \
  -H "Authorization: Bearer sk_test_4eC39HqLyjWDarhtT881g"
```

### Python 示例

```python
import requests

headers = {
    "Authorization": "Bearer sk_test_4eC39HqLyjWDarhtT881g",
    "Content-Type": "application/json"
}

response = requests.get(
    "https://api.example.com/api/user/self",
    headers=headers
)

print(response.json())
```

### JavaScript 示例

```javascript
const headers = {
  'Authorization': 'Bearer sk_test_4eC39HqLyjWDarhtT881g',
  'Content-Type': 'application/json'
};

fetch('https://api.example.com/api/user/self', {
  headers: headers
})
.then(res => res.json())
.then(data => console.log(data));
```

---

## Token 管理

### 生成 Token

1. 登录 Web 控制台
2. 进入**"个人中心"** → **"令牌管理"**
3. 点击**"生成新令牌"**按钮
4. 填写以下信息：
   - **名称**：用于标识此 Token（如 "Production API"）
   - **过期时间**：选择过期时间或永不过期
   - **权限**（可选）：选择此 Token 的权限范围

### Token 安全最佳实践

#### ✅ 应该做的

- 使用环境变量存储 Token
- 定期轮换 Token
- 为不同应用使用不同的 Token
- 监控 Token 的使用情况
- 及时撤销不使用的 Token

#### ❌ 不应该做的

- 不要在代码中硬编码 Token
- 不要提交 Token 到版本控制系统
- 不要通过非加密通道传输 Token
- 不要将 Token 日志记录到文件中
- 不要在浏览器中公开显示 Token

### 环境变量配置

**Bash/Linux/Mac:**
```bash
export NEW_API_TOKEN="sk_test_4eC39HqLyjWDarhtT881g"
```

**.env 文件:**
```
NEW_API_TOKEN=sk_test_4eC39HqLyjWDarhtT881g
```

**Windows (PowerShell):**
```powershell
$env:NEW_API_TOKEN="sk_test_4eC39HqLyjWDarhtT881g"
```

**Python 中读取：**
```python
import os
from dotenv import load_dotenv

load_dotenv()
token = os.getenv('NEW_API_TOKEN')
```

---

## Token 类型

### 完全访问 Token

具有账户的所有权限，包括：
- 调用 API
- 管理令牌
- 访问计费信息
- 修改账户设置

### 只读 Token

仅允许读取操作，不能：
- 修改账户信息
- 创建新令牌
- 变更计费信息

### 特定权限 Token

可以限制到特定的：
- 操作类型（如仅聊天 API）
- 模型列表（如仅 GPT-4）
- IP 地址范围
- 使用期限

---

## Token 过期和续期

### 自动过期

- Token 在设定的过期日期自动失效
- 无法通过续期延长使用期限
- 需要生成新的 Token

### 手动撤销

可以随时在"令牌管理"中撤销 Token：

1. 进入**"令牌管理"**
2. 找到要撤销的 Token
3. 点击**"撤销"**按钮
4. 确认撤销

撤销后 Token 立即失效。

---

## 轮换策略建议

为了安全，定期轮换 Token：

1. **生成新 Token**
   ```bash
   curl -X POST https://api.example.com/api/token \
     -H "Authorization: Bearer OLD_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"name": "new-token", "expires_in": 2592000}'
   ```

2. **更新应用配置**
   - 更新环境变量或配置文件
   - 部署新版本

3. **验证新 Token 工作正常**
   ```bash
   curl https://api.example.com/api/user/self \
     -H "Authorization: Bearer NEW_TOKEN"
   ```

4. **撤销旧 Token**
   - 在控制台中撤销旧 Token

---

## 故障排查

### 401 Unauthorized

**原因：**
- Token 无效或已过期
- Authorization 标头格式错误
- Token 拼写错误

**解决方法：**
```bash
# 检查 Token 格式
curl https://api.example.com/api/user/self \
  -H "Authorization: Bearer $(echo $NEW_API_TOKEN)"
```

### 403 Forbidden

**原因：**
- Token 权限不足
- 账户被禁用
- 操作不被允许

**解决方法：**
1. 检查 Token 的权限设置
2. 联系管理员检查账户状态

### Token 不工作

**排查步骤：**
```bash
# 1. 检查 Token 是否存在
echo $NEW_API_TOKEN

# 2. 测试连接
curl -i https://api.example.com/api/user/self \
  -H "Authorization: Bearer $NEW_API_TOKEN"

# 3. 查看详细错误
curl -v https://api.example.com/api/user/self \
  -H "Authorization: Bearer $NEW_API_TOKEN"
```

---

## 更多信息

- 查看[用户 API 文档](/api/user)了解用户相关端点
- 查看[令牌 API 文档](/api/tokens)了解令牌管理端点
- 查看[错误处理](/api/errors)了解如何处理 API 错误
