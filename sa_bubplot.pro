; sa_bubplot.pro	Eric R. Weeks, 8-10-2016
;
; sa = standalone
;
; taken from breakarch02.pro
;
; modified 11-7-2017 to work with nonstopbub03.pro, hopperbub13.pro
; modified 11-12-2017 to work with hopperava06.pro

;============================================================
pro sa_bubplot,bub,circx,circy,hwall,num,width,$
	archptr=archptr,wallstate=wallstate,wallsize=wallsize, $
    nooutlet=nooutlet,narrow=narrow, $
	ampx=ampx,ampy=ampy,freqx=freqx,freqy=freqy,thetime=thetime, $
	_extra=eee

	plot,bub(0,*),bub(1,*), $
		/iso,ps=1,/ynozero,/nodata,/xs,/ys,_extra=eee

	for i=0,num-1 do $
		oplot,bub(0,i)+circx*bub(4,i),bub(1,i)+circy*bub(4,i),ps=3

	if (keyword_set(archptr)) then begin
		for j=0,n_elements(archptr)-1 do begin
			i=archptr(j)-1
			for e=0.1,0.6,0.1 do begin
				oplot,bub(0,i)+e*circx*bub(4,i),$
						bub(1,i)+e*circy*bub(4,i),ps=3
			endfor
		endfor
	endif

	xshift = 0.0 & yshift = 0.0
	if (keyword_set(ampx)) then xshift = -ampx*sin(freqx*thetime)
	if (keyword_set(ampy)) then yshift = -ampy*sin(freqy*thetime)

	; hopper
	yy=[0,1000]
	oplot,(-hwall[1]*yy-hwall[2])/hwall[0]+xshift,yy+yshift
	oplot,(-hwall[5]*yy-hwall[6])/hwall[4]+xshift,yy+yshift
	if (not keyword_set(nooutlet)) then begin
		oplot,[1,1]*width/2.+xshift,[0,-100]+yshift
		oplot,-[1,1]*width/2.+xshift,[0,-100]+yshift
	endif

	if (keyword_set(wallstate)) then begin
		if (wallstate eq 1b) then $
			oplot,[-1,-1,1,1]*wallsize*0.5+xshift,[0,1,1,0]*wallsize+yshift
			; this is a square wall for when gravity is 'up'
		if (wallstate eq 3b) then $
			oplot,[-1,1]*width+xshift,[0.5,0.5]
			; this blocks particles at the exit
		if (wallstate eq 4b) then begin
			; for hopperava06.pro
			hor,wallsize[0]+yshift,lines=1
			oplot,[-30,-20]+xshift,[1,1]*wallsize[1]+yshift,lines=2
			oplot,[+30,+20]+xshift,[1,1]*wallsize[1]+yshift,lines=2
			ver,[-20,20]+xshift
		endif
		if (wallstate eq 5b) then begin
			; for constbub01.pro
			hor,wallsize[0]+yshift,lines=1
			ver,[-10,10]+xshift
		endif
	endif
	if (keyword_set(narrow)) then begin
		y0=(hwall[0]/hwall[1]*(narrow-width*0.5))
		oplot,[narrow,narrow]+xshift,[y0,200]+yshift
		oplot,-[narrow,narrow]+xshift,[y0,200]+yshift
	endif

end
