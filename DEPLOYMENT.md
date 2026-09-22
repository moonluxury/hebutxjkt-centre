# 网站发布与日常更新

仓库：https://github.com/moonluxury/hebutxjkt-centre

这是一个静态网站，不需要安装 npm 依赖或数据库。

## 访问地址

- 新网站：http://81.70.80.234/
- 保留的旧网站：http://81.70.80.234:8080/
- GitHub Pages 开启后的地址：https://moonluxury.github.io/hebutxjkt-centre/

## 网站文件

`index.html` 位于根目录，脚本在 `js/`，样式在 `styles/`，成员照片在 `assets/team/`。修改时请保留这些目录。

发布脚本 `scripts/prepare-site.py` 检查 HTML 引用的本地文件，只将首页、脚本、样式和照片复制到 `_site/`。部署文档、凭据、工作流和服务器配置不会被发布到网页目录。

## 开启 GitHub Pages

1. 打开仓库 **Settings → Pages → Build and deployment → Source**，选择 **GitHub Actions**。
2. 打开 **Actions → Publish website** 查看运行结果。如果第一次因 Pages 尚未开启而失败，完成设置后重新运行。
3. 成功后访问上面的 GitHub Pages 地址。

`.github/workflows/pages.yml` 会在提交到 `main` 时发布网站；pull request 只执行检查，不发布。

## 腾讯云自动更新

`.github/workflows/tencent.yml` 使用专用账号 `hebut-deploy`，登录 `81.70.80.234:22`，更新 `/var/www/hebutxjkt-centre`。该账号不需要 sudo 权限。服务器首次安装、旧网站迁移及账号准备步骤见 `deploy/README.md`。

服务器账号和登录公钥准备好后，在仓库 **Settings → Secrets and variables → Actions** 中设置：

| 类型 | 名称 | 内容 |
| --- | --- | --- |
| Secret | `TENCENT_SSH_KEY` | 专用于这个发布账号的 SSH 私钥 |
| Secret | `TENCENT_KNOWN_HOSTS` | 从已登录的服务器终端核对的 SSH 主机公钥记录 |
| Repository variable | `TENCENT_DEPLOY_ENABLED` | 设置为 `true` 后启用发布 |

在 **Settings → Environments → tencent-cloud** 中将允许部署的分支限制为 `main`。不要将私钥加入仓库。

完成设置后，可从 **Actions → Publish to Tencent Cloud → Run workflow** 发布一次。以后提交到 `main` 会自动触发。未开启变量时跳过腾讯云部署，不影响 Pages 工作流。

每次发布先检查网站，将完整文件上传到新的版本目录，再切换 `current` 链接。随后检查 Nginx 返回的版本标记和首页；失败时恢复上一次链接并将任务标为失败。不会修改旧网站目录或 Nginx 配置，也不需要为每次内容更新重启服务。

## 以后如何快速修改

- 小改动：在 GitHub 编辑 `index.html`、`js/data.js` 或样式文件，然后 **Commit changes** 提交到 `main`。
- 本地修改：保存文件后，需要提交并推送到 GitHub 的 `main`。只修改电脑里的文件不会触发发布。
- 在 Actions 查看两个发布任务：绿色表示成功，红色可展开查看失败原因。服务器上的网站和 Pages 分别发布，可能在不同时间完成。
- 撤销内容：恢复需要的旧版本文件并重新提交，让发布任务再次执行。

## 检查与恢复

本地安装 Python 3.9 或更新版本后，在网站目录运行：

```text
python scripts/prepare-site.py
```

输出目录为 `_site/`。若目录已存在，用 `--output` 指定一个新目录；脚本不会覆盖或删除现有目录。

服务器的版本文件保存在 `/var/www/hebutxjkt-centre/releases/`，`current` 指向当前版本。旧版本保留以便恢复；长期使用后应检查磁盘空间并按需清理不再使用的版本。

首次首页切换的 Nginx 备份保存在 `/etc/nginx/hebut-backup.zc8ffI`。自动更新不会改动它。

## 官方文档

- https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages
- https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/use-secrets
- https://nginx.org/en/docs/beginners_guide.html
