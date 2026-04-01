! =====================================================================
!     ****** CODICI/sleep
!
!     COPYRIGHT
!       (c) 2026 by Giorgio Amati
!     NAME
!       sleel
!     DESCRIPTION
!       example of use of NVML to get energy 
!     INPUTS
!       none
!     OUTPUT
!       energy/power
!     TODO
!
!     NOTES
!       tested only on Leonardo
!       
!
!     *****
! =====================================================================

program sleep
!
    use timing_module
!
    use iso_c_binding
    use nvml_interface
!
    implicit none
!
    integer :: mydev0
    integer :: mydev1
    integer :: mydev2
    integer :: mydev3
!
    integer(c_int) :: ierrc
    integer(c_long_long) :: energy0_1,energy0_2
    integer(c_long_long) :: energy1_1,energy1_2
    integer(c_long_long) :: energy2_1,energy2_2
    integer(c_long_long) :: energy3_1,energy3_2
    integer(c_int) :: mydev0_c
    integer(c_int) :: mydev1_c
    integer(c_int) :: mydev2_c
    integer(c_int) :: mydev3_c
!
    real(my_kind):: time1, time2 ! timing
!
    write(6,*) "--------------------------------------"
    write(6,*) " Sleep....                            "
    write(6,*) " NVML enabled "
    write(6,*) "--------------------------------------"
!
    mydev0 = 0
    mydev1 = 1
    mydev2 = 2
    mydev3 = 3
!
! main loop
    call system("date       > time.log")
    call timing(time1)
!
    mydev0_c=int(mydev0,kind=c_int)
    mydev1_c=int(mydev1,kind=c_int)
    mydev2_c=int(mydev2,kind=c_int)
    mydev3_c=int(mydev3,kind=c_int)
    ierrc=get_gpu_energy_mJ_u64(mydev0_c,energy0_1)
    if (ierrc /= 0_c_int) then
       write(*,*) "NVML error reading energy for device 0, err=", ierrc
    endif
!    
    ierrc=get_gpu_energy_mJ_u64(mydev1_c,energy1_1)
    if (ierrc /= 0_c_int) then
       write(*,*) "NVML error reading energy for device 1, err=", ierrc
    endif
!    
    ierrc=get_gpu_energy_mJ_u64(mydev2_c,energy2_1)
    if (ierrc /= 0_c_int) then
       write(*,*) "NVML error reading energy for device 2, err=", ierrc
    endif
!    
    ierrc=get_gpu_energy_mJ_u64(mydev3_c,energy3_1)
    if (ierrc /= 0_c_int) then
       write(*,*) "NVML error reading energy for device 3, err=", ierrc
    endif
!    
! do something, e,g, sleep
    call system("sleep 60")
!
    ierrc=get_gpu_energy_mJ_u64(mydev0_c,energy0_2)
    ierrc=get_gpu_energy_mJ_u64(mydev1_c,energy1_2)
    ierrc=get_gpu_energy_mJ_u64(mydev2_c,energy2_2)
    ierrc=get_gpu_energy_mJ_u64(mydev3_c,energy3_2)
!
    call timing(time2)
    call system("date       >> time.log")
!
    write(6,*) "----------------------------"
    write(6,*) "GPU0:Energy       (J)       ", (energy0_2-energy0_1)/1000
    write(6,*) "GPU0:Mean Power   (W)       ", (energy0_2-energy0_1)/(time2-time1)/1000.0
    write(6,*) "GPU1:Energy       (J)       ", (energy1_2-energy1_1)/1000
    write(6,*) "GPU1:Mean Power   (W)       ", (energy1_2-energy1_1)/(time2-time1)/1000.0
    write(6,*) "GPU2:Energy       (J)       ", (energy2_2-energy2_1)/1000
    write(6,*) "GPU2:Mean Power   (W)       ", (energy2_2-energy2_1)/(time2-time1)/1000.0
    write(6,*) "GPU3:Energy       (J)       ", (energy3_2-energy3_1)/1000
    write(6,*) "GPU3:Mean Power   (W)       ", (energy3_2-energy3_1)/(time2-time1)/1000.0
    write(6,*) "----------------------------"
!
end program sleep

