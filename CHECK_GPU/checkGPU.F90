!
      program checkGPU
!
! (borrowed) from M. Fatica book (2nd edition)
!
! compile with
! nvfortran -cuda checkGPU -o checkGPU.x
!
              use cudafor
!
              implicit none
!              
              integer :: i
              integer :: istat
              integer :: iunit
              integer :: nDevices
              type (cudaDeviceProp) :: prop
!
              istat = cudaGetDeviceCount(nDevices)
!
              write(6,*) "INFO: -------------------------"
              write(6,*) "INFO: found", nDevices, " GPUs "              
              write(6,*) "INFO: -------------------------"
              do i = 0, nDevices-1
                   istat = cudaGetDeviceProperties(prop,i)
!                   
                   write(6,*) "                         "
                   write(6,*) "-------------------------"
                   write(6,*) "Device #",i
                   write(6,*) "NAME    ", trim(prop%name)
                   write(6,*) "Freq  (GPU, Mhz)     ", prop%clockRate/1000
                   write(6,*) "Freq  (HBM, Mhz)     ", prop%memoryClockRate/1000
                   write(6,*) "Bus Width (bits)     ", prop%memoryBusWidth
                   write(6,*) "SP to DP ratio       ", prop%singleToDoublePrecisionPerfRatio
                   write(6,*) "ECC enabled          ", prop%ECCEnabled
                   write(6,*) "Max Threads per node ", prop%maxThreadsPerBlock
                   write(6,*) "SM available         ", prop%multiProcessorCount
                   write(6,*) "--------Derived figures------"
                   write(6,*) "Cuda cores           ",       & 
                               prop%multiProcessorCount*64
                   write(6,*) "Peak BW   (GB/s)     ",       & 
                               2.0*(prop%memoryBusWidth/8)*  &
                               (prop%memoryClockRate/1000)/  &
                               1000
                   write(6,*) "Peak FP64 (TF/s)     ",            &
                               2.0*prop%multiProcessorCount*64.0*     &
                               ((prop%clockrate/1000.0)/1000.0)/1000.0
                   write(6,*) "Peak FP32 (TF/s)     ",            &
                               4.0*prop%multiProcessorCount*64.0*     &
                               ((prop%clockrate/1000.0)/1000.0)/1000.0
                   write(6,*) "-------------------------"
              enddo
!       
      end program checkGPU

