all: predict
predict:
	mex CFLAGS=" -std=c99" -largeArrayDims libsvmread.c
	mex CFLAGS=" -std=c99" -largeArrayDims libsvmwrite.c
	mex CFLAGS=" -std=c99" -largeArrayDims svmtrain.c svm.cpp svm_model_matlab.c -o libsvmtrain.mexa64
	mex CFLAGS=" -std=c99" -largeArrayDims svmpredict.c svm.cpp svm_model_matlab.c -o libsvmpredict.mexa64
