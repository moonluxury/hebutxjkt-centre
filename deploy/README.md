# 腾讯云部署：新网站使用 IP 首页

目标地址为 `http://81.70.80.234/`。旧网站计划保留在 `http://81.70.80.234:8080/`。
首次安装已完成：首页提供新网站，旧网站保留在 8080；以下保留安装、迁移和自动发布设置步骤，便于维护。Nginx 原配置备份为 `/etc/nginx/hebut-backup.zc8ffI`，请保留。

## 1. 先验证旧网站的新入口

已知旧站配置位于 `/etc/nginx/sites-enabled/zgmf`，程序监听 `127.0.0.1:8000`。
在服务器上的发布包目录运行：

```bash
sudo bash deploy/stage-legacy-site.sh
```

脚本检查 8080 是否空闲，复制当前配置到独立的 `zgmf-8080` 配置，只调整监听端口，并让转发的 Host 保留端口。配置检查通过后才重载 Nginx。脚本不会覆盖已有的目标配置，不会改动旧站的 80 端口入口。

在腾讯云该实例的 **防火墙 → 添加规则** 中，放行 TCP 8080（网站需公开访问时，来源为所有 IPv4，即 `0.0.0.0/0`）。脚本会在 UFW 已启用时放行 TCP 8080；不会启用或关闭 UFW。
用浏览器打开 `http://81.70.80.234:8080/`，测试页面、登录、表单、静态资源和跳转。若仍跳回不带端口的地址，需先检查旧程序是否写死了原网址。

## 2. 准备新网站文件

若上传 ZIP 不便，可以使用 `deploy/bootstrap-from-github.sh`。它固定下载已核对的提交 `a09bf5a6cefdda03c20a0b5bb67935fbe374473d`，将仓库当前平铺的文件整理成正确目录，备份旧站入口后安装新站配置。仅用于首次安装，已有目标目录或配置时会停止。运行前须保证旧站 8080 入口已可用。

该脚本完成下述文件准备和首页切换；后续自动发布所需的专用账号、目录所有权及 SSH 密钥仍须配置。脚本创建的初始网站文件属于 root；创建 `hebut-deploy` 后，将 `/var/www/hebutxjkt-centre` 交给这个账号管理，再启用 Actions。

新网站使用专用账号 `hebut-deploy`，不授予 sudo 权限。发布目录为：

```text
/var/www/hebutxjkt-centre/
  releases/
    bootstrap/
      index.html
      assets/
      js/
      styles/
  current -> releases/bootstrap
```

准备文件时，在完整源码目录运行 `python3 scripts/prepare-site.py`，只将生成的 `_site` 内容复制到新的 `releases/bootstrap/`；已存在时不要覆盖。网页目录归 `hebut-deploy` 所有，目录权限为 755、普通文件为 644。
`current` 必须是指向 `releases/bootstrap` 的相对符号链接，而不是普通目录。

## 3. 更换 IP 首页

只有旧站 8080 已可用、新站文件已完整就位后才执行此阶段。

1. 将 `/etc/nginx/sites-enabled/zgmf` 的实际目标文件和链接信息备份到不被 Nginx include 的独立目录。
2. 将 `deploy/nginx-hebutxjkt.conf` 安装为新站配置；停用旧站的 80 端口入口，保留 `zgmf-8080`。
3. 先运行 `sudo nginx -t`，成功后再运行 `sudo systemctl reload nginx`。
4. 分别验证 IP 首页的新站和 `:8080` 上的旧站。配置检查或访问验证失败时恢复备份，验证通过后重载。

不要把旧站的配置文件删除当作迁移步骤；保留原配置，便于恢复。

## 4. 配置 GitHub 自动更新

工作流为 `.github/workflows/tencent.yml`，与 Pages 工作流分别运行。上传完整源码目录结构后，在仓库设置中完成：

- **Settings → Secrets and variables → Actions → Secrets**：
  - `TENCENT_SSH_KEY`：专门用于 `hebut-deploy` 的 SSH 私钥，GitHub Actions 使用它登录服务器。对应公钥加到该账号的 `authorized_keys`，可使用 `restrict` 公钥选项禁用端口转发等能力。
  - `TENCENT_KNOWN_HOSTS`：通过腾讯云已登录的服务器终端读取 `/etc/ssh/ssh_host_ed25519_key.pub`，将其中的密钥类型和公钥内容与 IP 组合为一行：`81.70.80.234 ssh-ed25519 公钥内容`。这是用于核对服务器身份的公钥，不是部署账号公钥。
- **同一页面 → Variables**：创建仓库变量 `TENCENT_DEPLOY_ENABLED`，值为 `true`。在前面的部署和密钥设置完成前不要开启。
- **Settings → Environments → tencent-cloud**：将允许部署的分支限制为 `main`。
- 部署账号需要可用的 Bash、rsync、curl、Python 3 和 SSH 公钥登录。22 端口需要允许发布任务连接；浏览器免密登录本身不代表 Actions 已能连接。

密钥在服务器或你的电脑上生成，通过 GitHub 设置页面填入 Secrets，不放进源码或发到聊天里。
工作流固定登录 `hebut-deploy@81.70.80.234:22`，部署账号需要可写 `/var/www/hebutxjkt-centre/`，但不需要写 Nginx 配置或重启服务的权限。

启用后，可从 **Actions → Publish to Tencent Cloud → Run workflow** 手动发布一次。以后提交到 `main` 即触发；未启用开关时，这个工作流会跳过部署。

发布先检查源文件，再把完整网站上传到一个新版本目录，通过切换 `current` 链接生效。通过本机 Nginx 检查版本标记和首页；失败则恢复上一次链接，且任务标为失败。它不改动 `/var/www/zgmf` 或 Nginx 配置。
这个检查不验证外部防火墙或浏览器交互，首次部署还需从浏览器验证两个网站。

旧版本会保留，便于恢复；本流程不自动清理磁盘，长期使用后按需检查空间并清理不再需要的版本。

## 官方文档

- https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets
- https://nginx.org/en/docs/beginners_guide.html
