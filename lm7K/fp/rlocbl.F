#define USEOPTIONAL
      module m_prlcb
      contains
      subroutine prlcb2(job,ia,nkaph,iprmb,nlmha,kmax,nlma,isp,cPkL,
     .nlmto,evec,ewgt,numq,evl,qhh,qhp)
C- Add one and two-center terms to density coeffs
C ----------------------------------------------------------------------
Ci Inputs
Ci   job   :0 accumulate local density-matrix
Ci         :1 accumulate local density-matrix weighted by energy
Ci   ia    :site of augmentation
Ci   nkaph :dimensions qhh,qhp
Ci   iprmb :permutations ordering orbitals in l+i+h blocks (makidx.f)
Ci   nlmha :dimensions qhh,qhp
Ci   kmax  :polynomial cutoff
Ci   nlma  :augmentation L-cutoff
Ci   isp   :spin channel
Ci   cPkL  :PkL expansion eigenvector at site ia.
Ci   nlmto :dimension of lmto component of basis
Ci   evec  :eigenvector
Ci   numq  :number of trial fermi levels
Ci   ewgt  :eigenvector weight
Ci   evl   :energy weight (job=1)
Co Outputs
Co   qhh   :one-center density-matrix for PkL expansion (job=0)
Co         :energy-weighted matrix (job=1)
Co   qhp   :two-center density-matrix for PkL expansion (job=0)
Co         :energy-weighted matrix (job=1)
Cr Remarks
Cu Updates
Cu   05 Jul 08 (T. Kotani)
Cu             Option to accumulate energy-weighted output density
Cu   27 Aug 01 Extended to local orbitals.
C ----------------------------------------------------------------------
C     implicit none
C ... Passed parameters
      integer job,ia,kmax,nkaph,isp,nlmto,nlma,nlmha,numq,iprmb(1)
#ifdef USEOPTIONAL
      double precision qhh(nkaph,nkaph,nlmha,nlmha,numq,isp),
     .qhp(nkaph,0:kmax,nlmha,nlma,numq,isp),ewgt(numq)
      real(8),optional::evl
#else
      double precision qhh(nkaph,nkaph,nlmha,nlmha,numq,isp),
     .qhp(nkaph,0:kmax,nlmha,nlma,numq,isp),ewgt(numq),evl
#endif
      double complex evec(nlmto),cPkL(0:kmax,nlma)
C ... Local parameters
      integer i1,i2,ilm1,ilm2,ilma,io1,io2,iq,k,ik1,ik2,
     .l1,l2,n0,nkap0,nlm11,nlm12,nlm21,nlm22
      parameter (n0=10,nkap0=3)
      integer norb,ltab(n0*nkap0),ktab(n0*nkap0),offl(n0*nkap0),
     .blks(n0*nkap0),ntab(n0*nkap0)
      double precision xx

      if (nlmto .eq. 0) return
      call tcn('prlcb2')

C --- Loop over all orbitals centered at site ia, incl. local orbs ---
      call orbl(ia,0,nlmto,iprmb,norb,ltab,ktab,xx,offl,xx)
C     Block into groups of consecutive l
      call gtbsl1(4,norb,ltab,ktab,xx,xx,ntab,blks)

      do  io1 = 1, norb

        l1  = ltab(io1)
        ik1 = ktab(io1)
        nlm11 = l1**2+1
        nlm12 = nlm11 + blks(io1)-1
C       i1 = hamiltonian offset for first orbital in block
        i1 = offl(io1)
        do  ilm1 = nlm11, nlm12
          i1 = i1+1
C     ... Accumulate products H*Pkl
          do  iq = 1, numq
            if (job .eq. 0) then
              do  k = 0, kmax
                do  ilma = 1, nlma
                  qhp(ik1,k,ilm1,ilma,iq,isp)= qhp(ik1,k,ilm1,ilma,iq,isp)
     .            + 2d0*dconjg(evec(i1))*cPkL(k,ilma)*ewgt(iq)
                enddo
              enddo
            else
              do  k = 0, kmax
                qhp(ik1,k,ilm1,ilm1,iq,isp)= qhp(ik1,k,ilm1,ilm1,iq,isp)
     .          + evl*2d0*dconjg(evec(i1))*cPkL(k,ilm1)*ewgt(iq)
              enddo
            endif
          enddo

C     ... Accumulate products H*H
          do  io2 = 1, norb

            l2  = ltab(io2)
            ik2 = ktab(io2)
            nlm21 = l2**2+1
            nlm22 = nlm21 + blks(io2)-1
C           i2 = orbital index in iprmb order
            i2 = offl(io2)
            do  ilm2 = nlm21, nlm22
              i2 = i2+1
              if (job .eq. 0) then
                do  iq = 1, numq
                  qhh(ik1,ik2,ilm1,ilm2,iq,isp) =
     .            qhh(ik1,ik2,ilm1,ilm2,iq,isp) +
     .            dconjg(evec(i1))*evec(i2)*ewgt(iq)
                enddo
              elseif (job .eq. 1 .and. ilm1 .eq. ilm2) then
                do  iq = 1, numq
                  qhh(ik1,ik2,ilm1,ilm2,iq,isp) =
     .            qhh(ik1,ik2,ilm1,ilm2,iq,isp) +
     .            evl*dconjg(evec(i1))*evec(i2)*ewgt(iq)
                enddo
              endif
            enddo
          enddo

        enddo
      enddo

      call tcx('prlcb2')
      end subroutine prlcb2


      subroutine prlcb3(job,kmax,nlma,isp,cPkL,numq,ewgt,evl,qpp)

C- Add to local density coefficients for one state
C ----------------------------------------------------------------------
Ci Inputs
Ci   job   :0 accumulate local density-matrix
Ci         :1 accumulate local density-matrix weighted by energy
Ci   kmax  :polynomial cutoff in PkL expansion
Ci   nlma  :L cutoff in PkL expansion
Ci   isp   :spin channel
Ci   cPkL  :coefficients to PkL expansion of evec
Ci   numq  :number of trial fermi levels
Ci   ewgt  :eigenvector weights
Ci   evl   :energy weight (job=1)
Co Outputs
Co   qpp   :local density matrix for PkL expansion (job=0)
Co         :energy-weighted local density matrix (job=1)
Cr Remarks
Cu Updates
Cu   05 Jul 08 (T. Kotani)
Cu             Option to accumulate energy-weighted output density
C ----------------------------------------------------------------------
C     implicit none
C ... Passed parameters
      integer job,kmax,nlma,isp,numq
      double complex cPkL(0:kmax,nlma)
#ifdef USEOPTIONAL
      double precision qpp(0:kmax,0:kmax,nlma,nlma,numq,isp),ewgt(numq)
      real(8),optional::evl
#else
      double precision qpp(0:kmax,0:kmax,nlma,nlma,numq,isp),ewgt(numq),
     .evl
#endif
C ... Local parameters
      double precision fac
      integer iq,ilm2,ilm1,k1,k2

      call tcn('prlcb3')
      do  iq = 1, numq
        fac = ewgt(iq)
        if (job .eq. 1) fac = evl*ewgt(iq)
        do  ilm2 = 1, nlma
          do  ilm1 = 1, nlma
            do  k1 = 0, kmax
              do  k2 = 0, kmax
                qpp(k1,k2,ilm1,ilm2,iq,isp)= qpp(k1,k2,ilm1,ilm2,iq,isp)
     .          + fac*dconjg(cPkL(k1,ilm1))*cPkL(k2,ilm2)
              enddo
            enddo
          enddo
        enddo
      enddo
      call tcx('prlcb3')
      end subroutine prlcb3
      end module m_prlcb


CSFCPP#define F90 1
      subroutine rlocbl ( ssite , sspec , slat , lfrce , nbas , isp 
     .     , q , ndham , ndimh , nspc , napw , igvapw , iprmb , numq , nevec 
     .     , evec , ewgt , evl , sv_p_osig , sv_p_otau , sv_p_oppi , lcplxp 
     .     , lekkl , sv_p_oqkkl , sv_p_oeqkkl , f )
      use m_struc_def  !Cgetarg
      use m_globalvariables
      use m_prlcb
C- Accumulates the local atomic densities.
C ----------------------------------------------------------------------
Ci Inputs
Ci   ssite :struct for site-specific information; see routine usite
Ci     Elts read: spec pos
Ci     Stored:    *
Ci     Passed to: bstrux
Ci   sspec :struct for species-specific information; see routine uspec
Ci     Elts read: lmxa kmxt lmxb rsma
Ci     Stored:    *
Ci     Passed to: bstrux
Ci   slat  :struct for lattice information; see routine ulat
Ci     Elts read: ocg ojcg oidxcg ocy alat qlat
Ci     Stored:    *
Ci     Passed to: bstrux
Ci   lfrce :if nonzero, accumulate contribution to force
Ci   nbas  :size of basis
Ci   isp   :spin channel
Ci   q     :Bloch wave number
Ci   ndham :leanding dimension of evl
Ci   ndimh :dimension of evec
Ci   nspc  :2 for coupled spins; otherwise 1
Ci   napw  :number of G vectors in PW basis (gvlst2.f)
Ci   igvapw:G vectors in PW basis, units of qlat (gvlst2.f)
Ci   iprmb :permutations ordering orbitals in l+i+h blocks (makidx.f)
Ci   numq  :number of trial fermi levels
Ci   nevec :number of occupied eigenvectors
Ci   evec  :eigenvectors
Ci   ewgt  :eigenvector weights
Ci   evl   :eigenvalues
Ci   osig  :overlap matrix of P_kL
Ci   otau  :kinetic energy matrix of P_kL (not used here)
Ci   oppi  :potential matrix of P_kL
Ci   lcplxp:0 if ppi is real; 1 if ppi is complex
Ci   lekkl :0 do not accumulate oeqkkl; 1 do accumulate oeqkkl
Co Outputs
Co   oqkkl :local density-matrix; see Remarks
Co   oeqkkl:local part of energy-weighted density matrix
Co   f     :local contribution to forces is added
Cl Local variables
Cl   ispc  :the current spin index in the coupled spins case.
Cl         :Some quantities have no separate address space for each
Cl         :spin in the indepedent-spins case (evec,evl,ewgt) but do
Cl         :in the coupled-spins case.  A separate loop ispc=1..nspc
Cl         :must be added for the latter case
Cl         :ispc is the appropriate index for objects which distinguish
Cl         :spins in the spin-coupled case only
Cl   isp   :isp  is the appropriate index for objects which distinguish
Cl         :spins in the spin-uncoupled case only
Cl   ksp   :the current spin index in both independent and coupled
Cl         :spins cases.
Cl         :ksp is appropriate spin index for quantities that have
Cl         :separate address space for each spin in every case
Cl         :(potential- and density-like objects).
Cr Remarks
Cr   The qkkl are contractions of the proper density-matrix
Cr      Dij = {sum_n w_n evec*_in evec_jn}
Cr   and the coefficients to the one-center expansion of the wave
Cr   function inside the augmentation sphere
Cr     F~i = Fi + sum_kL C^i_kL (P~kL - PkL)
Cr   As usual, we neglect cross terms when making function products.
Cr   Thus function products are of the form
Cr     F~i F~j = Fi Fj +
Cr             = sum_kLk'L' C^i_kL (P~kL P~k'L' - PkL Pk'L') C^j_k'L'
Cr             = sum_kLk'L' C^i_kL (n1kLk'L' - n2kLk'L') C^j_k'L'
Cr   the qkkl are defined as, e.g.
Cr      qpp_kLk'L' = sum_ij D_ij C^i_kL C^j_k'L'
Cr   so that the local part of the output density is
Cr      n1 - n2 = sum_kLk'L' qpp_kLk'L' (n1kLk'L' - n2kLk'L')
Cu Updates
Cu   05 Jul 08 (T. Kotani) output density for new PW part
Cu             Option to accumulate energy-weighted output density
Cu   01 Jul 05 handle sites with lmxa=-1 -> no augmentation
Cu   16 Jun 05 Makes spin-off-diagonal density matrix, noncollinear case
Cu   23 Dec 04 Extended to spin-coupled case
Cu    1 Sep 04 Adapted to handle complex ppi
Cu   25 Aug 04 Adapted to extended local orbitals
Cu   10 Apr 02 Redimensionsed eh,rsmh to accomodate larger lmax
Cu   15 Feb 02 (ATP) Added MPI parallelization
Cu   27 Aug 01 Extended to local orbitals.
Cu   17 Jun 00 spin polarized
Cu   25 May 00 Adapted from nfp rloc_q.f
C ----------------------------------------------------------------------
      implicit none
C ... Passed parameters
#if MPI
      include "mpif.h"
      integer procid,master
      integer numprocs, ierr, status(MPI_STATUS_SIZE)
      integer MAX_PROCS
      parameter (MAX_PROCS = 100)
      integer resultlen
      character*(MPI_MAX_PROCESSOR_NAME) name
      character*10 shortname(0:MAX_PROCS-1)
      character*20 ext
      character*26 datim
      integer namelen(0:MAX_PROCS-1), pid
      double precision starttime, endtime
      character*120 strn
      logical mlog,cmdopt
#endif
      integer lfrce,nbas,isp,ndimh,nspc,numq,nevec,lcplxp,lekkl,
     .iprmb(1),ndham,napw,igvapw(3,napw)
      type(s_rv1) :: sv_p_oppi(3,1)
      type(s_rv1) :: sv_p_otau(3,1)
      type(s_rv1) :: sv_p_osig(3,1)
      type(s_rv1) :: sv_p_oeqkkl(3,1)
      type(s_rv1) :: sv_p_oqkkl(3,1)
      real(8):: q(3) , ewgt(numq,nevec) , evl(ndham,isp) , f(3,nbas,numq)
      type(s_site)::ssite(*)
      type(s_spec)::sspec(*)
      type(s_lat)::slat

      double complex evec(ndimh,nspc,nevec)
C ... Local parameters or process-shared variables
#if MPI
      double precision, dimension(:), allocatable :: buffer
      integer, dimension(:), allocatable :: bproc
      integer nelt(3),lgunit,lmxh,nlmh,nsp,i
#endif

      integer is,nlmbx,nlmx,ktop0,npmx,nkap0,n0
      parameter (nlmbx=25,  nkap0=3, n0=10) !npmx=32,
      integer kmaxx,nlmax,igetss,nglob,nlmto !mp,
      double precision alat,qlat(3,3)
C ... Local process-specific variables
      integer ia,isa,ivec,kmax,lmxa,nlma,ip,oxf,
     .lmxha,nlmha,nkaph,ispc,ksp
      integer:: ob , odb
      double precision pa(3),rsma,pi,tpiba
CSFCPP#if F90
      complex(8),allocatable:: cPkL(:),da(:),wk(:)
CSFCPP#else
CSFCPP      integer ib,nlmhb,ik
CSFCPP      double precision p(3),xx
CSFCPP      parameter (nlmx=49,ktop0=10)
CSFCPP      double complex cPkL((ktop0+1)*nlmx),da((ktop0+1)*nlmx*3),
CSFCPP     .b0((ktop0+1)*nlmx*nlmbx),db0((ktop0+1)*nlmx*nlmbx*3),
CSFCPP     .wk((ktop0+1)*nlmx),bos((ktop0+1)*nlmbx)
CSFCPP      integer norb,nkapi
CSFCPP      integer lh(nkap0),ltab(n0*nkap0),ktab(n0*nkap0),offl(n0*nkap0)
CSFCPP      double precision eh(n0,nkap0),rsmh(n0,nkap0)
CSFCPP#endif
C$    integer mp_numthreads,mp_my_threadnum
C ... Heap
      integer ::iwdummy

      integer:: iaini,iaend
      complex(8),allocatable::w_ob(:),w_odb(:),w_oxf(:)

#if MPI
      call MPI_COMM_RANK( MPI_COMM_WORLD, procid, ierr )
      call MPI_COMM_SIZE( MPI_COMM_WORLD, numprocs, ierr )
      call MPI_GET_PROCESSOR_NAME(name, resultlen, ierr)
      call strcop(shortname(procid),name,10,'.',i)
      namelen(procid) = i-1
      master = 0
      mlog = cmdopt('--mlog',6,0,strn)
Changenglob      nsp = nglob('nsp')
      nsp = globalvariables%nsp
      if (mlog) then
        do  pid = 0, numprocs-1
          call MPI_BCAST(shortname(pid),10,MPI_CHARACTER,pid,
     .    MPI_COMM_WORLD,ierr)
          call MPI_BCAST(namelen(pid),1,MPI_INTEGER,pid,
     .    MPI_COMM_WORLD,ierr)
        enddo
      endif
#endif

      if (nevec .le. 0) return
      call tcn('rlocbl')

C --- Setup ---
      nkaph = globalvariables%nkaph
C ... Find maximum sizes needed to allocate strux; allocate them
      nlmax = 0
      kmaxx = 0
      do  ia = 1, nbas
        isa = int(ssite(ia)%spec)
        lmxa=sspec(isa)%lmxa
        kmax=sspec(isa)%kmxt
        nlma = (lmxa+1)**2
        kmaxx = max(kmaxx,kmax)
        nlmax = max(nlmax,nlma)
      enddo
      nlmto = ndimh-napw
C     Needed for PW part
      alat=slat%alat
c      i_copy_size=size(slat%qlat)
c      call dcopy(i_copy_size,slat%qlat,1,qlat,1)
      qlat=slat%qlat
      pi = 4d0*datan(1d0)
      tpiba = 2d0*pi/alat

CSFCPP#if F90
C ... Allocate workspace for augmentation arrays
      nlmx  = nlmax
      ktop0 = kmaxx
      allocate(cPkL((ktop0+1)*nlmx),da((ktop0+1)*nlmx*3),
     .wk((ktop0+1)*nlmx))
C      allocate(cPkL((ktop0+1)*nlmx),da((ktop0+1)*nlmx*3),
C     .  b0((ktop0+1)*nlmx*nlmbx),db0((ktop0+1)*nlmx*nlmbx*3),
C     .  wk((ktop0+1)*nlmx),bos((ktop0+1)*nlmbx))
CSFCPP#else
CSFCPP      if (napw .gt. 0) call rx('rlocbl: PWs require F90 compiler')
CSFCPP#endif
      if (nlmax .gt. nlmx) call rxi('rlocbl: nlmx.lt.nlma=',nlmax)
      if (kmaxx .gt. ktop0) call rxi('rlocbl: ktop0.lt.kmax=',kmax)

C ... Allocate workspace for strux
c      mp = 1
C$    mp = mp_numthreads()

      allocate(w_ob(ndimh*nlmax*(kmaxx+1)))
      allocate(w_odb(ndimh*nlmax*(kmaxx+1)*3))
      if (lfrce .ne. 0) then
        allocate(w_oxf(3*nbas*numq))
        w_oxf=0d0
      endif
c      do  ip = 1, mp
c        call defcc(oib(ip), ndimh*nlmax*(kmaxx+1))
c        call defcc(oidb(ip),ndimh*nlmax*(kmaxx+1)*3)
c        if (lfrce .ne. 0) call defrr(oixf(ip),-3*nbas*numq)
c      enddo

C --- Loop over augmentation sites ---
#if MPI
      allocate (bproc(0:numprocs), stat=ierr)
      call dstrbp(nbas,numprocs,1,bproc(0))
c      do  ia = bproc(procid), bproc(procid+1)-1
      iaini=bproc(procid)
      iaend=bproc(procid+1)-1
#else
      iaini=1
      iaend=nbas
#endif
      do ia = iaini,iaend
#if MPI
        if (mlog .and. ia .eq. bproc(procid)) then
          call gettime(datim)
          call awrit4(' rlocbl '//datim//' Process %i of %i on '
     .    //shortname(procid)(1:namelen(procid))//
     .    ' starting atoms %i to %i',' ',256,lgunit(3),
     .    procid,numprocs,bproc(procid),bproc(procid+1)-1)
        endif
#endif
        ip=1
        isa=ssite(ia)%spec
        pa=ssite(ia)%pos(1:3)
        lmxa=sspec(isa)%lmxa
        lmxha=sspec(isa)%lmxb
        kmax=sspec(isa)%kmxt
        rsma=sspec(isa)%rsma
        nlmha = (lmxha+1)**2
        nlma  = (lmxa+1)**2
        if (lmxa .eq. -1) goto 10

#define OQPP sv_p_oqkkl(1,ia)%v
#define OQHP sv_p_oqkkl(2,ia)%v
#define OQHH sv_p_oqkkl(3,ia)%v
#define OEQPP sv_p_oeqkkl(1,ia)%v
#define OEQHP sv_p_oeqkkl(2,ia)%v
#define OEQHH sv_p_oeqkkl(3,ia)%v
#define OPPIPP sv_p_oppi(1,ia)%v
#define OSIGPP sv_p_osig(1,ia)%v
#define OPPIHP sv_p_oppi(2,ia)%v
#define OSIGHP sv_p_osig(2,ia)%v

C   --- Strux to expand all orbitals and their gradients at site ia ---
        call bstrux ( 1 , slat , ssite , sspec , slat%rv_a_ocg , slat%iv_a_oidxcg
     .      , slat%iv_a_ojcg , slat%rv_a_ocy , iprmb , nbas , ia , pa , rsma , q , 
     .      kmax , nlma , ndimh , napw , igvapw , w_ob , w_odb )

C   --- Loop over eigenstates ---
C       In noncollinear case, isp=1 always => need internal ispc=1..2
C       ksp is the current spin index in both cases:
C       ksp = isp  in the collinear case
C           = ispc in the noncollinear case
C       whereas ispc is spin index in the noncoll case, but 1 for coll.
        do  ivec = 1, nevec
          do  ispc = 1, nspc
            ksp = max(ispc,isp)
C     ... Pkl expansion of eigenvector
            call rlocb1(ndimh,nlma,kmax,evec(1,ispc,ivec),w_ob,cPkL)
C     ... Add to local density coefficients for one state
#ifdef USEOPTIONAL
            call prlcb3 ( job=0 , kmax=kmax , nlma=nlma , isp=ksp ,
     .        cpkl=cpkl , numq=numq , ewgt=ewgt ( 1 , ivec ) , qpp= OQPP )
            call prlcb2 ( job=0 , ia=ia , nkaph=nkaph , iprmb=iprmb ,
     .         nlmha=nlmha , kmax=kmax , nlma=nlma , 
     .         isp=ksp , cpkl=cpkl , nlmto=nlmto , 
     .         evec=evec ( 1 , ispc , ivec ) , ewgt=ewgt ( 1 , ivec ) ,
     .         numq=numq  , qhh=OQHH , qhp=OQHP )
#else
            call prlcb3 ( 0 , kmax , nlma , ksp , cpkl , numq , ewgt ( 1
     .        , ivec ) , iwdummy , OQPP )
            call prlcb2 ( 0 , ia , nkaph , iprmb , nlmha , kmax , nlma , 
     .         ksp , cpkl , nlmto , evec ( 1 , ispc , ivec ) , ewgt ( 1 , ivec
     .         ) , numq , iwdummy , OQHH , OQHP )
#endif
            if (lekkl .eq. 1) then
               call prlcb3 ( 1 , kmax , nlma , ksp , cpkl , numq , ewgt ( 1
     .              , ivec ) , evl ( ivec , isp ) , OEQPP )
               call prlcb2 ( 1 , ia , nkaph , iprmb , nlmha , kmax , nlma , 
     .              ksp , cpkl , nlmto , evec ( 1 , ispc , ivec ) , ewgt ( 1 , ivec
     .              ) , numq , evl ( ivec , isp ) , OEQHH , OEQHP )
            endif
C          ... needed for off-diagonal density matrix ... comment out now
CC#ifdef F90
C          if (nspc .eq. 2 .and. ispc .eq. 2) then
C            call prlc23(kmax,nlma,2,cPkL1,cPkL,numq,ewgt(1,ivec),
C     .        w(oqpp))
C            call prlc22(ia,nkaph,iprmb,nlmha,kmax,nlma,2,cPkL,ndimh,
C     .        evec(1,1,ivec),evec(1,2,ivec),ewgt(1,ivec),numq,
C     .        w(oqhh),w(oqhp))
C            deallocate(cPkL1)
C          endif
CC#endif

C     ... Contribution to forces
            if (lfrce .ne. 0) then
              call rxx(nspc.ne.1,'forces not implemented in noncoll case')
              call flocbl ( nbas , ia , kmax , nkaph , lmxha , nlmha , nlma 
     .            , lmxa , nlmto , ndimh , iprmb , ksp , evl ( ivec , isp ) , evec 
     .            ( 1 , ispc , ivec ) , ewgt ( 1 , ivec ) , numq , cpkl , w_odb
     .            , da , wk , OPPIPP , OPPIPP , OSIGPP , OPPIHP
     .            , OPPIHP , OSIGHP , lcplxp , w_oxf )
            endif
          enddo
        enddo
   10   continue
C ... end loop over ia
      enddo
#if MPI
      call MPI_BARRIER(MPI_COMM_WORLD,ierr)
      do  pid = 0, numprocs-1
        do  ia = bproc(pid), bproc(pid+1)-1
          is = int(ssite(ia)%spec)
          lmxa=sspec(is)%lmxa
          lmxh=sspec(is)%lmxb
          kmax=sspec(is)%kmxt
          nlma = (lmxa+1)**2
          nlmh = (lmxh+1)**2
          nelt(1) = (kmax+1)*(kmax+1)*nlma*nlma
          nelt(2) = (kmax+1)*nkaph*nlma*nlmh
          nelt(3) = nkaph*nkaph*nlmh*nlmh
          do  i = 1, 3
            call mpi_bcast ( sv_p_oqkkl( i , ia )%v , nelt ( i ) * numq * 
     .       nsp * nspc , mpi_double_precision , pid , mpi_comm_world , ierr 
     .       )

            if (mlog) then
              call gettime(datim)
              call awrit6(' rlocbl '//datim//' Process %i of %i on '
     .        //shortname(procid)(1:namelen(procid))//
     .        ' bcast w(oqkkl(%i,%i)) %i d.p. numbers'//
     .        ' from process %i on '
     .        //shortname(pid)(1:namelen(pid)),' ',
     .        256,lgunit(3),procid,numprocs,i,ia,
     .        nelt(i)*numq*nsp*nspc,pid)
            endif
            if (lekkl .eq. 1) then
              call mpi_bcast ( sv_p_oeqkkl( i , ia )%v , nelt ( i ) * numq 
     .         * nsp * nspc , mpi_double_precision , pid , mpi_comm_world , 
     .         ierr )

              if (mlog) then
                call gettime(datim)
                call awrit6(' rlocbl '//datim//' Process %i of %i on '
     .          //shortname(procid)(1:namelen(procid))//
     .          ' bcast w(oeqkkl(%i,%i)) %i d.p. numbers'//
     .          ' from process %i on '
     .          //shortname(pid)(1:namelen(pid)),' ',
     .          256,lgunit(3),procid,numprocs,i,ia,
     .          nelt(i)*numq*nsp*nspc,pid)
              endif
            endif
          enddo
        enddo
      enddo
      if (lfrce .ne. 0) then
        allocate(buffer(3*nbas*numq), stat=ierr)
c        call MPI_ALLREDUCE(w(oixf(1)),buffer,3*nbas*numq,
        call MPI_ALLREDUCE(w_oxf,buffer,3*nbas*numq,
     .  MPI_DOUBLE_PRECISION,MPI_SUM,MPI_COMM_WORLD,ierr)
        if (mlog) then
          call gettime(datim)
          call awrit2(' rlocbl '//datim//' Process %i of %i on '
     .    //shortname(procid)(1:namelen(procid))//
     .    ' allreduce forces',' ',256,lgunit(3),
     .    procid,numprocs)
        endif
        call daxpy(3*nbas*numq,1d0,buffer,1,f,1)
        deallocate(buffer, stat=ierr)
      endif
      deallocate(bproc, stat=ierr)
#else
      if (lfrce .ne. 0) then
ctakao think mp=1 is assumed in this routine 3rdJune2010
c        do  ip = 1, mp
        call daxpy(3*nbas*numq,1d0,w_oxf,1,f,1)
c        enddo
      endif
#endif
CSFCPP#if F90
      deallocate(cPkL,da,wk)
CSFCPP#endif
c      call rlse(o)
      deallocate(w_ob,w_odb)
      if(lfrce /=0) deallocate(w_oxf)
      call tcx('rlocbl')
      end subroutine rlocbl


      subroutine rlocb1(ndimh,nlma,kmax,evec,b,cPkL)

C- Pkl expansion of wave function at one site
C ----------------------------------------------------------------------
Ci Inputs
Ci   ndimh :dimension of evec
Ci   nlma  :augmentation L-cutoff in PkL expansion
Ci   kmax  :k- cutoff in PkL expansion
Ci   evec  :eigenvector coefficients
Ci   b     :strux to expand of orbitals from other sites in PkL
Ci         :b = b(ndimh,nlma,0:kmax)
Co Outputs
Co   cPkL  :coefficients to PkL expansion of evec
Cu Updates
C ----------------------------------------------------------------------
C     implicit none
C ... Passed parameters
      integer kmax,ndimh,nlma
      double complex b(ndimh,nlma,0:kmax),cPkL(0:kmax,nlma),evec(ndimh)
C ... Local parameters
      integer i,k,ilma


      call tcn('rlocb1')
C     call zprm('b',2,b,ndimh,ndimh,nlma*(kmax+1))
      call dpzero(cPkL, 2*(kmax+1)*nlma)
      do  k = 0, kmax
        do  ilma = 1, nlma
          do  i = 1, ndimh
            cPkL(k,ilma) = cPkL(k,ilma) + evec(i)*b(i,ilma,k)
          enddo
        enddo
      enddo
C     call zprm('cPkL',2,cPkL,kmax+1,kmax+1,nlma)
      call tcx('rlocb1')
      end subroutine rlocb1




C  ... needed for off-diagonal density matrix ... comment out now
C      subroutine prlc22(ia,nkaph,iprmb,nlmha,kmax,nlma,ioff,cPkL,ndimh,
C     .  evec1,evec2,ewgt,numq,qhh,qhp)
CC- Add one and two-center terms to density coeffs
CC ----------------------------------------------------------------------
CCi Inputs
CCi   ia    :site of augmentation
CCi   nkaph :dimensions qhh,qhp
CCi   iprmb :permutations ordering orbitals in l+i+h blocks (makidx.f)
CCi   nlmha :dimensions qhh,qhp
CCi   kmax  :polynomial cutoff
CCi   nlma  :augmentation L-cutoff
CCi   ioff  :spin channel
CCi   cPkL  :PkL expansion eigenvector at site ia.
CCi   ndimh :dimension of hamiltonian
CCi   evec1 :left eigenvector
CCi   evec2 :right eigenvector
CCi   numq  :number of trial fermi levels
CCi   ewgt  :eigenvector weight
CCo Outputs
CCo   qhh   :one-center density-matrix, spin 12 block
CCo   qhp   :two-center density-matrix, spin 12 block
CCr Remarks
CCu Updates
CCu   27 Aug 01 Extended to local orbitals.
CC ----------------------------------------------------------------------
C      implicit none
CC ... Passed parameters
C      integer ia,kmax,nkaph,ioff,ndimh,nlma,nlmha,numq,iprmb(1)
C      double precision ewgt(numq)
C      double complex qhh(nkaph,nkaph,nlmha,nlmha,numq,ioff),
C     .  qhp(nkaph,0:kmax,nlmha,nlma,numq,ioff)
C      double complex evec1(ndimh),evec2(ndimh),cPkL(0:kmax,nlma)
CC ... Local parameters
C      integer i1,i2,ilm1,ilm2,ilma,io1,io2,iq,k,ik1,ik2,
C     .  l1,l2,n0,nkap0,nlm11,nlm12,nlm21,nlm22
C      parameter (n0=10,nkap0=3)
C      integer norb,ltab(n0*nkap0),ktab(n0*nkap0),offl(n0*nkap0),
C     .  blks(n0*nkap0),ntab(n0*nkap0)
C      double precision xx
C
C      call tcn('prlc22')
C
CC --- Loop over all orbitals centered at site ia, incl. local orbs ---
C      call orbl(ia,0,ndimh,iprmb,norb,ltab,ktab,xx,offl,xx)
CC     Block into groups of consecutive l
C      call gtbsl1(4,norb,ltab,ktab,xx,xx,ntab,blks)
C
C      do  io1 = 1, norb
C
C        l1  = ltab(io1)
C        ik1 = ktab(io1)
C        nlm11 = l1**2+1
C        nlm12 = nlm11 + blks(io1)-1
CC       i1 = hamiltonian offset for first orbital in block
C        i1 = offl(io1)
C        do  ilm1 = nlm11, nlm12
C          i1 = i1+1
CC     ... Accumulate products H*Pkl
C          do  iq = 1, numq
C            do  k = 0, kmax
C              do  ilma = 1, nlma
C                qhp(ik1,k,ilm1,ilma,iq,ioff) =
C     .          qhp(ik1,k,ilm1,ilma,iq,ioff)
C     .            + 2d0*dconjg(evec1(i1))*cPkL(k,ilma)*ewgt(iq)
C              enddo
C            enddo
C          enddo
C
CC     ... Accumulate products H*H
C          do  io2 = 1, norb
C
C            l2  = ltab(io2)
C            ik2 = ktab(io2)
C            nlm21 = l2**2+1
C            nlm22 = nlm21 + blks(io2)-1
CC           i2 = orbital index in iprmb order
C            i2 = offl(io2)
C            do  ilm2 = nlm21, nlm22
C              i2 = i2+1
C              do  iq = 1, numq
C                qhh(ik1,ik2,ilm1,ilm2,iq,ioff) =
C     .          qhh(ik1,ik2,ilm1,ilm2,iq,ioff) +
C     .          dconjg(evec1(i1))*evec2(i2)*ewgt(iq)
C              enddo
C            enddo
C          enddo
C
C        enddo
C      enddo
C
C      call tcx('prlc22')
C
C      end
C      subroutine prlc23(kmax,nlma,ioff,cPkL1,cPkL2,numq,ewgt,qpp)
CC- Add to local density coefficients for one state, off-diagonal spin block
CC ----------------------------------------------------------------------
CCi Inputs
CCi   kmax  :polynomial cutoff in PkL expansion
CCi   nlma  :L cutoff in PkL expansion
CCi   ioff  :offset in qpp array
CCi   cPkL1 :coefficients to PkL expansion of left evec
CCi   cPkL2 :coefficients to PkL expansion of right evec
CCi   numq  :number of trial fermi levels
CCi   ewgt  :eigenvector weights
CCo Outputs
CCo   qpp   :local density matrix for PkL expansion, spin 12 block
CCr Remarks
CCu Updates
CCu   16 Jun 05 Adapted from prlcb3
CC ----------------------------------------------------------------------
C      implicit none
CC ... Passed parameters
C      integer kmax,nlma,ioff,numq
C      double complex cPkL1(0:kmax,nlma),cPkL2(0:kmax,nlma)
C      double precision ewgt(numq)
C      double complex qpp(0:kmax,0:kmax,nlma,nlma,numq,ioff)
CC ... Local parameters
C      integer iq,ilm2,ilm1,k1,k2
C
C      call tcn('prlc23')
C      do  iq = 1, numq
C        do  ilm2 = 1, nlma
C          do  ilm1 = 1, nlma
C            do  k1 = 0, kmax
C              do  k2 = 0, kmax
C                qpp(k1,k2,ilm1,ilm2,iq,ioff) =
C     .          qpp(k1,k2,ilm1,ilm2,iq,ioff)
C     .            + ewgt(iq)*dconjg(cPkL1(k1,ilm1))*cPkL2(k2,ilm2)
C              enddo
C            enddo
C          enddo
C        enddo
C      enddo
C      call tcx('prlc23')
C      end

