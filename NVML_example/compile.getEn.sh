#
rm -rf *.o getEn.x *.mod
#
# nvfortran (NVIDIA)
FC=nvfortran
CC=nvcc
OPT="-O3 -Minfo=all"
#
# Pitagora
INC1=/pitagora/prod/spack/6.1/install/0.22/linux-rhel9-zen4/gcc-11.4.1/nvhpc-25.11-ntshdsgl52b6ckb6iu7xazd6uvqi3wqi/Linux_x86_64/25.11/cuda/13.0/targets/x86_64-linux/include
LIB1="/pitagora/prod/spack/6.1/install/0.22/linux-rhel9-zen4/gcc-11.4.1/nvhpc-25.11-ntshdsgl52b6ckb6iu7xazd6uvqi3wqi/Linux_x86_64/25.11/cuda/13.0/targets/x86_64-linux/lib/stubs -lnvidia-ml"
# 
# Leonardo
#INC1=/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/Linux_x86_64/24.3/cuda/12.3/targets/x86_64-linux/include
#LIB1="/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/Linux_x86_64/24.3/cuda/12.3/targets/x86_64-linux/lib/stubs -lnvidia-ml"
#
echo "compiling GPU with " $COMP $OPT 
#
$CC -O3 -I$INC1 -DNVML -c nvml_wrapper.c
#
$FC $OPT -DNVML -c nvml_interface_module.F90
$FC $OPT -c mod_tools.F90
$FC $OPT -c getEn.F90 
#
$FC $OPT mod_tools.o nvml_interface_module.o nvml_wrapper.o getEn.o -o getEn.x -L$LIB1
#
echo "That's all folks!!!"
#

