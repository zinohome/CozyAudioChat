# CozyAudioChat 前端镜像：构建上游 web_demo/client 静态资源，nginx 托管并反代 ws。
ARG NODE_IMAGE=node:20-bookworm
ARG NGINX_IMAGE=nginx:1.27-alpine

FROM ${NODE_IMAGE} AS build
ARG UPSTREAM_REPO=https://github.com/FunAudioLLM/Fun-Audio-Chat.git
ARG UPSTREAM_REF=main
WORKDIR /src
RUN git clone --depth 1 --branch ${UPSTREAM_REF} ${UPSTREAM_REPO} repo
WORKDIR /src/repo/web_demo/client
ENV VITE_QUEUE_API_PATH=/api
RUN npm install
# 直接调用 vite build，跳过上游 tsc 类型检查（不修改上游源码）。
RUN npx vite build

FROM ${NGINX_IMAGE}
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /src/repo/web_demo/client/dist /usr/share/nginx/html
EXPOSE 80
