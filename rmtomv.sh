###重定义rm命令###

#定义回收站目录
trash_path=’~/.trash’

#判断$trash_path 定义的文件是否存在，如果不存在，那么就创建$trash_path.
if [ ! -d $trash_path ]; then
mkdir -p $trash_path
fi

#定义别名：使用rm就调用trash
alias rm=trash

#使用rl就调用’ls ~/.trash’ 如果更改上面的回收站目录这里的目录也需要修改
alias rl=’ls ~/.trash’

#使用unrm就调用restorefile
alias unrm=restorefile

#使用rmtrash就调用claearteash
alias rmtrash=cleartrash

#恢复文件的函数
restorefile()
{
mv -i ~/.trash/$@ ./
}

#删除文件的函数
trash()
{
mv $@ ~/.trash/
}

#清空回收站的函数
cleartrash()
{
read -p “确定要清空回收站吗?[y/n]” confirm
[ $confirm == ‘y’ ] || [ $confirm == ‘Y’ ] && /bin/rm -rf ~/.trash/*
}