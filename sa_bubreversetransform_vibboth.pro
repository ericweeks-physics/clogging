;this will transform particle locations from resting coordinate system to one with an added sin term to either x, y, or both axis.

function sa_bubreversetransform_vibboth, bub, ampx=ampx,freqx=freqx, ampy=ampy,freqy=freqy, num
  common time, count
  bub(0,*) -= ampx*sin(freqx*double(count))
  bub(1,*) -= ampy*sin(freqy*double(count))
  return, bub
end
