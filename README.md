# chrome-vnc-socat

一个用于运行 **Chrome + VNC + noVNC + socat** 的 Docker 项目，方便远程可视化调试浏览器、容器内自动化任务以及通过 9222 暴露 DevTools 协议。

本仓库包含多个镜像版本，其中重点是：

- `chrome-vnc-socat-134`（固定 Chrome 134 的构建）
- `chrome-vnc-socat-latest`（偏向最新版本的构建）
- `chrome-only`（仅安装 Chrome 的最小镜像）
---

## 快速开始
请检查[docker-compose](./docker-compose.yml)

### 本地构建

> [!CAUTION]
> 必须在仓库根目录执行

> [!NOTE]
> 网络问题请尝试使用注释换掉的源

```bash
docker compose build chrome-vnc-socat-134 --no-cache
```

### 本地运行

```bash
docker compose up -d cdp
```
---

## GitHub Action：自动构建并推送 Docker Hub

已提供工作流文件：

- `.github/workflows/build-chrome-vnc-socat-134.yml`

触发条件：

1. 推送到 `main` 或 `master` 分支，且修改了以下路径之一：
   - `chrome-vnc-socat-134/**`
   - `copyables/**`
   - 工作流文件本身
2. 手动触发（`workflow_dispatch`）

推送镜像标签：

- `latest`（始终指向最新一次构建）
- `sha-<short_commit>`（每次提交唯一，例如 `sha-abc1234`）

每次构建会同时推送两个标签：一个可追踪版本（sha），一个滚动版本（latest）。

### 需要在 GitHub 仓库中配置的 Secrets / Variables

#### Secrets（必填）

- `DOCKERHUB_USERNAME`：Docker Hub 用户名
- `DOCKERHUB_TOKEN`：Docker Hub Access Token
---

## 常见操作

### 拉取镜像

```bash
docker pull <dockerhub-username>/chrome-vnc-socat:latest
```

### 查看容器日志

```bash
docker logs -f cdp
```

### 进入容器

```bash
docker exec -it cdp /bin/bash
```

---

## 注意事项
> [!TIP]
> 1. `chrome-vnc-socat-134/Dockerfile` 使用了仓库内 `copyables/` 的资源（脚本、deb 包等），构建上下文必须是仓库根目录 `.`。
> 2. GitHub Action 也使用 `context: .`，与本地构建保持一致，避免因上下文错误导致 `COPY` 失败。
> 3. Chrome 在构建时会直接下载固定 deb：`https://mirror.cs.uchicago.edu/google-chrome/pool/main/g/google-chrome-stable/google-chrome-stable_134.0.6998.88-1_amd64.deb`。
> 4. 如果你更新了 Chrome 安装包或相关脚本，工作流会自动触发重新构建。
> 5. 首次推送前请确认 Docker Hub 仓库已创建，且 Token 具备推送权限。

---

## 许可证
[MIT](./LICENSE)
