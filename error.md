Mac os 常见错误说明：
Mac 10.11系统版本以下的（包括10.11），brew官方已经停止对这类老系统的支持。
0、不小心改动了brew文件夹里面的内容，如何重置，运行：
brew update-reset
1、报错提示中如果有 git -c xxxxxxx xxx xxx 等类似语句。
如果有这种提示，把报错中提供的解决语句（git -C ....）逐句运行一般就可以解决。
2、如果遇到报错中含有errno 54 / 443 / 的问题：
    这种一般切换源以后没有问题，因为都是公益服务器，不稳定性很大。
3、检测到你不是最新系统，需要自动升级 Ruby 后失败的：
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/bottles-portable-ruby

rm -rf /Users/$(whoami)/Library/Caches/Homebrew/

brew update

图标
4、如果报错 command not found : brew
先运行下面命令看是否能出来Homebrew的版本号（结果看倒数3句）
/usr/local/Homebrew/bin/brew -v      

如果是ARM架构的M1芯片运行下面这句
/opt/homebrew/bin/brew -v
再运行设置临时PATH的代码：
export PATH=/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

brew -v
如果能用就是电脑PATH配置问题，重启终端运行echo $PATH打印出来自己分析一下。
5、如果brew -v没有报错 ， brew update出错的：
      这种不影响使用，尝试再次运行brew update可能赶上服务器不稳定的一瞬间。
6、brew有一个自检程序，如果有问题自检试试：
/usr/local/bin/brew doctor
提示github.com的地址问题不用在意，因为换成国内地址了，所以警告⚠️
7、Error: Running Homebrew as root is extremely dangerous and no longer supported.
As Homebrew does not drop privileges on installation you would be giving all
build scripts full access to your system.

   原因是执行过su命令，把账户切换到了root权限，退出root权限即可。
   一般关闭终端重新打开即可，或者输入命令exit回车 或者su - 用户名
8、/usr/local/bin/brew: bad interpreter: /bin/bash^M: no such file or directory
git config --global core.autocrlf
如果显示true那就运行下面这句话可以解决：
git config --global core.autocrlf input
运行完成后，需要重新运行安装脚本。
9、from /usr/local/Homebrew/Library/Homebrew/brew.rb:23:in `<main>'
brew update-reset
10、M1芯片电脑运行which brew如果显示/usr/local/Homebrew/bin/brew
解决方法，运行卸载程序把之前的卸载掉或者手动删除/usr/local目录：
arch -x86_64 /bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh)"
