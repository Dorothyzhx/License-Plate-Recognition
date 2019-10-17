function varargout = main(varargin)

% 开始初始化代码 - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% 结束初始化代码
pause(1);
% 执行之前主要是可见的。
function main_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.process,'enable','on')

% 此函数没有输出参数，见 OutputFcn.
% main的选择默认的命令行输出
handles.output = hObject;
% 更新handles 结构
guidata(hObject, handles);
% UIWAIT 等待用户响应 (see UIRESUME)
% uiwait(handles.figure1);

% --- 这个函数的输出返回到命令行。
function varargout = main_OutputFcn(hObject, eventdata, handles) 
tic
% 获得缺省命令行输出的把手结构
varargout{1} = handles.output;

% --- 执行按钮在pushbutton1。
function pushbutton1_Callback(hObject, eventdata, handles)

[filename pathname]=uigetfile({'*.jpg';'*.bmp'}, 'File Selector');
I = imread([pathname '\' filename]);
handles.I = I;
% 更新处理结构
guidata(hObject, handles);
axes(handles.axes1);
imshow(I);title('原始图片')

set(handles.process,'enable','on')
% --- 执行过程中按下按钮。

function process_Callback(hObject, eventdata, handles)
I = handles.I;
I1=rgb2gray(I);;%rgb2gray转换成灰度图
guidata(hObject, handles);
axes(handles.axes2);
imshow(I1);title('灰度图');
axes(handles.axes3);
imhist(I1);title('灰度图直方图');
%继续
pause(2);
I2=edge(I1,'roberts',0.15,'both');
guidata(hObject, handles);
axes(handles.axes2);
imshow(I2);title('robert算子边缘检测');
pause(2);
se=[1;1;1];
I3=imerode(I2,se);
guidata(hObject, handles);
axes(handles.axes3);
imshow(I3);title('腐蚀后图像');
%继续
pause(2);
se=strel('rectangle',[10,25]);%生成一个矩阵
I4=imclose(I3,se);%闭运算
guidata(hObject, handles);
axes(handles.axes2);
imshow(I4);title('平滑图像的轮廓');
%继续
pause(2);
I5=bwareaopen(I4,2000);%小于2000的对象都被删除
guidata(hObject, handles);
axes(handles.axes2);
imshow(I5);title('从对象中移除小对象');
%继续
pause(2);
[PY2,PY1,PX2,PX1]=chepai_fenge(I5);%调用分割车牌
global threshold;
[PY2,PY1,PX2,PX1,threshold]=chepai_xiuzheng(PY2,PY1,PX2,PX1);%调用车牌校正
IY=I(PY1:PY2,:,:);
Plate=I5(PY1:PY2,PX1:PX2);%使用caitu_tiqu
 global dw;
 dw=Plate;
PX1=PX1-1;%对车牌区域的校正
 PX2=PX2+1;
  dw=I(PY1:PY2-8,PX1:PX2,:);
  axes(handles.axes2);
  imshow(dw),title('车牌区域的校正');
 pause(2);
 t=tic;
guidata(hObject, handles);
axes(handles.axes2);
imshow(IY),title('水平方向合理区域');
axes(handles.axes3);
imshow(dw),title('定位剪切后的彩色车牌图像');
pause(2);
imwrite(dw,'New number plate.jpg');
[filename,filepath]=uigetfile('New number plate.jpg','输入一个定位裁剪后的车牌图像');
jpg=strcat(filepath,filename);
a=imread('New number plate.jpg');
b=rgb2gray(a);%对定位后的车牌灰度化
figure(3),subplot(3,2,1),imshow(b),title('车牌灰度图像');
g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/2); %T 为二值化的阈值
[m,n]=size(b);
d=(double(b)>=T);  %  d:二值图像
figure(3),subplot(3,2,2),imshow(d),title('车牌二值图像');
figure(3),subplot(3,2,3),imshow(d),title('均值滤波前');
pause(1);
h=fspecial('average',3); %均值滤波器
d=im2bw(round(filter2(h,d)));
figure(3),subplot(3,2,4),imshow(d),title('均值滤波后');
se=eye(2); % eye(n) returns the n-by-n identity matrix 单位矩阵  
%字符面积与车牌面积之比在(0.235,0.365)之间
[m,n]=size(d);  %如果大于0.365则对图像进行腐蚀，如果小于0.235则对图像进行膨胀
if bwarea(d)/m/n>=0.365%计算面积
    d=imerode(d,se);%imerode 实现图像腐蚀 d为待处理图像，se是结构元素对象
elseif bwarea(d)/m/n<=0.235
    d=imdilate(d,se);%imdilate 图像膨胀
end
figure(3),subplot(3,2,5),imshow(d),title('膨胀或腐蚀处理后');
pause(2);
% 寻找连续有文字的块，若长度大于某阈值，则认为该块有两个字符组成，需要分割
d=zifufenge(d);
[m,n]=size(d);
guidata(hObject, handles);
axes(handles.axes3);imshow(d);
k1=1;k2=1;s=sum(d);j=1;
while j~=n
    while s(j)==0
        j=j+1;
    end
    k1=j;
    while s(j)~=0 && j<=n-1
        j=j+1;
    end
    k2=j-1;
    if k2-k1>=round(n/6.5)
        [val,num]=min(sum(d(:,[k1+5:k2-5])));
        d(:,k1+num+5)=0  % 分割
    end
end
% 再分割
d=zifufenge(d);
% 切割出 7 个字符
y1=10;y2=0.25;flag=0;word1=[];
while flag==0
    [m,n]=size(d);
    left=1;wide=0;
    while sum(d(:,wide+1))~=0
        wide=wide+1;
    end
	if wide<y1   %  认为是左侧干扰
	        d(:,[1:wide])=0;
        d=zifufenge(d);
    else
        temp=zifufenge(imcrop(d,[1 1 wide m]));
        [m,n]=size(temp);
        all=sum(sum(temp));
        two_thirds=sum(sum(temp([round(m/3):2*round(m/3)],:)));
        if two_thirds/all>y2
            flag=1;word1=temp;  
        end
        d(:,[1:wide])=0;
        d=zifufenge(d);
    end 
end
% 分割出第二个字符
[word2,d]=getword(d);
pause(1);
% 分割出第三个字符
[word3,d]=getword(d);
pause(1);
% 分割出第四个字符
[word4,d]=getword(d);
pause(1);
% 分割出第五个字符
[word5,d]=getword(d);
pause(1);
% 分割出第六个字符
[word6,d]=getword(d);
pause(1);
% 分割出第七个字符
[word7,d]=getword(d);
pause(1);
guidata(hObject, handles);
axes(handles.axes4);imshow(word1),title('1');
guidata(hObject, handles);
axes(handles.axes4);imshow(word2),title('2');
guidata(hObject, handles);
axes(handles.axes4);imshow(word3),title('3');
guidata(hObject, handles);
axes(handles.axes4);imshow(word4),title('4');
guidata(hObject, handles);
axes(handles.axes4);imshow(word5),title('5');
guidata(hObject, handles);
axes(handles.axes4);imshow(word6),title('6');
guidata(hObject, handles);
axes(handles.axes4);imshow(word7),title('7');
[m,n]=size(word1);
% 商用系统程序中归一化大小为 40*20,此处演示
word1=imresize(word1,[40 20]);
word2=imresize(word2,[40 20]);
word3=imresize(word3,[40 20]);
word4=imresize(word4,[40 20]);
word5=imresize(word5,[40 20]);
word6=imresize(word6,[40 20]);
word7=imresize(word7,[40 20]);
guidata(hObject, handles);
axes(handles.axes4);imshow(word1),title('1');
guidata(hObject, handles);
axes(handles.axes5);imshow(word2),title('2');
guidata(hObject, handles);
axes(handles.axes6);imshow(word3),title('3');
guidata(hObject, handles);
axes(handles.axes7);imshow(word4),title('4');
guidata(hObject, handles);
axes(handles.axes8);imshow(word5),title('5');
guidata(hObject, handles);
axes(handles.axes9);imshow(word6),title('6');
guidata(hObject, handles);
axes(handles.axes10);imshow(word7),title('7');
imwrite(word1,'1.jpg');
imwrite(word2,'2.jpg');
imwrite(word3,'3.jpg');
imwrite(word4,'4.jpg');
imwrite(word5,'5.jpg');
imwrite(word6,'6.jpg');
imwrite(word7,'7.jpg');
liccode=char(['0':'9' 'A':'Z' '桂鲁苏豫京']);  %建立自动识别字符代码表
SubBw2=zeros(40,20);  %初始值归为0矩阵
l=1;
for I=1:7
      ii=int2str(I);%将整数转换为字符串
     t=imread([ii,'.jpg']);
      SegBw2=imresize(t,[40 20],'nearest');%实用最近邻插值法放大图像
        if l==1                 %第一位汉字识别
            kmin=37;
            kmax=41;   
            pause(1);
        elseif l==2              %第二位 A~Z 字母识别
            kmin=11;
            kmax=36;   
            pause(1);
        else l>=3              %第三位以后是字母或数字识别
            kmin=1;
            kmax=36;       
        end     
        for k2=kmin:kmax
            fname=strcat('模板库\',liccode(k2),'.jpg');  %读取字符模板库中的图像
            SamBw2 = imread(fname);
            for  i=1:40
                for j=1:20
                    SubBw2(i,j)=SegBw2(i,j)-SamBw2(i,j);
                end
            end
           % 以上相当于两幅图相减得到第三幅图
            Dmax=0;
            for k1=1:40
                for l1=1:20
                    if  ( SubBw2(k1,l1) > 0 || SubBw2(k1,l1) <0 )
                        Dmax=Dmax+1;  %如果两幅图像对应的图像相减得到不是0，次数加1
                    end
                end
            end
            Error(k2)=Dmax;
        end
        Error1=Error(kmin:kmax);
        MinError=min(Error1);%如果第三幅图像所得到0数量最多，那么两幅图像相似度最高
        findc=find(Error1==MinError);
        Code(l*2-1)=liccode(findc(1)+kmin-1);
        Code(l*2)=' ';%确定识别出的图像在车牌中的位置，中间加上空格
        l=l+1;  %继续循环
end
guidata(hObject, handles);
axes(handles.axes3);
imshow(dw),title (['车牌识别号码:', Code],'Color','b');
pause(2);
fid = fopen('Data.xls', 'a+');
 fprintf(fid,'%s\r\n',Code,datestr(now));
 winopen('Data.xls');
 fclose(fid);
function pushbutton6_Callback(hObject, eventdata, handles)
close(gcf);

