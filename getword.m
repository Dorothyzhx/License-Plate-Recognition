function [word,result]=getword(d)%��ȡ�ַ�
word=[];flag=0;y1=8;y2=0.5;
    while flag==0
        [m,n]=size(d);
        wide=0;
        while sum(d(:,wide+1))~=0 && wide<=n-2%�а�ɫ��1֪��û�а�ɫ��Ҳ�����ҳ�һ����ɫ����
            wide=wide+1;
        end
        temp=zifufenge(imcrop(d,[1 1 wide m]));
        [m1,n1]=size(temp);
        if wide<y1 && n1/m1>y2
            d(:,[1:wide])=0;
            if sum(sum(d))~=0
                d=zifufenge(d);  % �и����С��Χ
            else word=[];flag=1;
            end
        else
            word=zifufenge(imcrop(d,[1 1 wide m]));
            d(:,[1:wide])=0;
            if sum(sum(d))~=0;
                d=zifufenge(d);flag=1;
            else d=[];
            end
        end
    end
          result=d;

