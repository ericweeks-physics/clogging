; wrapbub   Eric R. Weeks   3-9-16
; v02:  use hopperbub11
; v03:  use hopperbub12
; v04:  use hopperbub13
; v05:  use hopperbub14
; v05v:  taken from Mia's wrapbub05_vibbothnewnochan.pro
; v15:  use hopperbub15

function wrapbub16,width,num,maxframes,trials,$
  prefix=prefix,grav=grav,_extra=eee
  common time, count

  if (not keyword_set(grav)) then grav=0.01d
  if (not keyword_set(prefix)) then begin
    message,'you really ought to set prefix',/inf
    message,'using prefix=blah',/inf
    prefix='blah.'
  endif

  jamstring=prefix+'  --  no clogging data yet'
  result=fltarr(4,trials)
  num0=num

  f=findfile(prefix+'*',count=nf)
  if (nf gt 0) then begin
    for i=0,nf-1 do begin
      b=read_gdf(f(i))
      maxt=max(round(b(-2,*)))
      w=where(round(b(-2,*)) eq maxt,nw)
      if (nw gt 3) then begin
        vel=b(3,w)/abs(grav)
        jamstate=[1,maxt,nw,min(vel)]
      endif else begin
        jamstate=[0,maxt,0,0.0]
      endelse
      result(*,i)=jamstate
    endfor
    jamcount=round(total(result(0,0:nf-1)))
    jamstring = prefix+ $
      '  jammed= '+strcompress(string(jamcount),/remove_all)+$
      '/'+strcompress(string(nf),/remove_all)
    w=where(result(2,*) gt 0,nw)
    if (nw gt 0) then begin
      leftover=round(mean(result(2,w)))
      jamstring += ' leftover='+string(leftover)
    endif
    w=where(result(2,0:nf-1) eq 0,nw)
    if (nw gt 0) then begin
      lasttime=round(mean(result(1,w)))
      jamstring += ' time='+string(lasttime)
    endif
  endif

  for i=nf,trials-1 do begin
    num=num0
    b=hopperbub16(num,maxframes,jamstate=jamstate,$
      jamstring=jamstring,width=width,grav=grav, _extra=eee)
    write_gdf,b,prefix+int2ext2(i)
    result(*,i)=jamstate
    jamcount=round(total(result(0,0:i)))
    jamstring = prefix+ $
      '  jammed= '+strcompress(string(jamcount),/remove_all)+$
      '/'+strcompress(string(i+1),/remove_all)
    w=where(result(2,*) gt 0,nw)
    if (nw gt 0) then begin
      leftover=round(mean(result(2,w)))
      jamstring += ' leftover='+string(leftover)
    endif
    w=where(result(2,0:i) eq 0,nw)
    if (nw gt 0) then begin
      lasttime=round(mean(result(1,w)))
      jamstring += ' time='+string(lasttime)
    endif
  endfor

  return,result
end
