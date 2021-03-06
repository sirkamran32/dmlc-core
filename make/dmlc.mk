#---------------------------------------------------------------------------------------
#  mshadow configuration script
#
#  include dmlc.mk after the variables are set
#
#  Add DMLC_CFLAGS to the compile flags
#  Add DMLC_LDFLAGS to the linker flags
#----------------------------------------------------------------------------------------
ifndef LIBJVM
	LIBJVM=$(JAVA_HOME)/jre/lib/amd64/server
endif

ifndef NO_OPENMP
	DMLC_CFLAGS += -fopenmp
	DMLC_LDFLAGS += -fopenmp
endif

# Mac OS X does not support "-lrt" flag
OS := $(shell uname -s)
ifneq ($(OS), Darwin)
    DMLC_LDFLAGS += -lrt
endif

# handle fpic options
ifndef WITH_FPIC
	WITH_FPIC = 1
endif

ifeq ($(WITH_FPIC), 1)
	DMLC_CFLAGS += -fPIC
endif

# Using default hadoop_home
ifndef HADOOP_HDFS_HOME
	HADOOP_HDFS_HOME=$(HADOOP_HOME)
endif

ifeq ($(USE_HDFS),1)
	DMLC_CFLAGS+= -DDMLC_USE_HDFS=1 -I$(HADOOP_HDFS_HOME)/include -I$(JAVA_HOME)/include
	HDFS_LIB_PATH=$(HADOOP_HDFS_HOME)/lib/native
	ifneq ("$(wildcard $(HDFS_LIB_PATH)/libhdfs.so)","")
		DMLC_LDFLAGS+= -L$(HDFS_LIB_PATH) -lhdfs
	else
		DMLC_LDFLAGS+= $(HDFS_LIB_PATH)/libhdfs.a
	endif
	DMLC_LDFLAGS += -L$(LIBJVM) -ljvm -Wl,-rpath=$(LIBJVM)
else
	DMLC_CFLAGS+= -DDMLC_USE_HDFS=0
endif

# setup S3
ifeq ($(USE_S3),1)
	DMLC_CFLAGS+= -DDMLC_USE_S3=1
	DMLC_LDFLAGS+= -lcurl -lssl -lcrypto
else
	DMLC_CFLAGS+= -DDMLC_USE_S3=0
endif

ifeq ($(USE_GLOG), 1)
	DMLC_CFLAGS += -DDMLC_USE_GLOG=1
endif
