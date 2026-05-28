#!/usr/bin/env bash
# 本地手动构建并推送镜像到 Harbor（CI 之外的备用手段）。
# 用法:
#   docker login harbor.naivehero.top:8443
#   ./scripts/build-and-push.sh [TAG]
set -euo pipefail

REGISTRY="${HARBOR_REGISTRY:-harbor.naivehero.top:8443/video}"
TAG="${1:-${IMAGE_TAG:-latest}}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

cd "$ROOT"

for comp in server client; do
  image="${REGISTRY}/cozyaudiochat-${comp}:${TAG}"
  echo ">>> 构建 ${image}"
  docker build -f "docker/${comp}.Dockerfile" -t "${image}" .
  echo ">>> 推送 ${image}"
  docker push "${image}"
done

echo "完成：${REGISTRY}/cozyaudiochat-{server,client}:${TAG}"
