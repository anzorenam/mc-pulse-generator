#!/usr/bin/env python3.9
# -*- coding: utf8 -*-

import numpy as np
import matplotlib as mat
import matplotlib.pyplot as plt
import matplotlib.path as path
import scipy.stats as stats
import numpy.random as rand

Nbits=12
Mbits=10
W=2**Nbits-1
M=2**Mbits
mu=255.0
sigma=60.0
N=1000000
seed=20
test=False
write=True
rng=rand.default_rng(seed)
u=rng.uniform(low=0,high=1.0,size=N)
udiscrete=rng.integers(low=0,high=W,size=N,endpoint=True)
t=np.arange(0,512.0,0.5)
tsample=np.zeros(N)
tsam_discrete=np.zeros(N)
pden=stats.norm.pdf(x=t,loc=mu,scale=sigma)
pcum=np.cumsum(pden)/np.sum(pden)
pcum_discrete=np.uint16(np.rint(W*pcum))
for k in range(0,N):
  tsample[k]=t[pcum>=u[k]][0]
  tsam_discrete[k]=t[pcum_discrete>=udiscrete[k]][0]

chi=3.0
tbins=np.arange(0,512.0,0.5)
if test==True:
  pnorm=stats.norm.rvs(size=N,loc=mu,scale=sigma,random_state=rng)
  fexp,e=np.histogram(pnorm,bins=tbins)
  fobs,e=np.histogram(tsample,bins=tbins)
  fobs=fobs.astype('float')
  fexp=fexp.astype('float')
  fexp[fexp==0]=0.5
  print(np.sum((fobs-fexp)**2.0/fexp))
  fig,ax=plt.subplots(nrows=1,ncols=2,sharex=False,sharey=False)
  ax[0].plot(t,pden,ds='steps-pre')
  ax[0].hist(tsample,bins=tbins,log=True,density=True)
  ax[0].set_xlim(mu-chi*sigma,mu+chi*sigma)
  ax[0].set_ylim(1e-7,1e0)
  ax[1].plot(t,pden,ds='steps-pre')
  ax[1].hist(tsam_discrete,bins=tbins,log=True,density=True)
  ax[1].set_xlim(mu-chi*sigma,mu+chi*sigma)
  ax[1].set_ylim(1e-7,1e0)
  plt.show()

if write==True:
  hexfile='inverse_sample.mif'
  coefile='inverse_sample.coe'
  memfile='inverse_sample.mem'
  f0=open(hexfile,'w')
  f1=open(coefile,'w')
  f2=open(memfile,'w')
  head_hex0='DEPTH=16384;'
  head_hex1='WIDTH=10;'
  head_hex2='ADDRESS_RADIX=DEC;'
  head_hex3='DATA_RADIX=DEC;'
  head_hex4='WIDTH=10;'
  head_hex5='CONTENT'
  head_hex6='BEGIN'
  end_hex='END;'

  head_coe0='memory_initialization_radix=10;'
  head_coe1='memory_initialization_vector='
  f0.write(head_hex0+'\n')
  f0.write(head_hex1+'\n')
  f0.write(head_hex2+'\n')
  f0.write(head_hex3+'\n')
  f0.write(head_hex4+'\n')
  f0.write(head_hex5+'\n')
  f0.write(head_hex6+'\n')

  f1.write(head_coe0+'\n')
  f1.write(head_coe1+'\n')

  for k in range(0,W+1):
    rv=np.uint16(np.rint(2.0*t[pcum_discrete>=k][0]))
    line0='{0:05d} : {1:d};\n'.format(k,rv)
    line1='{0:d}'.format(rv)
    line2='@{0:04X} {1:04X}\n'.format(k,rv)
    if k==W:
      endl=';'
    else:
      endl=',\n'
    reg1=line1+endl
    f0.write(line0)
    f1.write(reg1)
    f2.write(line2)
  f0.write(end_hex)
  f0.close()
  f1.close()
  f2.close()
