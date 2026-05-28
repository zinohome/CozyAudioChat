#!/usr/bin/env bash
# 启动前确保模型权重就绪（缺则下载到挂载卷），再拉起 S2S 推理服务。
set -euo pipefail

MODELS_DIR="${MODELS_DIR:-/app/Fun-Audio-Chat/pretrained_models}"
S2S_MODEL_NAME="${S2S_MODEL_NAME:-Fun-Audio-Chat-8B}"
# TTS 模型名被上游 utils/cosyvoice_detokenizer.py 硬编码，请勿改动。
TTS_MODEL_NAME="${TTS_MODEL_NAME:-Fun-CosyVoice3-0.5B-2512}"
DOWNLOAD_SOURCE="${DOWNLOAD_SOURCE:-modelscope}" # modelscope | huggingface
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-11235}"
TTS_GPU="${TTS_GPU:-0}"

mkdir -p "${MODELS_DIR}"

download_model() {
  local name="$1"
  local target="${MODELS_DIR}/${name}"
  if [ -d "${target}" ] && [ -n "$(ls -A "${target}" 2>/dev/null)" ]; then
    echo "[entrypoint] 模型已存在，跳过下载: ${target}"
    return
  fi
  echo "[entrypoint] 下载 ${name} (源: ${DOWNLOAD_SOURCE}) -> ${target}"
  if [ "${DOWNLOAD_SOURCE}" = "huggingface" ]; then
    hf download "FunAudioLLM/${name}" --local-dir "${target}"
  else
    modelscope download --model "FunAudioLLM/${name}" --local_dir "${target}"
  fi
}

download_model "${S2S_MODEL_NAME}"
download_model "${TTS_MODEL_NAME}"

cd /app/Fun-Audio-Chat
echo "[entrypoint] 启动 S2S 服务 ${HOST}:${PORT} (tts-gpu=${TTS_GPU})"
exec python3 -m web_demo.server.server \
  --host "${HOST}" \
  --port "${PORT}" \
  --model-path "pretrained_models/${S2S_MODEL_NAME}" \
  --tts-gpu "${TTS_GPU}" \
  "$@"
