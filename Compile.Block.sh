#
module purge
module load nvhpc/24.3
module li
#
rm -rf *.o *.x *.mod
#
COMP=nvfortran
#
OPT="-cuda"
LIB="-cudalib=cublas"
echo "compiling with " $COMP $OPT $LIB
$COMP $OPT streamBlockSize.node.F90 -o streamBlockSize.x $LIB
#
echo "That's all folks!!!"
