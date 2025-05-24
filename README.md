<h1 align="center">
   <img src="assets/preview/nixos-logo.png" width="100px" />
   <br>
      Install loneros on NixOS!
   <br>
      <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="600px" /> <br>
   <div align="center">

   <div align="center">
      <p></p>
      <div align="center">
         <a href="https://github.com/lonerOrz/loneros-nixos/stargazers">
            <img src="https://img.shields.io/github/stars/lonerOrz/loneros-nixos?color=F5BDE6&labelColor=303446&style=for-the-badge&logo=starship&logoColor=F5BDE6">
         </a>
         <a href="https://github.com/lonerOrz/loneros-nixos/">
            <img src="https://img.shields.io/github/repo-size/lonerOrz/loneros-nixos?color=C6A0F6&labelColor=303446&style=for-the-badge&logo=github&logoColor=C6A0F6">
         </a>
         <a href="https://nixos.org">
            <img src="https://img.shields.io/badge/NixOS-Unstable-blue?style=for-the-badge&logo=NixOS&logoColor=white&label=NixOS&labelColor=303446&color=91D7E3">
         </a>
         <a href="https://github.com/lonerOrz/loneros-nixos/blob/main/LICENSE">
            <img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&colorA=313244&colorB=F5A97F&logo=unlicense&logoColor=F5A97F&"/>
         </a>
      </div>
      <br>
   </div>
</h1>

> [!IMPORTANT]
> Note! I don't use home-manager for the configuration of user files, no why.

## 🖼️ 预览

展示一些关于这个项目的截图或预览图片，可以帮助用户更直观地了解项目的效果。

![Preview 1](assets/preview/demo-1.png)
_预览图 1 - 示例描述_

![Preview 2](assets/preview/demo-2.png)
_预览图 2 - 示例描述_

---

## 🛠️ 安装

按照以下步骤安装和使用这个项目：

```bash
git clone https://github.com/lonerOrz/loneros-nixos.git
cd loneros-nixos
chmod +x install.sh
./install.sh
```

## ⚙️ 配置

可以按照如下方式进行自定义配置：

1. 编辑配置文件：

xxxxxxx

2. 更新 NixOS 配置：

nh os switch --flake .#${HOSTNAME}

## 📝 TODO

- [ ] 支持更多主题
- [ ] 解决rustdesk控制远程桌面报错hyprland门户未实现RemoteDesktop
- [ ] 编写详细的文档

---

## 🔗 配置来源

以下是一些对本项目有帮助的资源：

- [NixOS 官方文档](https://nixos.org/manual/)
- [catppuccin/nixos](https://github.com/catppuccin/nixos) - 提供了一些灵感
- [其他借鉴的仓库 1](https://github.com/example/repo1)
- [其他借鉴的仓库 2](https://github.com/example/repo2)

---
