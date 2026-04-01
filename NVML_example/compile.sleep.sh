#
rm -rf *.o mm.x *.mod
#
# nvfortran (NVIDIA)
COMP=nvfortran
OPT="-O3 -cpp -DNVML -Minfo=accel"
#
echo "compiling GPU with " $COMP $OPT 
#
nvcc -O3 -I/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/Linux_x86_64/24.3/cuda/12.3/targets/x86_64-linux/include -DNVML -c nvml_wrapper.c
$COMP $OPT -c nvml_interface_module.f90
$COMP $OPT mod_tools.F90 -c
$COMP $OPT sleep.F90 -c
#
$COMP $OPT mod_tools.o nvml_interface_module.o nvml_wrapper.o sleep.o -o sleep.x -L/leonardo/prod/spack/5.2/install/0.21/linux-rhel8-icelake/gcc-8.5.0/nvhpc-24.3-v63z4inohb4ywjeggzhlhiuvuoejr2le/Linux_x86_64/24.3/cuda/12.3/targets/x86_64-linux/lib/stubs -lnvidia-ml
#
echo "That's all folks!!!"
#

