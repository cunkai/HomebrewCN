echo '\n 更新会在：https://zhuanlan.zhihu.com/p/111014448 \n'
echo '---第一步：通过命令删除之前的brew、创建一个新的Homebrew文件夹---'
echo '---请输入开机密码，输入过程不显示，输入完后回车---'
sudo rm -rf /usr/local/Homebrew
sudo mkdir /usr/local/Homebrew
echo '---第二步：git克隆---'
sudo git clone https://mirrors.ustc.edu.cn/brew.git /usr/local/Homebrew
echo '---第三步：删除原有的brew，创建一个新的---'
sudo rm -f /usr/local/bin/brew
sudo ln -s /usr/local/Homebrew/bin/brew /usr/local/bin/brew
echo '---第四步：创建core文件夹、克隆---'
sudo mkdir -p /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
sudo git clone https://mirrors.ustc.edu.cn/homebrew-core.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
echo '---第四步-2：创建cask文件夹、克隆---'
sudo mkdir -p /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
sudo git clone https://mirrors.ustc.edu.cn/homebrew-cask.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
echo '---第五步：删除之前brew环境，重新创建---'
sudo rm -rf /usr/local/var/homebrew/ 
sudo mkdir -p /usr/local/var/homebrew
sudo chown -R $(whoami) /usr/local/var/homebrew
echo '---最后一步：获取权限 运行更新---'
sudo chown -R $(whoami) /usr/local/Homebrew
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
brew update
echo '\n ---如果提示Already up-to-date表示成功，如果失败ctrl+c结束终端，去https://zhuanlan.zhihu.com/p/111014448 留言我看到会回复--- \n'