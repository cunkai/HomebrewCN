#UpdateRuby自动升级脚本
#cunkai.wang@foxmail.com
# 路径表.
HOMEBREW_PREFIX="/usr/local"
HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"

STAT="stat -f"
CHOWN="/usr/sbin/chown"
CHGRP="/usr/bin/chgrp"
GROUP="admin"

HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar/ruby"

TIME=$(date "+%Y-%m-%d %H:%M:%S")

HOMEBREW_CACHES="/Users/$(whoami)/Library/Caches/Homebrew"

#用户输入的brew版本号
if [[ $0 == ${0%%.*} ]]
then
    echo ""
else
    USER_BREW_VERSION=$0
fi

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
    echo "权限获取失败!！！"
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

#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}
#获取系统版本
macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"

#git提交
git_commit(){
    git add .
    git commit -m "提交"
}

#回退brew到git某个版本
git_back(){
  cd $HOMEBREW_PREFIX
  cd $(brew --repo)
  git_commit
  sudo git checkout master
  sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
  sudo git branch -D cunkai
  echo "==> 切换brew版本到$1"
  sudo git checkout -b cunkai $1
  JudgeSuccess
  sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
  sudo git branch
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

echo '
              \033[1;32m开始执行Ruby自动升级程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
               ['$TIME']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/113176932\033[0m
'
#提示用法
if [ -z "$USER_BREW_VERSION" ];then
    echo '
-> 为了防止系统版本和Brew版本不兼容问题；
所以本\033[1;32m脚本可以后置参数\033[0m，假设回退Brew到2.1.9版本来更新Ruby，如下写法:(当然Brew一定有Git信息才行)
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/UpdateRuby.sh)" 2.1.9
    '
else
    echo "你选择回退到brew("$USER_BREW_VERSION") 来更新Ruby和Gem"
    cd $(brew --repo)
    #循环tag判断是否输入正确
    tags='';
    ifTagInGit=0;
    for tag in $(git tag);
    do
      tags=$tags$tag"  "
      if [[ $tag == $USER_BREW_VERSION ]]; then
        ifTagInGit=1
      fi
    done

    if [ $ifTagInGit -eq 0 ]; then
        echo '\033[1;31m
版本号不正确,下面是正确的版本号：\033[0m'
        echo $tags
        echo ''
        exit 0
    else
        echo '版本号已匹配'
    fi
fi
#选择一个下载源
echo '\033[1;32m
请选择一个下载镜像，例如中科大，输入1回车。
(选择后，下载速度觉得慢可以ctrl+c重新运行脚本选择)

1、中科大下载源 2、清华大学下载源(建议)\033[0m'
read "MY_DOWN_NUM?请输入序号: "
if [[ "$MY_DOWN_NUM" -eq "2" ]];then
echo "你选择了清华大学下载源"
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles
else
echo "你选择了中国科学技术大学下载源"
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
fi
echo '==> 通过命令删除之前的缓存
(设置开机密码：在左上角苹果图标->系统偏好设置->用户与群组->更改密码)
(如果就是不想设置密码，自行百度mac sudo免密码)
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
RmCreate $HOMEBREW_CACHES
RmCreate $HOMEBREW_CELLAR
sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
#判断用户是否输入版本号
if [ -z "$USER_BREW_VERSION" ];then
  echo "$macos_version"
else
  #用户输入版本号
  git_back $USER_BREW_VERSION
fi
brew install ruby
if [ $? -ne 0 ];then
    echo '\033[1;31m此步骤失败，尝试切换下载源 或者 网络 或者 brew版本号\033[0m'
    exit 0
else
    echo "\033[1;32m此步骤成功\033[0m"
fi
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
export LDFLAGS="-L/usr/local/opt/readline/lib"
export CPPFLAGS="-I/usr/local/opt/readline/include"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
echo '\nexport PATH="/usr/local/opt/openssl@1.1/bin:$PATH"' >> ~/.zshrc
export PATH=/usr/local/opt/openssl@1.1/bin:$PATH
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
export PATH=/usr/local/opt/ruby/bin:$PATH
echo '\nexport PATH="/usr/local/opt/openssl@1.1/bin:$PATH"' >> ~/.bash_profile
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.bash_profile
source ~/.zshrc
JudgeSuccess
source ~/.bash_profile
JudgeSuccess
#系统版本低，切换回去brew版本。
if [ -z "$USER_BREW_VERSION" ];then
    echo ""
else
    cd $HOMEBREW_PREFIX
    cd $(brew --repo)
    sudo git branch
    git_commit
    echo '==> 切换brew到最新版本'
    sudo git checkout master
    JudgeSuccess
    sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
    sudo git branch -D cunkai
    sudo git branch
    brew -v
fi
echo "\033[1;31m
设置完成，还需要手动安装证书
\033[1;32m
1、去文件夹(访达中按下组合键Shift+cmd+G) /usr/local/etc/openssl@1.1/ 双击 .pem 扩展名的文件
2、终端运行 /usr/local/opt/openssl@1.1/bin/c_rehash
\033[0m

更新后Gem版本为:"
gem -v
echo "
Ruby版本为："
ruby -v