CC = g++
CFLAG = -Wall -w -O2 -msse2 -ggdb -fPIC

SRC = ../src
OBJ = ../obj
LIB = ../lib
BIN = ../bin

INCLUDE = -I. -I../include -I/usr/include -I/usr/sys/include -I/usr/local/include/opencv -I/usr/local/include/opencv2 -I/usr/local/include
LIB_FLAG = -L../lib -L/usr/lib64 -L/usr/local/lib64 -L/usr/local/lib -L/usr/lib

MY_LIB = -lpthread -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_ml -lopencv_imgcodecs

#LibObjs = $(patsubst $(SRC)/%.cpp, $(OBJ)/%.o, $(wildcard $(SRC)/*.cpp))
LibObjs = 	$(OBJ)/ColorLayout.o \
			$(OBJ)/SD_global.o 
DemoObjs = $(OBJ)/Demo.o

all: Demo
Demo: $(BIN) $(LIB) $(OBJ) $(DemoObjs) lib
	@echo ---------------------------------------------------------------------------------------------------------
	$(CC) $(CFLAG) $(INCLUDE) -o $(BIN)/Demo $(DemoObjs) -lSD_global $(LIB_FLAG) $(MY_LIB)
	@echo ---------------------------------------------------------------------------------------------------------

$(BIN) $(LIB) $(OBJ):
	@mkdir -p $@

$(DemoObjs): %.o:
	@echo ---------------------------------------------------------------------------------------------------------
	$(CC) -c $(CFLAG) $(INCLUDE) -o $@ $(SRC)/$(@F:.o=.cpp)    
	@echo ---------------------------------------------------------------------------------------------------------

lib: $(LIB) $(OBJ) $(LibObjs)
	@echo ---------------------------------------------------------------------------------------------------------
	ar -rv $(LIB)/libSD_global.a $(LibObjs)
	@echo ---------------------------------------------------------------------------------------------------------
	
$(LibObjs): %.o:
	@echo ---------------------------------------------------------------------------------------------------------
	$(CC) -c $(CFLAG) $(INCLUDE) -o $@ $(SRC)/$(@F:.o=.cpp)    
	@echo ---------------------------------------------------------------------------------------------------------

.PHONY : clean
clean :
	rm -f $(BIN)/Demo $(LIB)/libSD_global.a core $(DemoObjs) $(LibObjs)
