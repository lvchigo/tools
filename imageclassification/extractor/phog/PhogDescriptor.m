function p = PhogDescriptor(Img)
%@descript: Computing the phog descriptor
%@param: img - image data, rgb or gray 
%@return: desc - the desc descriptor, float, [0.0 1.0] sum(desc) = 1
%         dimensions = 680
%@example:
%         im = imread('rice.png');
%         phog = PhogDescriptor(im);

bin = 8;
angle = 360;
L=3;

[m,n,k] = size(Img);
roi = [1;m;1;n];
if size(Img,3) == 3
    G = rgb2gray(Img);
else
    G = Img;
end
bh = [];
bv = [];

if sum(sum(G))>100
    E = edge(G,'canny');
    [GradientX,GradientY] = gradient(double(G));
    GradientYY = gradient(GradientY);
    Gr = sqrt((GradientX.*GradientX)+(GradientY.*GradientY));
            
    index = GradientX == 0;
    GradientX(index) = 1e-5;
            
    YX = GradientY./GradientX;
    if angle == 180, A = ((atan(YX)+(pi/2))*180)/pi; end
    if angle == 360, A = ((atan2(GradientY,GradientX)+pi)*180)/pi; end
                                
    [bh bv] = anna_binMatrix(A,E,Gr,angle,bin);
else
    bh = zeros(size(I,1),size(I,2));
    bv = zeros(size(I,1),size(I,2));
end

bh_roi = bh(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
bv_roi = bv(roi(1,1):roi(2,1),roi(3,1):roi(4,1));
p = anna_phogDescriptor(bh_roi,bv_roi,L,bin);
