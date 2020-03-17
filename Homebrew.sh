#HomeBrew自动安装脚本
#cunkai.wang@foxmail.com
#路径表.
HOMEBREW_PREFIX="/usr/local"
HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"

STAT="stat -f"
CHOWN="/usr/sbin/chown"
CHGRP="/usr/bin/chgrp"
GROUP="admin"

#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}

#获取系统版本
macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
#获取系统时间
TIME=$(date "+%Y-%m-%d %H:%M:%S")

JudgeSuccess()
{
    if [ $? -ne 0 ];then
        echo '\033[1;31m此步骤失败 '$1'\033[0m'
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

  if [[ "$HAVE_SUDO_ACCESS" -ne 0 ]]; then
    echo "获取权限失败!"
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

#git提交
git_commit(){
    git add .
    git commit -m "your del"
}

#version_gt 判断$1是否大于$2
version_gt() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -gt "${2#*.}" ]]
}
#version_ge 判断$1是否大于等于$2
version_ge() {
  [[ "${1%.*}" -gt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -ge "${2#*.}" ]]
}
#version_lt 判断$1是否小于$2
version_lt() {
  [[ "${1%.*}" -lt "${2%.*}" ]] || [[ "${1%.*}" -eq "${2%.*}" && "${1#*.}" -lt "${2#*.}" ]]
}

#一些警告判断
warning_if(){
  git_proxy=$(git config --global https.proxy)
  if [[ -z "$git_proxy" ]]; then
  echo "未发现Git代理（属于正常状态）"
  else
  echo "\033[1;33m
      提示：发现你电脑设置了Git代理，如果后面Git报错，请运行下面这句话：
              git config --global --unset https.proxy
  "
  fi
}

echo '
              \033[1;32m开始执行Brew自动安装程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
               ['$TIME']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m
'
#选择一个下载源
echo '\033[1;32m
请选择一个下载镜像，例如中科大，输入1回车。
(选择后，下载速度觉得慢可以ctrl+c重新运行脚本选择)

1、中科大下载源 2、清华大学下载源\033[0m'
read "MY_DOWN_NUM?请输入序号: "
if [[ "$MY_DOWN_NUM" -eq "2" ]];then
  echo "你选择了清华大学下载源"
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
  #HomeBrew基础框架
  USER_BREW_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
  #HomeBrew Core
  USER_CORE_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
  #HomeBrew Cask
  USER_CASK_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
  USER_CASK_FONTS_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
  USER_CASK_DRIVERS_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
else
  echo "你选择了中国科学技术大学下载源"
  #HomeBrew 下载源 install
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
  #HomeBrew基础框架
  USER_BREW_GIT=https://mirrors.ustc.edu.cn/brew.git
  #HomeBrew Core
  USER_CORE_GIT=https://mirrors.ustc.edu.cn/homebrew-core.git
  #HomeBrew Cask
  USER_CASK_GIT=https://mirrors.ustc.edu.cn/homebrew-cask.git
fi
echo '==> 通过命令删除之前的brew、创建一个新的Homebrew文件夹
(设置开机密码：在左上角苹果图标->系统偏好设置->用户与群组->更改密码)
(如果就是不想设置密码，自行百度mac sudo免密码)
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
# 让环境暂时纯粹，重启终端后恢复
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
RmCreate ${HOMEBREW_REPOSITORY}
echo '==> 删除之前brew环境，重新创建'
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
warning_if
echo '==> 克隆Homebrew基本文件(32M+)'
sudo git --version
if [ $? -ne 0 ];then
  sudo rm -rf "/Library/Developer/CommandLineTools/"
  echo '\033[1;36m安装Git\033[0m后再运行此脚本，\033[1;31m在系统弹窗中点击“安装”按钮
如果没有弹窗的老系统，需要自己下载安装：https://git-scm.com/downloads \033[0m'
  xcode-select --install
  exit 0
fi
sudo git clone $USER_BREW_GIT ${HOMEBREW_REPOSITORY}
JudgeSuccess 尝试切换下载源或者网络
echo '==> 创建brew的替身'
find ${HOMEBREW_PREFIX}/bin -name brew -exec sudo rm -f {} \;
sudo ln -s ${HOMEBREW_PREFIX}/Homebrew/bin/brew ${HOMEBREW_PREFIX}/bin/brew
JudgeSuccess
echo '==> 克隆Homebrew Core(224M+) 
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
sudo mkdir -p ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core
sudo git clone $USER_CORE_GIT ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-core/
JudgeSuccess 尝试切换下载源或者网络
echo '==> 克隆Homebrew Cask(248M+) 类似AppStore 
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
sudo mkdir -p ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-cask
sudo git clone $USER_CASK_GIT ${HOMEBREW_PREFIX}/Homebrew/Library/Taps/homebrew/homebrew-cask/
JudgeSuccess 尝试切换下载源或者网络
echo '==> 配置国内下载地址'
echo 'export HOMEBREW_BOTTLE_DOMAIN='${USER_HOMEBREW_BOTTLE_DOMAIN} >> ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN='${USER_HOMEBREW_BOTTLE_DOMAIN} >> ~/.bash_profile
JudgeSuccess
source ~/.zshrc
source ~/.bash_profile
echo '
==> 安装完成，brew版本
'
#判断系统版本
if version_gt "$macos_version" "10.13"; then
    echo "$macos_version"
else
    echo '\033[1;31m检测到你的系统比较老，会有一些报错，请稍等Ruby下载安装;'
fi

sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
#先暂时设置到清华大学源，中科大没有Ruby下载镜像
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
brew -v
if [ $? -ne 0 ];then
    echo '
    \033[1;31m失败 留言我看到会回复(附带前面提示“此步骤失败”以及它的前6句)
    https://zhuanlan.zhihu.com/p/111014448
    或者所有命令截图发到 cunkai.wang@foxmail.com  \033[0m
    '
    exit 0
else
    echo "\033[1;32mBrew前期配置成功\033[0m"
fi
echo '
==> brew update
'
HOMEBREW_BOTTLE_DOMAIN=${USER_HOMEBREW_BOTTLE_DOMAIN}
brew update
if [ $? -ne 0 ];then
    echo '
    \033[1;31m失败 留言我看到会回复(附带前面提示“此步骤失败”以及它的前6句)
    https://zhuanlan.zhihu.com/p/111014448
    或者所有命令截图发到 cunkai.wang@foxmail.com  \033[0m
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
\033[1;32m
现在可以输入命令open ~/.zshrc 或者 open ~/.bash_profile 整理一下重复的语句(运行 echo \$SHELL 可以查看应该打开那一个文件修改)

        https://zhuanlan.zhihu.com/p/111014448  欢迎来给点个赞\033[0m
    "
fi