###�ض���rm����###

#�������վĿ¼
trash_path=��~/.trash��

#�ж�$trash_path ������ļ��Ƿ���ڣ���������ڣ���ô�ʹ���$trash_path.
if [ ! -d $trash_path ]; then
mkdir -p $trash_path
fi

#���������ʹ��rm�͵���trash
alias rm=trash

#ʹ��rl�͵��á�ls ~/.trash�� �����������Ļ���վĿ¼�����Ŀ¼Ҳ��Ҫ�޸�
alias rl=��ls ~/.trash��

#ʹ��unrm�͵���restorefile
alias unrm=restorefile

#ʹ��rmtrash�͵���claearteash
alias rmtrash=cleartrash

#�ָ��ļ��ĺ���
restorefile()
{
mv -i ~/.trash/$@ ./
}

#ɾ���ļ��ĺ���
trash()
{
mv $@ ~/.trash/
}

#��ջ���վ�ĺ���
cleartrash()
{
read -p ��ȷ��Ҫ��ջ���վ��?[y/n]�� confirm
[ $confirm == ��y�� ] || [ $confirm == ��Y�� ] && /bin/rm -rf ~/.trash/*
}