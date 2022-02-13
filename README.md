# Homebrew国内源

[知乎文章地址：https://zhuanlan.zhihu.com/p/111014448](https://zhuanlan.zhihu.com/p/111014448)

苹果电脑标准安装脚本：（推荐 优点全面 缺点慢一点）


```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"

```

苹果电脑极速安装脚本：（优点安装速度快 缺点update功能需要命令修复 ）


```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" speed

```

Linux 标准安装脚本：


```
rm Homebrew.sh ; wget https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh ; bash Homebrew.sh

```

苹果电脑卸载脚本：


```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh)"

```

Linux卸载脚本：


```
rm HomebrewUninstall.sh ; wget https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh ; bash HomebrewUninstall.sh

```



 **---Brew介绍** 

macOS 和 Linux 缺失软件包的管理器

 **---Homebrew 能干什么?** 

使用 Homebrew 安装 Mac（或Linux）没有预装但你需要的东西。

 **--Homebrew自身如何使用** 

知道软件包具体名称，直接 `brew install 软件包名`
只知道一小部分名称，用 `brew search 小部分名称` 查询即可
例如`brew search chrome`就会把带chrome的软件包全部列出


![输入图片说明](%E5%BE%AE%E4%BF%A1%E5%9B%BE%E7%89%87_20220213130333.jpg)