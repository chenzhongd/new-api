#!/bin/bash
# =============================================================
# deploy.sh — 一键构建并部署到服务器
# 使用方法：
#   chmod +x deploy.sh
#   ./deploy.sh [steps]
# 示例：
#   ./deploy.sh                 # 执行 1,2,3 全部步骤
#   ./deploy.sh 3               # 仅执行步骤 3
#   ./deploy.sh 13              # 执行步骤 1 和 3
#   ./deploy.sh 1,3             # 执行步骤 1 和 3（逗号写法也支持）
# =============================================================
set -e

# 确保 bun 在 PATH 中
export PATH="$HOME/.bun/bin:$PATH"

# ============= 修改这里 =============
# 镜像仓库与 Tag（可通过第一个参数覆盖：./deploy.sh my-tag）
DOCKER_REPO="chenzhong996/new-api"
IMAGE_TAG="1.0.1"
DOCKER_IMAGE="$DOCKER_REPO:$IMAGE_TAG"
# ====================================

# 命令行参数
# 步骤选择（默认 123，可传 1 / 2 / 3 / 12 / 13 / 23 / 123 / 1,3 等）
RUN_STEPS_RAW="${1:-123}"
RUN_STEPS="${RUN_STEPS_RAW//,/}"

case "$RUN_STEPS" in
  ""|*[!123]*)
    err "步骤参数非法：$RUN_STEPS_RAW，示例：./deploy.sh 3 或 ./deploy.sh 1,3"
    ;;
esac

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${YELLOW}➡️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; exit 1; }

should_run_step() {
  local step="$1"
  case "$RUN_STEPS" in
    *"$step"*) return 0 ;;
    *) return 1 ;;
  esac
}

# ---- Step 1: 编译前端 ----
if should_run_step 1; then
  info "[1/3] 编译前端..."
  cd "$(dirname "$0")/web"
  bun install
  bun run build
  cd ..
  log "前端编译完成"
else
  info "[1/3] 跳过前端编译（steps=$RUN_STEPS）"
fi

# ---- Step 2: 构建 Docker 镜像 ----
if should_run_step 2; then
  info "[2/3] 构建 Docker 镜像..."
  info "平台: linux/amd64，镜像: $DOCKER_IMAGE"
  docker buildx build \
    --platform linux/amd64 \
    -t "$DOCKER_IMAGE" \
    --load \
    .
  log "镜像构建完成: $DOCKER_IMAGE"
else
  info "[2/3] 跳过镜像构建（steps=$RUN_STEPS）"
fi

# ---- Step 3: 推送 Docker 镜像 ----
if should_run_step 3; then
  info "[3/3] 推送 Docker 镜像到 Docker Hub..."
  docker push "$DOCKER_IMAGE"
  log "镜像推送完成: $DOCKER_IMAGE"
else
  info "[3/3] 跳过镜像推送（steps=$RUN_STEPS）"
fi

log "完成！镜像已推送: $DOCKER_IMAGE"