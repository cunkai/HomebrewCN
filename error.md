### Mac os 常见错误说明

> Mac 10.11系统版本以下的（ **包括10.11** ）brew官方已经 **停止** 支持，有办法降级但是此安装脚本没有这个功能，太冗余。 
    


 **1.** 如果遇到安装软件报错 **404** ，切换网络如果还不行：

查看下官方更新记录` https://brew.sh/blog/ ` 如果近期有更新，可以发我邮箱cunkai.wang@foxmail.com。我看看是否官方修改了某些代码。

**2.** 不小心改动了brew文件夹里面的内容，如何重置，运行：
`brew update-reset`

**3.** 报错提示中如果有  **git -c xxxxxxx xxx xxx**  等类似语句。

  如果有这种提示，把报错中提供的解决语句（git -C ....）逐句运行一般就可以解决。

**4.** 如果遇到报错中含有errno  **54**  /  **443**  / 的问题：

    这种一般切换源以后没有问题，因为都是公益服务器，不稳定性很大。

**5.** 检测到你不是最新系统，需要自动升级 Ruby 后失败的：


```
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/bottles-portable-ruby

rm -rf /Users/$(whoami)/Library/Caches/Homebrew/

brew update
```

**6.** 如果报错  **command not found : brew** 

先运行此命令`/usr/local/Homebrew/bin/brew -v` ，如果是ARM架构的芯片运行`/opt/homebrew/bin/brew -v` 看是否能出来Homebrew的版本号。

如果能用就是电脑PATH配置问题，重启终端运行 `echo $PATH` 打印出来自己分析一下。

 **7.** Error: Running Homebrew as root is extremely dangerous and no longer supported.
As Homebrew does not drop privileges on installation you would be giving all
 **build scripts full access to your system.** 

   此报错原因是执行过su命令，把账户切换到了root权限，退出root权限即可。一般关闭终端重新打开即可，或者输入命令exit回车 或者su - 用户名

 **8.** /usr/local/bin/brew:  **bad interpreter: /bin/bash^M: no such file or directory** 

`git config --global core.autocrlf`

如果显示true那就运行下面这句话可以解决：

`git config --global core.autocrlf input`

运行完成后，需要重新运行安装脚本。

 **9.** from /usr/local/Homebrew/Library/Homebrew/ **brew.rb:23:in `<main>'** 

`brew update-reset`

 **10.** M1芯片电脑运行which brew如果显示/usr/local/Homebrew/bin/brew

解决方法，手动删除/usr/local目录，重新安装：

```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"

```
