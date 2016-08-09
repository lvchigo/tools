#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include <time.h>

#include <sys/types.h>
#include <dirent.h>
#include <sys/stat.h>

#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include "TErrorCode.h"
#include "SD_comm.h"

using namespace std;

#define SD_GLOBAL_FEAT_LEN 36 
////////////////////////////////////////////////////////////////////////////
//configuration Macro definition
////////////////////////////////////////////////////////////////////////////

typedef struct tagSD_Global_Feature
{
	UInt64 ImageID;
	unsigned char m_feat[SD_GLOBAL_FEAT_LEN];
}SD_Global_Feature;

//-------------------------------------------------------------------------

int repair(const char* szSDdat)
{
	char szFixed[1024];
	char *pch;
	FILE *fpIn = NULL;
	FILE *fpOut = NULL;
	int i, nImages, ClassID, SubClassID;
	bool bFilebreak = false;
	SD_Global_Feature item;
	vector< SD_Global_Feature > vecFeat; 

	if (strstr(szSDdat, ".SDdat") == NULL)
	{
		printf("%s is not a .SDdat file \n", szSDdat);
		return TEC_INVALID_PARAM;
	}

	strcpy(szFixed, szSDdat);
	pch = strrchr(szFixed, '.');
	strcpy(pch, "_fixed.SDdat");

	fpIn = fopen(szSDdat, "rb");
	if (!fpIn)
	{
		printf("Fail to open %s\n", szSDdat);
		return  TEC_FILE_OPEN;
	}
	fpOut = fopen(szFixed, "wb");
	if (!fpOut)
	{
		printf("Fail to open %s\n", szFixed);
		fclose(fpIn);
		return  TEC_FILE_OPEN;
	}

	while ( 1 == fread(&ClassID, sizeof(ClassID), 1, fpIn) &&
			1 == fread(&SubClassID, sizeof(SubClassID), 1, fpIn) &&
			1 == fread(&nImages, sizeof(nImages), 1, fpIn) )
	{
		vecFeat.clear();
		if (nImages == 0)  break;
		for (i = 0; i < nImages; i++) 
		{
			if ( 1 == fread(&(item.ImageID), sizeof(item.ImageID), 1, fpIn) && 
				 1 == fread(item.m_feat, SD_GLOBAL_FEAT_LEN, 1, fpIn) ) 
				vecFeat.push_back(item);	
			else
			{
				bFilebreak = true;
				break;
			}
		}
		if (bFilebreak != true)
		{
			if (1 != fwrite(&ClassID, sizeof(ClassID), 1, fpOut) )
			{
				fclose(fpIn);
				fclose(fpOut);
				printf("Raise error when writing %s \n", szFixed);
				return TEC_FILE_WRITE;
			}
			if (1 != fwrite(&(SubClassID), sizeof(SubClassID), 1, fpOut))
			{
				fclose(fpIn);
				fclose(fpOut);
				printf("Raise error when writing %s \n", szFixed);
				return TEC_FILE_WRITE;
			}
			if (1 != fwrite(&nImages, sizeof(int), 1, fpOut))
			{
				fclose(fpIn);
				fclose(fpOut);
				printf("Raise error when writing %s \n", szFixed);
				return TEC_FILE_WRITE;
			}
			for (i = 0; i < nImages; i++) 
			{
				if (1 != fwrite(&(vecFeat[i].ImageID), sizeof(UInt64), 1, fpOut))
				{
					fclose(fpIn);
					fclose(fpOut);
					printf("Raise error when writing %s \n", szFixed);
					return TEC_FILE_WRITE;
				}
				if (1 != fwrite(vecFeat[i].m_feat, SD_GLOBAL_FEAT_LEN, 1, fpOut))
				{
					fclose(fpIn);
					fclose(fpOut);
					printf("Raise error when writing %s \n", szFixed);
					return TEC_FILE_WRITE;
				}
			}
		}
		else
			break;
	}

	fclose(fpIn);
	fclose(fpOut);
	return TOK;
}

int main(int argc, const char *argv[])
{
	int nRet = TOK;
	if (argc != 2)
	{
		printf("Usage: repairSDdat SDdat_file_Path\n");
		return -1;
	}
	nRet = repair(argv[1]);
	return nRet;
}
