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
  git_https_proxy=$(git config --global https.proxy)
  git_http_proxy=$(git config --global http.proxy)
  if [[ -z "$git_https_proxy"  &&  -z "$git_http_proxy" ]]; then
  echo "未发现Git代理（属于正常状态）"
  else
  echo "\033[1;33m
      提示：发现你电脑设置了Git代理，如果Git报错，请运行下面两句话：

              git config --global --unset https.proxy

              git config --global --unset http.proxy
  "
  fi
}

echo '
              \033[1;32m开始执行Brew自动安装程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
           ['$TIME']['$macos_version']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m
'