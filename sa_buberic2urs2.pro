; sa_buberic2urs2.pro -- Eric R. Weeks, 11-7-2017
;
; broken out from hopperbub12.pro for use in v13 and
; also nonstopbub03.pro

function sa_buberic2urs2,bub,nne,rsum,distlist,rslist=rslist,dslist=dslist
; taken from "eric2urs" with extra code added for rslist

nparticles=n_elements(bub(0,*))
maxnn=70
nnu=intarr(maxnn+1,nparticles+1)
rslist=dblarr(maxnn+1,nparticles+1)
dslist=dblarr(maxnn+1,nparticles+1)
if (nne[0] ge 0) then begin
	for i=0L,n_elements(nne[0,*])-1 do begin
		i1=nne[0,i]
		i2=nne[1,i]

		; ceilings below are safety for when we initialize
		; the simulation, and we have excessive clumps of
		; droplets with many neighbors.
		nnu[0,i1] = ((nnu[0,i1]+1) < (maxnn-1))
		nnu[nnu[0,i1],i1]=i2
		nnu[0,i2] = ((nnu[0,i2]+1) < (maxnn-1))
		nnu[nnu[0,i2],i2]=i1
		rslist[nnu[0,i1],i1]=rsum[i]
		rslist[nnu[0,i2],i2]=rsum[i]
		dslist[nnu[0,i1],i1]=distlist[i]
		dslist[nnu[0,i2],i2]=distlist[i]
	endfor
endif

return,nnu
end

