; sa_bubhopperwall.pro -- Eric R. Weeks, 11-7-2017
;
; broken out from hopperbub12.pro
;
; gets force from walls on bubbles
;
; for debugging: uncomment 'tmp' variable which stores
; the distance to the closest wall.
;
; also added in functionality from 'breakarch02.pro'

function sa_bubhopperwall,bub,newvel,hwall,f0,archptr=archptr, $
   wt2=wt2,narrow=narrow,nooutlet=nooutlet
; narrow:  set if hopper has narrow vertical walls at the top, rather
;          than the slanted walls going to infinity.


; tmp=fltarr(n_elements(bub(0,*))); for debugging

halfwidth=abs(hwall[2]/hwall[0])

leftflag=bytarr(n_elements(bub[0,*]))
rightflag=bytarr(n_elements(bub[0,*]))
dist1 = abs(hwall[0]*bub[0,*]+hwall[1]*bub[1,*]+hwall[2])
dist2 = abs(hwall[4]*bub[0,*]+hwall[5]*bub[1,*]+hwall[6])

; patch for 11-7-2017 to prevent force from blowing up
dist1 = (dist1 > 0.01)
dist2 = (dist2 > 0.01)


; add 'and' clause below 11-7-2017
w1=where((dist1 lt bub[4,*]) and (bub[1,*] gt 0.0d),nw1)
if (nw1 gt 0) then begin
	; some bubbles may be next to wall #1
	;closex=(hwall[1]*(hwall[1]*bub[0,w1]-hwall[0]*bub[1,w1])-hwall[0]*hwall[2])
	;closex /= (hwall[3]^2)
	closey=(hwall[0]*(-hwall[1]*bub[0,w1]+hwall[0]*bub[1,w1])-hwall[1]*hwall[2])
	;closey /= (hwall[3]^2)
	w2=where(closey gt 0,nw2)
	if (nw2 gt 0) then begin
		; tmp[w1[w2]] = dist1[w1[w2]] & print,nw2
		force = 1.0d/dist1[w1[w2]] - bub[5,w1[w2]]
		newvel[0,w1[w2]] += f0*force*hwall[0]
		newvel[1,w1[w2]] += f0*force*hwall[1]
		if (mean(bub[0,w1[w2]]) lt 0) then leftflag[w1[w2]] = 1b $
			else rightflag[w1[w2]] = 1b 
		; leftflag and rightflag:  indicates they are safely
		; receiving a force from the left or right wall, and
		; thus we don't need a corner force for them.
		; I checked 11-7-2017:  these are indeed all the valid
		; locations where I don't need a corner force.
		if (keyword_set(archptr)) then begin
			for i=0,n_elements(archptr)-1 do begin
                w=where(w1[w2] eq archptr[i],nw)
                if (nw gt 0) then wt2 += f0*force[w]*hwall[1]
            endfor
		endif
	endif
endif

; add 'and' clause below 11-7-2017
w1=where((dist2 lt bub[4,*]) and (bub[1,*] gt 0.0d),nw1)
if (nw1 gt 0) then begin
	; some bubbles may be next to wall #1
	;closex=(hwall[5]*(hwall[5]*bub[0,w1]-hwall[4]*bub[1,w1])-hwall[4]*hwall[6])
	;closex /= (hwall[7]^2)
	closey=(hwall[4]*(-hwall[5]*bub[0,w1]+hwall[4]*bub[1,w1])-hwall[5]*hwall[6])
	;closey /= (hwall[7]^2)
	w2=where(closey gt 0,nw2)
	if (nw2 gt 0) then begin
		; tmp[w1[w2]] = dist2[w1[w2]] & print,nw2
		force = 1.0d/dist2[w1[w2]] - bub[5,w1[w2]]
		newvel[0,w1[w2]] += f0*force*hwall[4]
		newvel[1,w1[w2]] += f0*force*hwall[5]
		if (mean(bub[0,w1[w2]]) lt 0) then leftflag[w1[w2]] = 1b $
			else rightflag[w1[w2]] = 1b 
		if (keyword_set(archptr)) then begin
            for i=0,n_elements(archptr)-1 do begin
                w=where(w1[w2] eq archptr[i],nw)
                if (nw gt 0) then wt2 += f0*force[w]*hwall[5]
            endfor
		endif
	endif
endif

dist3=bub[0,*]+halfwidth
dist4=halfwidth-bub[0,*]
if (not keyword_set(nooutlet)) then begin
	; patch for 11-7-2017 to prevent force from blowing up
	dist3 = (dist3 > 0.01)
	dist4 = (dist4 > 0.01)
endif

; positive values for bubbles in the exit channel
; left vertical wall, pushes right:
w3=where(leftflag eq 0b and bub[1,*] lt 0 and dist3 lt bub[4,*],nw3)
if (nw3 gt 0) then begin
	; tmp[w3] = dist3[w3] & print,nw3
	force = 1.0d/dist3[w3]-bub[5,w3]
	newvel[0,w3] += f0*force
	leftflag[w3] = 1b
endif
; right vertical wall, pushes left:
w4=where(rightflag eq 0b and bub[1,*] lt 0 and dist4 lt bub[4,*],nw4)
if (nw4 gt 0) then begin
	; tmp[w4] = dist4[w4] & print,nw4
	force = 1.0d/dist4[w4]-bub[5,w4]
	newvel[0,w4] += -f0*force
	rightflag[w4] = 1b
endif

; dist2 = abs(hwall[4]*bub[0,*]+hwall[5]*bub[1,*]+hwall[6])
;		force = 1.0d/dist2[w1[w2]] - bub[5,w1[w2]]
;		newvel[0,w1[w2]] += f0*force*hwall[4]
;		newvel[1,w1[w2]] += f0*force*hwall[5]
;dist3=bub[0,*]+halfwidth
;dist4=halfwidth-bub[0,*]

; corners
dist5=(dist3^2+bub[1,*]^2)
dist6=(dist4^2+bub[1,*]^2)
; patch for 11-7-2017 to prevent force from blowing up
dist5 = (dist5 > 0.0001)
dist6 = (dist6 > 0.0001)
w5=where(leftflag eq 0b and dist5 lt bub[4,*]^2,nw5)
if (nw5 gt 0) then begin
	dx=dist3[w5]
	dy=bub[1,w5]
	dr=sqrt(dx*dx+dy*dy)
	dx /= dr
	dy /= dr
	force = 1.0d/dr-bub[5,w5]
	; tmp[w5] = dr & print,nw5
	newvel[0,w5] += f0*force*dx
	newvel[1,w5] += f0*force*dy
	leftflag[w5] = 1b
	if (keyword_set(archptr)) then begin
        for i=0,n_elements(archptr)-1 do begin
            w=where(w5 eq archptr[i],nw)
            if (nw gt 0) then wt2 += f0*force[w]*dy[w]
        endfor
	endif
endif
w6=where(rightflag eq 0b and dist6 lt bub[4,*]^2,nw6)
; checked 11-7-2017:  these are correctly the points
; in the pie-wedge touching the corner.
if (nw6 gt 0) then begin
	dx=dist4[w6]; points away from wall, thus points left!
	dy=bub[1,w6]
	dr=sqrt(dx*dx+dy*dy)
	dx /= dr
	dy /= dr
	force = 1.0d/dr-bub[5,w6]
	; tmp[w6] = dr & print,nw6
	newvel[0,w6] -= f0*force*dx
	newvel[1,w6] += f0*force*dy
	rightflag[w6] = 1b
	if (keyword_set(archptr)) then begin
        for i=0,n_elements(archptr)-1 do begin
            w=where(w6 eq archptr[i],nw)
            if (nw gt 0) then wt2 += f0*force[w]*dy[w]
        endfor
	endif
endif

if (keyword_set(narrow)) then begin

	; taken from hopperava07.pro
	; top left & right walls
	dist7 = (bub[0,*] + narrow) > 0.01
	dist8 = narrow - bub[0,*] > 0.01
	; positive values for bubbles in the exit channel
	; left vertical wall, pushes right:
	w7=where(dist7 lt bub[4,*],nw7)
	if (nw7 gt 0) then begin
		force = 1.0d/dist7[w7]-bub[5,w7]
		newvel[0,w7] += f0*force
	endif
	; right vertical wall, pushes left:
	w8=where(dist8 lt bub[4,*],nw8)
	if (nw8 gt 0) then begin
		force = 1.0d/dist8[w8]-bub[5,w8]
		newvel[0,w8] += -f0*force
	endif

endif

; OK, I checked 'tmp' variable:  this should be the
; distance to the nearest wall for every point.  And
; indeed it is a smooth function of position.

return,newvel
end
