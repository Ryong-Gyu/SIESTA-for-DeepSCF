! 
! Copyright (C) 1996-2016	The SIESTA group
!  This file is distributed under the terms of the
!  GNU General Public License: see COPYING in the top directory
!  or http://www.gnu.org/copyleft/gpl.txt.
! See Docs/Contributors.txt for a list of contributors.
!
      subroutine rhoov( no, np, Datm, rhoover, iaorb, iphorb, isa )
C ********************************************************************
C Compute overlap density 
C *********************** InpUT **************************************
C integer no              : Number of basis orbitals
C integer np              : Number of mesh points
C real*8  Datm(no)        : Occupations of basis orbitals in free atom
C integer iaorb(*)        : Pointer to atom to which orbital belongs
C integer iphorb(*)       : Orbital index within each atom
C integer isa(*)          : Species index of all atoms
C *********************** OUTPUT **************************************
C real    rhoover(nsp,np)  : Overlap density at mesh points
C *********************************************************************
C
C  Modules
C
      use precision, only: dp, grid_p

      use atmfuncs, only: rcut, phiatm
      use atomlist, only: indxuo
      use mesh,     only: nsp, dxa, xdop, xdsp
      use meshphi
C
      implicit none

      integer, intent(in)       ::    no, np
      integer, intent(in)       ::    iaorb(*), iphorb(*), isa(*)
      real(grid_p), intent(out) ::    rhoover(nsp,np)
      real(dp), intent(in)      ::    Datm(no)

      real(dp)     :: phip

      integer      ::  i, ip, isp, iu, kn, iop, is, iphi, ia, ix
      real(dp)     ::  Ci, gradCi(3), r2o, r2sp, dxsp(3) 

      integer      ::  maxloc
      integer      ::  ic, jc, nc, imp
      integer      ::  j, ju, ja

      real(dp), pointer :: Clocal(:,:)


#ifdef DEBUG
      call write_debug( '      Pre rhooda' )
#endif


      maxloc = maxval(endpht(1:np)-endpht(0:np-1))

      nullify ( Clocal )
      allocate( Clocal(nsp,maxloc) )

C  Loop on mesh points
      do ip = 1,np

C  Initialise rhoover
        do isp = 1, nsp
          rhoover(isp,ip) = 0.0_grid_p
        enddo

        nc = endpht(ip) - endpht(ip-1)

C  Loop on orbitals of mesh point
        do ic = 1, nc
          imp = endpht(ip-1) + ic
          i = lstpht(imp)
          iu = indxuo(i)

C  Generate phi value and loop on subpoints
          iphi = iphorb(i)
          ia = iaorb(i)
          is = isa(ia)
          r2o = rcut(is,iphi)**2
          iop = listp2(imp)

          do isp = 1,nsp
            do ix = 1,3
              dxsp(ix) = xdop(ix,iop) + xdsp(ix,isp) - dxa(ix,ia)
            enddo
            r2sp = dxsp(1)**2 + dxsp(2)**2 + dxsp(3)**2
            if (r2sp.lt.r2o) then
              call phiatm(is,iphi,dxsp,phip,gradCi)
              Clocal(isp,ic) = phip**2.0_dp
            else
              Clocal(isp,ic) = 0.0_dp
            endif
          enddo

          do jc = 1, ic - 1
            imp = endpht(ip-1) + jc
            j = lstpht(imp)
            ju = indxuo(j)
            ja = iaorb(j)

            if (ia.ne.ja) then
              do isp = 1,nsp
                rhoover(isp,ip) = rhoover(isp,ip) + 
     &               Datm(iu)*Datm(ju)*Clocal(isp,ic)*Clocal(isp,jc)
              enddo
            endif
          enddo
        enddo
      enddo

      deallocate( Clocal )


#ifdef DEBUG
      call write_debug( '      POS rhooda' )
#endif
      end subroutine rhoov
