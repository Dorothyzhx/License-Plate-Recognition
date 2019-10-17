function e=zifufenge(d)   %字符分割
[m,n]=size(d);
top=1;bottom=m;  %m为高
left=1;right=n;  %n为宽
while sum(d(top,:))==0 && top<=m   %切割出白色区域（横切）
    top=top+1;  
end
while sum(d(bottom,:))==0 && bottom>=1  %同上
    bottom=bottom-1;
end
while sum(d(:,left))==0 && left<=n      %切割出白区域（纵切）
    left=left+1;
end
while sum(d(:,right))==0 && right>=1
    right=right-1;
end
dd=right-left;
hh=bottom-top;
e=imcrop(d,[left top dd hh]);   %在一个数字窗口显示图像d