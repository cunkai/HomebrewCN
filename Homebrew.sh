#HomeBrew自动安装脚本
#cunkai.wang@foxmail.com
#brew brew brew brew

#获取系统时间
TIME=$(date "+%Y-%m-%d %H:%M:%S")
#获取硬件信息 判断inter还是苹果M
UNAME_MACHINE="$(uname -m)"
#在X86电脑上测试arm电脑
# UNAME_MACHINE="arm64"
Brew_Install="https://gitee.com/Homebrew2/install/raw/master/install.sh"

# 判断是Linux还是Mac os
OS="$(uname)"
if [[ "${OS}" == "Linux" ]]
then
  HOMEBREW_ON_LINUX=1
elif [[ "${OS}" == "Darwin" ]]
then
  HOMEBREW_ON_MACOS=1
else
  echo "Homebrew 只运行在 Mac OS 或 Linux."
fi




#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}

#判断是arm还是x86
if [[ -n "${HOMEBREW_ON_MACOS-}" ]]
then
  UNAME_MACHINE="$(/usr/bin/uname -m)"

  HOMEBREW_REPOSITORY_Arm64="/opt/homebrew"
  HOMEBREW_REPOSITORY_X86="/usr/local/Homebrew"

  if [[ "${UNAME_MACHINE}" == "arm64" ]]
  then
    # On ARM macOS, this script installs to /opt/homebrew only
    HOMEBREW_PREFIX="/opt/homebrew"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
  else
    # On Intel macOS, this script installs to /usr/local only
    HOMEBREW_PREFIX="/usr/local"
    HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  fi
  HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"
  HOMEBREW_LOGS="${HOME}/Library/Logs/Homebrew"

  STAT_PRINTF=("stat" "-f")
  PERMISSION_FORMAT="%A"
  CHOWN=("/usr/sbin/chown")
  CHGRP=("/usr/bin/chgrp")
  GROUP="admin"
  TOUCH=("/usr/bin/touch")
  INSTALL=("/usr/bin/install" -d -o "root" -g "wheel" -m "0755")
  #获取Mac系统版本
  macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"

else
  UNAME_MACHINE="$(uname -m)"

  # On Linux, this script installs to /home/linuxbrew/.linuxbrew only
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
  HOMEBREW_CACHE="${HOME}/.cache/Homebrew"
  HOMEBREW_LOGS="${HOME}/.logs/Homebrew"

  STAT_PRINTF=("stat" "--printf")
  PERMISSION_FORMAT="%a"
  CHOWN=("/bin/chown")
  CHGRP=("/bin/chgrp")
  GROUP="$(id -gn)"
  TOUCH=("/bin/touch")
  INSTALL=("/usr/bin/install" -d -o "${USER}" -g "${GROUP}" -m "0755")
fi




# 字符串染色程序
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi

tty_universal() { tty_escape "0;$1"; } #正常显示
tty_mkbold() { tty_escape "1;$1"; }    #设置高亮
tty_underline="$(tty_escape "4;39")"   #下划线
tty_blue="$(tty_universal 34)"         #蓝色
tty_red="$(tty_universal 31)"          #红色
tty_green="$(tty_universal 32)"        #绿色
tty_yellow="$(tty_universal 33)"       #黄色
tty_bold="$(tty_universal 39)"         #加黑
tty_cyan="$(tty_universal 36)"         #青色
tty_reset="$(tty_escape 0)"            #去除颜色

#判断是否执行成功
JudgeSuccess()
{
    if [ $? -ne 0 ];then
        echo "${tty_red}此步骤失败 '$1'${tty_reset}"
        if [[ "$2" == 'out' ]]; then
          exit 0
        fi
    else
        echo "${tty_green}此步骤成功${tty_reset}"

    fi
}

#发现错误 关闭脚本 提示如何解决
error_game_over() {
  echo "
    ${tty_red}失败$MY_DOWN_NUM 终端输入 ${HOMEBREW_REPOSITORY}/bin/brew -v 没有反应表示失败
    右键下面地址查看常见错误解决办法
    https://gitee.com/cunkai/HomebrewCN/blob/master/error.md
    或者别的安装方法：https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
    如果没有解决，把全部运行过程截图发到 cunkai.wang@foxmail.com ${tty_reset}
    "
  exit 0
}

RmAndCopy()
{
  if [[ -d $1 ]]; then
    echo "  ---备份要删除的$1到系统桌面，后续可把桌面的文件删除...."
    if ! [[ -d $HOME/Desktop/Old_Homebrew/$TIME/$1 ]]; then
      sudo mkdir -p "$HOME/Desktop/Old_Homebrew/$TIME/$1"
    fi
    sudo cp -rf $1 "$HOME/Desktop/Old_Homebrew/$TIME/$1"
    echo "   ---$1 备份完成"
  fi
  sudo rm -rf $1
}

#一些警告判断
warning_if() {
  git_https_proxy=$(git config --global https.proxy)
  git_http_proxy=$(git config --global http.proxy)
  if [[ -z "$git_https_proxy" && -z "$git_http_proxy" ]]; then
    echo "未发现Git代理（属于正常状态）"
  else
    echo "${tty_yellow}
      提示：发现你电脑设置了Git代理，如果Git报错，请运行下面两句话：

              git config --global --unset https.proxy

              git config --global --unset http.proxy${tty_reset}
  "
  fi
}


#调用原版Brew安装程序
start_clone_brew() {

  #引导如何设置开机密码 和 注意事项
  if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
    #MAC
    echo "${tty_yellow} Mac os设置开机密码方法：
    (设置开机密码：在左上角苹果图标->系统偏好设置->"用户与群组"->更改密码)
    (如果提示This incident will be reported. 在"用户与群组"中查看是否管理员) ${tty_reset}"
  fi

  echo "${tty_cyan}请输入开机密码，输入过程不显示，输入完后回车${tty_reset}"

  sudo echo '已获取权限
  



  '



  #询问是否删除之前的brew
  echo -n "${tty_cyan}==> 安装过程开始调用Brew官方安装脚本，提示会变成英文，看不懂的复制到在线翻译。
  如果下载速度慢可以ctrl+c或control+c重新运行脚本选择下载源${tty_reset}

  -> ${tty_red} !!!!是否删除之前本机安装的Brew（是Y  否N） 我没有检测本机是否安装brew，选哪个都会继续运行 ${tty_reset} 
  (Y/N):   "
  read MY_Del_Old
  echo "${tty_reset}"
  case $MY_Del_Old in
  "y" | "Y")
    echo "--> 脚本开始执行"
    #删除以前的Homebrew
    RmAndCopy ${HOMEBREW_REPOSITORY_Arm64}
    RmAndCopy ${HOMEBREW_REPOSITORY_X86}
    RmAndCopy $HOMEBREW_CACHE
    RmAndCopy $HOMEBREW_LOGS
    ;;
  *)
    echo "你输入了 $MY_Del_Old ，本机的老Brew未被删除，脚本开始尝试安装"
    ;;
  esac

  # 让环境暂时纯粹，脚本运行结束后恢复
  if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
    export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOMEBREW_REPOSITORY}/bin
  fi

  warning_if

  echo "         
  
              开始  进入brew官方安装脚本  开始
  
  "
    # 切换到当前用户的主目录
  cd ~

  # 接下来可以执行你需要在用户目录下运行的命令
  echo "下载官方install.sh文件,当前目录是: $(pwd)"

  sudo rm -rf brew-install-ck

  sudo git clone --depth=1 ${USER_BREW_GIT}/install.git brew-install-ck

  sudo sed -i '' "s|https://github.com/Homebrew|$USER_BREW_GIT|g" brew-install-ck/install.sh
  sudo sed -i '' 's|to continue or any|${tty_red}现在是brew官方安装提示，它需要你按回车键开始${tty_reset}|g' brew-install-ck/install.sh
  sudo sed -i '' 's|"update"|"update-reset"|g' brew-install-ck/install.sh

  #2024年添加，ruby版本只有阿里保留老版本
  sudo sed -i '' 's|#!/bin/bash|#!/bin/bash \nexport HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles|' brew-install-ck/install.sh

  
  /bin/bash brew-install-ck/install.sh
  JudgeSuccess 调用官方安装失败请查看上方报错信息 out
  
  sudo rm -rf brew-install-ck

  echo "         
  
  
                完成  退出brew官方安装脚本  完成
  
  
  "
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


#代码从这里开始执行


#判断git是否安装
git --version
if [ $? -ne 0 ]; then

  if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
    # sudo rm -rf "/Library/Developer/CommandLineTools/"
    echo "${tty_red}请安装Git${tty_reset}后再运行此脚本，${tty_red}在系统弹窗中点击“安装”按钮
    如果没有弹窗可能你系统太老了,brew只支持Mac三个大版本号 ${tty_reset}"
    xcode-select --install
    exit 1
  else
    echo "${tty_red} 发现缺少git，开始安装，请输入Y ${tty_reset}"
    sudo apt install git
  fi
fi



echo "
              ${tty_green} 开始执行Homebrew自动安装程序 ${tty_reset}
            ${tty_cyan} [cunkai.wang@foxmail.com] ${tty_reset}
          ['$TIME']['$macos_version']
      ${tty_cyan} https://zhuanlan.zhihu.com/p/111014448 ${tty_reset}
"
#选择一个brew下载源
echo -n "${tty_green}
请选择下列一个 ${tty_blue}数字编号${tty_green} 后回车
（这里只是下载brew，随意选。国内下载源有5种稍后让你选择配置）

1、通过清华大学下载brew
2、通过Gitee下载brew
3、！我已经安装brew，跳过克隆，直接带我去配置国内下载源
4、不克隆brew，只把仓库地址设置成Gitee
5、不克隆brew，只把仓库地址设置成清华大学
${tty_reset}"

echo -n "
${tty_blue}请输入序号: "
read MY_DOWN_NUM
echo "${tty_reset}"
case $MY_DOWN_NUM in
"2"|"4")
  echo "
    你选择了Gitee brew本体下载源
    "
  #HomeBrew基础框架
  USER_BREW_GIT=https://gitee.com/Homebrew2  
  ;;
"3")
  echo "
    你选择了3
    "
  ;;
*)
  echo "
    你选择了清华大学brew本体下载源
    "
  #HomeBrew基础框架
  USER_BREW_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew
  ;;
esac

if [[ $MY_DOWN_NUM == "3" ]]; then
  echo '==> 跳过brew安装，准备配置install镜像源'
elif [[ $MY_DOWN_NUM == "4" || $MY_DOWN_NUM == "5" ]]; then
  echo '==> 跳过brew安装，但配置仓库地址'
  # 尝试找到 brew 命令的路径
  brew_path=$(whence brew 2>/dev/null)

  # 检查 brew_path 是否为空
  if [ -z "$brew_path" ]; then
    echo "
        ${tty_red}
        未找到本地 brew 仓库地址。请确保 brew 在终端可以正常运行。
        ${tty_reset}
    "
    exit 0
  else
    # 解析出 brew 命令的真实路径
    real_brew_path=$(realpath "$brew_path")

    # 获取 brew 命令真实路径的父目录
    brew_parent_dir=$(dirname "$real_brew_path")
    
    # 输出父目录路径
    echo "brew 的目录是：$brew_parent_dir"
    
    # 进入目录并设置远程仓库地址
    cd "$brew_parent_dir" && git remote set-url origin "$USER_BREW_GIT/brew"

    # 检查是否成功设置远程仓库地址
    if [ $? -eq 0 ]; then
        # 验证远程仓库 URL
        echo "  ${tty_green}
                远程仓库地址已成功设置为:"
        git remote -v
        echo "
                ${tty_reset}"
    else
        echo "    ${tty_red}
                  设置远程仓库地址失败。
                  请确保本地已经安装了brew
                  ${tty_reset}
        
        "
        exit 0
    fi
  fi
else
  start_clone_brew
fi

echo "==> 配置国内镜像源HOMEBREW BOTTLE     
${tty_cyan}此处如果显示Password表示需要再次输入开机密码，输入完后回车${tty_reset}"

#判断下mac os终端是Bash还是zsh
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

if [[ -n "${HOMEBREW_ON_LINUX-}" ]]; then
  #Linux
  shell_profile="/etc/profile"
fi

# if [[ -f ${shell_profile} ]]; then
#   AddPermission ${shell_profile}
# fi
#删除之前的环境变量
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
  #Mac
  sed -i "" "/ckbrew/d" ${shell_profile}
  echo '有些电脑xcode和git混乱，再运行一次，此处如果有error正常。'
  xcode-select --install
else
  #Linux
  sed -i "/ckbrew/d" ${shell_profile}
fi

#选择一个homebrew-bottles下载源
echo -n "${tty_green}

        Homebrew已经安装成功，接下来配置国内软件下载源。

请选择今后brew install的时候访问那个国内镜像，例如阿里巴巴，输入5回车。

1、中科大国内源
2、清华大学国内源
3、上海交通大学国内源
4、腾讯国内源
5、阿里巴巴国内源(推荐) ${tty_reset}"

echo -n "
${tty_blue}请输入序号: "
read MY_DOWN_NUM
echo "${tty_reset}"
case $MY_DOWN_NUM in
"2")
  echo "
    你选择了清华大学国内源
    "
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
  USER_HOMEBREW_PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
  ;;
"3")
  echo "
    上海交通大学国内源
    "
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirror.sjtu.edu.cn/homebrew-bottles
  USER_HOMEBREW_PIP_INDEX_URL=https://mirror.sjtu.edu.cn/pypi/web/simple
  ;;
"4")
  echo "
    你选择了腾讯国内源
    "
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.cloud.tencent.com/homebrew-bottles
  USER_HOMEBREW_PIP_INDEX_URL=https://mirrors.cloud.tencent.com/pypi/simple
  ;;
"5")
  echo "
    你选择了阿里巴巴国内源
    "
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.aliyun.com/homebrew/homebrew-bottles
  USER_HOMEBREW_PIP_INDEX_URL=http://mirrors.aliyun.com/pypi/simple
  ;;
*)
  echo "
  你选择了中国科学技术大学国内源
  "
  #HomeBrew 下载源 install
  USER_HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
  USER_HOMEBREW_PIP_INDEX_URL=https://pypi.mirrors.ustc.edu.cn/simple
  ;;
esac

#写入环境变量到文件
echo "

        环境变量写入->${shell_profile}

"
#创建shell_profile文件
touch ${shell_profile}
#这里暂时把api写死吧，很多源还没有更新
echo "
  export HOMEBREW_PIP_INDEX_URL=${USER_HOMEBREW_PIP_INDEX_URL} #ckbrew
  export HOMEBREW_API_DOMAIN=${USER_HOMEBREW_BOTTLE_DOMAIN}/api  #ckbrew
  export HOMEBREW_BOTTLE_DOMAIN=${USER_HOMEBREW_BOTTLE_DOMAIN} #ckbrew
  eval \$(${HOMEBREW_REPOSITORY}/bin/brew shellenv) #ckbrew
" >>${shell_profile}
JudgeSuccess
source "${shell_profile}"
if [ $? -ne 0 ]; then
  echo "${tty_red}发现错误，${shell_profile} 文件中有错误，建议根据上一句提示修改；
                否则会导致提示 permission denied: brew${tty_reset}"
fi

# AddPermission ${HOMEBREW_REPOSITORY}

if [[ -n "${HOMEBREW_ON_LINUX-}" ]]; then
  #检测linux curl是否有安装
  echo "${tty_red}-检测curl是否安装 留意是否需要输入Y${tty_reset}"
  curl -V
  if [ $? -ne 0 ]; then
    sudo apt-get install curl
    if [ $? -ne 0 ]; then
      sudo yum install curl
      if [ $? -ne 0 ]; then
        echo '失败 请自行安装curl 可以参考https://www.howtoing.com/install-curl-in-linux'
        error_game_over
      fi
    fi
  fi
fi

echo '
==> 安装完成，brew版本
'
brew -v
if [ $? -ne 0 ]; then
  echo '发现错误，自动修复一次！'
  rm -rf $HOMEBREW_CACHE
  export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOMEBREW_REPOSITORY}/bin
  brew update-reset
  brew -v
  if [ $? -ne 0 ]; then
    error_game_over
  fi
else
  echo "${tty_green}Homebrew前期配置成功${tty_reset}"
fi

brew update
if [[ $? -ne 0 ]]; then
  echo "${tty_green}更换阿里源试试，2024.07.29很多人发的邮件显示大学的ruby版本3.3.3全部下架了${tty_reset}"
  brew config
  error_game_over
  exit 0
fi

echo "
        ${tty_green}Homebrew自动安装程序运行完成${tty_reset}
          ${tty_green}国内地址已经配置完成${tty_reset}

  ${tty_underline}之前步骤选了删除本机brew的话，桌面多出一个Old_Homebrew文件夹，可以删除。${tty_reset}

              初步介绍几个brew命令
查看版本：brew -v  更新brew版本：brew update
查找：brew search python（其中python替换为要查找的关键字）
安装：brew install python（其中python替换为要安装的名称）
本地软件库列表：brew ls

        ${tty_green}
        欢迎右键点击下方地址-打开链接 点个赞吧${tty_reset}
        ${tty_underline} https://zhuanlan.zhihu.com/p/111014448 ${tty_reset}

        如果遇到问题可以右键下面地址查看常见错误解决办法
        https://gitee.com/cunkai/HomebrewCN/blob/master/error.md

        brew官方地址：https://brew.sh/zh-cn/
"

if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
  #Mac
  echo "${tty_red} 安装成功 但还需要重启终端 或者 运行${tty_bold} source ${shell_profile}  ${tty_reset} ${tty_red}否则国内地址无法生效${tty_reset}
  "
else
  #Linux
  echo "${tty_red} Linux需要重启电脑 或者暂时运行${tty_bold} source ${shell_profile} ${tty_reset} ${tty_red}否则可能无法使用${tty_reset}
  "
fi
