#
# PItagora: use 24.9
#
# Leonardo (24.9 not working corrrectly): 
module purge
module load profile/global
module load nvhpc/25.3
module li
#
rm -rf *.o *.x *.mod
#
COMP=nvfortran
#
OPT="-O3 "
echo "compiling serial vestion with " $COMP $OPT
$COMP $OPT mod_tools.F90 -c
$COMP $OPT mm.matmul.F90 -c
$COMP $OPT mod_tools.o mm.matmul.o -o mm.matmul.serial.x
#
rm -rf *.o 
#
OPT="-O3 "
echo "compiling serial+validation with " $COMP $OPT
$COMP $OPT mod_tools.F90 -c
$COMP $OPT -DVALIDATION mm.matmul.F90 -c
$COMP $OPT mod_tools.o mm.matmul.o -o mm.matmul.validation.x
#
#OPT="-O3 -acc -gpu=managed -cuda -cudalib -Minfo=acc -DSINGLEPRECISION"
#
OPT="-O3 -acc -gpu=managed -cuda -cudalib -Minfo=acc"
echo "compiling GPU with " $COMP $OPT 
$COMP $OPT mod_tools.F90 -c
$COMP $OPT mm.matmul.F90 -c
echo "That's all folks!!!"


