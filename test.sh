echo "test" 
echo $0 
echo $1 
echo $2
read "brave?Here be dragons. Continue?"
echo $brave

# INT1 -eq INT2           INT1和INT2两数相等为真 ,=
# INT1 -ne INT2           INT1和INT2两数不等为真 ,<>
# INT1 -gt INT2            INT1大于INT1为真 ,>
# INT1 -ge INT2           INT1大于等于INT2为真,>=
# INT1 -lt INT2             INT1小于INT2为真 ,<</div>
# INT1 -le INT2             INT1小于等于INT2为真,<=

if $0 -eq '-5';then
    echo "我爱你"
fi