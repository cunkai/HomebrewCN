#HomeBrew卸载脚本
#cunkai.wang@foxmail.com

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

#选择一个brew卸载源
echo -n "${tty_green}
请输入下列一个数字编号后回车

1、清华大学源  卸载脚本
2、Gitee源  卸载脚本
${tty_reset}"

echo -n "
${tty_blue}请输入序号: "
read MY_DOWN_NUM
echo "${tty_reset}"
case $MY_DOWN_NUM in
"1")
  echo "
    你选择了清华大学brew卸载脚本
    "
  #HomeBrew基础框架
  USER_BREW_GIT=https://mirrors.tuna.tsinghua.edu.cn/git/homebrew
  ;;
*)
  echo "
    你选择了Gitee brew卸载脚本
    "
  #HomeBrew基础框架
  USER_BREW_GIT=https://gitee.com/Homebrew2  
  ;;
esac


echo "${tty_red}HomeBrew卸载脚本  下面开始调用官方卸载脚本 遇到不认识的英文复制到在线翻译来理解${tty_reset}
"
rm -rf brew-uninstall
git clone --depth=1 ${USER_BREW_GIT}/install.git brew-uninstall
/bin/bash brew-uninstall/uninstall.sh
rm -rf brew-uninstall
