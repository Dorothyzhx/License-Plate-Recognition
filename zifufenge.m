function e=zifufenge(d)   %�ַ��ָ�
[m,n]=size(d);
top=1;bottom=m;  %mΪ��
left=1;right=n;  %nΪ��
while sum(d(top,:))==0 && top<=m   %�и����ɫ���򣨺��У�
    top=top+1;  
end
while sum(d(bottom,:))==0 && bottom>=1  %ͬ��
    bottom=bottom-1;
end
while sum(d(:,left))==0 && left<=n      %�и�����������У�
    left=left+1;
end
while sum(d(:,right))==0 && right>=1
    right=right-1;
end
dd=right-left;
hh=bottom-top;
e=imcrop(d,[left top dd hh]);   %��һ�����ִ�����ʾͼ��d