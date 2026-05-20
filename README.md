# chrome-vnc-socat

构建可视化, 可调试的Chrome Docker Image, 实现通过端口暴露cdp协议

本仓库包含多个镜像版本，其中重点是：

- chrome-vnc-socat-134: 固定版本Chrome版本134.0.6998.88的构建, 当前主要维护
- chrome-vnc-socat-latest: 偏向最新版本的构建
- chrome-only: 仅安装 Chrome 的最小镜像

镜像包含:
- [supervisor](https://github.com/Supervisor/supervisor)
- [socat](http://www.dest-unreach.org/socat/)
- [noVNC](https://github.com/novnc/noVNC)
- [chrome](https://www.google.com/chrome/)
- [chrome-remote-desktop](https://remotedesktop.google.com/support/)
- [chrome代理插件](./copyables/proxy_extension/)
- [singlefile](https://github.com/gildas-lormeau/SingleFile)
- [chrome-extensions-reloader](https://github.com/arikw/chrome-extensions-reloader)

## 快速开始
请检查[docker-compose.yml](./docker-compose.yml)

### 本地构建

> [!CAUTION]
> 必须在仓库根目录执行
> 项目代码改动会触发构建并推送到dockerhub, 请检查[build-chrome-vnc-socat-134.yml](./.github/workflows/build-chrome-vnc-socat-134.yml)  

> [!NOTE]
> 网络问题请尝试使用注释换掉的源

```bash
docker compose build chrome-vnc-socat-134 --no-cache
```

### 本地运行

```bash
docker compose up -d cdp
```

## GitHub Action：自动构建并推送配置

- `DOCKERHUB_USERNAME`：Docker Hub username
- `DOCKERHUB_TOKEN`：Docker Hub Access Token
---

## 常见操作

### 拉取镜像

```bash
docker pull weiensong/chrome-vnc-socat:latest
```

### 查看容器日志

```bash
docker logs -f cdp
```

### 进入容器

```bash
docker exec -it cdp /bin/bash
```

### 使用noVNC查看
[http://127.0.0.1:8900/?autoconnect=1&password=secret&resize=scale&null](http://127.0.0.1:8900/?autoconnect=1&password=secret&resize=scale&null)


## 注意事项
> [!TIP]
> `chrome-vnc-socat-134/Dockerfile` 使用了仓库内 `copyables/` 的资源，构建上下文必须是仓库根目录 `.`。  
> GitHub Action 也使用 `context: .`，与本地构建保持一致，避免因上下文错误导致 `COPY` 失败。  
> 如果你更新了 Chrome 安装包或相关脚本，工作流会自动触发重新构建。  
> 首次推送前请确认 Docker Hub 仓库已创建，且 Token 具备推送权限。  


## 许可证
[MIT](./LICENSE)
