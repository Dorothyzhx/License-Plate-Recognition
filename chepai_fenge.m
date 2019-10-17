function [PY2,PY1,PX2,PX1]=chepai_fenge(I5)
[y,x,z]=size(I5);
myI=double(I5);
%begin横向扫描
tic
Y_threshlow=5; %这个数值很重要。决定了提取的彩图的质量
X_firrectify=5;
%=== Y 方向===从左向右寻找第一个1值像素大于5的坐标为水平方向左侧分界线，从优向左寻找到第一个1值像素量大于5的为右侧分界线
Blue_y=zeros(y,1);
for i=1:y
    for j=1:x
        if(myI(i,j,1)==1)%如果myI(i,j,1)即myI图像中坐标为(i,j)的点为白色
         %则Blue_y的相应行的元素white_y(i,1)值加1
           Blue_y(i,1)= Blue_y(i,1)+1;     % 蓝色象素点统计                    
        end  
    end       
end
        [temp MaxY]=max(Blue_y);% Y方向车牌区域确定 temp(最多点数):所有行中，最多的累积像素点 MaxY（最多点所在行）:该行中蓝点最多
         PY1=MaxY;%有最多蓝点的行付给PY1
        while ((Blue_y(PY1,1)>=Y_threshlow)&&(PY1>1))%找到图片上边界
            PY1=PY1-1;
        end 
       
        %PY1：存储车牌上边界值
        PY2=MaxY;
        while ((Blue_y(PY2,1)>=Y_threshlow)&&(PY2<y))%阈值为5
             PY2=PY2+1;
        end
       PY1, PY2 %原始图像I中截取的纵坐标在PY1：PY2之间的部分
    figure(1),imshow(Blue_y),title('y方向确定');
    pause(2);
    %==============X 方向===============================
        X_threshhigh=(PY2-PY1)/11;%这个数值很重要。决定了提取的彩图的质量,适当提高可抗干扰，但是小图会照成剪裁太多
        Blue_x=zeros(1,x);             % 进一步确定X方向的车牌区域
        for j=1:x
            for i=PY1:PY2
                if(myI(i,j,1)==1)
                 Blue_x(1,j)= Blue_x(1,j)+1;               
                end  
            end       
        end
        [temp MaxX]=max(Blue_x);
        PX1=MaxX-6*(PY2-PY1);
        if  PX1<=1
            PX1=1;
        end
        while ((Blue_x(1,PX1)<=X_threshhigh)&&(PX1<x))%阈值
              PX1=PX1+1;
        end               %确定出X方向车牌起点   
        PX2=MaxX+6*(PY2-PY1);
        if  PX2>=x
            PX2=x;
        end
        while ((Blue_x(1,PX2)<=X_threshhigh)&&(PX2>PX1))%阈值
               PX2=PX2-1;
        end            %确定出X方向车牌终点
        PX1 ,PX2
     figure(2),imshow(Blue_x),title('X方向确定');    