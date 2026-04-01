! =====================================================================
!     ****** myTools/mm
!
!     COPYRIGHT
!       (c) 2026 by Giorgio Amati
!     NAME
!       mm
!     DESCRIPTION
!       Matrix-Matrix Multiplication
!               * naive version
!               * CPU (serial)
!               * GPU (openACC, kernel=1)  
!       size of the matrix should be given at standard input
!     INPUTS
!       matrix size (at standard input)
!     OUTPUT
!       time, Mflops, energy for GPU
!     TODO
!
!     NOTES
!       It works if GPUs are 4, if they are less the code must be *fixed*
!       active preprocessing flags
!       _OPENACC
|       NVML
!     *****
! =====================================================================

program mm
!
    use precision_module
    use timing_module
!
#ifdef _OPENACC
    use openacc
#endif
!
#ifdef NVML
!    use iso_c_binding, only: c_int,c_long_long
    use iso_c_binding
    use nvml_interface
#endif
!
    implicit none
!
    integer :: i,j,k  ! index
    integer :: n      ! size of the matrix
    integer :: mydev0 ! GPUs
    integer :: mydev1
    integer :: mydev2
    integer :: mydev3
!
#ifdef NVML
    integer(c_int) :: ierrc
    integer(c_long_long) :: energy0_1,energy0_2
    integer(c_long_long) :: energy1_1,energy1_2
    integer(c_long_long) :: energy2_1,energy2_2
    integer(c_long_long) :: energy3_1,energy3_2
    integer(c_int) :: mydev0_c
    integer(c_int) :: mydev1_c
    integer(c_int) :: mydev2_c
    integer(c_int) :: mydev3_c
#endif
!
    real(my_kind), dimension(:,:), allocatable:: a ! matrix (origin)
    real(my_kind), dimension(:,:), allocatable:: b ! matrix (origin)
    real(my_kind), dimension(:,:), allocatable:: c ! matrix (destination)
    real(my_kind):: time1, time2 ! timing
    real(my_kind):: time3, time4 ! timing
    real(my_kind):: mflops ! Mflops
    real(dp_kind):: check
!
    write(6,*) "--------------------------------------"
    write(6,*) " Matrix-Matrix Multiplication         "
    write(6,*) " precision used    ",precision(a(1,1))
    write(6,*) " rel. 0.75 "
!
#ifdef _OPENACC
    write(6,*) " Gpu version (openacc) "
#else
!
    write(6,*) " Cpu version "
#endif
!
#ifdef NVML
    write(6,*) " NVML enabled "
#endif 
!
    write(6,*) " Which matrix size?                   "
    read(5,*) n
    write(6,*) " Matrix size      =", n
    write(6,*) " Memory size (MB) =", 3*n*n*my_kind/1024/1024 
    write(6,*) "--------------------------------------"
!
! allocate arrays 
    allocate(a(1:n,1:n))
    allocate(b(1:n,1:n))
    allocate(c(1:n,1:n))
!
! set some variables
    mflops = 2*float(n)*float(n)*float(n)/(1000.0*1000.0)
    check = 0.0
    mydev0 = 0
    mydev1 = 1
    mydev2 = 2
    mydev3 = 3
!
! initialization arrays
    call timing(time1)
    call random_number(a)
    call random_number(b)
    c = 0._my_kind
    call timing(time2)
    write(*,*) " Time initialization", time2-time1
    write(*,*) " Check arrays       ",a(n/2,n/2),b(n/2,n/2),c(n/2,n/2)
!
! computational Core
    call system("date       > time.log")
    call timing(time1)
!
#ifdef NVML
    mydev0_c=int(mydev0,kind=c_int)
    mydev1_c=int(mydev1,kind=c_int)
    mydev2_c=int(mydev2,kind=c_int)
    mydev3_c=int(mydev3,kind=c_int)
    ierrc=get_gpu_energy_mJ_u64(mydev0_c,energy0_1)
    ierrc=get_gpu_energy_mJ_u64(mydev1_c,energy1_1)
    ierrc=get_gpu_energy_mJ_u64(mydev2_c,energy2_1)
    ierrc=get_gpu_energy_mJ_u64(mydev3_c,energy3_1)
#endif
!
#ifdef _OPENACC
!$acc data copyin(a,b) copy(c)
!$acc kernels
#endif
!
    do j = 1, n
       do k = 1, n
          do i = 1, n
             c(i,j) = c(i,j) + a(i,k)*b(k,j)
          enddo
       enddo
    enddo
!
#ifdef _OPENACC
!$acc end kernels
!$acc end data
#endif
!
#ifdef NVML
    ierrc=get_gpu_energy_mJ_u64(mydev0_c,energy0_2)
    ierrc=get_gpu_energy_mJ_u64(mydev1_c,energy1_2)
    ierrc=get_gpu_energy_mJ_u64(mydev2_c,energy2_2)
    ierrc=get_gpu_energy_mJ_u64(mydev3_c,energy3_2)
#endif
!
    call timing(time2)
    call system("date       >> time.log")
!
    write(6,*) "----------------------------"
    write(6,*) "GPU:time for moltiplication ", time2-time1
    write(6,*) "GPU:MFLOPS                  ", mflops/(time2-time1)
    write(6,*) "GPU:check                   ", c(n/2-1,n/2-1)
    write(6,*) "----------------------------"
    write(6,*) "GPU0:Energy       (J)       ", (energy0_2-energy0_1)/1000
    write(6,*) "GPU0:Mean Power   (W)       ", (energy0_2-energy0_1)/1000.0/(time2-time1)
    write(6,*) "GPU1:Energy       (J)       ", (energy1_2-energy1_1)/1000
    write(6,*) "GPU1:Mean Power   (W)       ", (energy1_2-energy1_1)/1000.0/(time2-time1)
    write(6,*) "GPU2:Energy       (J)       ", (energy2_2-energy2_1)/1000
    write(6,*) "GPU2:Mean Power   (W)       ", (energy2_2-energy2_1)/1000.0/(time2-time1)
    write(6,*) "GPU3:Energy       (J)       ", (energy3_2-energy3_1)/1000
    write(6,*) "GPU3:Mean Power   (W)       ", (energy3_2-energy3_1)/1000.0/(time2-time1)
    write(6,*) "----------------------------"
!
end program mm

