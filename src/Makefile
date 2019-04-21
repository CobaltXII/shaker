# Linux (all archs) generic Makefile
# Copyright Eric Bachard / 2019 April 21st
# License MIT


UNAME_S = $(shell uname -s)

ifeq (${UNAME_S}, Linux)

# on Linux, returns the arch name
UNAME_M = $(shell uname -m)

# change or comment me if you want to select another g++ version
VERSION=-7

CXX = g++${VERSION}
CXX_STANDARD = -std=c++11

# often src, or something close
SOURCES_DIR = .
BUILD_DIR = .

APPLICATION_NAME = shaker
FILENAME = ${BUILD_DIR}/${APPLICATION_NAME}

CXX_OPTIMIZATION_FLAGS = -march=native -mtune=native -O3
OS_EXTRA_FLAGS = -DLinux 

CXX_FLAGS = -Wall  ${CXX_STANDARD} ${OS_EXTRA_FLAGS} ${CXX_OPTIMIZATION_FLAGS}

# Some dependencies :
# SDL2 + headers are mandatory
SDL2_FLAGS = `sdl2-config --cflags --libs`
# glew is needed, but you can adapt the code to glad or any other OpenGL loader
OPENGL_LD_FLAGS = -lGL -lGLEW

LDFLAGS = ${OPENGL_LD_FLAGS}  ${SDL2_FLAGS} ${OPENGL_LD_FLAGS}

DEBUG_SUFFIX = _debug
CXX_FLAGS_DEBUG = -g -DDEBUG  -DSHAKER_DEBUG

FILES = ${SOURCES_DIR}/shaker.cpp


all : ${FILENAME} ${FILENAME}${DEBUG_SUFFIX}

${FILENAME}:
	@${CXX} ${INCLUDE_DIR} ${CXX_FLAGS} -o $@ ${FILES} ${LDFLAGS}

${FILENAME}${DEBUG_SUFFIX}: ${OBJS}
	@${CXX} ${INCLUDE_DIR} ${CXX_FLAGS} ${CXX_FLAGS_DEBUG} -o $@ ${FILES} ${LDFLAGS}

clean:
	@${RM} *.o ${FILENAME} ${FILENAME}${DEBUG_SUFFIX}

endif
