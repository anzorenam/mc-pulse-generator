#!/usr/bin/env python3.9
# -*- coding: utf8 -*-

import matplotlib.pyplot as plt
import socket
import sitcpy.rbcp as rbcp
import numpy as np
import time
import datetime

class tdc_instrument(object):
  def __init__(self,IPaddress,PortNumber=4000):
    self.s=socket.socket(socket.AF_INET,socket.SOCK_STREAM,socket.IPPROTO_TCP)
    self.s.connect((IPaddress,PortNumber))

  def read(self):
    nbyte=16
    data=np.zeros(int(nbyte/2))
    byte=self.s.recv(nbyte)
    M=len(byte)
    if M==nbyte:
      k=np.array([b for b in byte])
      print(k)
      data=0.5*(256*k[0::2]+k[1::2])
    return data

  def close(self):
    self.s.close()

def init_daq(dev,addr0,addr1):
  try:
    dev.write(addr0,b'\x07')
    dev.write(addr1,b'\x14')
    p=True
  except:
    p=False
  return p

ipaddr='192.168.10.16'
port_udp=4660
port_tcp=24
Nevt=10000
p=False

date=datetime.datetime.now()
name='TDC{0}.dat'.format(date.strftime('%y%m%d_%H%M'))
#f=open(name,'w')

waddr0,waddr1,=0x08,0x09
scaler=rbcp.Rbcp(ipaddr,port_udp)

while p==False:
  p=init_daq(scaler,waddr0,waddr1)
  time.sleep(0.2)
print('Init config done ...')

jevt=0
tdc_data=np.zeros([Nevt,8])
tdc=tdc_instrument(ipaddr,port_tcp)
print('Starting DAQ ...')
while jevt!=Nevt:
  t0=time.time()
  tdc_data[jevt,:]=tdc.read()
  tiempo=time.gmtime(t0)
  hora_pant=time.strftime('%y%m%d %H:%M:%S',tiempo)
  data='{0} {1} '.format(jevt,hora_pant)
  for k in range(0,8):
    data+='{0} '.format(tdc_data[jevt,k])
  print(data)
  jevt+=1
  #f.write(data)
  #f.write('\n')
tdc.close()
print('DAQ finished...')
#f.close()

tdc_data=tdc_data[:,7]
print(np.amax(tdc_data))
tbins=np.arange(0,1200,1.0)
fig,ax=plt.subplots(nrows=1,ncols=1,sharex=False,sharey=False)
ax.hist(tdc_data,bins=tbins,histtype='stepfilled',log=True)
ax.set_xlabel(r'Time delay [ns]',x=0.9,ha='right')
ax.set_ylabel(r'Number of events')
plt.tight_layout(pad=1.0)
#plt.savefig('pulse-gen-ch0.pdf')
plt.show()
