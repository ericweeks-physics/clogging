; sa_rungekutta.pro -- Eric R. Weeks, 11-11-2017
;
; break this out of nonstopbub04.pro so it becomes a stand-alone
; subroutine

function sa_rungekutta,newvel,grav,bub,bubsqr,bubsqrinv, $
    ursneighbors,dslist,rslist,one,f0,wallstate,hwall,num, $
    stopflag=stopflag,dt,nbors, $
    thetime=thetime,ampx=ampx,freqx=freqx,ampy=ampy,freqy=freqy,_extra=eee

	common thetime, time, alost
	originaltime = time
	if (keyword_set(ampx)) then begin
		xshift1 = ampx*sin(freqx*thetime)
		xshift2 = ampx*sin(freqx*(thetime+dt*0.5d))
		xshift3 = ampx*sin(freqx*(thetime+dt))
	endif
	if (keyword_set(ampy)) then begin
		yshift1 = ampy*sin(freqy*thetime)
		yshift2 = ampy*sin(freqy*(thetime+dt*0.5d))
		yshift3 = ampy*sin(freqy*(thetime+dt))
	endif


	if (keyword_set(ampx)) then bub(0,*) += xshift1
	if (keyword_set(ampy)) then bub(1,*) += yshift1
	k1=sa_getnewvel(newvel,grav,bub,bubsqr,bubsqrinv,ursneighbors, $
			dslist,rslist,one,f0,wallstate,hwall,num, $
			stopflag=stopflag,_extra=eee)
	if (keyword_set(ampx)) then bub(0,*) += xshift2-xshift1
	if (keyword_set(ampy)) then bub(1,*) += yshift2-yshift1
	tmpbub=bub
	tmpbub(2:3,*) = k1
	tmpbub(0:1,*) += k1*dt*0.5d
	d2=sa_bubdistance(tmpbub,nbors)
	dslist=sa_buberic2urs3(tmpbub,nbors,d2)
	time = originaltime + dt*0.5d
	k2=sa_getnewvel(newvel,grav,tmpbub,bubsqr,bubsqrinv,ursneighbors, $
			dslist,rslist,one,f0,wallstate,hwall,num, $
			stopflag=stopflag,_extra=eee)
	tmpbub=bub
	tmpbub(2:3,*) = k2
	tmpbub(0:1,*) += k2*dt*0.5d
	d2=sa_bubdistance(tmpbub,nbors)
	dslist=sa_buberic2urs3(tmpbub,nbors,d2)
	k3=sa_getnewvel(newvel,grav,tmpbub,bubsqr,bubsqrinv,ursneighbors, $
			dslist,rslist,one,f0,wallstate,hwall,num, $
			stopflag=stopflag,_extra=eee)
	if (keyword_set(ampx)) then bub(0,*) += xshift3-xshift2
	if (keyword_set(ampy)) then bub(1,*) += yshift3-yshift2
	tmpbub=bub
	tmpbub(2:3,*) = k3
	tmpbub(0:1,*) += k3*dt
	d2=sa_bubdistance(tmpbub,nbors)
	dslist=sa_buberic2urs3(tmpbub,nbors,d2)
	time = originaltime + dt
	k4=sa_getnewvel(newvel,grav,tmpbub,bubsqr,bubsqrinv,ursneighbors, $
			dslist,rslist,one,f0,wallstate,hwall,num, $
			stopflag=stopflag,_extra=eee)

	if (keyword_set(ampx)) then bub(0,*) -= xshift3
	if (keyword_set(ampy)) then bub(1,*) -= yshift3
	time = originaltime
	bub(2:3,*) = (k1+2.0d*k2+2.0d*k3+k4)/6.0d
	bub(0:1,*) += dt*bub(2:3,*)

return,bub
end
