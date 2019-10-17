function varargout = main(varargin)

% ��ʼ��ʼ������ - DO NOT EDIT
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
% ������ʼ������
pause(1);
% ִ��֮ǰ��Ҫ�ǿɼ��ġ�
function main_OpeningFcn(hObject, eventdata, handles, varargin)
set(handles.process,'enable','on')

% �˺���û������������� OutputFcn.
% main��ѡ��Ĭ�ϵ����������
handles.output = hObject;
% ����handles �ṹ
guidata(hObject, handles);
% UIWAIT �ȴ��û���Ӧ (see UIRESUME)
% uiwait(handles.figure1);

% --- ���������������ص������С�
function varargout = main_OutputFcn(hObject, eventdata, handles) 
tic
% ���ȱʡ����������İ��ֽṹ
varargout{1} = handles.output;

% --- ִ�а�ť��pushbutton1��
function pushbutton1_Callback(hObject, eventdata, handles)

[filename pathname]=uigetfile({'*.jpg';'*.bmp'}, 'File Selector');
I = imread([pathname '\' filename]);
handles.I = I;
% ���´���ṹ
guidata(hObject, handles);
axes(handles.axes1);
imshow(I);title('ԭʼͼƬ')

set(handles.process,'enable','on')
% --- ִ�й����а��°�ť��

function process_Callback(hObject, eventdata, handles)
I = handles.I;
I1=rgb2gray(I);;%rgb2grayת���ɻҶ�ͼ
guidata(hObject, handles);
axes(handles.axes2);
imshow(I1);title('�Ҷ�ͼ');
axes(handles.axes3);
imhist(I1);title('�Ҷ�ͼֱ��ͼ');
%����
pause(2);
I2=edge(I1,'roberts',0.15,'both');
guidata(hObject, handles);
axes(handles.axes2);
imshow(I2);title('robert���ӱ�Ե���');
pause(2);
se=[1;1;1];
I3=imerode(I2,se);
guidata(hObject, handles);
axes(handles.axes3);
imshow(I3);title('��ʴ��ͼ��');
%����
pause(2);
se=strel('rectangle',[10,25]);%����һ������
I4=imclose(I3,se);%������
guidata(hObject, handles);
axes(handles.axes2);
imshow(I4);title('ƽ��ͼ�������');
%����
pause(2);
I5=bwareaopen(I4,2000);%С��2000�Ķ��󶼱�ɾ��
guidata(hObject, handles);
axes(handles.axes2);
imshow(I5);title('�Ӷ������Ƴ�С����');
%����
pause(2);
[PY2,PY1,PX2,PX1]=chepai_fenge(I5);%���÷ָ��
global threshold;
[PY2,PY1,PX2,PX1,threshold]=chepai_xiuzheng(PY2,PY1,PX2,PX1);%���ó���У��
IY=I(PY1:PY2,:,:);
Plate=I5(PY1:PY2,PX1:PX2);%ʹ��caitu_tiqu
 global dw;
 dw=Plate;
PX1=PX1-1;%�Գ��������У��
 PX2=PX2+1;
  dw=I(PY1:PY2-8,PX1:PX2,:);
  axes(handles.axes2);
  imshow(dw),title('���������У��');
 pause(2);
 t=tic;
guidata(hObject, handles);
axes(handles.axes2);
imshow(IY),title('ˮƽ�����������');
axes(handles.axes3);
imshow(dw),title('��λ���к�Ĳ�ɫ����ͼ��');
pause(2);
imwrite(dw,'New number plate.jpg');
[filename,filepath]=uigetfile('New number plate.jpg','����һ����λ�ü���ĳ���ͼ��');
jpg=strcat(filepath,filename);
a=imread('New number plate.jpg');
b=rgb2gray(a);%�Զ�λ��ĳ��ƻҶȻ�
figure(3),subplot(3,2,1),imshow(b),title('���ƻҶ�ͼ��');
g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/2); %T Ϊ��ֵ������ֵ
[m,n]=size(b);
d=(double(b)>=T);  %  d:��ֵͼ��
figure(3),subplot(3,2,2),imshow(d),title('���ƶ�ֵͼ��');
figure(3),subplot(3,2,3),imshow(d),title('��ֵ�˲�ǰ');
pause(1);
h=fspecial('average',3); %��ֵ�˲���
d=im2bw(round(filter2(h,d)));
figure(3),subplot(3,2,4),imshow(d),title('��ֵ�˲���');
se=eye(2); % eye(n) returns the n-by-n identity matrix ��λ����  
%�ַ�����복�����֮����(0.235,0.365)֮��
[m,n]=size(d);  %�������0.365���ͼ����и�ʴ�����С��0.235���ͼ���������
if bwarea(d)/m/n>=0.365%�������
    d=imerode(d,se);%imerode ʵ��ͼ��ʴ dΪ������ͼ��se�ǽṹԪ�ض���
elseif bwarea(d)/m/n<=0.235
    d=imdilate(d,se);%imdilate ͼ������
end
figure(3),subplot(3,2,5),imshow(d),title('���ͻ�ʴ�����');
pause(2);
% Ѱ�����������ֵĿ飬�����ȴ���ĳ��ֵ������Ϊ�ÿ��������ַ���ɣ���Ҫ�ָ�
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
        d(:,k1+num+5)=0  % �ָ�
    end
end
% �ٷָ�
d=zifufenge(d);
% �и�� 7 ���ַ�
y1=10;y2=0.25;flag=0;word1=[];
while flag==0
    [m,n]=size(d);
    left=1;wide=0;
    while sum(d(:,wide+1))~=0
        wide=wide+1;
    end
	if wide<y1   %  ��Ϊ��������
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
% �ָ���ڶ����ַ�
[word2,d]=getword(d);
pause(1);
% �ָ���������ַ�
[word3,d]=getword(d);
pause(1);
% �ָ�����ĸ��ַ�
[word4,d]=getword(d);
pause(1);
% �ָ��������ַ�
[word5,d]=getword(d);
pause(1);
% �ָ���������ַ�
[word6,d]=getword(d);
pause(1);
% �ָ�����߸��ַ�
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
% ����ϵͳ�����й�һ����СΪ 40*20,�˴���ʾ
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
liccode=char(['0':'9' 'A':'Z' '��³��ԥ��']);  %�����Զ�ʶ���ַ������
SubBw2=zeros(40,20);  %��ʼֵ��Ϊ0����
l=1;
for I=1:7
      ii=int2str(I);%������ת��Ϊ�ַ���
     t=imread([ii,'.jpg']);
      SegBw2=imresize(t,[40 20],'nearest');%ʵ������ڲ�ֵ���Ŵ�ͼ��
        if l==1                 %��һλ����ʶ��
            kmin=37;
            kmax=41;   
            pause(1);
        elseif l==2              %�ڶ�λ A~Z ��ĸʶ��
            kmin=11;
            kmax=36;   
            pause(1);
        else l>=3              %����λ�Ժ�����ĸ������ʶ��
            kmin=1;
            kmax=36;       
        end     
        for k2=kmin:kmax
            fname=strcat('ģ���\',liccode(k2),'.jpg');  %��ȡ�ַ�ģ����е�ͼ��
            SamBw2 = imread(fname);
            for  i=1:40
                for j=1:20
                    SubBw2(i,j)=SegBw2(i,j)-SamBw2(i,j);
                end
            end
           % �����൱������ͼ����õ�������ͼ
            Dmax=0;
            for k1=1:40
                for l1=1:20
                    if  ( SubBw2(k1,l1) > 0 || SubBw2(k1,l1) <0 )
                        Dmax=Dmax+1;  %�������ͼ���Ӧ��ͼ������õ�����0��������1
                    end
                end
            end
            Error(k2)=Dmax;
        end
        Error1=Error(kmin:kmax);
        MinError=min(Error1);%���������ͼ�����õ�0������࣬��ô����ͼ�����ƶ����
        findc=find(Error1==MinError);
        Code(l*2-1)=liccode(findc(1)+kmin-1);
        Code(l*2)=' ';%ȷ��ʶ�����ͼ���ڳ����е�λ�ã��м���Ͽո�
        l=l+1;  %����ѭ��
end
guidata(hObject, handles);
axes(handles.axes3);
imshow(dw),title (['����ʶ�����:', Code],'Color','b');
pause(2);
fid = fopen('Data.xls', 'a+');
 fprintf(fid,'%s\r\n',Code,datestr(now));
 winopen('Data.xls');
 fclose(fid);
function pushbutton6_Callback(hObject, eventdata, handles)
close(gcf);

