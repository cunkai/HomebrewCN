#HomeBrew自动安装脚本
#cunkai.wang@foxmail.com
#路径表.
HOMEBREW_PREFIX="/usr/local"
HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
HOMEBREW_CACHE="${HOME}/Library/Caches/Homebrew"

#获取前面两个.的数据
major_minor() {
  echo "${1%%.*}.$(x="${1#*.}"; echo "${x%%.*}")"
}

#获取系统版本
macos_version="$(major_minor "$(/usr/bin/sw_vers -productVersion)")"
#获取系统时间
TIME=$(date "+%Y-%m-%d %H:%M:%S")

RmAndCopy()
{
  if [[ -d $1 ]]; then
    echo '   ---备份要删除的文件夹到系统桌面....'
    if ! [[ -d /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1 ]]; then
      mkdir -p /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1
    fi
    cp -rf $1 /Users/$(whoami)/Desktop/Old_Homebrew/$TIME/$1
    echo "   ---$1 备份完成"
  fi
  sudo rm -rf $1
}




echo '
              \033[1;32m开始执行Brew自动卸载程序\033[0m
             \033[1;36m[cunkai.wang@foxmail.com]\033[0m
           ['$TIME']['$macos_version']
       \033[1;36mhttps://zhuanlan.zhihu.com/p/111014448\033[0m
'

echo '\033[1;32m'
read "MY_Del_Old?！！！此脚本将要完全删除brew(包括它下载的软件)。
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
;;
esac
echo '==> 
(设置开机密码：在左上角苹果图标->系统偏好设置->"用户与群组"->更改密码)
(如果提示This incident will be reported. 在"用户与群组"中查看是否管理员)
\033[1;36m请输入开机密码，输入过程不显示，输入完后回车\033[0m'
sudo echo '开始执行'
# 让环境暂时纯粹，重启终端后恢复
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
RmAndCopy ${HOMEBREW_REPOSITORY}
RmAndCopy /Users/$(whoami)/Library/Caches/Homebrew/
RmAndCopy /Users/$(whoami)/Library/Logs/Homebrew/
RmAndCopy ${HOMEBREW_PREFIX}/Caskroom
RmAndCopy ${HOMEBREW_PREFIX}/Cellar
RmAndCopy ${HOMEBREW_PREFIX}/var/homebrew
directories=(bin etc include lib sbin share var opt
             share/zsh share/zsh/site-functions
             var/homebrew var/homebrew/linked
             Cellar Caskroom Homebrew Frameworks)
for dir in "${directories[@]}"; do
  if ! [[ -d "${HOMEBREW_PREFIX}/${dir}" ]]; then
    RmAndCopy "${HOMEBREW_PREFIX}/${dir}"
  fi
done

echo "

脚本运行结束，并且已经把删除过的文件夹备份到了桌面请自行删除。
现在可以输入命令open ~/.zshrc -e 或者 open ~/.bash_profile -e 删除掉brew有关的语句即可(运行 echo \$SHELL 可以查看应该打开那一个文件修改)

"