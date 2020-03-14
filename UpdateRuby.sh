JudgeSuccess()
{
    if [ $? -ne 0 ];then
        echo '\033[1;31m此步骤失败\033[0m'
    else
        echo "\033[1;32m此步骤成功\033[0m"

    fi
}

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