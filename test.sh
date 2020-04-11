execute_sudo chmod a+rwx ~/.zshrc
echo 'export HOMEBREW_BOTTLE_DOMAIN='${USER_HOMEBREW_BOTTLE_DOMAIN} >> ~/.zshrc
execute_sudo chmod a+rwx ~/.bash_profile
echo 'export HOMEBREW_BOTTLE_DOMAIN='${USER_HOMEBREW_BOTTLE_DOMAIN} >> ~/.bash_profile