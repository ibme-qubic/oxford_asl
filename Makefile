include ${FSLCONFDIR}/default.mk

PROJNAME = oxford_asl

LIBS = -lfsl-newimage -lfsl-miscmaths -lfsl-cprob -lfsl-utils \
       -lfsl-NewNifti -lfsl-znz

XFILES = asl_file
SCRIPTS = oxford_asl asl_calib asl_reg quasil toast oxford_asl_roi_stats.py
VERSIONED = oxford_asl asl_calib quasil asl_reg toast

OBJS = readoptions.o asl_functions.o

# Pass Git revision details
GIT_SHA1:=$(shell git describe --dirty)
GIT_DATE:=$(shell git log -1 --format=%ad --date=local)
CXXFLAGS += -DGIT_SHA1=\"${GIT_SHA1}\" -DGIT_DATE="\"${GIT_DATE}\""

# Always rebuild scripts
.PHONY: FORCE

all: ${XFILES} ${VERSIONED}

asl_file: ${OBJS} asl_file.o
	${CXX} ${CXXFLAGS} -o $@ $^ ${LDFLAGS}

$(VERSIONED): %: %.in FORCE
	sed -e "s/@GIT_SHA1@/${GIT_SHA1}/" -e "s/@GIT_DATE@/${GIT_DATE}/" $< >$@
	chmod a+x $@

# call setup.py -V to force creation
# of _version.py before installation
pyinstall:
	fslpython python/setup.py -V
	fslpython -m pip install --no-deps -vv ./python/

clean:
	rm -f ${VERSIONED} asl_file *.o
