


(
//LEAP MOTION
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\x1, msg[4]);  }, '/hand0', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\z1, msg[5]);  }, '/hand0', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\y1, msg[6]);  }, '/hand0', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\active, msg[4]);  }, '/active', n);



//EEG CONTROL
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\alpha1, msg);  }, '/BrainWave/Alpha1', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\alpha2, msg);  }, '/BrainWave/Alpha2', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\beta1, msg);  }, '/BrainWave/Beta1', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\beta2, msg);  }, '/BrainWave/Beta2', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\gamma1, msg);  }, '/BrainWave/Gamma1', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\gamma2, msg);  }, '/BrainWave/Gamma2', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\delta, msg);  }, '/BrainWave/Delta', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\theta, msg);  }, '/BrainWave/Theta', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\attention, msg);  }, '/BrainWave/Attention', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\meditation, msg);  }, '/BrainWave/Meditation', n);
o = OSCFunc({ arg msg, time, addr, recvPort;  p.set(\signal, msg);  }, '/BrainWave/SignalQuality', n);
)





(

// allocate a buffer for writinig into
s = Server.local;
s.sendMsg("/b_alloc", 0, 44100 * 2);//alpha1
s.sendMsg("/b_alloc", 1, 44100 * 2);//alpha2
s.sendMsg("/b_alloc", 2, 44100 * 2);//beta1
s.sendMsg("/b_alloc", 3, 44100 * 2);//beta2
s.sendMsg("/b_alloc", 4, 44100 * 2);//gamma1
s.sendMsg("/b_alloc", 5, 44100 * 2);//gamma2
s.sendMsg("/b_alloc", 6, 44100 * 2);//delta
s.sendMsg("/b_alloc", 7, 44100 * 2);//theta
s.sendMsg("/b_alloc", 8, 44100 * 2);//attention
s.sendMsg("/b_alloc", 9, 44100 * 2);//meditation
s.sendMsg("/b_alloc", 10, 44100 * 2);//signal quality
s.sendMsg("/b_alloc", 11, 44100 * 2);//hand0 x1
s.sendMsg("/b_alloc", 12, 44100 * 2);//hand0 y1
s.sendMsg("/b_alloc", 13, 44100 * 2);//hand0 z1
s.sendMsg("/b_alloc", 14, 44100 * 2);//active

)

(

p = {arg alpha1,alpha2,beta1,beta2,gamma1,gamma2,delta,theta,attention,meditation,signal,x1,z1,y1,active;

		BufWr.kr(alpha1,0 ,loop: 1);
		BufWr.kr(alpha2,1 ,loop: 1);
		BufWr.kr(beta1,2 ,loop: 1);
		BufWr.kr(beta2,3 ,loop: 1);
		BufWr.kr(gamma1,4 ,loop: 1);
		BufWr.kr(gamma2,5 ,loop: 1);
		BufWr.kr(delta,6 ,loop: 1);
		BufWr.kr(theta,7 ,loop: 1);
		BufWr.kr(attention,8 ,loop: 1);
		BufWr.kr(meditation,9 ,loop: 1);
		BufWr.kr(signal,10 ,loop: 1);
		BufWr.kr(x1,11 ,loop: 1);
		BufWr.kr(z1,12 ,loop: 1);
		BufWr.kr(y1,13 ,loop: 1);
		BufWr.kr(active,14 ,loop: 1);


}.play;
)



p.free;




//read it with a BufRd
(
x = { arg rate=1;

var
	   zi = BufRd.kr(1, 11),
	ci = BufRd.kr(1, 12),
	ni = BufRd.kr(1, 13),
	mi = BufRd.kr(1, 14);

	Pan2.ar((SinOsc.ar(4000*zi)+SinOsc.ar(4000*ni)+SinOsc.ar(4000*ci))/3,level: mi*0.01);

}.play(s);
)

x.free;
x.run(false);
x.set(\rate, 5);
y.set(\rate, 2.0.rand);
x.set(\rate, 2);




