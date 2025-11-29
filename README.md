# Cloudflare SpeedTest 跨平台自动化工具

[![Version](https://img.shields.io/badge/Version-2.2.3-blue.svg)](https://github.com/1williamaoayers/yx-tools)
[![Python](https://img.shields.io/badge/Python-3.7+-blue.svg)](https://python.org)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**全平台 Cloudflare 优选 IP 工具**，支持 Windows、macOS、Linux，特别优化了对 **树莓派 (ARM32/ARM64)** 的支持。

无论你是想给电脑加速，还是想在软路由、NAS、树莓派上跑定时任务，这个工具都能满足你。

## ✨ 核心亮点

*   **🌐 全球测速**：内置 97 个 Cloudflare 数据中心代码（如 HKG, NRT, LAX），想测哪里测哪里。
*   **⚡ 智能优选**：自动下载最新 IP 库，一键找出当下最快的 IP。
*   **🤖 自动化**：支持定时任务，每天自动测速并更新配置，彻底解放双手。
*   **🐳 Docker 神器**：提供全架构 Docker 镜像，**树莓派/软路由一条命令直接跑**。
*   **📈 结果上报**：测速结果可自动上传到 GitHub 或 Cloudflare Workers，方便其他设备订阅。

## 🖥️ 支持平台

我们实现了真正的**全平台支持**，无需繁琐配置，下载即用。

| 平台 | 架构 | 说明 |
|------|------|------|
| **Windows** | x64 / ARM64 | 电脑、Surface 等 |
| **macOS** | Intel / M1/M2 | MacBook, Mac mini 等 |
| **Linux** | x64 | 服务器、VPS、软路由 (x86) |
| **Linux** | ARM64 | 树莓派 4/5、N1 盒子、高端软路由 |
| **Linux** | **ARM32 (armv7)** | **树莓派 2/3、玩客云、老式机顶盒** |

---

## 🚀 极速上手 (Docker 篇) - 强烈推荐

**小白福音！** 不用管什么 Python 环境、依赖库，只要你的设备上有 Docker，一条命令搞定。

> **特别说明**：我们的镜像已经集成了所有主流设备架构（包括 x86/amd64 的普通电脑、arm64 的树莓派/Mac、以及 arm32 的玩客云等），**Docker 会自动识别你的设备并拉取正确的版本**。你不需要做任何区分，命令都是一样的！

### 方法一：一条命令直接跑 (最简单)

适合想快速试一下，或者不想保存配置的用户。

```bash
docker run -it --rm ghcr.io/1williamaoayers/yx-tools:latest
```
*运行后按提示选择“小白模式”即可开始测速。*

### 方法二：后台运行 + 定时任务 (最推荐)

适合长期挂在 **NAS、树莓派、软路由** 上，每天自动测速更新 IP。

```bash
# 启动容器（后台运行，重启自动恢复）
docker run -d --name cf-speedtest \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/config:/app/config \
  --restart unless-stopped \
  ghcr.io/1williamaoayers/yx-tools:latest
```

```bash
# 进入容器设置定时任务
docker exec -it cf-speedtest python3 /app/cloudflare_speedtest.py
```
*进入容器后，选择功能菜单中的“设置定时任务”即可。结果文件会保存在当前目录的 `data` 文件夹下。*

### 方法三：Docker Compose (高级玩家)

如果你喜欢用 Compose 管理容器：

```yaml
version: '3'
services:
  speedtest:
    image: ghcr.io/1williamaoayers/yx-tools:latest
    container_name: cf-speedtest
    restart: unless-stopped
    volumes:
      - ./data:/app/data
      - ./config:/app/config
    # 可选：通过环境变量自动设置定时任务（每天凌晨2点测速）
    environment:
      - CRON_SCHEDULE=0 2 * * *
      - CRON_COMMAND=python3 /app/cloudflare_speedtest.py --mode beginner --count 10
```

---

## 📦 极速上手 (本地运行篇)

如果你不想用 Docker，也可以直接下载运行。

### 1. 下载运行
1.  **下载项目**：点击右上角 `Code` -> `Download ZIP`，解压。
2.  **安装依赖**：确保有 Python3 环境，运行 `pip install -r requirements.txt`。
3.  **运行**：
    *   Windows: 双击 `cloudflare_speedtest.py` 或在 CMD 中运行。
    *   Linux/Mac: 终端运行 `python3 cloudflare_speedtest.py`。

### 2. 关于 ARM32 (树莓派) 用户
如果你是 ARM32 设备（如树莓派 3B 以前的型号），直接运行脚本即可。脚本会**自动检测**你的架构，并尝试下载对应的测速核心组件。如果网络不好下载失败，请手动下载 `CloudflareST_linux_arm.tar.gz` 解压到项目根目录。

---

## 🛠️ 进阶功能：命令行参数

适合配合 Crontab 或其他自动化脚本使用。

```bash
# 小白模式：测速最快的10个IP
python3 cloudflare_speedtest.py --mode beginner --count 10

# 常规模式：指定测速香港 (HKG) 地区
python3 cloudflare_speedtest.py --mode normal --region HKG

# 结果上报：测速完自动上传到 Cloudflare Workers KV
python3 cloudflare_speedtest.py --mode beginner --upload api --worker-domain your.worker.dev --uuid your-uuid
```

## 📂 结果说明
测速完成后，结果文件位于 `data` 目录下：
*   `result.csv`: 完整测速报告。
*   `ips_ports.txt`: 生成好的 IP:端口 列表，可直接导入 Clash/V2Ray 等软件。

---

## ❓ 常见问题 (FAQ) & 避坑指南

**Q: 启动容器后为什么没有出现配置菜单？/ 日志提示"检测到非交互式环境"？**
A: 这是因为使用了 `-d` 参数让容器在**后台静默运行**。
- **正确做法**：先让容器在后台跑着，然后通过以下命令“进入”容器进行配置：
  ```bash
  docker exec -it cf-speedtest python3 /app/cloudflare_speedtest.py
  ```

**Q: (热修复) 为什么我看不到 result.csv 结果文件？**
A: 如果您是早期部署的用户，结果文件可能被保存在了容器内部而不是映射的 `data` 目录。
- **解决方法**：无需重新安装，直接运行以下"热补丁"命令即可修复：
  ```bash
  docker exec cf-speedtest sed -i 's/"-o", "result.csv"/"-o", "data\/result.csv"/g' /app/cloudflare_speedtest.py
  ```
  运行后，下一次测速的结果就会自动出现在您的 `data` 目录中了。

- **如何验证任务是否运行？**
  旧版本容器无法通过 `docker logs` 查看定时任务日志（这是新版本才有的功能）。
  您可以通过检查结果文件的**修改时间**来确认：
  ```bash
  # 在宿主机运行
  ls -l data/result.csv
  ```
  只要时间在更新，就说明任务正常运行。

**Q: 我是玩客云/机顶盒 (ARM32)，需要自己下载二进制文件吗？**
A: **完全不需要！** 
- 之前的版本可能需要下载，但现在的 Docker 镜像已经**内置**了专门为 ARM32 编译好的核心组件。
- 你只需要运行 Docker 命令，它会自动识别你的设备架构并使用内置文件。

**Q: 如何确认定时任务真的设置成功了？**
A: 因为容器隔离机制，你在主机上直接输 `crontab -l` 是看不到的。
- **正确做法**：查询容器内部的任务列表：
  ```bash
  docker exec -it cf-speedtest crontab -l
  ```
  如果看到类似 `0 4 * * * ...` 的输出，就是成功了。

**Q: 怎么看每天有没有自动测速？**
A: 查看容器运行日志：
```bash
docker logs --tail 50 cf-speedtest
```

**Q: 镜像标签 (Tag) 怎么选？**
A: 请直接使用 `:latest`。
- 示例：`ghcr.io/1williamaoayers/yx-tools:latest`
- 它会自动指向最新版本，且包含所有设备架构的支持（如 amd64/arm64/arm32 等，涵盖电脑、树莓派、玩客云）。

**Q: 测速结果文件在哪里？**
A: 就在你映射的本地目录里。
- 如果你使用了推荐命令，结果在当前目录的 `data/` 文件夹内。
- `result.csv` 是详细报告，`ips_ports.txt` 可以直接复制到代理软件使用。
