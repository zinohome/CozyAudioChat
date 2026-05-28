# CozyAudioChat S2S 推理服务镜像
# 上游源码（含 third_party 子模块）在构建期 clone，不纳入本仓库版本控制。
ARG CUDA_IMAGE=nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
FROM ${CUDA_IMAGE}

ARG UPSTREAM_REPO=https://github.com/FunAudioLLM/Fun-Audio-Chat.git
ARG UPSTREAM_REF=main

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        git git-lfs ffmpeg sox build-essential \
        python3 python3-dev python3-pip ca-certificates curl \
    && git lfs install \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --recursive --depth 1 --branch ${UPSTREAM_REF} ${UPSTREAM_REPO} Fun-Audio-Chat

WORKDIR /app/Fun-Audio-Chat
# torch 必须先于 requirements 安装（cu128 轮子）
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch==2.8.0 torchaudio==2.8.0 --index-url https://download.pytorch.org/whl/cu128 \
    && python3 -m pip install -r requirements.txt \
    && python3 -m pip install sphn aiohttp modelscope "huggingface_hub[cli]" "numpy<2.0.0"

ENV PYTHONPATH=/app/Fun-Audio-Chat

COPY docker/server-entrypoint.sh /usr/local/bin/server-entrypoint.sh
RUN chmod +x /usr/local/bin/server-entrypoint.sh

EXPOSE 11235
ENTRYPOINT ["/usr/local/bin/server-entrypoint.sh"]
