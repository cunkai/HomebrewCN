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

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

JudgeSuccess()
{
    if [ $? -ne 0 ];then
        echo "${tty_red}m此步骤失败 '$1'${tty_reset}"
        if [[ "$2" == 'out' ]]; then
          exit 0
        fi
    else
        echo "${tty_green}此步骤成功${tty_reset}"

    fi
}

echo -n "
          ${tty_green} 开始执行Command Line Tools自动安装程序 ${tty_reset}
             ${tty_cyan} [cunkai.wang@foxmail.com] 

请输入开机密码:${tty_reset}
"

clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
sudo "touch" "$clt_placeholder"

clt_label_command="/usr/sbin/softwareupdate -l |
                    grep -B 1 -E 'Command Line Tools' |
                    awk -F'*' '/^ *\\*/ {print \$2}' |
                    sed -e 's/^ *Label: //' -e 's/^ *//'"
clt_label="$(chomp "$(/bin/bash -c "$clt_label_command")")"

if [[ -n "$clt_label" ]]; then
  echo "
  调用Apple工具Software Update Tool
  "
  sudo "/usr/sbin/softwareupdate" "-i" "$clt_label"
  JudgeSuccess 尝试再次运行自动脚本或者切换网络 out
  echo "--删除临时文件"
  sudo "/bin/rm" "-f" "$clt_placeholder"
  JudgeSuccess
  echo "--配置Tools"
  sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools"
  JudgeSuccess
fi

echo "${tty_green}
运行安装完成
${tty_reset}"