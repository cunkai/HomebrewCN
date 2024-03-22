### Mac os 常见错误说明

> [官方表示只支持最新的三个Mac os版本](https://brew.sh/blog/),老的Mac系统可以试试MacPorts。
 
.>首先确保运行的/bin/zsh -c "$(curl -fsSL https://gitee.com/ **cunkai** /HomebrewCN/raw/master/Homebrew.sh)" 中间那个 **cunkai** 不是别的。


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
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles

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

 **11.** The x86_64 architecture is required
这句话意思是，这个软件不支持M1芯片，只支持x86_64架构的CPU。

 **12.** Warning: No remote 'origin' in /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask, skipping update!

看评论区说解决方法（我未测试）：https://gitee.com/cunkai/HomebrewCN/issues/I5A7RV

 **13.** fatal: not in a git directory   Error: Command failed with exit 128: git

git config --global http.sslVerify false
