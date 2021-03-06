      program hbndout
C- Write band data for QP and GW from QPNT file.
c QPNT points in agreemnet with SYML are used for QP bands.
      implicit none
      integer(4) :: iopenxx,nq,ntq, iq,it, iftote,ifsyml,
     &  nline,iline,nqnum,nqnumx,iflband,iqq,nqqmx,ilinex,
     &  ndimh,ibr,ifi,igx,ngrp,i,ig,nxx,iag,nagmx,iqx,
     &  iflda,ifqp1,ifqp2,iy,ix,iqagree,nqmx,ifbandqp,iq0,ib0,ifip,naa
     &  ,iform
c
      integer(4),parameter :: nlinemax = 50
      character*1  dd1,dd2
c
      integer(4),allocatable:: iout(:,:),nqq(:),nx(:),nag(:)
     &  ,itq(:),itqinv(:),ibidx(:,:,:),iq_ag(:,:),iqq_ag(:,:)
      real(8) qxx(3),ef,polinta2,rydberg,plat(3,3),qlat(3,3),
     &     zerolevel, efermi, eshtlda, eshift0, eshift02
      real(8),allocatable:: elda(:,:),eqp1(:,:),eqp2(:,:),zfac(:,:)
     & ,symops(:,:,:),qp(:,:), xxx(:),dse1(:),dse2(:)
     & ,qq1(:,:),qq2(:,:),qb(:,:,:),qqr(:,:,:),evl(:,:,:),
     & eqp_1(:,:,:), eqp_2(:,:,:),qpos(:,:)
      character*3 charnum3
      character*30 filnm,filnmx
      logical :: d0min(nlinemax), d0max(nlinemax)
      logical :: initqp1=.true., initqp2=.true.
     &  ,extzero=.false.

      logical :: bnddiv=.false., allb
c
      real(8):: ddd(100)
      integer(4) :: iii(100),ifzero
      character(16):: aa1(nlinemax),aa2(nlinemax)
c---------------------------------
      call headver('hbndout',0)
      write(6,*)'--- bndout : make band-plot data LDA and QP ---'
      write(6,*)'--- Readin TOTE2'

      inquire(file='TOTE2',exist=allb) !if allb=F, we only plot LDA ones.
      if(allb) then
        iftote = iopenxx('TOTE2')
      else
        nq=0
        ntq=0
        zerolevel=0d0
        goto 2001
      endif

c      write(6,*)' output format?: std->1 set(sparete)->2 '
c      read (5,*,err=210) iform
c      goto 211
c 210  continue
c      iform=1
c 211  continue
      iform=1
      if(iform == 1) then
        bnddiv=.false.
      elseif(iform == 2) then
        bnddiv=.true.
c      elseif(iform == 3) then
c        bnddiv=.false.
      else
Cstop2rx 2013.08.09 kino        stop 'hbndout : wrong mode'
        call rx( 'hbndout : wrong mode')
      endif

      read (iftote,*) nq,ntq, efermi, eshtlda, eshift0, eshift02
      write(6,"(' nq ntq ef eshtlda eshift0 eshift02=',2i9,4f14.5)") 
     &   nq, ntq, efermi, eshtlda, eshift0, eshift02
      zerolevel = -efermi + eshtlda
      allocate( qp(1:3,nq), itq(ntq)
     &    ,elda(ntq,nq), eqp1(ntq,nq), eqp2(ntq,nq), zfac(ntq,nq))
c
      do iq = 1,nq
        do it = 1,ntq
          read(iftote,"(3f12.7,1x,2i4,1x,4d24.16)") 
     &  qxx,itq(it),iqx, elda(it,iq), eqp1(it,iq), eqp2(it,iq),
     &  zfac(it,iq)
c        write(6,"(3f12.7,1x,2i4,1x,4d24.16)")
c     &  qxx,itq(it),iqx, elda(it,iq), eqp1(it,iq), eqp2(it,iq)
          if(it ==1) then
            qp(:,iq) = qxx
          else
            if( sum(abs(qp(:,iq)-qxx))>1d-10 ) then
              write(6,*)' it iq iqx',it,iq,iqx
Cstop2rx 2013.08.09 kino              stop 'bndout: badQPU qxx'
              call rx( 'bndout: badQPU qxx')
            endif
          endif
        end do
      end do
      eqp1 = eqp1 - elda  ! dSE
      eqp2 = eqp2 - elda  ! dSEnoZ

c---Readin SYML
 2001 write(6,*)'--- Readin SYML'
      d0min =.false.
      d0max =.false.
      allocate(nqq(nlinemax),qq1(1:3,nlinemax),qq2(1:3,nlinemax))
      ifsyml = iopenxx('SYML')
      nline = 0
      do
        nline = nline + 1
        read(ifsyml,*,err=602,end=601) 
     &    nqq(nline),qq1(1:3,nline),qq2(1:3,nline),dd1,dd2
     &   ,aa1(nline),aa2(nline)
c
c        write(6,*)
c     &    nqq(nline),qq1(1:3,nline),qq2(1:3,nline),dd1,dd2

        if((dd1/='T' .and. dd1/='F').or.(dd2/='T' .and. dd2/='F')  ) 
Cstop2rx 2013.08.09 kino     &     stop 'Error readin SYML derivative switches OK? xxx'
     &     call rx( 'Error readin SYML derivative switches OK? xxx')
c        cycle
c
c  602   continue
c        backspace(ifsyml)
c        read(ifsyml,*,err=601,end=601)
c     &    nqq(nline),qq1(1:3,nline),qq2(1:3,nline)
        if(dd1=='T') d0min(nline)=.true.
        if(dd2=='T') d0max(nline)=.true.

        write(6,"(' ndiv+1=',i4, ' qinit= ',3f10.6,' qend=',3f10.6, 
     &      ' Derivative switches:',L,' at qint=',a,' 'L,' at qend=' 
     &      ,a)") 
     &       nqq(nline),qq1(1:3,nline),qq2(1:3,nline)
     &     ,d0min(nline),aa1(nline), d0max(nline),aa2(nline)
      enddo
Cstop2rx 2013.08.09 kino  602 stop 'bndout: Error readin SYML derivative switches OK?  yyy'
  602 call rx( 'bndout: Error readin SYML derivative switches OK?  yyy')
  601 continue
      close(ifsyml)
      nline = nline - 1
ccccccccccccccccccccc
c      write(6,*) 'readin SYML line=',nline
c      stop
ccccccccccccccccccccc
      nqnumx = sum (nqq(1:nline))
      nqqmx = maxval(nqq(1:nline))
      write(6,*)' nline nqnumx nqqmx= ',nline, nqnumx, nqqmx

c --- Readin LBAND
      write(6,*)'--- Readin LBAND'
      iflband = 3001
      open(iflband,form='unformatted',file='LBAND')
      read(iflband) ndimh, nqnum
      read(iflband) plat,qlat
      write(6,*)' ndimh nqnum=', ndimh, nqnum
      write(6,"(' plat =',9f12.6)") plat
      write(6,"(' qlat =',9f12.6)") qlat
      if(nqnum/=nqnumx) then
        write(6,*) nqnum, nqnumx
Cstop2rx 2013.08.09 kino        stop 'hbndout: nqnum of LBAND and SYML is inconsistent'
        call rx( 'hbndout: nqnum of LBAND and SYML is inconsistent')
      endif

c ---- Readin symops(3,3,ng)
      write(6,*)'--- Readin SYMOPS'
      ifi= iopenxx('SYMOPS')
      read(ifi,*) ngrp
      allocate( symops(3,3,ngrp) )
      do ig = 1,ngrp
        read(ifi,*) igx
        do i=1,3
          read(ifi,*) symops(i,1:3,ig)
        enddo
      enddo
      close(ifi)
c
c      write(6,*)' xxx1 ngrp=',ngrp
      nxx = ngrp
      allocate(qb(3,nqqmx,nline),
     &      ibidx(ndimh,nqqmx,nline),
     &       evl (ndimh,nqqmx,nline),
     &     qqr(3,nxx,nq),nx(nq),nag(nline),qpos(nqqmx,nline))

      write(6,*)' xxx2 qb = ----------------ndimh=',ndimh

      do iline = 1,nline
        write(6,*)' iline nqq=',iline,nqq(iline)
        do iqq   = 1,nqq(iline)
          read(iflband) ilinex, qb(1:3,iqq,iline), qpos(iqq,iline)
     &      ,(ibidx(ibr,iqq,iline),evl(ibr,iqq,iline),ibr=1,ndimh)

cccccccccccccccccccccccc
          write(1995,"(i2,3f9.5,' ',f9.5,' ',255(i3,f10.5))") ilinex,
     &     qb(1:3,iqq,iline), qpos(iqq,iline)
     &      ,(ibidx(ibr,iqq,iline),evl(ibr,iqq,iline),ibr=1,ndimh)
cccccccccccccccccccccccc

          if(iline/=ilinex) 
Cstop2rx 2013.08.09 kino     &    stop 'hbndout:iline of LBAND & SYML is inconsistent'
     &    call rx( 'hbndout:iline of LBAND & SYML is inconsistent')
ccccccccccccccccccccccccccccc
c          write(6,*) qb(1:3,iqq,iline)
ccccccccccccccccccccccccccccccccc
        enddo
      enddo
      close(iflband)

c      write(6,*)' xxx3'
      do iq = 1,nq
        ix=0
        do ig= 1,ngrp
          qxx = matmul(symops(:,:,ig),qp(:,iq) )
          do iy=1,ix
            if(sum(abs(qxx -qqr(:,iy,iq)))<1d-5) goto 1102
          enddo
          ix=ix+1
          qqr(:,ix,iq) = qxx
 1102     continue
        enddo
        nx(iq) =ix
ccccccccccccccccccc
c        do ix=1,nx(iq)
c          write(6,"('iq iy qqr=',2i5,3f12.7)") iq, ix,qqr(:,ix,iq)
c        enddo
ccccccccccccccccccc
      enddo

c      write(6,*)' xxx4'
c qqr(3,1:nx(iq), iq) -------------------
      nagmx = nqqmx
      allocate(iq_ag(nagmx,nline),iqq_ag(nagmx,nline))
      do iline = 1, nline
        iag = 0
        do iqq = 1, nqq(iline)
c        write(6,*) 'qb1 =', qb(1:3,iqq,iline)
c        write(6,*) 'qqr =', qqr(1:3,1,1)
          iq = iqagree(qb(1:3,iqq,iline),qqr,nxx,nx,nq,plat,qlat)
          if(iq/=0) then
            iag = iag+1
            iqq_ag(iag,iline) = iqq
            iq_ag (iag,iline) = iq
ccccccccccccccccccccc
            write(6,"(' iline iag iqqOnLine  iq=',4i4)") iline,iag,iqq,iq
ccccccccccccccccccccc
          endif
        enddo
        nag(iline) = iag
      enddo



c--- itqinv(iband) = it
      allocate(itqinv(ndimh),iout(ndimh,nline)
     & ,xxx(nqqmx),dse1(nqqmx),dse2(nqqmx)
     & ,eqp_1(ndimh,nqqmx,nline),eqp_2(ndimh,nqqmx,nline) )
      itqinv = 0
      do it =1,ntq
        itqinv(itq(it)) = it ! inverse-indexing of itq
      enddo

c --- Zerolevel shift when we find elda(it,iq)==0d0 in TOTE2
      inquire(file='ZEROLEVEL',exist=extzero)
      if(extzero) then
        ifzero = iopenxx('ZEROLEVEL')
        read(ifzero,*) zerolevel
        zerolevel= -zerolevel*rydberg()
        close(ifzero)
      endif

c      iq0=-99999
c      zerolevel=0d0
c      do iq = 1,nq
c      do it = 1,ntq
c        if(elda(it,iq)==0d0) then
c          ib0 =itq(it)
c          iq0 =iq
c        endif
c      enddo
c      enddo
c      if(iq0==-99999) goto 1134
c      do iline = 1, nline
c      do iqq   = 1, nqq(iline)
c        iq = iqagree(qb(1:3,iqq,iline),qqr,nxx,nx,nq,plat,qlat)
c        if(iq == iq0) then
c          do ibr=1,ndimh
c          if(ib0==ibidx(ibr,iqq,iline) ) then
c            zerolevel = - evl(ibr,iqq,iline)*rydberg()
c            goto 1134
c          endif
c          enddo
c        endif
c      enddo
c      enddo
c      stop ' bndout: can not find zero level along SYML.'
c 1134 continue
c      write(6,*)' zero level=',  zerolevel



c----
      if(allb) then
        filnmx = 'BandGWpoint'
        ifip = iopenxx (filnmx)

        iout = 1
        do iline = 1, nline
          do ibr = 1, ndimh
            naa=0
            do iag = 1,nag(iline)
!            write(6,*)iline,ibr,iag,iqq_ag(iag,iline),' ibidx=',
!     &               ibidx(ibr,iqq_ag(iag,iline),iline)
              it = itqinv( ibidx(ibr,iqq_ag(iag,iline),iline) )
              if(it==0) cycle
              naa=naa+1
              xxx (naa) = iqq_ag(iag,iline)
              dse1(naa) = eqp1(it,iq_ag(iag,iline))     !dSE at xxx
              dse2(naa) = eqp2(it,iq_ag(iag,iline))     !dSE at xxx
c
              iqq = iqq_ag(iag,iline)
              write(ifip,134) qpos(iqq,iline),  ! Write all points in TOTE2
     &        evl(ibr,iqq,iline)*rydberg() + zerolevel,
     &        evl(ibr,iqq,iline)*rydberg() + dse1(naa)  + zerolevel,
     &        evl(ibr,iqq,iline)*rydberg() + dse2(naa)  + zerolevel,
     &        iline,ibr,qb(1:3,iqq,iline)
 134          format(f12.6,3f14.7,'   ',2i5,3f12.6)
            enddo
            if( naa /= nag(iline).or.naa==0 ) then
              iout(ibr,iline) = 0
              goto 1220
            endif

C --- check write of dse
            do iag = 1,nag(iline)
              it = itqinv( ibidx(ibr,iqq_ag(iag,iline),iline) )
              write(6,"(' iline ibr iag =',3i5,/)") iline,ibr,iag
              write(6,"(' it iq iqq q dse1 dse2=',3i5,3f12.6,2f14.6)") 
     &      it,iq_ag(iag,iline), iqq_ag(iag,iline),
     &      qb(1:3,iqq_ag(iag,iline),iline),
     &      eqp1(it,iq_ag(iag,iline)),eqp2(it,iq_ag(iag,iline))
            enddo
c
            write(6,*) 'xxxxxxxxxxxxxxxxxxxxxxxx'
            do iqq = 1, nqq(iline)
              eqp_1(ibr,iqq,iline)= evl(ibr,iqq,iline)*rydberg() 
     &        + polinta2(dble(iqq), xxx, dse1, naa,
     &              1d0,dble(nqq(iline)), d0min(iline), d0max(iline))
              eqp_2(ibr,iqq,iline)= evl(ibr,iqq,iline)*rydberg() 
     &        + polinta2(dble(iqq), xxx, dse2, naa,
     &              1d0,dble(nqq(iline)), d0min(iline), d0max(iline))
            enddo
 1220       continue
          enddo
        enddo
c
c      do iline= 1, nline
c      do ibr  = 1, ndimh
c        if(iout(ibr,iline)/=0) write(6,*)' ibr iline iout= '
c     &  ,ibr,iline, iout(ibr,iline)
c      enddo
c      enddo
        write(6,'("--- Write ",a)') filnmx
      endif
c--------------------------------
      filnm = 'BandQpoint'
      write(6,'("--- Write ",a)') filnm
      ifbandqp = iopenxx (filnm)
      write(ifbandqp,*) nline
      do iline= 1, nline
        iqq = 1
        write(ifbandqp,"(f14.6,x,a16,'   ',3f12.6)") 
     &  qpos(iqq,iline),aa1(iline),qb(1:3,iqq,iline)
        iqq = nqq(iline)
        write(ifbandqp,"(f14.6,x,a16,'   ',3f12.6)") 
     &  qpos(iqq,iline),aa2(iline),qb(1:3,iqq,iline)
      enddo
      write(ifbandqp,*) "***"
      do iline= 1, nline
        do iqq  = 1, nqq(iline)
          write(ifbandqp,"(f14.6,'    ',2i5,3f12.6)") 
     &  qpos(iqq,iline), iline,iqq,qb(1:3,iqq,iline)
        enddo
        write(ifbandqp,*)
      enddo

      if(.not.bnddiv) then
        filnm = 'BandLDA'
        iflda = iopenxx (filnm)
        write(6,'("--- Write ",a)') filnm
        if(allb) then
          filnm = 'BandQP1'
          ifqp1 = iopenxx (filnm)
          write(6,'("--- Write ",a)') filnm
          filnm = 'BandQP2'
          ifqp2 = iopenxx (filnm)
          write(6,'("--- Write ",a)') filnm
        endif
      endif

C --- write bands
      do ibr  = 1, ndimh
        if(bnddiv) then
          filnm = 'BandLDA.'//charnum3(ibr)
          iflda = iopenxx (filnm)
          write(6,'("--- Write ",a)') filnm
        endif

        if(.not.bnddiv) then
          write(iflda,*)
          write(iflda,*)
        endif

        do iline= 1, nline
          do iqq  = 1, nqq(iline)
            write(iflda,133)   qpos(iqq,iline), 
     &     evl (ibr,iqq,iline)*rydberg() + zerolevel,
     &     iline,ibr, qb(1:3,iqq,iline)
          enddo
          write(iflda,*)'----------------------------------'
        enddo

        if(.not.allb) cycle

        if( sum(iout(ibr,1:nline)) /=0) then
          if(bnddiv) then
            filnm = 'BandQP1.'//charnum3(ibr)
            ifqp1 = iopenxx (filnm)
            write(6,'("--- Write ",a)') filnm
            filnm = 'BandQP2.'//charnum3(ibr)
            ifqp2 = iopenxx (filnm)
            write(6,'("--- Write ",a)') filnm
          endif

          if(.not.bnddiv) then
            write(ifqp1,*)
            write(ifqp2,*)
            write(ifqp1,*)
            write(ifqp2,*)
          endif

          do iline= 1, nline
            if(iout(ibr,iline) /=0) then
              do iqq  = 1, nqq(iline)
                write(ifqp1,133)   qpos(iqq,iline), 
     &          eqp_1(ibr,iqq,iline)          + zerolevel,
     &          iline,ibr, qb(1:3,iqq,iline)
                write(ifqp2,133)   qpos(iqq,iline), 
     &          eqp_2(ibr,iqq,iline)          + zerolevel,
     &          iline,ibr,qb(1:3,iqq,iline)
 133            format(f12.6,f14.7,'   ',2i5,3f12.6)
              enddo
              write(ifqp1,*)'----------------------------------'
              write(ifqp2,*)'----------------------------------'
            endif
          enddo
        endif
      enddo
Cstop2rx 2013.08.09 kino      stop ' OK! bndout for SYML'
      call rx0( ' OK! bndout for SYML')
      end

































