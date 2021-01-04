; sa_bubsomeneighbors.pro -- Eric R. Weeks, 7-11-2017
;
; taken from hopperbub12.pro -- to be stand-alone, work
; with hopperbub13.pro and nonstopbub03.pro

function sa_bubsomeneighbors,bub,nbs,distlist,r1plusr2,d2=d2,r2=r2
; idea is that sa_buballneighbors has found 1st and 2nd
; nearest neighbors.  This works on that list to identify
; just the 1st nearest neighbors.

if (n_elements(nbs) gt 1) then begin
	rsq = total((bub(0:1,nbs(0,*))-bub(0:1,nbs(1,*)))^2,1,/double)
	w=where(rsq lt 1.21*r1plusr2^2,nw); 10% margin added

	if (nw gt 0) then begin
		neighbors = nbs(*,w)
		d2 = 1.0d / sqrt(rsq(w))
		r2 = 1.0d / r1plusr2(w)
	endif else begin
		d2 = -1.0d & neighbors = -1 & r2 = -1
	endelse
endif else begin
	d2 = -1.0d & neighbors = -1 & r2 = -1
endelse

return,neighbors
end
