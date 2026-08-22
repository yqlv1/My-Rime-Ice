# Rime个人配置

这是我个人的[Rime](https://rime.im/)输入法配置文件，基于[小狼毫](https://github.com/rime/weasel)和[雾凇拼音](https://github.com/iDvel/rime-ice)。本仓库用于符合我个人输入习惯的配置文件的备份，仅包含自定义的配置文件。

---

## 简介

本配置基于Windows 11平台上的小狼毫输入法，使用雾凇拼音方案，并进行了个性化的修改。主要特点包括：

- 自定义颜色接近微软输入法绿紫色主题的皮肤；
- 主输入方案为雾凇拼音的小鹤双拼方案，保留了朙月全拼作为备用方案，通过快捷键`Ctrl+Shift+S`切换；
- 添加了萌娘百科词库，方便输入ACG相关词汇；
- 通过自定义短语，键入`H`和`K`可以输入日语平假名和片假名；
- 通过lua脚本，键入`ja`后可以输入日语假名。

## 部署

1. 备份你的原配置，通常位于`%APPDATA%\Rime`目录下。
2. 按照[雾凇拼音](https://github.com/iDvel/rime-ice)的部署说明安装雾凇拼音方案。
3. 保持本仓库与Rime用户目录位于同一父目录下，例如`RimeCustomConfig`与`Rime`。双击`relink-rime.cmd`，脚本会按照`rime-links.txt`创建或修复硬链接。本仓库中的文件是配置源，目标文件内容不同时会以本仓库版本为准。
4. 点击小狼毫的“重新部署”按钮。

也可以在PowerShell中只检查链接而不修改：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\relink-rime.ps1 -CheckOnly
```

如果Rime目录不在本仓库的相邻位置，可通过`-RimeDir`指定，例如：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\relink-rime.ps1 -RimeDir "D:\path\to\Rime" -Force
```

## 更新萌娘百科词典

硬链接指向的是文件本身。删除旧文件再放入同名新文件会产生一个新的文件，原硬链接因此失效。推荐使用以下方式更新：

1. 下载新的`toneless_moe.dict.yaml`（有些版本名为`moe.dict.yaml`），不需要改名，也不必手动删除仓库中的旧词典。
2. 将下载的原文件直接拖放到`update-moe-dict.cmd`上。
3. 脚本会校验词典头，在原文件上覆写内容、核对SHA-256，并修复清单中的全部硬链接。
4. 点击小狼毫的“重新部署”按钮。

如果已经通过删除、替换文件弄断了链接，直接双击`relink-rime.cmd`即可恢复。需要部署到Rime目录的文件统一记录在`rime-links.txt`；以后增加个人配置文件时，应同时把相对路径加入该清单。

## 鸣谢

- [meotype](https://github.com/suiginko/moetype)：使用了其中的[萌娘百科](https://mzh.moegirl.org.cn/)词库；
- [電腦 Rime 洋蔥方案](https://github.com/oniondelta/Onion_Rime_Files)：使用了其中的日语输入脚本；
- 本项目的部分配置审阅、维护脚本和文档整理使用了OpenAI Codex辅助完成。
  
请遵守原作者的许可协议。
