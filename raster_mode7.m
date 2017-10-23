clear
close all

red   = [ 0, 43, 82, 118, 153, 188, 222, 255];
green = [ 0, 43, 82, 118, 153, 188, 222, 255];
blue  = [ 0, 82, 153, 255];

i=1;
for g=0:7
    for r=0:7
        for b=0:3
            pal(i,:) = ([red(r+1) green(g+1) blue(b+1)]/255);
            i=i+1;
        end
    end
end

fid = fopen('scr8.act','w');
for i=1:256
    fwrite(fid,uint8(pal(i,:)*255),'uint8');
end
fclose(fid);


[A,MAP]= imread('mars-volcano.bmp');
% A = [A(400:400+127,400:400+255,:);A(400+127:-1:400,400:400+255,:)];
figure;
image([A;A]);
if any(size(MAP)==0)
    [A,MAP] = rgb2ind(A,256);
end
[ A , ~] = imapprox(A,MAP,pal, 'dither');
fid = fopen('plasma.bin','wb');
for i=1:min([256, size(A,1)])
    fwrite(fid,A(i,:),'uint8');
end
fclose(fid);

%---
[B,MAP]= imread('nebula256.bmp');

figure;
image(B);
colormap(MAP);
if any(size(MAP)==0)
    [B,MAP] = rgb2ind(B,256);
end
[B, MAP] = imapprox(B,MAP,pal, 'dither');
fid = fopen('galaxy.bin','wb');
for i=1:min([256, size(B,1)])
    fwrite(fid,B(i,:),'uint8');
end
fclose(fid);


!compila_ras.bat

