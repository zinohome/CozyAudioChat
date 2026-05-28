# CozyAudioChat

CozyAudioChat 是 [Fun-Audio-Chat](https://github.com/FunAudioLLM/Fun-Audio-Chat) 项目的本地 docker-compose 部署优化版本。

## 项目结构

```
.
├── projects/
│   └── Fun-Audio-Chat/   # 上游项目（只读参考，不纳入版本控制）
├── .gitignore
└── README.md
```

- `projects/Fun-Audio-Chat/` 为上游项目的本地克隆，仅作只读参考，**禁止修改**，且已通过 `.gitignore` 排除在本仓库版本控制之外。
- 所有部署优化（docker-compose 配置、脚本等）均放在仓库根目录或其他子目录中进行。

## 上游项目

- 源仓库：https://github.com/FunAudioLLM/Fun-Audio-Chat

## 部署

docker-compose 部署配置将放置于仓库根目录（后续补充）。
