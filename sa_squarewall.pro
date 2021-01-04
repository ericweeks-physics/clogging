; sa_squarewall.pro -- Eric R. Weeks, 11-7-2017
;
; broken out from hopperbub12.pro

function sa_squarewall,bub,newvel,f0,wallsize

; top wall
dist1=(wallsize - bub[1,*]) > 0.01d
w1=where(dist1 lt bub[4,*],nw1)
if (nw1 gt 0) then begin
	force = 1.0d / dist1[w1] - bub[5,w1]
	newvel[1,w1] -= f0*force
endif

; left & right walls
dist2=(wallsize*0.5d + bub[0,*]) > 0.001d
dist3=(wallsize*0.5d - bub[0,*]) > 0.001d
w2=where(dist2 lt bub[4,*],nw2)
if (nw2 gt 0) then begin
	force = 1.0d / dist2[w2] - bub[5,w2]
	newvel[0,w2] += f0*force
endif
w3=where(dist3 lt bub[4,*],nw3)
if (nw3 gt 0) then begin
	force = 1.0d / dist3[w3] - bub[5,w3]
	newvel[0,w3] -= f0*force
endif

return,newvel
end
