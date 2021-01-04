; sa_getnewvel.pro -- Eric R. Weeks, 11-7-2017
;
; breaking this out from hopperbub12.pro,
; adding in appropriate bits from nonstopbub02.pro so that
; this will work both with hopperbub13.pro and nonstopbub03.pro
;
; stopflag is there just so that I can set it equal to 1b
; to stop the program at a higher level.  Otherwise when I
; hit control-C I always seem to be in this subroutine, and
; that's not where I want to stop.

function sa_getnewvel,newvel,grav,bub,bubsqr,bubsqrinv,ursneighbors, $
	dslist,rslist,one,f0,wallstate,hwall,num,wallsize,stopflag=stopflag, $
    xia=xia,_extra=eee
; note wallsize is optional:  just used for hopperbub13.pro

if (not keyword_set(wallsize)) then wallsize = 120.0

newvel(0,*) = 0.0d
if (not keyword_set(xia)) then begin
	newvel(1,*) = grav*bubsqr
endif else begin
	newvel(1,*) = getgrav(grav,bub)*bubsqr
endelse
numnbs=intarr(num)

for i=0,num-1 do begin
	numnbs(i)=ursneighbors(0,i)
	if (numnbs(i) gt 0) then begin
		nn=numnbs(i)
		dlist = reform(dslist(1:nn,i))
		rsum  = reform(rslist(1:nn,i))
		nbs = reform(ursneighbors(1:nn,i))

		; viscous drag from neighbors, repulsive forces from neighbors
		newvel(0,i) += total(bub(2,nbs),/double)
		newvel(1,i) += total(bub(3,nbs),/double)
		; the "> 0.0" in the next line is to ensure
		; bubbles overlap, in case we haven't updated
		; the neighbor list recently.
		; note dlist and rsum are already inversed (1/r)
		overlap = (dlist - rsum) > 0.0d
		dirx = bub(0,i)*one(1:nn) - bub(0,nbs)
		diry = bub(1,i)*one(1:nn) - bub(1,nbs)
		fx = dirx*overlap
		fy = diry*overlap
		; let's hard-code bdrag=1
		newvel(0,i) += f0*total(fx,/double)
		newvel(1,i) += f0*total(fy,/double)
		; newvel(0,i) += f0*total(fx,/double)/bdrag
		; newvel(1,i) += f0*total(fy,/double)/bdrag
	endif; else  no neighbors!

endfor

if (wallstate lt 2b) then begin
	newvel = sa_squarewall(bub,newvel,f0,wallsize) 
endif else begin
	; it will always be this for nonstopbub03.pro
	newvel = sa_bubhopperwall(bub,newvel,hwall,f0,_extra=eee)
endelse

if (wallstate eq 3b) then begin
	; this part just for nonstopbub03.pro
	; wallstate will never be 3b for hopperbub13.pro
	; this adds a wall blocking outflow at exit, just for initial condition
    dist0=(bub[1,*] - 0.5d) > 0.01d
    w0=where(dist0 lt bub[4,*],nw0)
    if (nw0 gt 0) then begin
        force = 1.0d/dist0[w0]-bub[5,w0]
        newvel[1,w0] += f0*force; pushes up
    endif
endif


; hard-code bdrag=cdrag=1
w5=where(numnbs eq 0,nw5)
;if (nw5 gt 0) then newvel(0:1,w5) /= cdrag
if (nw5 gt 0) then begin
	newvel(0,w5) *= (bubsqrinv(w5))
	newvel(1,w5) *= (bubsqrinv(w5))
endif
w6=where(numnbs gt 0,nw6)
if (nw6 gt 0) then begin
	newvel(0,w6) /= (numnbs(w6) + bubsqr(w6))
	newvel(1,w6) /= (numnbs(w6) + bubsqr(w6))
	;newvel(0,w6) /= (numnbs(w6)*1.0d + cdrag/(bdrag))
	;newvel(1,w6) /= (numnbs(w6)*1.0d + cdrag/(bdrag))
endif


return,newvel
end

