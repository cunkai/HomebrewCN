#UpdateRuby自动升级脚本
#cunkai.wang@foxmail.com

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

HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar/ruby"

TIME=$(date "+%Y-%m-%d %H:%M:%S")

HOMEBREW_CACHES='/Users/a2007/Library/Caches/Homebrew'

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

#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}
#获取系统版本
if [[ -z "${HOMEBREW_ON_LINUX-}" ]]; then
  macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
fi

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

echo '
              \033[1;32m开始执行Ruby自动升级程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
               ['$TIME']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/113176932\033[0m
'
sw_vers
echo '==> 通过命令删除之前的缓存
(设置开机密码：在左上角苹果图标->系统偏好设置->用户与群组->更改密码)
(如果就是不想设置密码，自行百度mac sudo免密码)
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
RmCreate ${HOMEBREW_CACHES}
sudo chown -R $(whoami) ${HOMEBREW_REPOSITORY}
#如果系统版本太低，切换brew版本。
if version_gt "$macos_version" "10.13"; then
    echo "$macos_version"
else
    cd $(brew —repo)
    git_commit
    sudo git checkou master
    sudo git branch -D cunkai
    echo '==> 切换brew版本到2.1.9'
    sudo git checkout -b cunkai 2.1.9
    JudgeSuccess
    sudo git branch
    echo '\033[1;36m开始下载ruby，老系统报gem错不用管
    等ruby下载完成更新后，gem也会一起更新版本\033[0m'
fi
RmCreate $HOMEBREW_CELLAR
brew install ruby
JudgeSuccess
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
if version_lt "$version_gt" "10.3"; then
    echo ""
else
    cd $(brew —repo)
    sudo git branch
    git_commit
    echo '==> 切换brew到最新版本'
    sudo git checkout master
    JudgeSuccess
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