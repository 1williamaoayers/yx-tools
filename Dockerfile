# 构建阶段 - 编译CloudflareSpeedTest
FROM golang:1.21-alpine AS builder
WORKDIR /src
# 复制本地源码到容器中
COPY CloudflareSpeedTest .
# 编译各架构版本
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o CloudflareST_proxy_linux_amd64 .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags "-s -w" -o CloudflareST_proxy_linux_arm64 .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 go build -ldflags "-s -w" -o CloudflareST_proxy_linux_arm .

# 运行阶段
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8

# 安装系统依赖（包括cron用于定时任务）
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    ca-certificates \
    tzdata \
    cron \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制依赖文件
COPY requirements.txt .

# 安装Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY cloudflare_speedtest.py .

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /src/CloudflareST_proxy_linux_amd64 /app/CloudflareST_proxy_linux_amd64
COPY --from=builder /src/CloudflareST_proxy_linux_arm64 /app/CloudflareST_proxy_linux_arm64
COPY --from=builder /src/CloudflareST_proxy_linux_arm /app/CloudflareST_proxy_linux_arm

# 赋予可执行文件执行权限
RUN chmod +x /app/CloudflareST_proxy_linux_amd64 \
    && chmod +x /app/CloudflareST_proxy_linux_arm64 \
    && chmod +x /app/CloudflareST_proxy_linux_arm

# 创建数据目录（用于保存结果文件）
RUN mkdir -p /app/data /app/config

# 声明数据卷，确保数据持久化
VOLUME ["/app/data", "/app/config"]

# 复制启动脚本
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

# 设置入口点
ENTRYPOINT ["/app/docker-entrypoint.sh"]

# 默认命令（保持容器运行）
CMD []

