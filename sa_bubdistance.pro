; sa_bubdistance.pro -- Eric R. Weeks, 7-11-2017
;
; broken out from hopperbub12.pro

function sa_bubdistance,bub,neighbors
; this assumes we have correct neighbors from 'bubneighbors'
; and all we're doing is updating the distances.

if (neighbors[0] ge 0) then begin
	p1=bub(0:1,neighbors(0,*))
	p2=bub(0:1,neighbors(1,*))
	rsq=total((p1-p2)^2,1,/double)
	distlist = 1.0d / sqrt(rsq)
endif else begin
	distlist = 0.0d
endelse

return,distlist
end

