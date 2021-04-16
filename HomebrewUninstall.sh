#HomeBrew自动安装脚本
#cunkai.wang@foxmail.com

#获取硬件信息
UNAME_MACHINE="$(uname -m)"

# 判断是Linux还是Mac os
OS="$(uname)"
if [[ "$OS" == "Linux" ]]; then
  HOMEBREW_ON_LINUX=1
fi

# 字符串染色程序
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_universal() { tty_escape "0;$1"; } #正常显示
tty_mkbold() { tty_escape "1;$1"; } #设置高亮
tty_underline="$(tty_escape "4;39")" #下划线
tty_blue="$(tty_universal 34)" #蓝色
tty_red="$(tty_universal 31)" #红色
tty_green="$(tty_universal 32)" #绿色
tty_yellow="$(tty_universal 33)" #黄色
tty_bold="$(tty_universal 39)" #加黑
tty_cyan="$(tty_universal 36)" #青色
tty_reset="$(tty_escape 0)" #去除颜色

#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}


#设置一些平台地址
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
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
    HOMEBREW_LOGS="${HOME}/Library/Logs/Homebrew"

    STAT="stat -f"
    CHOWN="/usr/sbin/chown"
    CHGRP="/usr/bin/chgrp"
    GROUP="admin"
    TOUCH="/usr/bin/touch"

    #获取Mac系统版本
    macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
else
  #Linux
  UNAME_MACHINE="$(uname -m)"

  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"

  HOMEBREW_CACHE="${HOME}/.cache/Homebrew"
  HOMEBREW_LOGS="${HOME}/.logs/Homebrew"

  STAT="stat --printf"
  CHOWN="/bin/chown"
  CHGRP="/bin/chgrp"
  GROUP="$(id -gn)"
  TOUCH="/bin/touch"
fi

#获取系统时间
TIME=$(date "+%Y-%m-%d %H:%M:%S")

RmAndCopy()
{
  if [[ -d $1 ]]; then
    echo "  ---备份要删除的$1到系统桌面...."
    if ! [[ -d $HOME/Desktop/Old_Homebrew/$TIME/$1 ]]; then
      sudo mkdir -p "$HOME/Desktop/Old_Homebrew/$TIME/$1"
    fi
    sudo cp -rf $1 "$HOME/Desktop/Old_Homebrew/$TIME/$1"
    echo "   ---$1 备份完成"
  fi
  sudo rm -rf $1
}




echo "
              ${tty_green} 开始执行Brew自动卸载程序 ${tty_reset}
             ${tty_cyan} [cunkai.wang@foxmail.com] ${tty_reset}
           ['$TIME']['$macos_version']
       ${tty_cyan} https://zhuanlan.zhihu.com/p/111014448 ${tty_reset}
"

echo -n "$tty_green ！！！此脚本将要完全删除brew(包括它下载的软件)。
->是否现在开始执行脚本（N/Y）"
read MY_Del_Old
echo "${tty_reset}"
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
;;
esac
echo "==>$tty_cyan 请输入开机密码，输入过程不显示，输入完后回车 $tty_reset"
sudo echo '开始执行'

RmAndCopy ${HOMEBREW_REPOSITORY}
RmAndCopy $HOMEBREW_CACHE
RmAndCopy $HOMEBREW_LOGS

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
#删除之前的环境变量
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
  #Mac
  sed -i "" "/ckbrew/d" ${shell_profile}
else
  #Linux
  sed -i "/ckbrew/d" ${shell_profile}
fi

echo "
$tty_green
脚本运行结束，删除的文件备份到了桌面Old_Homebrew文件夹中，请自行删除。
$tty_reset
"