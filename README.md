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
3. 将本仓库中的配置文件复制到用户文件夹中，覆盖原有的配置文件。
4. 点击“重新部署”按钮。

## 鸣谢

- [meotype](https://github.com/suiginko/moetype)：使用了其中的[萌娘百科](https://mzh.moegirl.org.cn/)词库；
- [電腦 Rime 洋蔥方案](https://github.com/oniondelta/Onion_Rime_Files)：使用了其中的日语输入脚本。
  
请遵守原作者的许可协议。
