# 
# Copyright (C) 1996-2016	The SIESTA group
#  This file is distributed under the terms of the
#  GNU General Public License: see COPYING in the top directory
#  or http://www.gnu.org/copyleft/gpl.txt.
# See Docs/Contributors.txt for a list of contributors.
#
.SUFFIXES:
.SUFFIXES: .f .F .o .a .f90 .F90

SIESTA_ARCH=x86_64-unknown-linux-gnu--unknown

FPP=
FPP_OUTPUT= 
FC=mpiifort
RANLIB=ranlib

SYS=nag

SP_KIND=4
DP_KIND=8
KINDS=$(SP_KIND) $(DP_KIND)


#MPIROOT=/opt/intel/MPI/2017.4.239/impi/2017.4.239/intel64


#gees
#Must have INCFLAGS for the netcdf INCULDE
CC=icc
#modified

MKLROOT=/opt/intel/oneapi/mkl/2022.1.0
MPIROOT=/opt/intel/oneapi/mpi/2021.6.0
MKL_LIB=/opt/intel/oneapi/mkl/2022.1.0/lib/intel64

#CDFROOT=/opt/netcdf-4.4.0
#HDFROOT=/opt/hdf5-1.8.16
#modified
#

CDFROOT=/home2/rong/opt/netcdf_build/build/build/netcdf/4.4.1.1
CDFFROOT=/home2/rong/opt/netcdf_build/build/build/netcdf/4.4.1.1
ZLIB=/home2/rong/opt/netcdf_build/build/build//zlib/1.2.11
HDFROOT=/home2/rong/opt/netcdf_build/build/build/hdf5/1.8.19



#INCFLAGS=-I$(MKLROOT)/include -I$(MKLROOT)/include/intel64/lp64 -I$(MPIROOT)/include
INCFLAGS=-I$(MKLROOT)/include -I$(MKLROOT)/include/intel64/lp64 -I$(MPIROOT)/include -I$(CDFROOT)/include 
#modified
#Que: X1= -xSSE4.2, X2 upto: -xAVX,  X3 upto: -xCORE-AVX2
FFLAGS=-g -O2 -fPIC -xSSE4.2 -fp-model source
FPPFLAGS= -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DMPI #-DCDF
LDFLAGS=

ARFLAGS_EXTRA=

FCFLAGS_fixed_f=
FCFLAGS_free_f90=
FPPFLAGS_fixed_F=
FPPFLAGS_free_F90=

#BLAS_LIBS=libblas.a
#LAPACK_LIBS=dc_lapack.a liblapack.a
#BLACS_LIBS=
#SCALAPACK_LIBS=
#
BLAS_LIBS= $(MKL_LIB)/libmkl_blas95_lp64.a -Wl,--start-group $(MKL_LIB)/libmkl_intel_lp64.a $(MKL_LIB)/libmkl_sequential.a $(MKL_LIB)/libmkl_core.a -Wl,--end-group
LAPACK_LIBS=
BLACS_LIBS=
SCALAPACK_LIBS= -Wl,--start-group $(MKL_LIB)/libmkl_scalapack_lp64.a $(MKL_LIB)/libmkl_intel_lp64.a $(MKL_LIB)/libmkl_core.a $(MKL_LIB)/libmkl_sequential.a $(MKL_LIB)/libmkl_blacs_intelmpi_lp64.a -Wl,--end-group -lpthread




#NETCDF_LIBS=
#NETCDF_INTERFACE=
#
# hdf5 may requires ${HOME}/local/szip-2.1/lib/libsz.a, libcurl
#NETCDF_LIBS=-L${CDFROOT}/lib -L${HDFROOT}/lib -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lcurl
NETCDF_LIBS=-L${CDFROOT}/lib -L${CDFFROOT}/lib -L${HDFROOT}/lib -L${ZLIB}/lib ${CDFFROOT}/lib/libnetcdff.a ${CDFROOT}/lib/libnetcdf.a ${HDFROOT}/lib/libhdf5_hl.a ${HDFROOT}/lib/libhdf5.a ${ZLIB}/lib/libz.a -lcurl
NETCDF_INTERFACE=

LIBS=$(SCALAPACK_LIBS) $(BLACS_LIBS) $(LAPACK_LIBS) $(BLAS_LIBS) $(NETCDF_LIBS)

#SIESTA needs an F90 interface to MPI
#This will give you SIESTA's own implementation
#If your compiler vendor offers an alternative, you may change
#to it here.
MPI_INTERFACE=libmpi_f90.a
MPI_INCLUDE=$(MPIROOT)/include

INCFLAGS += -I/home2/rong/opt/netcdf_build/build/build/netcdf/4.4.1.1/include
LDFLAGS += -L/home2/rong/opt/netcdf_build/build/build/zlib/1.2.11/lib -Wl,-rpath=/home2/rong/opt/netcdf_build/build/build/zlib/1.2.11/lib
LDFLAGS += -L/home2/rong/opt/netcdf_build/build/build/hdf5/1.8.19/lib -Wl,-rpath=/home2/rong/opt/netcdf_build/build/build/hdf5/1.8.19/lib
LDFLAGS += -L/home2/rong/opt/netcdf_build/build/build/netcdf/4.4.1.1/lib -Wl,-rpath=/home2/rong/opt/netcdf_build/build/build/netcdf/4.4.1.1/lib
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
COMP_LIBS += libncdf.a libfdict.a
FPPFLAGS += -DCDF -DNCDF -DNCDF_4


#Dependency rules are created by autoconf according to whether
#discrete preprocessing is necessary or not.
.F.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F)  $< 
.F90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $< 
.f.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f)  $<
.f90.o:
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90)  $<

