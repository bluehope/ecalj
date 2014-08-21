### You need to set switches (1) to (6), by hand
###

#(1) Compilar ###################
# ... Fortran and linker switches for machine LINUX with intel fortran

FC = mpif90 -132 
#FC = mpiifort -132 
#FC = f95 

# -cm is supress all comment.
# -w95 and -w90 is to remove noisy warning related to f90 and f95 recommendations.
# See http://www.intel.com/software/products/compilers/flin/docs/ug/msg_warn.htm


#(2) CPP SWITCHES ###################
CPPSWITCH_INTELLINUXIFC  = \
-DEXPAND_ISWAP  -DEXPAND_VDV   -DCOMMONLL  -UDUMMY_ETIME -DEXPAND_MELPLN2         \
-DUSE_X0KBLAS   -DX0KBLAS_DIV  -UEXPAND_SUBSTITUTION     -UCOMMENTOUTfor_PARALLEL \
-DMbytes_X0KBLAS_DIV=2        -DNWORD_RECORDSIZE=1 -DEXPAND_SORTEA \
-DUSE_GEMM_FOR_SUM


#CPPSWITCH_DECALPHA  = \
#-DEXPAND_ISWAP  -DEXPAND_VDV   -UCOMMONLL  -UDUMMY_ETIME -DEXPAND_MELPLN2         \
#-DUSE_X0KBLAS   -DX0KBLAS_DIV  -UEXPAND_SUBSTITUTION     -UCOMMENTOUTfor_PARALLEL \
#-DMbytes_X0KBLAS_DIV=2        -DNWORD_RECORDSIZE=4     -DEXPAND_SORTEA

#CPPSWITCH_SR8K = \
#-DEXPAND_ISWAP  -DEXPAND_VDV   -UCOMMONLL  -DDUMMY_ETIME  -DEXPAND_MELPLN2 \
#-DUSE_X0KBLAS   -DX0KBLAS_DIV  -UEXPAND_SUBSTITUTION      -DCOMMENTOUTfor_PARALLEL \
#-DMbytes_X0KBLAS_DIV=1024     -DNWORD_RECORDSIZE=1      -DEXPAND_SORTEA


#(3) Compilar options ###############################################
# 
### INTEL FORTRAN PENTIUM4 LINUX ###
#FFLAGS_c0 = -O0 -Vaxlib  -cpp $(CPPSWITCH_INTELLINUXIFC)
#FFLAGS    = -Vaxlib -tpp7 -cpp $(CPPSWITCH_INTELLINUXIFC)   # for .o
FFLAGS=-O3 -cpp $(CPPSWITCH_INTELLINUXIFC)
FFLAGS_OMP= -openmp -O3 -cpp $(CPPSWITCH_INTELLINUXIFC)

#gfortran
#FFLAGS=  -O3  -fomit-frame-pointer -funroll-loops  -ffast-math -ffixed-line-length-132
#FFLAGS=  -O0  -ffixed-line-length-132

#
### Don't change para_g = .o ... below (or modify it if you know how this work) 
#### don't need to read here #####NoteStart
# Some groups of .f sources are compiled into .c*_o files.  (* is 1 to 4).
# The compile options are in FFLAGS_c*. The others are with .o and FFLAGS. See makefile and Search para_g or so.
# ---> It cause a problem if a source file foo.f, which compiled into foo.c*_o contains USE module, 
#      because checkmodule does now just support *.o. In such a case, you have to modify checkmodule by yourself.
#      (This note is by takao. Oct.2003)
############## NoteEnd
para_g = .o     # ppbafp.f  psi2bc1.f psi2bc.f See makefile.
sxcf_g = .o     # sxcf.f
x0kf_g = .o     # x0kf.f
hqpe_g = .o     # hqpe.f
tet5_g = .o


### alpha for older compaq compilar ###
#FFLAGS = -O4 -fast -arch host -tune host -recursive -cpp $(CPPSWITCH_DECALPHA)   # for .o
#FFLAGS  = -K -O4 -fast -arch host -tune host -recursive -cpp $(CPPSWITCH_DECALPHA)   # for .o
#para_g = .o     # ppbafp.f  psi2bc1.f psi2bc.f See makefile.
#sxcf_g = .o     # sxcf.f
#x0kf_g = .o     # x0kf.f
#hqpe_g = .o     # hqpe.f
#
#### alpha compaq compilar to override the compilar bug (rather the latest compiler requires this) ###
#FFLAGS     = -O3 -fast -arch host -tune host -recursive -cpp $(CPPSWITCH_DECALPHA)   # for .o
#FFLAGS_c1  = -O1 -fast -arch host -tune host -recursive -cpp $(CPPSWITCH_DECALPHA)   # for .c1_o
#FFLAGS_c2  = 
#FFLAGS_c3  = 
#FFLAGS_c4  = -O4 -fast -arch host -tune host -recursive -cpp $(CPPSWITCH_DECALPHA)   # for .c4_o
#para_g = .o        # ppbafp.f  psi2bc1.f psi2bc.f
#sxcf_g = .c4_o     # sxcf.f
#x0kf_g = .c4_o     # x0kf.f
#hqpe_g = .c1_o     # hqpe.f
#
#
### for sr8k ###
#FFLAGS    = -Oss -loglist -Xpcomp -limit -noparallel -Xparmonitor  -nosave -64  -cpp $(CPPSWITCH_SR8K)
#FFLAGS_c1 = -Oss -loglist -Xpcomp -limit -parallel -Xparmonitor -uinline=2 -nosave -64  -cpp  $(CPPSWITCH_SR8K)
## We devide .f souces to some groups, which are compiled with the same optins to the objects with the same extentions. 
#para_g = .c1_o  # ppbafp.f  psi2bc1.f psi2bc.f
#x0kf_g = .c1_o  # x0kf.f
#sxcf_g = .o     # sxcf.f
#hqpe_g = .o     # hqpe.f



#(4) BLAS + LAPACK ####################################################
### ifort ###
#LIBMATH= -mkl  

### ubuntu12.04 gfortran ####
#LIBMATH= /usr/lib64/libfftw3.so.3 /usr/lib64/liblapack.so.3gf /usr/lib64/libblas.so.3gf 

### ATLAS BLAS
#LIBMATH= $(ECAL)/BLASplusLAPACK/LAPACK_A/lapack_a.a \
#-L$(ECAL)/BLASplusLAPACK/ATLAS/ -llapack  -lcblas -lf77blas -latlas
#
### Goto's BLAS; faster than ATLAS.
#
### See http://www.cs.utexas.edu/users/flame/goto/
#LIBMATH= $(ECAL)/BLASplusLAPACK/LAPACK_A/lapack_a.a \
#$(ECAL)/BLASplusLAPACK/GotoBLAS/xerbla.o  $(ECAL)/BLASplusLAPACK/GotoBLAS/libgoto_p4_512-r0.6.so 
#
## This is for multi-threaded version of GotoBlas...
##$(ECAL)/BLASplusLAPACK/GotoBLAS/xerbla.o  $(ECAL)/BLASplusLAPACK/GotoBLAS/libgoto_p4_512p-r0.6.so 

### alpha for henry.eas.asu.edu (Xeon cluster) ###
#LIBMATH=-lcxml #for alpha

#LIBMATH= -lgoto -L/usr/local/lib/ATLAS/ -lf77blas -latlas -L/opt/intel/mkl/lib/32 -lmkl_lapack -lmkl_def -lguide -lsvml -lPEPCF90 $(ECAL)/BLASplusLAPACK/LAPACK_A/lapack_a.a 

LIBMATH= -mkl 

# I had a problem in zgemm in pwmat. 
#LIBMATH= /opt/acml4.2.0/gfortran64/lib/libacml.a -lfftw3
# this caused segmentation fault during lmf. (just after BNDFP: started).
#LIBMATH= /opt/acml4.1.0/gfortran64/lib/libacml.a -lfftw3

# centos yum install blas, yum install lapack
#LIBMATH= -lfftw3 /usr/lib64/liblapack.so.3.0.3 /usr/lib64/libblas.a 

#LIBMATH= -lfftw3   $(HOME)/kit/numericallib/LAPACK/lapack_core2gfortran.a \
# $(HOME)/kit/numericallib/LAPACK/blas_core2gfortran.a \
# $(HOME)/kit/numericallib/LAPACK/tmglib_core2gfortran.a 

#LIBMATH= -lfftw3 -L/opt/intel/mkl/10.0.2.018/lib/em64t/lib -lmkl_lapack -lmkl_em64t  -lmkl_core 

#for ubuntu thinkpadt61.
#LIBMATH=  /usr/lib64/libfftw3.so.3.1.2 /usr/lib64/liblapack.a /usr/lib64/libblas-3.a 

#LIBMATH = -L/usr/lib64/atlas/ /usr/lib64/atlas/liblapack.so.3 \
#          /usr/lib64/atlas/libf77blas.so.3 /usr/lib64/atlas/libcblas.so.3 \
#          /usr/lib64/atlas/libatlas.so.3 -lfftw3

# yum install atlas --> this did not work... normchk.si gave NaN
#LIBMATH = -L/usr/lib64/atlas/ /usr/lib64/atlas/liblapack.so.3 \
#            /usr/lib64/atlas/libf77blas.so.3 /usr/lib64/atlas/libcblas.so.3 \
#            /usr/lib64/atlas/libatlas.so.3 -lfftw3

# centos yum install blas, yum install lapack
#LIBMATH= /usr/lib64/libblas.a /usr/lib64/liblapack.so.3.0.3 -lfftw3


#(5) Linker ####################################################
### gfortran ubuntu12.04 #######
LK = mpif90
#LK= ifort -parallel 
#LK=mpiifort -openmp
LKFLAGS2 = $(LIBMATH) 

### ifort ####################
#LK=mpiifort -openmp

### linux 586
#LKFLAGS2 = $(ECAL)/slatsm/slatsm.a  -L/usr/intel/mkl/LIB -lmkl32_lapack -lmkl32_p3  -L/usr/lib/gcc-lib/i586-redhat-linux/2.95.3 -lg2c -lpthread  
### sr8k
#LKFLAGS2 = $(COMMON) $(ECAL)/slatsm/slatsm.a  -lblas -llapack -lpl -parallel  -lm

#LK = f95
#-Vaxlib -tpp7
#LKFLAGS2 = $(LIBMATH) -Vaxlib -tpp7 -lpthread


#(6) Root of ecal #############################################
# just for make install
ECAL   = $(HOME)/ecal
BINDIR = $(HOME)/bin

