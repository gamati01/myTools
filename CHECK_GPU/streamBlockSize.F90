! ----------------------------------------------------
! simple copy Memory-to-Memory kernel...
! to compile nvfortran -cuda
!
      module m
              use, intrinsic :: iso_fortran_env
              integer, parameter :: fpKind = real64
      contains
            attributes (global) subroutine copy (lhs, rhs, n)
              implicit none
              real(fpKind):: lhs(*)
              real(fpKind):: rhs(*)
              integer, value :: n
              integer :: i
              i = blockDim%x * (blockIdx%x-1) + threadIdx%x  
              if (i<=n) lhs(i) = rhs(i)
            end subroutine copy
      end module m
      !
! ----------------------------------------------------
      program streamBlockSize
!
! simple stream code (borrowed) from M. Fatica book (2nd edition)
! computer BW as a function of the Blocksize (max 1024)
!
          use cudafor
          use m
!
          implicit none
!              
          integer, parameter   :: n=(2*64*1024*1024)
          real(fpKind), device :: a_d(n)        !lhs
          real(fpKind), device :: b_d(n)        !rhs
          real(fpKind)         :: a(n)          !check
          real :: time
          real :: somma
          real :: peakBW, sustBW
          integer :: iter, i
          integer :: istat 
          integer :: nDevices
          integer(8) :: nBytes
          integer :: nBlocks, blockSize
          type(cudaevent) :: startEvent, stopEvent
          type(cudaDeviceProp) :: prop
!
! set blocksize et al...
          blockSize = 8
          nBlocks = (n-1)/blockSize+1
          nBytes = 2*sizeof(a_d)
!
! running on GPU0
          istat = cudaGetDeviceProperties(prop,0)
!
! theoretical peak
          peakBW = 2.0*(prop%memoryBusWidth/8)*  &
                   (prop%memoryClockRate/1000)/  &
                   1000
!           
          write(6,*) "-------------------------"
          write(6,*) "GPU              ", trim(prop%name)
          write(6,*) "GPU freq.   (Mhz)", prop%memoryClockRate/1000
          write(6,*) "Bus width  (bits)", prop%memoryBusWidth
          write(6,*) "Peak BW    (GB/s)", peakBW
          write(6,*) "Vector Size  (MB)        ", n/1024/1024
          write(6,*) "-------------------------"
          write(6,*) "BlockSize, Meas.BW, Peak BW(GB/s) "
!
! loop over blocksize (8,16,32,64,128,256,512,1024)
          do iter = 0, 7
!
! vector allocate & initialization          
             a_d=-666*1.0_fpKind
             b_d= (iter+1)*1.0_fpKind
!             
             istat = cudaEventCreate(startEvent)
             istat = cudaEventCreate(stopEvent)
!
! copy section
             istat = cudaDeviceSynchronize()
             istat = cudaEventRecord(startEvent,0)
!          
             call copy <<< nBlocks, blockSize >>> (a_d,b_d,n)
!          
             istat = cudaEventRecord(stopEvent, 0)
             istat = cudaEventSynchronize(stopEvent)
             istat = cudaEventElapsedTime(time,startEvent,stopEvent)
!          
             istat = cudaEventDestroy(startEvent)
             istat = cudaEventDestroy(stopEvent)
!
             sustBW = nBytes/time/1000000
!          
             write(6,*) blockSize, sustBW, peakBW
!             write(6,*) "-------------------------"
!             write(6,*) "    "
!
! check  (only last 100 elements)
             somma = 0
             do i = 1, n, 10000
                a(i) = a_d(i)
                somma  = somma - (a(i) - (iter+1)*1.0_fpKind)
             enddo
!            
             if (somma == 0) then
! do nothing
             else
                 write(6,*) "ERROR: somma is not zero ", somma
             endif    
!             
! new blockSize (et al...)             
             blockSize = 2*blockSize
             nBlocks = (n-1)/blockSize+1
!              
          enddo
!              
      end program streamBlockSize
!
