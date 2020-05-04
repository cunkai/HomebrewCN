echo '\033[1;32m'
read "MY_Del_Old?此脚本将要删除之前的brew(包括它下载的软件)，请自行备份。
->是否现在开始执行脚本（N/Y）"
echo '\033[0m'
case $MY_Del_Old in
"y" || "Y")
echo "--> 脚本开始执行"
;;
*)
echo "你输入了 $MY_Del_Old ，备份好以后再次运行吧,如果继续运行应该输入Y或者y"
exit 0
;;
esac