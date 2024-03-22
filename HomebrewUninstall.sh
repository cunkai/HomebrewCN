#HomeBrew卸载脚本
#cunkai.wang@foxmail.com



echo "HomeBrew卸载脚本  下面开始调用官方卸载脚本 遇到不认识的英文复制到在线翻译来理解"
rm -rf brew-uninstall
git clone --depth=1 https://gitee.com/Homebrew2/install/blob/master/install.git brew-uninstall
/bin/bash brew-uninstall/uninstall.sh
rm -rf brew-uninstall
