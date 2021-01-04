; sa_buberic2urs3.pro -- Eric R. Weeks, 11-7-2017
;
; broken out from hopperbub12.pro for use in v13 and
; nonstopbub03.pro.
;
; NOTE:  You also need "sa_buberic2urs.pro" -- these are
; both needed.

function sa_buberic2urs3,bub,nne,distlist

nparticles=n_elements(bub(0,*))
maxnn=70
dslist=dblarr(maxnn+1,nparticles+1)
nnu=intarr(nparticles+1)
if (nne[0] ge 0) then begin
	for i=0L,n_elements(nne[0,*])-1L do begin
		i1=nne[0,i]
		i2=nne[1,i]
		; ceilings below are safety for when we initialize
		; the simulation, and we have excessive clumps of
		; droplets with many neighbors.
		nnu[i1] = ((nnu[i1]+1) < (maxnn-1))
		nnu[i2] = ((nnu[i2]+1) < (maxnn-1))
		dslist[nnu[i1],i1]=distlist[i]
		dslist[nnu[i2],i2]=distlist[i]
	endfor
endif

return,dslist
end

