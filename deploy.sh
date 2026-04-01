#!/bin/bash
# =============================================================
# deploy.sh — 一键构建并部署到服务器
# 使用方法：
#   chmod +x deploy.sh
#   ./deploy.sh
# =============================================================
set -e

# ============= 修改这里 =============
DOCKER_IMAGE="chenzhong996/new-api:latest"
SERVER_USER="root"             # 服务器 SSH 用户名
SERVER_HOST=""                 # 服务器公网 IP，例如：1.2.3.4
SERVER_DIR="/opt/new-api"      # 服务器上 docker-compose.yml 所在目录
# ====================================

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${YELLOW}➡️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; exit 1; }

# 检查必填配置
[ -z "$SERVER_HOST" ] && err "请先在 deploy.sh 中填写 SERVER_HOST（服务器 IP）"

# ---- Step 1: 编译前端 ----
info "[1/3] 编译前端..."
cd "$(dirname "$0")/web"
bun run build
cd ..
log "前端编译完成"

# ---- Step 2: 构建并推送 Docker 镜像 ----
info "[2/3] 构建 Docker 镜像并推送到 Docker Hub..."
info "平台: linux/amd64，镜像: $DOCKER_IMAGE"
docker buildx build \
  --platform linux/amd64 \
  -t "$DOCKER_IMAGE" \
  --push \
  .
log "镜像推送完成: $DOCKER_IMAGE"

# ---- Step 3: 服务器拉取并重启 ----
info "[3/3] 更新服务器容器..."
ssh "$SERVER_USER@$SERVER_HOST" bash <<EOF
  set -e
  cd "$SERVER_DIR"
  docker compose pull
  docker compose up -d
  echo "容器状态："
  docker compose ps
EOF
log "部署完成！访问 https://aitechlab.com.cn 查看效果"
