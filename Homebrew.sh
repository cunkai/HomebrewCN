
# 判断系统是否为Linux
if [[ "$(uname)" = "Linux" ]]; then
  HOMEBREW_ON_LINUX=1
fi

# 如果Mac os系统 路径： /usr/local .
# 如果Linux /home/linuxbrew/.linuxbrew
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
  HOMEBREW_PREFIX="/usr/local"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"

  STAT="stat -f"
  CHOWN="/usr/sbin/chown"
  CHGRP="/usr/bin/chgrp"
  GROUP="admin"
else
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  HOMEBREW_CACHE="${HOME}/.cache/Homebrew"

  STAT="stat --printf"
  CHOWN="/bin/chown"
  CHGRP="/bin/chgrp"
  GROUP="$(id -gn)"
fi

TIME=$(date "+%Y-%m-%d %H:%M:%S")

JudgeSuccess()
{
    if [ $? -ne 0 ];then
        echo '\033[1;31m此步骤失败\033[0m'
    else
        echo "\033[1;32m此步骤成功\033[0m"

    fi
}
# 判断是否有系统权限
have_sudo_access() {
  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]; then
    /usr/bin/sudo -l mkdir &>/dev/null
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -z "${HOMEBREW_ON_LINUX-}" ]] && [[ "$HAVE_SUDO_ACCESS" -ne 0 ]]; then
    echo "Need sudo access on macOS!"
  fi

  return "$HAVE_SUDO_ACCESS"
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

# 管理员运行
execute_sudo() {
  local -a args=("$@")
  if [[ -n "${SUDO_ASKPASS-}" ]]; then
    args=("-A" "${args[@]}")
  fi
  if have_sudo_access; then
    execute "/usr/bin/sudo" "${args[@]}"
  else
    execute "${args[@]}"
  fi
}

CreateFolder()
{
    echo '-> 创建文件夹' $1
    execute_sudo "/bin/mkdir" "-p" "$1"
    JudgeSuccess
    execute_sudo "/bin/chmod" "g+rwx" "$1"
    execute_sudo "$CHOWN" "$USER" "$1"
    execute_sudo "$CHGRP" "$GROUP" "$1"
}

RmCreate()
{
    sudo rm -rf $1
    CreateFolder $1
}

echo '
              \033[1;32m开始执行Brew自动安装程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
               ['$TIME']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m
'
echo '==> 通过命令删除之前的brew、创建一个新的Homebrew文件夹
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
RmCreate ${HOMEBREW_REPOSITORY}
echo '==> 克隆Homebrew基本文件(32M+)
如果你电脑没有Git，会弹窗提示需要安装开发者工具，点安装。'
sudo git --version
if [ $? -ne 0 ];then
  sudo rm -rf "/Library/Developer/CommandLineTools/"
  echo '安装Git后再运行此脚本，\033[1;31m在系统弹窗中点击“安装”按钮\033[0m'
  xcode-select --install
fi
sudo git clone https://mirrors.ustc.edu.cn/brew.git ${HOMEBREW_REPOSITORY}
JudgeSuccess
echo '==> 创建brew的替身'
find ${HOMEBREW_PREFIX}/bin -name brew -exec sudo rm -f {} \;
sudo ln -s ${HOMEBREW_PREFIX}/Homebrew/bin/brew ${HOMEBREW_PREFIX}/bin/brew
JudgeSuccess
echo '==> 克隆Homebrew Core(224M+) '
sudo mkdir -p ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core
sudo git clone https://mirrors.ustc.edu.cn/homebrew-core.git ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core/
JudgeSuccess
echo '==> 克隆Homebrew Cask(248M+) 类似AppStore 
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
sudo mkdir -p ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-cask
sudo git clone https://mirrors.ustc.edu.cn/homebrew-cask.git ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-cask/
JudgeSuccess
echo '==> 删除之前brew环境，重新创建
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
sudo rm -rf /Users/$(whoami)/Library/Caches/Homebrew/
sudo rm -rf /Users/$(whoami)/Library/Logs/Homebrew/
RmCreate ${HOMEBREW_PREFIX}/Caskroom
RmCreate ${HOMEBREW_PREFIX}/Cellar
RmCreate ${HOMEBREW_PREFIX}/var/homebrew
directories=(bin etc include lib sbin share var opt
             share/zsh share/zsh/site-functions
             var/homebrew var/homebrew/linked
             Cellar Caskroom Homebrew Frameworks)
for dir in "${directories[@]}"; do
  if ! [[ -d "${HOMEBREW_PREFIX}/${dir}" ]]; then
    CreateFolder "${HOMEBREW_PREFIX}/${dir}"
  fi
  sudo chown -R $(whoami) ${HOMEBREW_PREFIX}/${dir}
done
echo '==> 配置国内下载地址'
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
JudgeSuccess
source ~/.zshrc
source ~/.bash_profile
echo '
==> 安装完成，brew版本
'
brew -v
echo '
==> brew update
'
brew update
if [ $? -ne 0 ];then
    echo '
    \033[1;31m失败 留言我看到会回复(附带前面提示“此步骤失败”以及它的前6句)
    https://zhuanlan.zhihu.com/p/111014448  \033[0m
    '
else
    echo "
        \033[1;32m上一句如果提示Already up-to-date表示成功\033[0m
            \033[1;32mBrew自动安装程序运行完成\033[0m
              \033[1;32m国内地址已经配置完成\033[0m

                初步介绍几个brew命令

        本地软件库列表：brew ls
        查找软件：brew search google（其中google替换为要查找的软件关键字）
        查看brew版本：brew -v  更新brew版本：brew update

        Formulae（方案库 例如python）
        安装方案库：brew install curl（其中curl替换为要安装的软件库名称）
        卸载方案库：brew uninstall curl（其中curl替换为要卸载的软件库名称）

        Casks   （界面软件 例如谷歌浏览器）
        安装软件：brew cask install visual-studio-code（其中visual-studio-code替换为安装的软件名字，例如google-chrome）
        卸载软件：brew cask uninstall visual-studio-code（其中visual-studio-code替换为要卸载的软件名字，例如google-chrome）

        查找命令安装的位置：which brew（brew可以换成任何命令，包括brew安装的）

    \033[1;32m  https://zhuanlan.zhihu.com/p/111014448  欢迎来给点个赞，哈哈哈\033[0m
    "
fi