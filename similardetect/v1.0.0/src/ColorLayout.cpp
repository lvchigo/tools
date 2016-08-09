#include <math.h>
#include <iostream>
using namespace std;

#include "ColorLayout.h"

namespace SIMILARDETECT_INTERNAL{

#ifndef M_PI
#define M_PI (3.14159265358979323846)
#endif

#ifndef FLT_MAX
#define FLT_MAX 10000000000.0
#endif

#ifndef MABS
//fast abs of integer number
#define MABS(x)                (((x)+((x)>>31))^((x)>>31))     
#endif //MABS

unsigned char zigzag_scan[64]={        /* Zig-Zag scan pattern  */
	0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
	12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
	35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
	58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
};

#define NUMBEROFYCOEFF 6
#define NUMBEROFCCOEFF 3

#define WIDTH	256
#define HEIGHT	256

//double c[8][8]; /* transform coefficients 转化系数 */

void CreateSmallImage(IplImage *src, int small_img[3][64]);

void init_fdct(double trans_coffe[8][8]);

inline void fdct(int *block,double trans_coffe[8][8]);

inline int quant_ydc(int i);

inline int quant_cdc(int i);

inline int quant_ac(int i);

void GetBGRChannelData(IplImage *img, unsigned char *B, unsigned char *G, unsigned char *R)
{
	char *pImgData = img->imageData;

	int nImgSize = img->width*img->height;
	int counter = 0;
	for(int i = 0; i < nImgSize; i++)
	{
		char b = 0, g = 0, r = 0;

		b = pImgData[counter];
		g = pImgData[counter+1];
		r = pImgData[counter+2];

		B[i] = (unsigned char)b;
		G[i] = (unsigned char)g;
		R[i] = (unsigned char)r;

		counter += 3;
	}

	return;
}

void ColorLayoutExtractor(IplImage *Image, unsigned char CLD[],int cld_len)
{
	if(!Image)	
		return;
	// 统一为256 * 256 
	IplImage *ImageMedia = cvCreateImage(cvSize(WIDTH, HEIGHT), Image->depth, Image->nChannels);
	cvResize(Image, ImageMedia);
	double  coffe[8][8];
    for(int i = 0; i < 8; i++)
	{
		for(int j= 0; j < 8; j++)
		{
			coffe[i][j]  = 0.0f;
		}
	}
	
	// Descriptor data // y cb cr空间
	int NumberOfYCoeff = NUMBEROFYCOEFF; // 6
	int NumberOfCCoeff = NUMBEROFCCOEFF; // 3
	
	if(NumberOfYCoeff < 1) 
		NumberOfYCoeff = 1;
	else if(NumberOfYCoeff > 64) 
		NumberOfYCoeff = 64;
	if(NumberOfCCoeff < 1) 
		NumberOfCCoeff = 1;
	else if(NumberOfCCoeff > 64) 
		NumberOfCCoeff = 64;

	//初始化系数
	init_fdct(coffe);

	int small_img[3][64];
	CreateSmallImage(ImageMedia, small_img);

	//dct变换 
	fdct(small_img[0],coffe); // y 
	fdct(small_img[1],coffe); // cb
	fdct(small_img[2],coffe); //cr

	int YCoeff[64], CbCoeff[64], CrCoeff[64];
	YCoeff[0]=quant_ydc(small_img[0][0]/8)>>1;
	CbCoeff[0]=quant_cdc(small_img[1][0]/8);
	CrCoeff[0]=quant_cdc(small_img[2][0]/8);

	for(int i=1;i<64;i++)
	{
		YCoeff[i]=quant_ac((small_img[0][(zigzag_scan[i])])/2)>>3;
		CbCoeff[i]=quant_ac(small_img[1][(zigzag_scan[i])])>>3;
		CrCoeff[i]=quant_ac(small_img[2][(zigzag_scan[i])])>>3;
	}

   
	int cldCounter = 0;
    int Coeffnum = 3;
	if(cld_len == 18)
	{
        Coeffnum = 6;
	}

	for(int i = 0; i < 6; i++)
		CLD[cldCounter++] = (unsigned char)YCoeff[i];
	for(int i = 0; i < Coeffnum; i++)
		CLD[cldCounter++] = (unsigned char)CbCoeff[i];
	for(int i = 0; i < Coeffnum; i++)
		CLD[cldCounter++] = (unsigned char)CrCoeff[i];

	cvReleaseImage(&ImageMedia);

	return;
}

// 8x8 DCT 
// init_fdct and fdct are developed by MPEG Software Simulation Group
void init_fdct(double trans_coffe[8][8])
{
	//#define COMPUTE_COS
	int i, j;
#ifdef COMPUTE_COS
	double s;
#else // for memory debugging!!
	double d_cos [8][8] =
	{{3.535534e-01, 3.535534e-01, 3.535534e-01, 3.535534e-01,
	3.535534e-01, 3.535534e-01, 3.535534e-01, 3.535534e-01},
	{4.903926e-01, 4.157348e-01, 2.777851e-01, 9.754516e-02,
	-9.754516e-02, -2.777851e-01, -4.157348e-01, -4.903926e-01},
	{4.619398e-01, 1.913417e-01, -1.913417e-01, -4.619398e-01,
	-4.619398e-01, -1.913417e-01, 1.913417e-01, 4.619398e-01},
	{4.157348e-01, -9.754516e-02, -4.903926e-01, -2.777851e-01,
	2.777851e-01, 4.903926e-01, 9.754516e-02, -4.157348e-01},
	{3.535534e-01, -3.535534e-01, -3.535534e-01, 3.535534e-01,
	3.535534e-01, -3.535534e-01, -3.535534e-01, 3.535534e-01},
	{2.777851e-01, -4.903926e-01, 9.754516e-02, 4.157348e-01,
	-4.157348e-01, -9.754516e-02, 4.903926e-01, -2.777851e-01},
	{1.913417e-01, -4.619398e-01, 4.619398e-01, -1.913417e-01,
	-1.913417e-01, 4.619398e-01, -4.619398e-01, 1.913417e-01},
	{9.754516e-02, -2.777851e-01, 4.157348e-01, -4.903926e-01,
	4.903926e-01, -4.157348e-01, 2.777851e-01, -9.754516e-02}};
#endif

	for (i=0; i<8; i++){
#ifdef COMPUTE_COS
		s = (i==0) ? sqrt(0.125) : 0.5;
#endif
		for (j=0; j<8; j++) {
#ifdef COMPUTE_COS
			trans_coffe[i][j] = s * cos((M_PI/8.0)*i*(j+0.5));
			fprintf(stderr,"%le ", trans_coffe[i][j]);
#else
			trans_coffe[i][j] = d_cos [i][j];

#endif
		}
	}
}

//----------------------------------------------------------------------------
void fdct(int *block, double trans_coffe[8][8])
{
	int i, j, k;
	double s;
	double tmp[64];

	for (i=0; i<8; i++)
	{
		for (j=0; j<8; j++)
		{
			s = 0.0;

			for (k=0; k<8; k++)
			{ 
				s += trans_coffe[j][k] * block[8*i+k];
			}
				
			tmp[8*i+j] = s;
		}
	}

	for (j=0; j<8; j++)
	{
		for (i=0; i<8; i++)
		{
			s = 0.0;
			for (k=0; k<8; k++) 
				s += trans_coffe[i][k] * tmp[8*k+j];
			block[8*i+j] = (int)floor(s+0.499999);
		}
	}
}
//
//  End of routines those are developed by MPEG Software Simulation Group
//

//----------------------小图像片------------------------------------------------------
void CreateSmallImage(IplImage *src, int small_img[3][64])
{
	int y_axis, x_axis;
	int i, j, k ;
	int x, y;
	int small_block_sum[3][64];
	int cnt[64];
	int src_width = src->width;
	int src_height= src->height; 

	// 初始化数据 
	for(i = 0; i < 64 ; i++)
	{
		cnt[i]=0;
		for( j = 0;j < 3;j++)
		{
			small_block_sum[j][i]=0;
			small_img[j][i] = 0;
		}
	}

	int nSize = src_width * src_height;
	unsigned char *pChannelB = new unsigned char[nSize];
	unsigned char *pChannelG = new unsigned char[nSize];
	unsigned char *pChannelR = new unsigned char[nSize];

	GetBGRChannelData(src, pChannelB, pChannelG, pChannelR);

	unsigned char *pB = pChannelB;
	unsigned char *pG = pChannelG;
	unsigned char *pR = pChannelR;

	int R, G, B;
	double yy = 0;
	for(y=0; y<src->height; y++)
	{
		for(x=0; x<src->width; x++)
		{
			y_axis = (int)(y/(src->height/8.0));
			x_axis = (int)(x/(src->width/8.0));
			k = y_axis * 8 + x_axis;

			G = *pG++;
			B = *pB++;
			R = *pR++;

			// RGB to YCbCr
			yy = ( 0.299*R + 0.587*G + 0.114*B)/256.0; 
			small_block_sum[0][k] += (int)(219.0 * yy + 16.5); // Y
			small_block_sum[1][k] += (int)(224.0 * 0.564 * (B/256.0*1.0 - yy) + 128.5); // Cb
			small_block_sum[2][k] += (int)(224.0 * 0.713 * (R/256.0*1.0 - yy) + 128.5); // Cr

			cnt[k]++;
		}
	}

	// create 8x8 image
	for(i=0; i<8; i++){
		for(j=0; j<8; j++){
			for(k=0; k<3; k++){
				if(cnt[i*8+j]) 
					small_img[k][i*8+j] = (small_block_sum[k][i*8+j] / cnt[i*8+j]);
				else 
					small_img[k][i*8+j] = 0;
			}
		}
	}

	delete [] pChannelB;
	delete [] pChannelG;
	delete [] pChannelR;
}

//----------------------------------------------------------------------------
int quant_ydc(int i)
{
	int j;
	if(i>191) j=112+(i-192)/4;
	else if(i>159) j=96+(i-160)/2;
	else if(i>95) j=32+(i-96);
	else if(i>63) j=16+(i-64)/2;
	else j=i/4;
	return j;
}

//----------------------------------------------------------------------------
int quant_cdc(int i)
{
	int j;
	if(i>191) j=63;
	else if(i>159) j=56+(i-160)/4;
	else if(i>143) j=48+(i-144)/2;
	else if(i>111) j=16+(i-112);
	else if(i>95) j=8+(i-96)/2;
	else if(i>63) j=(i-64)/4;
	else j=0;
	return j;
}

//----------------------------------------------------------------------------
int quant_ac(int i)
{
	int j;
	if(i>239) i= 239;
	if(i<-256) i= -256;
	if ((abs(i)) > 127) j= 64 + (abs(i))/4;
	else if ((abs(i)) > 63) j=32+(abs(i))/2;
	else j=abs(i);
	j = (i<0)?-j:j;
	j+=132;
	return j;
}

//-----------------------------------------------------------------------------
double CLDDist(int CLD1[], int CLD2[])
{
	double DY = sqrt((double)
		(2*(CLD1[0] - CLD2[0])*(CLD1[0] - CLD2[0]) + 
		2*(CLD1[1] - CLD2[1])*(CLD1[1] - CLD2[1]) + 
		2*(CLD1[2] - CLD2[2])*(CLD1[2] - CLD2[2]) +
		1*(CLD1[3] - CLD2[3])*(CLD1[3] - CLD2[3]) + 
		1*(CLD1[4] - CLD2[4])*(CLD1[4] - CLD2[4]) + 
		1*(CLD1[5] - CLD2[5])*(CLD1[5] - CLD2[5]))
		);

	double DCb = sqrt((double)
		(2*(CLD1[6] - CLD2[6])*(CLD1[6] - CLD2[6]) + 
		1*(CLD1[7] - CLD2[7])*(CLD1[7] - CLD2[7]) + 
		1*(CLD1[8] - CLD2[8])*(CLD1[8] - CLD2[8]))
		);

	double DCr = sqrt((double)
		(4*(CLD1[9] - CLD2[9])*(CLD1[9] - CLD2[9]) + 
		2*(CLD1[10] - CLD2[10])*(CLD1[10] - CLD2[10]) + 
		2*(CLD1[11] - CLD2[11])*(CLD1[11] - CLD2[11]))
		);

	double D = DY + DCb + DCr;

	return D;
};




///////////////////////////////////////////////////////////////////////////////////////

#define CLD_COLOR_DIM      72    //使用
#define CLD_SINGLE_DIM     18 
#define BLOB_NUM         	2 
#define MIN_IMAGE_WIDTH  	32 
#define MIN_IMAGE_HEIGHT 	32

// carla 修改为 提取特征向量
void MultiBlock_LayoutExtractor(IplImage *img, unsigned char *LayoutFV)
{
	if(!img && !LayoutFV) 
		return;

	int partion_size,partion_count; 
	unsigned char *LocalLayoutFV = NULL; 
	unsigned char  CLD[CLD_SINGLE_DIM];
	IplImage *partion_img = NULL, *imgFile = NULL; //分割后的图像内容 
	bool      image_resolution_error; 

	image_resolution_error = false; 
	int width    = img->width; 
	int height   = img->height;
	int partion_width, partion_height; 
	int partion_x,partion_y; 
	int half_width, half_height; 

	imgFile   = cvCreateImage(cvSize(width, height), img->depth,img->nChannels); 
	//cvCopyImage(img, imgFile);
	cvCopy(img, imgFile);
	partion_size = 6; 
	half_width   = width >>1;
	half_height  = height >>1; 

	//先不采用交叠的思想
	LocalLayoutFV = LayoutFV;

	for (int i = 0; i < BLOB_NUM; i++)
	{   
		//获取分割后的图像
		image_resolution_error = false; 
		switch(i)
		{
		case 0: // 原图
			{   
				partion_width  = width;
				partion_height = height; 
				partion_img    = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);
				cvCopy(imgFile, partion_img);
				//CopyImage(imgFile, partion_img);
			}
			break;
		case 1: // middle
			{    
				partion_width  = half_width;
				partion_height = half_height;
				partion_x = width >>2;
				partion_y = height >>2;

				partion_img = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);
				cvSetImageROI(imgFile,cvRect(partion_x,partion_y, partion_width, partion_height));
				
				//cvCopyImage(imgFile, partion_img);
				cvCopy(imgFile, partion_img);

				cvResetImageROI(imgFile);
			}
			break;
		case 2:  //top_left
			{
				partion_width  = half_width;
				partion_height = half_height;
				partion_x = 0;
				partion_y = 0;

				partion_img = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);
				cvSetImageROI(imgFile,cvRect(partion_x,partion_y,partion_width, partion_height));
				cvCopy(imgFile, partion_img);
				//cvCopyImage(imgFile, partion_img);
				cvResetImageROI(imgFile);
			}
			break;
		case 3: //top_right
			{   
				partion_width  = half_width;
				partion_height = half_height;
				partion_x = width / 2;
				partion_y = 0;

				partion_img = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);
				cvSetImageROI(imgFile,cvRect(partion_x,partion_y,partion_width, partion_height));
				cvCopy(imgFile, partion_img);
				//cvCopyImage(imgFile, partion_img);
				cvResetImageROI(imgFile);
			}
			break;
		case 4: // bottom_left
			{
				partion_width  = half_width;
				partion_height = half_height;
				partion_x = 0;
				partion_y = height / 2;
				partion_img = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);
				cvSetImageROI(imgFile,cvRect(partion_x,partion_y,partion_width, partion_height));
				cvCopy(imgFile, partion_img);
				//cvCopyImage(imgFile, partion_img);
				cvResetImageROI(imgFile);
			}
			break;
		case 5: //bottom_right
			{
				partion_width  = half_width;
				partion_height = half_height;
				partion_x = width / 2;
				partion_y = height / 2;
				partion_img = cvCreateImage(cvSize(partion_width, partion_height), imgFile->depth, imgFile->nChannels);

				cvSetImageROI(imgFile,cvRect(partion_x, partion_y,partion_width, partion_height));
				//cvCopyImage(imgFile, partion_img);
				cvCopy(imgFile, partion_img);
				cvResetImageROI(imgFile);
			}
			break;
		default:
			break; 
		} // end swtich

		//分析是否高宽比较小，切割后的
		int enlarge_width, enlarge_height;
		enlarge_width  = partion_img->width;
		enlarge_height = partion_img->height;

		if(enlarge_width < MIN_IMAGE_WIDTH)
		{
			enlarge_width = MIN_IMAGE_WIDTH;
			image_resolution_error = true; 
		}

		if(enlarge_height < MIN_IMAGE_HEIGHT)
		{
			enlarge_height         = MIN_IMAGE_HEIGHT;
			image_resolution_error = true; 
		}

		if(image_resolution_error )
		{
			//继续缩放操作
			IplImage* enlarge_img = cvCreateImage(cvSize(enlarge_width,enlarge_height), imgFile->depth, imgFile->nChannels);
			cvResize(partion_img, enlarge_img, CV_INTER_LINEAR); 
			cvReleaseImage(&partion_img);
			partion_img = 0; 
			partion_img = cvCreateImage(cvSize(enlarge_width,enlarge_height), imgFile->depth, imgFile->nChannels);
			//cvCopyImage(enlarge_img, partion_img); 
			cvCopy(enlarge_img, partion_img);
			cvReleaseImage(&enlarge_img);
			enlarge_img = NULL; 
		}

		// 注意判断图像的大小，是否满足最小分块要求
		memset(CLD, 0, CLD_SINGLE_DIM * sizeof(unsigned char));

		ColorLayoutExtractor(partion_img, CLD,CLD_SINGLE_DIM);
		//提取主色 

		for(int j = 0; j < CLD_SINGLE_DIM; j++)
			LocalLayoutFV[j] = CLD[j];
		LocalLayoutFV  += CLD_SINGLE_DIM;

		if(partion_img)
		{
			cvReleaseImage(&partion_img); 
			partion_img = NULL;
		}

	} // end for

	if (imgFile)
	{
		cvReleaseImage(&imgFile); 
	}

	return;

}

} //end of namespace
