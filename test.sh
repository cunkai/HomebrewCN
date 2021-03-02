#HomeBrew自动安装脚本
#cunkai.wang@foxmail.com

#获取硬件信息
UNAME_MACHINE="$(uname -m)"

#在X86电脑上测试arm电脑
# UNAME_MACHINE="arm64"

#用户输入极速安装speed，git克隆只取最近新版本
#但是update会出错，提示需要下载全部数据
GIT_SPEED=""
if [[ $0 == "speed" ]] then
    echo "检测到参数speed，只拉去最新数据，可以正常使用！update的时候会报错，运行提示的两句话即可"
    GIT_SPEED="--depth=1"
fi

#Mac
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
  #M1
  HOMEBREW_PREFIX="/opt/homebrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
else
  #Inter
  HOMEBREW_PREFIX="/usr/local"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
fi
HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"

STAT="stat -f"
CHOWN="/usr/sbin/chown"
CHGRP="/usr/bin/chgrp"
GROUP="admin"
TOUCH="/usr/bin/touch"

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
        if [[ "$2" == 'out' ]]; then
          exit 0
        fi
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
    echo "\033[1;31m开机密码输入错误，获取权限失败!\033[0m"
  fi

  return "$HAVE_SUDO_ACCESS"
}


abort() {
  printf "%s\n" "$1"
  # exit 1
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
    abort "$(printf "\033[1;31m此命令运行失败:sudo %s\033[0m" "$(shell_join "$@")")"
  fi
}

# 字符串格式化程序
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

ohai() {
  printf "${tty_blue}运行代码 ==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

# 管理员运行
execute_sudo() 
{

  local -a args=("$@")
  if have_sudo_access; then
    if [[ -n "${SUDO_ASKPASS-}" ]]; then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}
#添加文件夹权限
AddPermission()
{
  execute_sudo "/bin/chmod" "-R" "a+rwx" "$1"
  execute_sudo "$CHOWN" "$USER" "$1"
  execute_sudo "$CHGRP" "$GROUP" "$1"
}
#创建文件夹
CreateFolder()
{
    echo '-> 创建文件夹' $1
    execute_sudo "/bin/mkdir" "-p" "$1"
    JudgeSuccess
    AddPermission $1
}

RmAndCopy()
{
  if [[ -d $1 ]]; then
    echo "  ---备份要删除的$1到系统桌面...."
    if ! [[ -d /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1 ]]; then
      mkdir -p /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1
    fi
    cp -rf $1 /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1
    echo "   ---$1 备份完成"
  fi
  sudo rm -rf $1
}

RmCreate()
{
    RmAndCopy $1
    CreateFolder $1
}

#判断文件夹存在但不可写
exists_but_not_writable() {
  [[ -e "$1" ]] && ! [[ -r "$1" && -w "$1" && -x "$1" ]]
}
#文件所有者
get_owner() {
  stat -f "%u" "$1"
}
#文件本人无权限
file_not_owned() {
  [[ "$(get_owner "$1")" != "$(id -u)" ]]
}
#获取所属的组
get_group() {
  stat -f "%g" "$1"
}
#不在所属组
file_not_grpowned() {
  [[ " $(id -G "$USER") " != *" $(get_group "$1") "*  ]]
}
#获得当前文件夹权限 例如777
get_permission() {
  stat -f "%A" "$1"
}
#授权当前用户权限
user_only_chmod() {
  [[ -d "$1" ]] && [[ "$(get_permission "$1")" != "755" ]]
}


#创建brew需要的目录 直接复制于国外版本，同步
CreateBrewLinkFolder()
{
  echo "--创建Brew所需要的目录"
  directories=(bin etc include lib sbin share opt var
             Frameworks
             etc/bash_completion.d lib/pkgconfig
             share/aclocal share/doc share/info share/locale share/man
             share/man/man1 share/man/man2 share/man/man3 share/man/man4
             share/man/man5 share/man/man6 share/man/man7 share/man/man8
             var/log var/homebrew var/homebrew/linked
             bin/brew)
  group_chmods=()
  for dir in "${directories[@]}"; do
    if exists_but_not_writable "${HOMEBREW_PREFIX}/${dir}"; then
      group_chmods+=("${HOMEBREW_PREFIX}/${dir}")
    fi
  done

  # zsh refuses to read from these directories if group writable
  directories=(share/zsh share/zsh/site-functions)
  zsh_dirs=()
  for dir in "${directories[@]}"; do
    zsh_dirs+=("${HOMEBREW_PREFIX}/${dir}")
  done

  directories=(bin etc include lib sbin share var opt
              share/zsh share/zsh/site-functions
              var/homebrew var/homebrew/linked
              Cellar Caskroom Frameworks)
  mkdirs=()
  for dir in "${directories[@]}"; do
    if ! [[ -d "${HOMEBREW_PREFIX}/${dir}" ]]; then
      mkdirs+=("${HOMEBREW_PREFIX}/${dir}")
    fi
  done

  user_chmods=()
  if [[ "${#zsh_dirs[@]}" -gt 0 ]]; then
    for dir in "${zsh_dirs[@]}"; do
      if user_only_chmod "${dir}"; then
        user_chmods+=("${dir}")
      fi
    done
  fi

  chmods=()
  if [[ "${#group_chmods[@]}" -gt 0 ]]; then
    chmods+=("${group_chmods[@]}")
  fi
  if [[ "${#user_chmods[@]}" -gt 0 ]]; then
    chmods+=("${user_chmods[@]}")
  fi

  chowns=()
  chgrps=()
  if [[ "${#chmods[@]}" -gt 0 ]]; then
    for dir in "${chmods[@]}"; do
      if file_not_owned "${dir}"; then
        chowns+=("${dir}")
      fi
      if file_not_grpowned "${dir}"; then
        chgrps+=("${dir}")
      fi
    done
  fi

  if [[ -d "${HOMEBREW_PREFIX}" ]]; then
    if [[ "${#chmods[@]}" -gt 0 ]]; then
      execute_sudo "/bin/chmod" "u+rwx" "${chmods[@]}"
    fi
    if [[ "${#group_chmods[@]}" -gt 0 ]]; then
      execute_sudo "/bin/chmod" "g+rwx" "${group_chmods[@]}"
    fi
    if [[ "${#user_chmods[@]}" -gt 0 ]]; then
      execute_sudo "/bin/chmod" "755" "${user_chmods[@]}"
    fi
    if [[ "${#chowns[@]}" -gt 0 ]]; then
      execute_sudo "$CHOWN" "$USER" "${chowns[@]}"
    fi
    if [[ "${#chgrps[@]}" -gt 0 ]]; then
      execute_sudo "$CHGRP" "$GROUP" "${chgrps[@]}"
    fi
  else
    execute_sudo "/bin/mkdir" "-p" "${HOMEBREW_PREFIX}"
    if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
      execute_sudo "$CHOWN" "root:wheel" "${HOMEBREW_PREFIX}"
    else
      execute_sudo "$CHOWN" "$USER:$GROUP" "${HOMEBREW_PREFIX}"
    fi
  fi

  if [[ "${#mkdirs[@]}" -gt 0 ]]; then
    execute_sudo "/bin/mkdir" "-p" "${mkdirs[@]}"
    execute_sudo "/bin/chmod" "g+rwx" "${mkdirs[@]}"
    execute_sudo "$CHOWN" "$USER" "${mkdirs[@]}"
    execute_sudo "$CHGRP" "$GROUP" "${mkdirs[@]}"
  fi

  if ! [[ -d "${HOMEBREW_REPOSITORY}" ]]; then
    execute_sudo "/bin/mkdir" "-p" "${HOMEBREW_REPOSITORY}"
  fi
  execute_sudo "$CHOWN" "-R" "$USER:$GROUP" "${HOMEBREW_REPOSITORY}"

  if ! [[ -d "${HOMEBREW_CACHE}" ]]; then
    if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
      execute_sudo "/bin/mkdir" "-p" "${HOMEBREW_CACHE}"
    else
      execute "/bin/mkdir" "-p" "${HOMEBREW_CACHE}"
    fi
  fi
  if exists_but_not_writable "${HOMEBREW_CACHE}"; then
    execute_sudo "/bin/chmod" "g+rwx" "${HOMEBREW_CACHE}"
  fi
  if file_not_owned "${HOMEBREW_CACHE}"; then
    execute_sudo "$CHOWN" "-R" "$USER" "${HOMEBREW_CACHE}"
  fi
  if file_not_grpowned "${HOMEBREW_CACHE}"; then
    execute_sudo "$CHGRP" "-R" "$GROUP" "${HOMEBREW_CACHE}"
  fi
  if [[ -d "${HOMEBREW_CACHE}" ]]; then
    execute "$TOUCH" "${HOMEBREW_CACHE}/.cleaned"
  fi
  echo "--依赖目录脚本运行完成"
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
  git_https_proxy=$(git config --global https.proxy)
  git_http_proxy=$(git config --global http.proxy)
  if [[ -z "$git_https_proxy"  &&  -z "$git_http_proxy" ]]; then
  echo "未发现Git代理（属于正常状态）"
  else
  echo "\033[1;33m
      提示：发现你电脑设置了Git代理，如果Git报错，请运行下面两句话：

              git config --global --unset https.proxy

              git config --global --unset http.proxy\033[0m
  "
  fi
}

echo '
              \033[1;32m开始执行Brew自动安装程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
           ['$TIME']['$macos_version']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m
'
#选择一个下载源
echo '\033[1;32m
请选择一个下载镜像，例如中科大，输入1回车。
源有时候不稳定，如果git克隆报错重新运行脚本选择源。cask非必须，有部分人需要。
1、中科大下载源 2、清华大学下载源 3、北京外国语大学下载源 4、腾讯下载源（不显示下载进度） 5、阿里巴巴下载源(缺少cask源)\033[0m'
read "MY_DOWN_NUM?请输入序号: "
case $MY_DOWN_NUM in
"2")
    echo "
    你选择了清华大学下载源"
    USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
    #HomeBrew基础框架
    USER_BREW_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    #HomeBrew Core
    USER_CORE_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    #HomeBrew Cask
    USER_CASK_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask.git
    USER_CASK_FONTS_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-fonts.git
    USER_CASK_DRIVERS_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-cask-drivers.git
;;
"3")
    echo "
    北京外国语大学下载源"
    USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
    #HomeBrew基础框架
    USER_BREW_GIT=https://mirrors.bfsu.edu.cn/git/homebrew/brew.git
    #HomeBrew Core
    USER_CORE_GIT=https://mirrors.bfsu.edu.cn/git/homebrew/homebrew-core.git
    #HomeBrew Cask
    USER_CASK_GIT=https://mirrors.bfsu.edu.cn/git/homebrew/homebrew-cask.git
    USER_CASK_FONTS_GIT=https://mirrors.bfsu.edu.cn/git/homebrew/homebrew-cask-fonts.git
    USER_CASK_DRIVERS_GIT=https://mirrors.bfsu.edu.cn/git/homebrew/homebrew-cask-drivers.git
;;
"4")
    echo "
    你选择了腾讯下载源"
    USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles
    #HomeBrew基础框架
    USER_BREW_GIT=https://mirrors.cloud.tencent.com/homebrew/brew.git 
    #HomeBrew Core
    USER_CORE_GIT=https://mirrors.cloud.tencent.com/homebrew/homebrew-core.git
    #HomeBrew Cask
    USER_CASK_GIT=https://mirrors.cloud.tencent.com/homebrew/homebrew-cask.git
;;
"5")
    echo "
    你选择了阿里巴巴下载源(阿里缺少cask源)"
    USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
    #HomeBrew基础框架
    USER_BREW_GIT=https://mirrors.aliyun.com/homebrew/brew.git 
    #HomeBrew Core
    USER_CORE_GIT=https://mirrors.aliyun.com/homebrew/homebrew-core.git
    #HomeBrew Cask
    USER_CASK_GIT=https://mirrors.aliyun.com/homebrew/homebrew-cask.git
;;
*)
  echo "
  你选择了中国科学技术大学下载源"
  #HomeBrew 下载源 install
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
  #HomeBrew基础框架
  USER_BREW_GIT=https://mirrors.ustc.edu.cn/brew.git
  #HomeBrew Core
  USER_CORE_GIT=https://mirrors.ustc.edu.cn/homebrew-core.git
  #HomeBrew Cask
  USER_CASK_GIT=https://mirrors.ustc.edu.cn/homebrew-cask.git
;;
esac
echo '\033[1;32m'
read "MY_Del_Old?！！！此脚本将要删除之前的brew(包括它下载的软件)，请自行备份。
->是否现在开始执行脚本（N/Y）"
echo '\033[0m'
case $MY_Del_Old in
"y")
echo "--> 脚本开始执行"
;;
"Y")
echo "--> 脚本开始执行"
;;
*)
echo "你输入了 $MY_Del_Old ，自行备份老版brew和它下载的软件, 如果继续运行脚本应该输入Y或者y
"
open /usr/local/
exit 0
;;
esac
echo '==> 通过命令删除之前的brew、创建一个新的Homebrew文件夹
(设置开机密码：在左上角苹果图标->系统偏好设置->"用户与群组"->更改密码)
(如果提示This incident will be reported. 在"用户与群组"中查看是否管理员)
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
sudo echo '开始执行'
# 让环境暂时纯粹，重启终端后恢复
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOMEBREW_REPOSITORY}/bin
RmCreate ${HOMEBREW_REPOSITORY}
RmAndCopy /Users/$(whoami)/Library/Caches/Homebrew/
RmAndCopy /Users/$(whoami)/Library/Logs/Homebrew/

git --version
if [ $? -ne 0 ];then
  sudo rm -rf "/Library/Developer/CommandLineTools/"
  echo '\033[1;36m安装Git\033[0m后再运行此脚本，\033[1;31m在系统弹窗中点击“安装”按钮
如果没有弹窗的老系统，需要自己下载安装：https://sourceforge.net/projects/git-osx-installer/ \033[0m'
  xcode-select --install
  exit 0
fi

echo '
\033[1;36m下载速度觉得慢可以ctrl+c或control+c重新运行脚本选择下载源\033[0m
==> 克隆Homebrew基本文件(32M+)
'
warning_if
sudo git clone ${GIT_SPEED} $USER_BREW_GIT ${HOMEBREW_REPOSITORY}
JudgeSuccess 尝试再次运行自动脚本选择其他下载源或者切换网络 out

#依赖目录创建 授权等等
CreateBrewLinkFolder

echo '==> 创建brew的替身'
if [[ "${HOMEBREW_REPOSITORY}" != "${HOMEBREW_PREFIX}" ]]; then
  find ${HOMEBREW_PREFIX}/bin -name brew -exec sudo rm -f {} \;
  execute "ln" "-sf" "${HOMEBREW_REPOSITORY}/bin/brew" "${HOMEBREW_PREFIX}/bin/brew"
fi

echo '==> 克隆Homebrew Core(224M+) 
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
sudo mkdir -p ${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-core
sudo git clone ${GIT_SPEED} $USER_CORE_GIT ${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-core/
JudgeSuccess 尝试再次运行自动脚本选择其他下载源或者切换网络 out
echo '==> 克隆Homebrew Cask(248M+) 类似AppStore 
\033[1;36m此处如果显示Password表示需要再次输入开机密码，输入完后回车\033[0m'
if [[ "$MY_DOWN_NUM" -eq "5" ]];then
  echo '\033[1;33m阿里源没有Cask 跳过\033[0m'
else
  sudo mkdir -p ${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-cask
  sudo git clone ${GIT_SPEED} $USER_CASK_GIT ${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-cask/
  if [ $? -ne 0 ];then
      sudo rm -rf ${HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-cask
      echo '\033[1;31m尝试切换下载源或者切换网络,不过Cask组件非必须模块。可以忽略\033[0m'
  else
      echo "\033[1;32m此步骤成功\033[0m"

  fi
fi
echo '==> 配置国内镜像源HOMEBREW BOTTLE'

#判断下终端是Bash还是zsh
case "$SHELL" in
  */bash*)
    if [[ -r "$HOME/.bash_profile" ]]; then
      shell_profile="${HOME}/.bash_profile"
    else
      shell_profile="${HOME}/.profile"
    fi
    ;;
  */zsh*)
    shell_profile="${HOME}/.zprofile"
    ;;
  *)
    shell_profile="${HOME}/.profile"
    ;;
esac

if [[ -f ${shell_profile} ]]; then
  AddPermission ${shell_profile}
fi
#删除之前的环境变量
sed -i "" "/ckbrew/d" ${shell_profile}
#写入环境变量到文件
echo "环境变量写入->${shell_profile}"

echo "
  export HOMEBREW_BOTTLE_DOMAIN=${USER_HOMEBREW_BOTTLE_DOMAIN} #ckbrew
  eval \$(${HOMEBREW_REPOSITORY}/bin/brew shellenv) #ckbrew
" >> ${shell_profile} 
JudgeSuccess
source "${shell_profile}"
if [ $? -ne 0 ];then
    echo "\033[1;31m发现错误，${shell_profile} 文件中有错误，建议根据上一句提示修改；
                否则会导致提示 permission denied: brew\033[0m"
fi

#判断系统版本
if version_gt "$macos_version" "10.14"; then
    echo "电脑系统版本：$macos_version"
else
    echo '\033[1;31m检测到你不是最新系统，会有一些报错，请稍等Ruby下载安装;\033[0m
    '
fi

echo '
==> 安装完成，brew版本
'
AddPermission ${HOMEBREW_REPOSITORY}
#先暂时设置到清华大学源，中科大没有Ruby下载镜像
HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles

brew -v
if [ $? -ne 0 ];then
    echo '发现错误，自动修复一次！'
    rm -rf /Users/$(whoami)/Library/Caches/Homebrew/
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOMEBREW_REPOSITORY}/bin
    brew update-reset
    if [ $? -ne 0 ];then
      echo '
      \033[1;31m还是失败 查看下面文章第二部分的常见错误
      https://zhuanlan.zhihu.com/p/111014448
      如果没有解决，把运行脚本过程截图发到 cunkai.wang@foxmail.com --end
      \033[0m'
      brew -v
      exit 0
    fi
else
    echo "\033[1;32mBrew前期配置成功\033[0m"
fi
echo '
==> brew update
'
HOMEBREW_BOTTLE_DOMAIN=${USER_HOMEBREW_BOTTLE_DOMAIN}
brew update
if [[ $? -ne 0 ] && [ $0 -ne "speed" ]];then
    echo '
    \033[1;31m失败 去下面文章看一下第二部分的常见错误解决办法
    https://zhuanlan.zhihu.com/p/111014448
    如果没有解决，把运行脚本过程截图发到 cunkai.wang@foxmail.com \033[0m
    '
else
    echo "
        \033[1;32m上一句如果提示Already up-to-date表示成功\033[0m
            \033[1;32mBrew自动安装程序运行完成\033[0m
              \033[1;32m国内地址已经配置完成\033[0m
桌面的Old_Homebrew文件夹，只是为了备份，不需要删除即可。
                初步介绍几个brew命令

        本地软件库列表：brew ls
        查找软件：brew search google（其中google替换为要查找的软件关键字）
        查看brew版本：brew -v  更新brew版本：brew update
\033[1;32m
        欢迎右键点击下方地址-打开URL 来给点个赞
        https://zhuanlan.zhihu.com/p/111014448 \033[0m
    "
fi
if [[ "$UNAME_MACHINE" == "arm64" ]]; then
  echo "\033[1;31m  M1芯片重启终端或者运行\033[1;32m source ${shell_profile}\033[1;31m  ，否则可能无法使用  \033[0m"
fi