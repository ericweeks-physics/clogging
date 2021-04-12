; sa_setuphwall.pro -- Eric R. Weeks, 11-7-2017
;
; breaking out pieces of hopperbub12.pro so that they can
; be called from both v13 and also nonstopbub03.pro

function sa_setuphwall,angle,width

anglerad=angle/180.0d*3.14159265d
hwall=dblarr(8)
hwall[0] = sin(anglerad)
hwall[1] = cos(anglerad)
hwall[2] = hwall[0]*width/2.0d
hwall[3] = sqrt(hwall[0]^2+hwall[1]^2)
hwall[4] = -sin(anglerad)
hwall[5] = cos(anglerad)
hwall[6] = hwall[0]*width/2.0d
hwall[7] = sqrt(hwall[0]^2+hwall[1]^2)

return,hwall
end
