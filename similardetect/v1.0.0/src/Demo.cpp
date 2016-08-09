#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <dirent.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/stat.h> 

#include <iostream>
#include <sstream>
#include <fstream>
#include <string>
#include <vector>
#include "cv.h"
#include "cxcore.h"
#include "highgui.h"

#include "TErrorCode.h"
#include "SD_global.h"

using namespace std;

#define _TIME_STATISTICS_
#define THREAD_NUM    8

#ifdef _TIME_STATISTICS_
#include <sys/time.h>

static double timeSum = 0.0;
static int  nCount = 0;

vector<string> s_vecFile;

double difftimeval(const struct timeval *tv1, const struct timeval *tv2)
{
        double d;
        time_t s;
        suseconds_t u;

        s = tv1->tv_sec - tv2->tv_sec;
        u = tv1->tv_usec - tv2->tv_usec;
        d = 1000000.0 * s  + u ;
        return d;
}
#endif //_TIME_STATISTICS_

inline long GetIDFromFilePath(const char *filepath)
{
	long ID = 0;
	int atom =0;
	string tmpPath = filepath;
	for (int i=tmpPath.rfind('/')+1;i<tmpPath.rfind('.');i++)
	{
		atom = filepath[i] - '0';
		if (atom < 0 || atom >9)
			break;
		ID = ID * 10 + atom;
	}
	return ID;
}

string GetSrtingIDFromFilePath(const char *filepath)
{
	string ID;
	char szID[512] = {0};
	string tmpPath = filepath;
	for (int i=tmpPath.rfind('/')+1;i<tmpPath.rfind('.');i++)
	{
		szID[i] = filepath[i];
	}
	ID = szID;
	return ID;
}

/***********************************getRandomID***********************************/
void getRandomID( unsigned long long &randomID )
{
	int i,atom =0;
	randomID = 0;
	
	//time
	time_t nowtime = time(NULL);
	tm *now = localtime(&nowtime);

	char szTime[1024];
	sprintf(szTime, "%04d%02d%02d%02d%02d%02d%d",
			now->tm_year+1900, now->tm_mon+1, now->tm_mday,now->tm_hour, now->tm_min, now->tm_sec,(rand()%10000) );
	//printf("szTime Name:%s\n",szTime);

	string tmpID = szTime;
	for ( i=0;i<tmpID.size();i++)
	{
		atom = szTime[i] - '0';
		if (atom < 0 || atom >9)
			break;
		randomID = randomID * 10 + atom;
	}
}

int SimilarDetectSingle(char *szFileList, char *szKeyFiles, int ClassID, int subClassID, int BinSaveFeat)
{
	IplImage *img = 0;
	int  ret = 0;
	long ImageID;
	char szImgPath[512];
	FILE *fpListFile = 0 ;
	std::vector<int> resultVect;
	SD_RES result;
	SD_GLOBAL_1_1_0::ClassInfo ci;
	vector < SD_GLOBAL_1_1_0::ClassInfo > classList;

#ifdef _TIME_STATISTICS_
    struct timeval tv1;
    struct timeval tv2;
	double timeOnce;
#endif

	fpListFile = fopen(szFileList,"r");
	if (!fpListFile) 
	{
		cout << "0.can't open" << szFileList << endl;
		goto ERR;
	}

	ret  = SD_GLOBAL_1_1_0::Init(szKeyFiles); //加载资源
	if (ret != 0)
	{
	   cout<<"can't open"<< szKeyFiles<<endl;
	   goto ERR;
	}
	ci.ClassID = ClassID;
	ci.SubClassID = subClassID;
	classList.push_back(ci);
	ret = SD_GLOBAL_1_1_0::LoadClassData(classList);
	if (ret != 0)
	{
	   cout<<"Fail to LoadClassData. Error code:"<< ret << endl;
	   goto ERR;
	}
	while( EOF != fscanf(fpListFile, "%s", szImgPath))
	{
		ImageID = GetIDFromFilePath(szImgPath);

		img = cvLoadImage(szImgPath, 1);					//待提取特征图像文件
		if(!img) 
		{	
			cout<<"can't open " << szImgPath << ",or unsupported image format!! "<< endl;
			//goto ERR;
			continue;
		}	
#ifdef _TIME_STATISTICS_	
		gettimeofday(&tv1, NULL);
#endif //_TIME_STATISTICS_
		ret = SD_GLOBAL_1_1_0::SimilarDetect(img, (UInt64)ImageID, ClassID, subClassID,&result,BinSaveFeat);
#ifdef _TIME_STATISTICS_
		gettimeofday(&tv2, NULL);
		timeOnce = difftimeval(&tv2, &tv1);
		timeSum += timeOnce; 
		nCount++;
#endif //_TIME_STATISTICS_

		if (TOK == ret)
		{
			printf("%lld\t%lld\t%d\n",(UInt64)ImageID,result.id,result.sMode);
		}
		else if (ret == TEC_UNSUPPORTED)
		{
			cout<< szImgPath << " is unsupported image format!! "<< endl;
			continue;
		}
		cvReleaseImage(&img);
		img = 0;
	}

ERR:
	//释放资源
	SD_GLOBAL_1_1_0::Uninit();

	if (img)	
		cvReleaseImage(&img);

	if (fpListFile) {
		fclose(fpListFile);
		fpListFile = 0;
	}

	printf("SimilarDetect Done!\n");
#ifdef _TIME_STATISTICS_	
	if (nCount)
		printf("Average Extraction time = %lf\n",timeSum / nCount);
#endif //_TIME_STATISTICS_
	return ret;
}

typedef struct tagThreadParam
{
	int ClassID;
	int subClassID;
	int para;
	int nThreads;
	int BinSaveFeat;
}ThreadParam;

void* ThreadFunc(void* para)
{
	IplImage *img = 0;
	int  ret = 0;
	long ImageID;
	int idx;
	FILE *fp = 0 ;
	SD_RES result;
	ThreadParam *pParam = (ThreadParam*)para;

#ifdef _TIME_STATISTICS_
    struct timeval tv1;
    struct timeval tv2;
	double timeOnce;
#endif

	for (idx = pParam->para; idx < s_vecFile.size(); idx += pParam->nThreads) 
	{
		ImageID = GetIDFromFilePath(s_vecFile[idx].c_str());

		img = cvLoadImage(s_vecFile[idx].c_str(), 1);					//待提取特征图像文件
		if(!img) 
		{	
			cout<<"can't open " << s_vecFile[idx].c_str() << ",or unsupported image format!! "<< endl;
			//goto ERR;
			continue;
		}	
#ifdef _TIME_STATISTICS_	
		gettimeofday(&tv1, NULL);
#endif //_TIME_STATISTICS_
		ret = SD_GLOBAL_1_1_0::SimilarDetect(img, (UInt64)ImageID, pParam->ClassID, pParam->subClassID,&result, pParam->BinSaveFeat);
#ifdef _TIME_STATISTICS_
		gettimeofday(&tv2, NULL);
		timeOnce = difftimeval(&tv2, &tv1);
		timeSum += timeOnce; 
		nCount++;
#endif //_TIME_STATISTICS_

		if (TOK == ret)
		{
			printf("%lld\t%lld\t%d\n",(UInt64)ImageID,result.id,result.sMode);
		}
		else if (ret == TEC_UNSUPPORTED)
		{
			cout<< s_vecFile[idx].c_str() << " is unsupported image format!! "<< endl;
			continue;
		}
		cvReleaseImage(&img);
		img = 0;
	}

ERR:
	if (img)	
		cvReleaseImage(&img);

	printf("thread %d Over!\n", pParam->para);
	pthread_exit(0);
}


int SimilarDetectMulti(char *szFileList, char *szKeyFiles, int ClassID, int subClassID, int nThreads, int BinSaveFeat)
{
	IplImage *img = 0;
	int  ret = 0, ImageID;
	char szImgPath[1024];
	FILE *fpListFile = 0 ;
	SD_GLOBAL_1_1_0::ClassInfo ci;
	vector < SD_GLOBAL_1_1_0::ClassInfo > classList;

	s_vecFile.clear();
	fpListFile = fopen(szFileList,"r");
	if (!fpListFile) 
	{
		cout << "0.can't open" << szFileList << endl;
		goto ERR;
	}
	while( EOF != fscanf(fpListFile, "%s", szImgPath))
		s_vecFile.push_back(szImgPath);
	fclose(fpListFile);
	fpListFile = 0;

	ret  = SD_GLOBAL_1_1_0::Init(szKeyFiles); //加载资源
	if (ret != 0)
	{
	   cout<<"Fail to Initialzation with "<< szKeyFiles<< ",Error code:"<< ret << endl;
	   goto ERR;
	}
	ci.ClassID = ClassID;
	ci.SubClassID = subClassID;
	classList.push_back(ci);
	ret = SD_GLOBAL_1_1_0::LoadClassData(classList);
	if (ret != 0)
	{
	   cout<<"Fail to LoadClassData. Error code:"<< ret << endl;
	   goto ERR;
	}

	{  //multi-threads part
		pthread_t *pThread = new pthread_t[nThreads];
		ThreadParam *pParam = new ThreadParam[nThreads];
		
		for(int i=0; i<nThreads; ++i)
		{
			pParam[i].ClassID = ClassID;
			pParam[i].subClassID = subClassID;
			pParam[i].para = i;
			pParam[i].nThreads = nThreads;
			pParam[i].BinSaveFeat = BinSaveFeat;

			pthread_create(pThread+i, NULL, ThreadFunc,(void*)(pParam+i));
		}

		for(int i=0; i<nThreads; ++i)
		{
			pthread_join(pThread[i], NULL);
		}
		sleep (1);
		delete [] pThread;
		delete [] pParam;
	}

ERR:
	//释放资源
	SD_GLOBAL_1_1_0::Uninit();

	printf("SimilarDetect Done!\n");

#ifdef _TIME_STATISTICS_	
	if (nCount)
		printf("Average Extraction time = %lf\n",timeSum / nCount);
#endif //_TIME_STATISTICS_
	return ret;
}

int TestEraseClassData(char *szKeyFiles, int ClassID, int subClassID)
{
	int ret = TOK;
	SD_GLOBAL_1_1_0::ClassInfo ci;
	vector < SD_GLOBAL_1_1_0::ClassInfo > classList;

	ci.ClassID = ClassID;
	ci.SubClassID = subClassID;
	classList.push_back(ci);

	SD_GLOBAL_1_1_0::Init(szKeyFiles);
	SD_GLOBAL_1_1_0::EraseClassData(classList);
	SD_GLOBAL_1_1_0::Uninit();
	return ret;
}


int SimilarDetectSingle2(char *szFileList, char *szKeyFiles, char *szSavePath, char *szSaveName, int ClassID, int subClassID, int BinSaveFeat)
{
	IplImage *img = 0;
	int  ret = 0;
	unsigned long long ImageID = 0;
	char szImgPath[512];
	char szSaveImgPath[512];
	FILE *fpListFile = 0 ;
	std::vector<int> resultVect;
	SD_RES result;
	SD_GLOBAL_1_1_0::ClassInfo ci;
	vector < SD_GLOBAL_1_1_0::ClassInfo > classList;

#ifdef _TIME_STATISTICS_
    struct timeval tv1;
    struct timeval tv2;
	double timeOnce;
#endif

	fpListFile = fopen(szFileList,"r");
	if (!fpListFile) 
	{
		cout << "0.can't open" << szFileList << endl;
		goto ERR;
	}

	ret  = SD_GLOBAL_1_1_0::Init(szKeyFiles); //加载资源
	if (ret != 0)
	{
	   cout<<"can't open"<< szKeyFiles<<endl;
	   goto ERR;
	}
	ci.ClassID = ClassID;
	ci.SubClassID = subClassID;
	classList.push_back(ci);
	ret = SD_GLOBAL_1_1_0::LoadClassData(classList);
	if (ret != 0)
	{
	   cout<<"Fail to LoadClassData. Error code:"<< ret << endl;
	   goto ERR;
	}
	while( EOF != fscanf(fpListFile, "%s", szImgPath))
	{
		//ImageID = GetIDFromFilePath(szImgPath);

		img = cvLoadImage(szImgPath, 1);					//待提取特征图像文件
		if(!img) 
		{	
			cout<<"can't open " << szImgPath << ",or unsupported image format!! "<< endl;
			//goto ERR;
			continue;
		}	

		/***********************************getRandomID***********************************/
		getRandomID( ImageID );

#ifdef _TIME_STATISTICS_	
		gettimeofday(&tv1, NULL);
#endif //_TIME_STATISTICS_
		ret = SD_GLOBAL_1_1_0::SimilarDetect(img, ImageID, ClassID, subClassID,&result, BinSaveFeat);
#ifdef _TIME_STATISTICS_
		gettimeofday(&tv2, NULL);
		timeOnce = difftimeval(&tv2, &tv1);
		timeSum += timeOnce; 
		nCount++;
#endif //_TIME_STATISTICS_

		if (TOK == ret)
		{
			printf("%lld\t%lld\t%d\n",(UInt64)ImageID,result.id,result.sMode);
			if (result.sMode == 0)//no detect similar image
			{
				sprintf (szSaveImgPath, "%s/%s_%ld.jpg",szSavePath,szSaveName,ImageID);
				IplImage *ImageMedia = cvCreateImage(cvSize(256, 256), img->depth, img->nChannels);
				cvResize(img, ImageMedia);
				cvSaveImage(szSaveImgPath,ImageMedia);
				cvReleaseImage(&ImageMedia);
			}
		}
		else if (ret == TEC_UNSUPPORTED)
		{
			cout<< szImgPath << " is unsupported image format!! "<< endl;
			continue;
		}
		cvReleaseImage(&img);
		img = 0;
	}

ERR:
	//释放资源
	SD_GLOBAL_1_1_0::Uninit();

	if (img)	
		cvReleaseImage(&img);

	if (fpListFile) {
		fclose(fpListFile);
		fpListFile = 0;
	}

	printf("SimilarDetect Done!\n");
#ifdef _TIME_STATISTICS_	
	if (nCount)
		printf("Average Extraction time = %lf\n",timeSum / nCount);
#endif //_TIME_STATISTICS_
	return ret;
}


static pthread_mutex_t s_mutex = PTHREAD_MUTEX_INITIALIZER;
typedef struct tagThreadParam2
{
	int ClassID;
	int subClassID;
	int para;
	int nThreads;
	string szSavePath;
	string szSaveName;
	int BinSaveFeat;
	int BinReSizeImg;
	int BinUseName;
}ThreadParam2;

void* ThreadFunc2(void* para)
{
	IplImage *img = 0;
	int  ret = 0;
	unsigned long long ImageID;
	long idx;
	char szSaveImgPath[512];
	SD_RES result;
	ThreadParam2 *pParam = (ThreadParam2*)para;

#ifdef _TIME_STATISTICS_
    struct timeval tv1;
    struct timeval tv2;
	double timeOnce;
#endif

	for (idx = pParam->para; idx < s_vecFile.size(); idx += pParam->nThreads) 
	{
		img = cvLoadImage(s_vecFile[idx].c_str(), 1);					//待提取特征图像文件
		if(!img) 
		{	
			cout<<"can't open " << s_vecFile[idx].c_str() << ",or unsupported image format!! "<< endl;
			//goto ERR;
			continue;
		}	

		/***********************************getRandomID***********************************/
		if ( pParam->BinUseName == 1 )
			ImageID = GetIDFromFilePath(s_vecFile[idx].c_str());
		else
			getRandomID( ImageID );

#ifdef _TIME_STATISTICS_	
		gettimeofday(&tv1, NULL);
#endif //_TIME_STATISTICS_
		ret = SD_GLOBAL_1_1_0::SimilarDetect(img, ImageID, pParam->ClassID, pParam->subClassID,&result,pParam->BinSaveFeat);
#ifdef _TIME_STATISTICS_
		gettimeofday(&tv2, NULL);
		timeOnce = difftimeval(&tv2, &tv1);
		timeSum += timeOnce; 
		nCount++;
#endif //_TIME_STATISTICS_

		if (TOK == ret)
		{
			printf("%lld\t%lld\t%d\n",ImageID,result.id,result.sMode);
			if (result.sMode == 0)//no detect similar image
			{
				sprintf (szSaveImgPath, "%s/%s_%ld.jpg",pParam->szSavePath.c_str(),pParam->szSaveName.c_str(),ImageID);
				IplImage *ImageMedia = cvCreateImage(cvSize(256, 256), img->depth, img->nChannels);
				cvResize(img, ImageMedia);
				pthread_mutex_lock(&s_mutex);//对公用文件进行操作，需加锁
				if ( pParam->BinReSizeImg == 1 )
					cvSaveImage(szSaveImgPath,ImageMedia);
				else
					cvSaveImage(szSaveImgPath,img);
				pthread_mutex_unlock(&s_mutex);//解锁
				cvReleaseImage(&ImageMedia);
			}
		}
		else if (ret == TEC_UNSUPPORTED)
		{
			cout<< s_vecFile[idx].c_str() << " is unsupported image format!! "<< endl;
			continue;
		}
		cvReleaseImage(&img);
		img = 0;
	}

ERR:
	if (img)	
		cvReleaseImage(&img);

	printf("thread %d Over!\n", pParam->para);
	pthread_exit(0);
}


int SimilarDetectMulti2(char *szFileList, char *szKeyFiles, char *szSavePath, char *szSaveName, int nThreads, int BinSaveFeat, int BinReSizeImg, int BinUseName)
{
	IplImage *img = 0;
	int  ret = 0, ImageID;
	char szImgPath[1024];
	FILE *fpListFile = 0 ;
	SD_GLOBAL_1_1_0::ClassInfo ci;
	vector < SD_GLOBAL_1_1_0::ClassInfo > classList;
	int ClassID = 70020; 
	int SubClassID = 70020;

	s_vecFile.clear();
	fpListFile = fopen(szFileList,"r");
	if (!fpListFile) 
	{
		cout << "0.can't open" << szFileList << endl;
		goto ERR;
	}
	while( EOF != fscanf(fpListFile, "%s", szImgPath))
		s_vecFile.push_back(szImgPath);
	fclose(fpListFile);
	fpListFile = 0;

	ret  = SD_GLOBAL_1_1_0::Init(szKeyFiles); //加载资源
	if (ret != 0)
	{
	   cout<<"Fail to Initialzation with "<< szKeyFiles<< ",Error code:"<< ret << endl;
	   goto ERR;
	}
	ci.ClassID = ClassID;
	ci.SubClassID = SubClassID;
	classList.push_back(ci);
	ret = SD_GLOBAL_1_1_0::LoadClassData(classList);
	if (ret != 0)
	{
	   cout<<"Fail to LoadClassData. Error code:"<< ret << endl;
	   goto ERR;
	}

	{  //multi-threads part
		pthread_t *pThread = new pthread_t[nThreads];
		ThreadParam2 *pParam = new ThreadParam2[nThreads];
		
		for(int i=0; i<nThreads; ++i)
		{
			pParam[i].ClassID = ClassID;
			pParam[i].subClassID = SubClassID;
			pParam[i].para = i;
			pParam[i].nThreads = nThreads;
			pParam[i].szSavePath = szSavePath;
			pParam[i].szSaveName = szSaveName;
			pParam[i].BinSaveFeat = BinSaveFeat;
			pParam[i].BinReSizeImg = BinReSizeImg;
			pParam[i].BinUseName = BinUseName;

			pthread_create(pThread+i, NULL, ThreadFunc2,(void*)(pParam+i));
		}

		for(int i=0; i<nThreads; ++i)
		{
			pthread_join(pThread[i], NULL);
		}
		sleep (1);
		delete [] pThread;
		delete [] pParam;
	}

ERR:
	//释放资源
	SD_GLOBAL_1_1_0::Uninit();

	printf("SimilarDetect Done!\n");

#ifdef _TIME_STATISTICS_	
	if (nCount)
		printf("Average Extraction time = %lf\n",timeSum / nCount);
#endif //_TIME_STATISTICS_
	return ret;
}

inline void PadEnd(char *szPath)
{
	int iLength = strlen(szPath);
	if (szPath[iLength-1] != '/')
	{
		szPath[iLength] = '/';
		szPath[iLength+1] = 0;
	}
}

int main(int argc, char* argv[])
{
	int  ret = 0;
	char szKeyFiles[256],szSavePath[256];

	if ( argc == 7 && strcmp(argv[1],"-simdetect") == 0)
	{
		strcpy(szKeyFiles, argv[3]);
		PadEnd(szKeyFiles);
		//SimilarDetectMulti(argv[2], szKeyFiles, atol(argv[4]), atol(argv[5]), atoi(argv[6]));
		SimilarDetectSingle(argv[2], szKeyFiles, atol(argv[4]), atol(argv[5]), atol(argv[6]) );
	}
	else if (argc == 9 && strcmp(argv[1],"-simdetect") == 0)
	{
		strcpy(szKeyFiles, argv[3]);
		PadEnd(szKeyFiles);
		strcpy(szSavePath, argv[4]);
		PadEnd(szSavePath);
		SimilarDetectSingle2(argv[2], szKeyFiles, szSavePath, argv[5], atol(argv[6]), atol(argv[7]), atol(argv[8]) );
	}
	else if (argc == 5 && strcmp(argv[1],"-eraseclassdata") == 0)
	{
		strcpy(szKeyFiles, argv[2]);
		PadEnd(szKeyFiles);
		TestEraseClassData(szKeyFiles, atol(argv[3]), atol(argv[4]));
	}
	else if (argc == 10 && strcmp(argv[1],"-simdetectmuti") == 0)
	{
		strcpy(szKeyFiles, argv[3]);
		PadEnd(szKeyFiles);
		strcpy(szSavePath, argv[4]);
		PadEnd(szSavePath);
		SimilarDetectMulti2(argv[2], szKeyFiles, szSavePath, argv[5], atol(argv[6]), atol(argv[7]), atol(argv[8]), atol(argv[9]) );
	}
	else
	{
		cout << "usage:\n" << endl;
		cout << "\tSimilarDetect: Demo -simdetect ImageList.txt keyFilePath ClassID subCLassID BinSaveFeat\n" << endl;
		//cout << "\tSimilarDetect: Demo -simdetect ImageList.txt keyFilePath ClassID subCLassID nThreads\n" << endl;
		cout << "\tEraseClassData: Demo -eraseclassdata keyFilePath ClassID subCLassID BinSaveFeat\n" << endl;
		cout << "\t********************************************************\n" << endl;
		cout << "\tSimilarDetect: Demo -simdetectmuti ImageList.txt keyFilePath savePath saveName nThreads BinSaveFeat BinReSizeImg BinUseName\n" << endl;
		cout << "\tSimilarDetect: Demo -simdetect ImageList.txt keyFilePath savePath saveName ClassID subCLassID BinSaveFeat\n" << endl;
		return ret;
	}
	return ret;
}


