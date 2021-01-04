; hopperbub -- Eric R. Weeks, 2-23-16
;
; General idea:  I want to test hopper flow using the Durian
; bubble model.  Maybe someday I'll write more general code.  For
; now, I just want to see if I can get it working.
;
; v02:  use ursneighbors
; v07:  from v05, try to speed up
; v10:  for jamming probability
; v11:  try to do Runge-Kutta
; v12:  changed to bub(2:3,*) = (k1+2.0d*k2+2.0d*k3+k4)/6.0d
; v13:  break out some subroutines
; v14:  break out rungekutta portion
; v14v:  from Mia's hopperbub14_vibbothnewnochan.pro
; v15:  revised from v14v, with different initial conditions
; v15:  add 'narrow' keyword
; v16:  change initial state to be gravity down, wall blocking
;       exit, then open exit

;============================================================

function hopperbub16,num,maxframes,polyd=polyd,seed=seed,gravity=gravity, $
  f0=f0,dtuser=dtuser,angle=angle,width=width,mov=mov, $
  xrange=xrange,yrange=yrange, $
  startbub=startbub,useplot=useplot,jamstate=jamstate,jamstring=jamstring, $
  ampx=ampx,freqx=freqx, ampy=ampy,freqy=freqy,overflowmax=overflowmax, $
  narrow=narrow,noforce=noforce,_extra=eee
; eee ---> passed to sa_getnewvel

  common time, count
  common thetime, time, alost


  ; POLYD:  polydispersity
  ; SEED:   for random number generator
  ; GRAV:   sedimentation terminal velocity
  ; JAMSTATE:  returns jamming state at end of program

  if (not keyword_set(polyd)) then polyd=0.1d
  if (not keyword_set(gravity)) then begin
	gravity=0.0d
	message,'WARNING!!!   GRAVITY = 0',/inf
  endif
  if (not keyword_set(f0)) then f0=1.0d
  if (not keyword_set(dtuser)) then dtuser=0.1d
  if (not keyword_set(angle)) then angle=34.0d; degrees
  if (not keyword_set(width)) then width=3.0d; hopper opening
  if (not keyword_set(xrange)) then xrange=[-30,30]
  if (not keyword_set(yrange)) then yrange=[-10,40]
  if (not keyword_set(freqx)) then freqx=0.0d
  if (not keyword_set(freqy)) then freqy=0.0d
  if (not keyword_set(ampx)) then ampx=0.0d
  if (not keyword_set(ampy)) then ampy=0.0d
  if (not keyword_set(overflowmax)) then overflowmax=0.4d

  bdrag = 1.0d
  cdrag = 1.0d
  time = 0.0d

  hwall=sa_setuphwall(angle,width)

  if (keyword_set(startbub)) then begin
    maxtime=max(startbub(-2,*))
    w=where(round(startbub(-2,*)) eq round(maxtime),nw)
    if (nw ne num) then begin
      message,'warning:  number of bubbles found in startbub array',/inf
      message,'does not match the number you have told me to use.',/inf
      message,'I will use the number I found.',/inf
      message,'Found:  '+string(nw),/inf
      message,'You specified:  '+string(num),/inf
      num=nw
    endif
    bub=startbub(0:7,w)
    bub(5,*)=1.0d / bub(4,*); why do I need this?  I don't know.
    wallstate = 2b & grav=-gravity
    dt=dtuser
  endif else begin
    wallstate = 3b & grav = -gravity
    bub=dblarr(8,num); [x,y,vx,vy,radius,1/radius,time,ID]
    bub(4,*) = randomn(seed,num,/normal,/double)*polyd+1.0d
    bub(4,*) = (bub(4,*) > (1.0d - polyd*3.0d) < (1.0d + polyd*3.0d))
    bub(4,*) = bub(4,*) / mean(bub(4,*))
    bub(5,*) = 1.0d / bub(4,*)
    bub(7,*) = indgen(num)

    ; starting positions
	x0 = -width*0.5d + 1.0d
	y0 = 1.0d
	ranx = (randomu(seed,num)-0.5d)*2.0d
	rany = (randomu(seed,num)-0.5d)*2.0d
	slope=hwall[1]/hwall[0]
	for i=0,num-1 do begin
		bub(0:1,i) = [x0,y0] + [0d,rany[i]]
		x0 += 2d + ranx[i]
		thresh = (width*0.5d + y0*slope-1.0d)
		if keyword_set(narrow) then thresh = (thresh < narrow)
		if (x0 gt thresh) then begin
			y0 += 1.8d
			x0 = -width*0.5d - y0*slope + ranx[i] + 1.0d
			if (keyword_set(narrow)) then begin
				x0 = (x0 > (-narrow + 1.0d + ranx[i]))
			endif
		endif
	endfor
   ; bub(0,*) = (randomu(seed,num)-0.5d)*55.0d
   ; bub(1,*) = randomu(seed,num)*30.0d + 25.0d
    wallsize=60.0d
    if (num gt 500) then begin
   ;   bub(0,*) *= 2.0d
   ;   bub(1,*) = (bub(1,*) - 20.0d)*2.0d + 50.0d
      wallsize *= 2.0d
    endif
    dt=dtuser
  endelse
  itime=round(max(bub(6,*)))+1
  result=dblarr(8,long(num)*long(maxframes))

  one=dblarr(num+1)+1.0d
  thetime=0.0d
  timeoverflow=overflowmax+0.000001d

  ; OK, these are safe to be floating point!
  circx=cos(findgen(80)/80.0*2.0*3.14159265)
  circy=sin(findgen(80)/80.0*2.0*3.14159265)

  flag = 0b
  count=1L
  radwall=40.0d
  nbtimer = dblarr(2)+100d
  icount=0L
  bubsqr=bub(4,*)^2
  bubsqrinv=bub(5,*)^2
  ptr=0L
  nbors=0L
  ;debugforce=fltarr(num)
  newvel=dblarr(2,num)
  silenceflag = 1b; silence error messsage 1st time
  lastexit = 1000; just a large number

  while (flag eq 0b) do begin

    tmp1 = (nbtimer[0] gt 0.2d and wallstate eq 2b)
    tmp2 = (nbtimer[0] gt 0.002d and wallstate eq 3b)
    if (tmp1 or tmp2) then begin
      ;if (nbtimer[0] gt 0.1d) then begin
      tmp1=sa_bubsomeneighbors(bub,allnbors,distlist,r1plusr2,d2=d2,r2=r2)
      allnbors=sa_buballneighbors(bub,distlist=distlist,r1plusr2=r1plusr2)
      nbors=sa_bubsomeneighbors(bub,allnbors,distlist,r1plusr2,d2=d2,r2=r2)
      if (max(abs(tmp1-nbors)) gt 0 and silenceflag eq 0b) then $
        message,'should update allnbors more often',/inf
      ursneighbors= $
        sa_buberic2urs2(bub,nbors,r2,d2,rslist=rslist,dslist=dslist)
      silenceflag = 0b
      nbtimer[0] = 0.0d
    endif else if (nbtimer[1] gt 0.02d) then begin
      nbors=sa_bubsomeneighbors(bub,allnbors,distlist,r1plusr2,d2=d2,r2=r2)
      ursneighbors= $
        sa_buberic2urs2(bub,nbors,r2,d2,rslist=rslist,dslist=dslist)
      nbtimer[1] = 0.0d
    endif else begin
      d2=sa_bubdistance(bub,nbors)
      dslist=sa_buberic2urs3(bub,nbors,d2)
    endelse

    stopflag=0b
    bub=sa_bubtransform_vibboth(bub, ampx=ampx,freqx=freqx, ampy=ampy,freqy=freqy, num )
    bub=sa_rungekutta(newvel,grav,bub,bubsqr,bubsqrinv,ursneighbors, $
      dslist,rslist,one,f0,wallstate,hwall,num, $
      stopflag=stopflag,dt,nbors,narrow=narrow,_extra=eee)
    bub2 = sa_bubreversetransform_vibboth( bub, ampx=ampx,freqx=freqx, ampy=ampy,freqy=freqy, num)
    if (stopflag ne 0b) then message,'set stopflag=0b to continue'

    thetime += abs(grav*dt)
    timeoverflow += abs(grav*dt)
    nbtimer += abs(grav*dt)

    if (timeoverflow gt overflowmax) then begin
      timeoverflow -= overflowmax
      if (keyword_set(useplot)) then begin
        sa_bubplot,bub2,circx,circy,hwall,num,width, $
          xrange=xrange,yrange=yrange,wallstate=wallstate,$
          wallsize=wallsize,ampx=ampx,freqx=freqx, ampy=ampy,freqy=freqy, $
		  narrow=narrow,_extra=eee
        if (n_elements(nbors) gt 1 and not keyword_set(noforce)) then begin
          overlap2=((d2-r2) > 0.0d)
          force2=f0*overlap2/abs(grav)
          for k=0,n_elements(nbors(0,*))-1 do begin
            if (force2(k) gt 0.1) then begin
              col = 90 + (force2(k) < 8 > 0)*20
              th = (force2(k)*0.8 < 4) > 0.5
              oplot,[bub2(0,nbors(0,k)),bub2(0,nbors(1,k))], $
                [bub2(1,nbors(0,k)),bub2(1,nbors(1,k))],col=col, $
                thick=th
            endif
          endfor
        endif
        a=tvrd()
        if (icount eq 0) then begin
          ix=n_elements(a(*,0))
          iy=n_elements(a(0,*))
          mov = bytarr(ix,iy,maxframes)
        endif
        if (icount lt maxframes) then mov(*,*,icount)=a
      endif

	  ; check if we are done initializing
      w8=where(bub(1,*) gt 0,nw8)
      if (nw8 gt 0) then begin
        vel=abs(float(bub(3,w8)/grav)); downward component
      endif else begin
        vel=abs(float(bub(3,*)/grav)); downward component
      endelse
      if (wallstate eq 3b and max(vel) lt 0.01) then begin
        message,'opening exit now',/inf
        wallstate=2b
        dt=dtuser
        grav = -gravity
      endif

      if (icount lt maxframes and wallstate eq 2b) then begin
        result(0:7,ptr:ptr+num-1L)=bub
        result(6,ptr:ptr+num-1L)=itime
        ptr += long(num)
        itime++
        ; ARE ANY BUBBLES OUT OF HOPPER?
        w=where(bub(1,*) lt (-10.0d),nw)
        if (nw gt 0) then begin
          for j=0,nw-1 do begin
            ; swap bubble w[j] to end
            tmp=bub(*,num-1)
            bub(*,num-1)=bub(*,w[j])
            bub(*,w[j])=tmp
            tmp=bubsqr(num-1)
            bubsqr(num-1)=bubsqr(w[j])
            bubsqr(w[j])=tmp
            tmp=bubsqrinv(num-1)
            bubsqrinv(num-1)=bubsqrinv(w[j])
            bubsqrinv(w[j])=tmp
            num--
          endfor
          if (num lt 2) then begin
            flag=1b; exit program!
          endif else begin
            bub=bub(*,0:num-1)
            bubsqr=bubsqr(0:num-1)
            bubsqrinv=bubsqrinv(0:num-1)
            ; some caution here:
            nbtimer[0] = 10.0d & silenceflag=1b
            newvel=dblarr(2,num)
          endelse
          lastexit = icount
        endif
      endif

      if (icount ge maxframes) then flag=2b; exit program!
      minvel=min(abs(vel),max=maxvel)
      ;if ((icount-lastexit) gt (long(500*(0.1/dtuser)))) then flag=1b; exit program!
      if (maxvel lt 1e-10) then flag = 3b; exit program!
      icount++

	  tmps=strcompress(string(icount)+"/"+string(maxframes))+" "
      ;print,icount,"/",maxframes,count,mean(vel),min(vel),max(vel),num
      print,tmps,count,mean(vel),minvel,maxvel,num
	  if (ampx gt 0) then $
		 print,ampx*sin(freqx*double(count)), ampy*sin(freqy*double(count))
      if (keyword_set(jamstring)) then print,jamstring
    endif
    count++

  endwhile
  print,'exit condition =',flag
  print,'1: flowed out   2: reached number of steps   3: clogged'

  result=result(*,0:ptr-1)
  s=sort(result(-1,*)); sort on ID
  result=result(*,s)

  if (keyword_set(useplot)) then mov=mov(*,*,0:icount)

  if (num lt 2) then begin
    jamstate=[0,icount,0,0.0]
    ; icount = time hopper emptied
  endif else begin
    jamstate=[1,icount,num,min(vel)]
    ; icount = maximum time we ran for
    ; num = how much is left in hopper
    ; vel = reveals how equilibrated it is
  endelse

  return,result
end

