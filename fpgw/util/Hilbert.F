      integer(4),parameter:: nx = 10000
      integer(4):: nw,ifchi
      real(8):: q(3),jzero, freq(0:nx), dw=0.2,rrr,iii,polinta !meV
      real(8):: rchi(0:nx), ichi(0:nx), omg,rydberg,mmom,jval
     & ,drchi(nx),freqm(nx),czero,omgw,eps,pi,sum,sumw
      character(30) fname,aaa

      pi = atan(1d0)*4d0
c      print *,' pi=',pi
      read(5,*) fname
      ifchi=1015
      open(ifchi, file=fname)
      read(ifchi,*)
      iw=0
      do 
         read(ifchi,*,end=1011) q, freq(iw),rchi(iw),ichi(iw)
         iw=iw+1
      enddo
 1011 continue
      nw = iw
      eps= 1d0
      nwx= nw
      sum=0d0
      sumw=0d0
      do iw=2,nwx-1 !1600 !nw-1
c         if(iw<5.or.iw>nwx-3) 
c     &     write(6,'("read ",3f8.4,2x,f20.15,2x,2d23.15)') 
c     &     q, freq(iw), rchi(iw),ichi(iw)
        if( iw==1 ) then
          dw= ( freq(2) + freq(1) )/2d0
        else
          fr = (freq(iw+1) + freq(iw) )/2d0
          fl = (freq(iw-1) + freq(iw) )/2d0
          dw = fr-fl
        endif
        eps = eps + dw/pi * 2d0/freq(iw) *ichi(iw)
        sum = sum + dw * freq(iw) *ichi(iw)*13.605**2
c        sumw = sumw + dw * 2d0*freq(iw) *ichi(iw)*13.605
c        eps = eps + dw/pi * 2d0/freq(iw-1) *ichi(iw)
c        eps = eps + dw/pi * 2d0/freq(iw+1) *ichi(iw)
        if( mod(iw,50)==1 .or. iw==nwx-1) then
          write(6,"(' iw freq eps=',i6,f10.4,3f10.4)") 
     &    iw,freq(iw),eps,sum

        endif
      enddo
      end
