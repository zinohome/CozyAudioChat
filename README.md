# CozyAudioChat

CozyAudioChat 是 [Fun-Audio-Chat](https://github.com/FunAudioLLM/Fun-Audio-Chat) 项目的本地 docker-compose 部署优化版本。

## 项目结构

```
.
├── projects/
│   └── Fun-Audio-Chat/        # 上游项目（只读参考，不纳入版本控制）
├── docker/
│   ├── server.Dockerfile      # S2S 推理服务镜像（CUDA + 上游源码 + 子模块）
│   ├── client.Dockerfile      # 前端镜像（vite build → nginx 托管）
│   ├── nginx.conf             # 静态托管 + /api/simplex 反代到后端
│   └── server-entrypoint.sh   # 启动前自动下载缺失的模型权重
├── .github/workflows/
│   └── build-push.yml         # CI：自动构建并推送镜像到 Harbor
├── scripts/build-and-push.sh  # 本地手动构建推送（CI 备用）
├── docker-compose.yml         # 一键部署（仅用镜像，不含 build）
├── .env.example
├── .gitignore
└── README.md
```

- `projects/Fun-Audio-Chat/` 为上游项目的本地克隆，仅作只读参考，**禁止修改**，且已通过 `.gitignore` 排除在版本控制之外。镜像在构建期自行 `git clone --recursive` 上游源码，不依赖该目录。

## 上游项目

- 源仓库：https://github.com/FunAudioLLM/Fun-Audio-Chat

## 一键部署（docker-compose）

### 前置要求

- 一台带 **NVIDIA GPU 的主机**（显存 **≥24GB**，如 RTX 3090/4090、A10；12GB 无法运行，详见 issue 评估）。
- 已安装 Docker + [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)。
- 已存在 `1panel-network` 网络（1panel 环境默认具备）。
- Harbor 已登录或镜像可匿名拉取：`docker login harbor.naivehero.top:8443`。

### 步骤

```bash
# 1. 准备配置与数据目录（数据持久化路径由需求指定为 /data/RTVideo）
cp .env.example .env        # 按需修改镜像 tag / 端口 / GPU
sudo mkdir -p /data/RTVideo/models /data/RTVideo/output

# 2. 拉起服务（仅使用 Harbor 镜像，不在本机 build）
docker compose pull
docker compose up -d
```

- 首次启动 `server` 会自动把 `Fun-Audio-Chat-8B` 与 `Fun-CosyVoice3-0.5B-2512` 下载到 `/data/RTVideo/models`（约 17GB+，请预留磁盘与时间）。
- 访问前端：`http://<主机IP>:8080`（端口由 `.env` 的 `CLIENT_PORT` 控制；如经 1panel 反代可挂自有域名/证书）。

### 单卡 / 双卡

- **单卡（默认）**：`.env` 中 `TTS_GPU=0`，S2S 与 TTS 共用 GPU 0，需 ≥24GB 显存。
- **双卡**：`.env` 设 `TTS_GPU=1`，并将 `docker-compose.yml` 中 `count: all` 改为 `device_ids: ["0", "1"]`。

## 镜像构建与自动上传

镜像仓库：`harbor.naivehero.top:8443/video/cozyaudiochat-{server,client}`。

**CI 自动上传（推荐）**：`.github/workflows/build-push.yml` 在 push 到 `main` 或打 `v*` tag 时自动 buildx 构建并推送。需在仓库
`Settings → Secrets and variables → Actions` 配置：

- `HARBOR_USERNAME` / `HARBOR_PASSWORD`（Secrets）
- 可选 `HARBOR_REGISTRY`（Variable，默认 `harbor.naivehero.top:8443/video`）

**本地手动**：`docker login harbor.naivehero.top:8443 && ./scripts/build-and-push.sh [tag]`。
