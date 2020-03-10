JudgeSuccess()
{

    if [ $? -ne 0 ];then
        echo '              \033[1;31m此步骤失败\033[0m'
    else
        echo "              \033[1;32m此步骤成功\033[0m"

    fi
}
echo ''
echo '              \033[1;36m[cunkai.wang@foxmail.com]\033[0m'
echo '        \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m'
echo ''
echo '---第一步：通过命令删除之前的brew、创建一个新的Homebrew文件夹---'
echo '---请输入开机密码，输入过程不显示，输入完后回车---'
sudo rm -rf /usr/local/Homebrew
sudo mkdir /usr/local/Homebrew
JudgeSuccess
echo '---第二步：git克隆---'
sudo git clone https://mirrors.ustc.edu.cn/brew.git /usr/local/Homebrew
JudgeSuccess
echo '---第三步：删除原有的brew，创建一个新的---'
find /usr/local/bin -name brew -exec sudo rm -f {} \;
sudo ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew
JudgeSuccess
echo '---第四步：创建core文件夹、克隆---'
sudo mkdir -p /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
sudo git clone https://mirrors.ustc.edu.cn/homebrew-core.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
JudgeSuccess
echo '---第四步-2：创建cask文件夹、克隆---'
sudo mkdir -p /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
sudo git clone https://mirrors.ustc.edu.cn/homebrew-cask.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
JudgeSuccess
echo '---第五步：删除之前brew环境，重新创建---'
sudo rm -rf /Users/$(whoami)/Library/Caches/Homebrew/
sudo rm -rf /Users/$(whoami)/Library/Logs/Homebrew/
sudo rm -rf /usr/local/etc/bash_completion.d/brew
sudo rm -rf /usr/local/Cellar
sudo mkdir -p /usr/local/Cellar
JudgeSuccess
sudo rm -rf /usr/local/var/homebrew
sudo mkdir -p /usr/local/var/homebrew
JudgeSuccess
sudo chown -R $(whoami) /usr/local/var/homebrew
sudo chown -R $(whoami) /usr/local/Cellar
echo '---最后一步：获取权限---'
sudo chown -R $(whoami) /usr/local/Homebrew
JudgeSuccess
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
source ~/.zshrc
source ~/.bash_profile
echo '---开始运行brew update更新---'
brew update
echo ''
echo ''
echo '\033[1;36m如果提示Already up-to-date表示成功\033[0m，如果失败ctrl+c结束终端'
echo '如果\033[1;31m失败\033[0m去 https://zhuanlan.zhihu.com/p/111014448 留言我看到会回复(附带第几步出现问题)'
echo ''