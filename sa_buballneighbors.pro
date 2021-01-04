; sa_buballneighbors.pro -- Eric R. Weeks, 11-7-2017
;
; pulled out of hopperbub12.pro, to be stand-alone

;============================================================

function sa_buballneighbors,bub,distlist=distlist,r1plusr2=r1plusr2, $
    bamat=bamat,bbmat=bbmat
; this grabs first and second nearest neighbors (more or less)

if ((not keyword_set(bamat)) or (not keyword_set(bbmat))) then begin
	; following code taken from John Crocker:
	; define a triangular raster scan list
	maxn=n_elements(bub(0,*))
	bamat = make_array( maxn, maxn, /long, /index ) mod maxn
	bbmat = transpose( bamat )
	w = where(bbmat gt bamat)
	bamat = bamat(w)
	bbmat = bbmat(w)
endif

rsq = total((bub(0:1,bamat)-bub(0:1,bbmat))^2,1,/double)
r1plusr2 = bub(4,bamat)+bub(4,bbmat)

w=where(rsq lt (2.0*(r1plusr2^2)),nw)

if (nw gt 0) then begin
	neighbors = transpose([[bamat(w)],[bbmat(w)]])
	distlist = sqrt(rsq(w))
	;r1plusr2 = 1.0d / r1plusr2(w)
	r1plusr2 = r1plusr2(w)
endif else begin
	distlist = -1.0d
	neighbors = -1
	r1plusr2 = -1
endelse

return,neighbors
end

