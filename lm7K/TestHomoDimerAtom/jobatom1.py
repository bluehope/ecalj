#!/usr/bin/env python                            
import sys,string,re,os,commands

### ctrltemplete for diatomic molecule ### (foobar___ are replaced in the main routine below).
# The variable ctrltemple starting from """ ends with another """.  
ctrltemplete="""\
#!/bin/bash
fsmom=FSMOM___
alat=ALAT___
pwe=PWEMAX___
discenter=DISCENTER___
atomz=ATOMZ___
rmt=RMT___
xcfunc=XCFUNC___
nspin=NSPIN___
bzw=BZW___
rstar=RSTAR___
dis=DIS___
#echo ' distance center=' `echo "scale=3;${discenter}*0.529177"|bc` 'ang = ' `echo "scale=3;${discenter}"|bc` 'a.u.'
#echo ' rmt(a.u.)=' $rmt

arguments0="-vfsmom=$fsmom \
 -vatomz=$atomz -vrmt=$rmt -vrstar=$rstar \
 -vdiscenter=$discenter -vxcfunc=$xcfunc -vnspin=$nspin -valat=$alat -vbzw=$bzw"
echo $arguments0 > arguments0_lmf

JOBLIST___
exit

ctrlstart ==============================
### This is generated by ctrlgen.py from ctrls ; tkotani Nov12_2010
### For tokens, See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html. 
### However, lm7K is now a little different from Mark's lmf package in a few points.
### Do lmf --input to see all effective category and token ###
### It will be not so difficult to edit ctrlge.py for your purpose ###
%show vars
%const kmxa=5 alat=0
%const dis=0.0 fsmom=0 rmt=0
%const pwemax=2 nit=NIT___ atomz=0 bzw=0 gmax=12 nspin=2 xcfunc=103

% const dd=(discenter+dis)/alat

VERS    LM=7 FP=7
             # version check. Fixed.
IO      SHOW=T VERBOS=35
             # SHOW=T shows readin data (and default setting at the begining of console output)
	     # It is useful to check ctrl is read in correctly or not (equivalent with --show option).
	     #
	     # lerger VERBOSE gives more detailed console output.
SYMGRP___
             # 'find' evaluate space-group symmetry automatically.
             # Usually 'find is OK', but lmf may use lower symmetry
	     # because of numerical problem.
             # Do lmchk to check how it is evaluated.
             # See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html#SYMGRPcat
             
STRUC   ALAT={alat} DALAT=0 PLAT___
        NBAS= 1  NSPEC=1
SITE    ATOM=ATOM___ POS=POS1___
SPEC
     ATOM=ATOM___ Z={atomz} R={rmt} A=0.015
     RSMH___   EH___
     RSMH2___  EH2___
     LMX=3 LMXA=4 KMXA={kmxa} 
     P___
     PZ___
     MMOM___

BZ    NKABC=1 1 1  # division of BZ for q points.
      METAL=3   # METAL=3 is safe setting. For insulator, METAL=0 is good enough.
		# When you plot dos, set SAVDOS=T and METAL=3, and with DOS=-1 1 (range) NPTS=2001 (division) even for insulator.
		#   (SAVDOS, DOS, NPTS gives no side effect for self-consitency calculaiton).
                # 
                #BUG: For a hydrogen in a large cell, I(takao) found that METAL=0 for
                #(NSPIN=2 MMOM=1 0 0) results in non-magnetic solution. Use METAL=3 for a while in this case.
                # 

      BZJOB=0	# BZJOB=0 (including Gamma point) or =1 (not including Gamma point).
		#  In cases , BZJOB=1 makes calculation efficient.

      #Setting for molecules. No tetrahedron integration. (Smearing))
      TETRA=0 
      N=-1
      W={bzw}

      FSMOM={fsmom}
      FSMOMMETHOD=1    #added on May28 2011.

      #For Total DOS.   DOS:range, NPTS:division. We need to set METAL=3 with default TETRA (no TETRA).
      #SAVDOS=T DOS=-1 1 NPTS=2001

      #EFMAX= (not implemented yet, but maybe not so difficult).            


      #  See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html#HAMcat for tokens below.

      #NOINV=T (for inversion symmetry)
      #  Suppress the automatic addition of the inversion to the list of point group operations. 
      #  Usually the inversion symmetry can be included in the determination of the irreducible 
      #  part of the BZ because of time reversal symmetry. There may be cases where this symmetry 
      #  is broken: e.g. when spin-orbit coupling is included or when the (beyond LDA) 
      #  self-energy breaks time-reversal symmetry. In most cases, lmf program will automatically 
      #  disable this addition in cases that knows the symmetry is broken
      #

      #FSMOM=real number (fixed moment method)
      #  Set the global magnetic moment (collinear magnetic case). In the fixed-spin moment method, 
      #  a spin-dependent potential shift is added to constrain the total magnetic moment to value 
      #  assigned by FSMOM=. No constraint is imposed if this value is zero (the default).
      #

      #INVIT=F
      #  Enables inverse iteration generate eigenvectors (this is the default). 
      #  It is more efficient than the QL method, but occasionally fails to find all the vectors. 
      #   When this happens, the program stops with the message:
      #     DIAGNO: tinvit cannot find all evecs
      #   If you encounter this message set INVIT=F.
      #  T.Kotani think (this does not yet for lm7K).
    
ITER MIX=A2,b=.5,n=3 CONV=1e-6 CONVC=1e-6 NIT={nit}
#ITER MIX=B CONV=1e-6 CONVC=1e-6 NIT={nit}
                # MIX=A: Anderson mixing.
                # MIX=B: Broyden mixing (default). 
                #        Unstable than Anderson mixing. But faseter. It works fine for sp bonded systems.
                #  See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html#ITERcat

HAM   NSPIN={nspin}   # Set NSPIN=2 for spin-polarize case; then set SPEC_MMOM (initial guess of magnetic polarization).
      FORCES=0  # 0: no force calculation, 1: forces calculaiton 
      GMAX={gmax}   # this is for real space mesh. See GetStarted. (Real spece mesh for charge density).
                # Instead of GMAX, we can use FTMESH.
                # You need to use large enough GMAX to reproduce smooth density well.
                # Look into sugcut: shown at the top of console output. 
                # It shows required gmax for given tolelance HAM_TOL.
      REL=REL___  # T:Scaler relativistic, F:non rela.

      XCFUN={xcfunc}   # =1 for VWN.
                # =2 Birth-Hedin (if this variable is not set).
		#    (subs/evxc.F had a problem when =2 if rho(up)=0 or rho(down)=0).
                # =103 PBE-GGA

      PWMODE=11 # 10: MTO basis only (LMTO) PW basis is not used.
                # 11: APW+MTO        (PMT)
                # 12: APW basis only (LAPW) MTO basis is not used.

      PWEMAX={pwemax} # (in Ry). When you use larger pwemax more than 5, be careful
                      # about overcompleteness. See GetStarted.

      ELIND=0    # this is to accelarate convergence. Not affect to the final results.
                 # For sp-bonded solids, ELIND=-1 may give faster convergence.
                 # For O2 molecule, Fe, and so on, use ELIND=0(this is default).
  
      #STABILIZE=1e-10 #!!! Test option for convergence check. Not tested well.
                       # default is negative, then STABILIZER in diagonalization is not effective 
                       # (See slatsm/zhev.F delta_stabilize).
                       # I am not sure wether this stabilizer works OK or not(in cases this gives little help).
                       # STABILIZE=1e-10 may make convergence stabilized 
                       # (by pushing up poorly-linear-dependent basis to high eigenvalues).
                       # STABILIZE=1e-8 may give more stable convergence. 
                       # If STABILIZE is too large, it may affect to low eigenvalues around E_Fermi

      FRZWF=F          #If T, fix augmentation function. 
      #  See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html#HAMcat

      #For LDA+U calculation, see http://titus.phy.qub.ac.uk/packages/LMTO/fp.html#ldaplusu

      #For QSGW. you have to set them. Better to get some samples.
      #RDSIG=
      #RSRNGE=
               
OPTIONS PFLOAT=1 
        # Q=band (this is quit switch if you like to add)

# Relaxiation sample
#DYN     MSTAT[MODE=5 HESS=T XTOL=.001 GTOL=0 STEP=.015]  NIT=20
# See http://titus.phy.qub.ac.uk/packages/LMTO/tokens.html#DYNcat
"""

def replacer(setting, filein):
	fileout=filein
	for kkk in setting.keys():
		rrr=string.lstrip(setting[kkk])
		#print '# ',kkk,' --> ',rrr
		fileout=string.replace(fileout,kkk,rrr)
	return fileout

def setout(setting, key):
	return string.lstrip(setting[key])

def genctrl(readin,jobid):
	setting={}
	molset = readin #open(sys.argv[1],'rt').read()
	molset= re.sub("@ ?",'\n',molset)
	#jobid=sys.argv[2]
	#print 'mmmmmmmmmmmmmmmmmmmmm init ',jobid
	#print molset
	#print 'mmmmmmmmmmmmmmmmmmmmm end'
	exec(molset)
	#sys.exit()

	### They can be fixed in pmtmol paper ###
	setting['REL___']=rel
	setting['ATOM___']=atom
	setting['PATH___']=path
	setting['PLAT___']=plat
	setting['MMOM___']=mmom
	setting['PZ___']= pz
	setting['P___']=  p
	setting['SYMGRP___']=symgrp 
	nspin =2 
	if(fsmom == 0): nspin = 1
	pwe_c='%3.2f' % pwe
	setting['PWEMAX___']=pwe_c
	setting['BZW___']= '%f' % bzw
	setting['XCFUNC___']='%d' % xcfunc
	setting['FSMOM___']='%d' % fsmom
	setting['NSPIN___']='%d' % nspin
	setting['ATOMZ___']='%d' % atomz
	setting['ALAT___']= '%9.4f' % alat
	setting['DISCENTER___']='%3.3f' % discenter
	setting['DIS___']= '%9.3f' % dis
	setting['RSTAR___']='%3.2f' % rstar
	rmt = discenter/2.0*rstar
	rsmh= rmt/2.0 
	eh_c =' %3.1f'   % eh  # converted to char
	eh2_c=' %3.1f'   % eh2
	rsmh_c= ' %3.3f' % max(rsmh,0.5)
	setting['RMT___']=' %3.3f' % rmt
	setting['EH___']   =' EH='  +4*eh_c
	setting['EH2___']  ='EH2='  +4*eh2_c
	setting['RSMH___'] =' RSMH=' +4*rsmh_c
	setting['RSMH2___']='RSMH2='+4*rsmh_c
	#print 'nspin fsmon pwe=',nspin,fsmom,pwe_c

	### replacement
	ctrl0 = replacer(setting, ctrltemplete)
        return ctrl0


def getctrldir(readin,jobid):
	setting={}
	molset = readin #open(sys.argv[1],'rt').read()
	molset= re.sub("@ ?",'\n',molset)
	exec(molset)
	setting['ATOM___']=atom
	setting['PZ___']= pz
	setting['FSMOM___']='%d' % fsmom
	setting['ALAT___']= '%9.4f' % alat
	rmt = discenter/2.0*rstar
	rsmh= rmt/2.0 
	eh_c =' %3.1f'   % eh  # converted to char
	eh2_c=' %3.1f'   % eh2
	rsmh_c= ' %3.3f' % max(rsmh,0.5)
	setting['RMT___']=' %3.3f' % rmt
	setting['EH___']   =' EH='  +4*eh_c
	setting['EH2___']  ='EH2='  +4*eh2_c

	dname1 = dirhead  + setout(setting,'ATOM___') \
	    +',fsmom=' + setout(setting,'FSMOM___') \
	    +',alat=' + setout(setting,'ALAT___')
	dname2 = \
	    'rmt='+ setout(setting,'RMT___') \
	    + ',EH=' + string.lstrip(eh_c) +  ',EH2='+ string.lstrip(eh2_c) \
	    + ',' + setout(setting,'PZ___')+','
        return dname1,dname2

################ main ################################### 
temp1_init="""
plat='PLAT=0.9 0 0 0 1 0 0 0 1.1'
symgrp= 'SYMGRP e'
dirhead= 'DimerSYMI,dis,'
setting['NIT___']= '%i' % 30
setting['POS1___']= '{dd}*sqrt(1/3)*.5    {dd}*sqrt(1/3)*.5  {dd}*sqrt(1/3)*.5'
setting['JOBLIST___']=\
'''
  echo ' INIT:distance_c=' `echo "scale=3;${discenter}*0.529177"|bc` 'ang = ' `echo "scale=3;${discenter}"|bc` 'a.u.'
  echo ' rmt(a.u.)=' $rmt
  #mv save.dimer save.dimer.bk
  lmfa --noopt dimer $arguments0 > llmfa
  rm -f {rst,mixm,moms}.dimer
  #echo start ctrl dimer dis= $dis pwe= $pwe
  lmf --rs=1,1,1,0,0 dimer -vdis=$dis -vpwemax=$pwe $arguments0  > llmf,dis=$dis,pwe=$pwe,init
'''
"""

temp2_init="""
plat='PLAT=0.9 0 0 0 1 0 0 0 1.1'
symgrp= 'SYMGRP e'
dirhead= 'DimerSYMI,dis,'
setting['NIT___']= '%i' % 20
setting['POS1___']= '{dd}*sqrt(1/3)*.5    {dd}*sqrt(1/3)*.5  {dd}*sqrt(1/3)*.5'
setting['JOBLIST___']=\
'''
  echo ' INIT:distance_c=' `echo "scale=3;${discenter}*0.529177"|bc` 'ang = ' `echo "scale=3;${discenter}"|bc` 'a.u.'
  echo ' rmt(a.u.)=' $rmt
  #mv save.dimer save.dimer.bk
  #lmfa --noopt dimer $arguments0 > llmfa
  rm -f {mixm,moms}.dimer
  #echo start ctrl dimer dis= $dis pwe= $pwe
  lmf --rs=1,1,1,0,0 dimer -vdis=$dis -vpwemax=$pwe $arguments0  > llmf,dis=$dis,pwe=$pwe
'''
"""

dist=sys.argv[1].split(",")[0]
temp0_init=' '.join(sys.argv[2:])
basename=os.path.basename(sys.argv[0]).split(".")[0]
jobid =''.join(sys.argv[1:6])+basename
jobid =string.replace(jobid,"'","")
#print jobid

d1,d2=getctrldir(temp0_init+"pwe=2@ dis="+dist+"@ bzw=0.01@ nit=30"+temp1_init,jobid)
d0=d1+'/'+d2+'dis='+dist
if ( not os.path.exists(d1)): os.mkdir(d1)
if ( not os.path.exists(d0)): os.mkdir(d0)
#print 'd0=',d0
#print 'd1=',d1
#print 'd2=',d2
f=open('ctrldir','wt')
f.write(d0)
f.close()
os.chdir(d0)
#print sys.argv
if 'noctrlgen=1@' in sys.argv:
	#print '=== Not generate ctrl file'
	sys.exit()
print 
print '  --- Generate ctrl files in ',d0
print ' ',
for pwex in [-1,2,3,4,5,6,7,8]: #for initial condition generation
    print 'pwex=',pwex,
    if pwex==-1: lll=temp0_init+"pwe=2@ dis="+dist+"@ bzw=0.01@ "+temp1_init
    else:        lll=temp0_init+"pwe="+'%i' % pwex+"@ dis="+dist+"@ bzw=0.001@ "+temp2_init
    ctrl=genctrl(lll,jobid)
    ## replace foobar in ctrltemplete ###
    f=open('ctrl.dimer.'+'%i' % pwex,'wt')
    f.write(ctrl)
    f.close()
print 
sys.exit()

