%%
folders = dir('*shift*');
%%
for i=1:size(folders,1)
    cd(folders(i,1).name)
    gunzip(dir('*.gz').name)
    cd ..
end
%%
df= flipud((double(frames(:,:,1,10))./50).');
imshow(df)
xmin=7;
ymin=3;
xmax=51;
ymax=78;
dx = 90/(xmax-xmin);
%%
nblock = 25;
bar=-10;
gaussian_sigma=2.5;

parfor j=1:size(folders,1)
    cd(['/mnt/Boyuan/April15/' folders(j,1).name])
    V=niftiread(dir('*.nii').name);
    
    frames=zeros(size(V,2),size(V,1),size(V,4));
    binarizedArray=false(2*(ymax-ymin+1),2*(xmax-xmin+1),size(V,4));
    
    for i=1:size(V,4)
        frames(:,:,i) = flipud(V(:,:,1,i).');
    end
    
    
    
    vo=VideoWriter('binarized.avi','Uncompressed AVI');
    vo.open();
    
    for i =1:size(V,4)
        f=rescale(frames(:,:,i));
        f=imadjust(1-f);
        I = uint8(255*f(ymin:ymax,xmin:xmax));
        I=imresize(I,2,'bilinear');
        I2 = imgaussfilt(I,gaussian_sigma);
        I3 = logical(cvAdaptiveThreshold(I2,nblock,bar));
        I3= bwareaopen(I3,25);
        I3=imcomplement(I3);
        I3=bwareaopen(I3,200);
        I3=imcomplement(I3);
        binarizedArray(:,:,i)=I3;
        writeVideo(vo,cat(2,double(I3*1),double(I)/255));
    end
    vo.close()
    parsave([folders(j,1).name '.mat'],binarizedArray,nblock,bar, gaussian_sigma,xmax,xmin,ymax,ymin,dx)
    
    cd ..
end
%%
for j=1:size(folders,1)
    cd(folders(j,1).name)
    load([folders(j,1).name '.mat'])
    mri_process
    cd ..  
end