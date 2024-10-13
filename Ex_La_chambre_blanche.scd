n = NetAddr.new("127.0.0.1", NetAddr.langPort);
(
o = Array.fill(20);

	//LEAP MOTION

o[11] = OSCresponderNode(nil, "/hand0", {arg time, resp, msg; p.set(\x1, msg[4]);}).add;
o[12] = OSCresponderNode(nil, "/hand0", {arg time, resp, msg; p.set(\z1, msg[5]);}).add;
o[13] = OSCresponderNode(nil, "/hand0", {arg time, resp, msg; p.set(\y1, msg[6]);}).add;
o[14] = OSCresponderNode(nil, "/active", {arg time, resp, msg; p.set(\active, msg);}).add;

"ON osc EEG and LEAP MOTION".postln;
)



// allocate a buffer for writinig into
s = Server.local;
(
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

"Buf Alloc".postln;

)



(

p = {arg alpha1,alpha2,beta1,beta2,gamma1,gamma2,delta,theta,attention,meditation,signal,x1,z1,y1,active;

		BufWr.kr(alpha1,0 ,loop: 2);
		BufWr.kr(alpha2,1 ,loop: 2);
		BufWr.kr(beta1,2 ,loop: 2);
		BufWr.kr(beta2,3 ,loop: 2);
		BufWr.kr(gamma1,4 ,loop: 2);
		BufWr.kr(gamma2,5 ,loop: 2);
		BufWr.kr(delta,6 ,loop: 2);
		BufWr.kr(theta,7 ,loop: 2);
		BufWr.kr(attention,8 ,loop: 2);
		BufWr.kr(meditation,9 ,loop: 2);
		BufWr.kr(signal,10 ,loop: 2);
		BufWr.kr(x1,11 ,loop: 2);
		BufWr.kr(z1,12 ,loop: 2);
		BufWr.kr(y1,13 ,loop: 2);
		BufWr.kr(active,14 ,loop: 2);


}.play;

"Write into th buffer".postln;

)







//read it with a BufRd
(
x = { arg rate=1;


	z = BufRd.kr(1, 11);
	c = BufRd.kr(1, 12);
	n = BufRd.kr(1, 13);
	m = BufRd.kr(1, 14);

	Pan2.ar((SinOsc.ar(4000*z)+SinOsc.ar(4000*n)+SinOsc.ar(4000*c))/3,level: m);

}.play(s);
)


x.run(false);
x.set(\rate, 5);
y.set(\rate, 2.0.rand);
x.set(\rate, 2);





(
h ={ arg out = 0, buf1,buf2,buf3,buf4,z_rid, bufnum = 0;

	var sig;


	buf1 = BufRd.kr(1, 11);//x
	buf2 = BufRd.kr(1, 12);//z
	buf3 = BufRd.kr(1, 13);//y
	buf4 = BufRd.kr(1, 14);//active


	x = LinLin.ar(buf1,0,1,1,-1);
	y = LinLin.ar(buf3,-1,1,-1,1);
	z = LinLin.ar(buf2,0,1,-pi/2,pi/2);

	z_rid = LinLin.ar(buf2,0,1,pi/2,3*(pi/2));

		z_rid = z_rid.sin;



sig = BrownNoise.ar(0.2)*SinOsc.kr(0.5);


//	sig = GrainFM.ar(1,Dust.kr(2),1,y*5000,x*x*200,z*10,mul: 0.5);

//	sig = SinOsc.ar(SinOsc.kr(2000,0,x*2000),SinOsc.kr(200)*z,SinOsc.kr(5000*x));




	#w, x, y, z = BFEncode2.ar(sig*1,x+z_rid,y+z_rid,z,0.3);

	Out.ar(out,[w,x,y,z]);


}.play
)


h.run(false);
h.run(true);




(
i ={ arg out = 0, buf1,buf2,buf3,buf4,buf5,buf6,buf7,z_rid, bufnum = 0;

	var sig;



	buf1 = BufRd.kr(1, 11);//x
	buf2 = BufRd.kr(1, 12);//z
	buf3 = BufRd.kr(1, 13);//y
	buf4 = BufRd.kr(1, 14);//active
	buf5 = BufRd.kr(1, 5);//x
	buf6 = BufRd.kr(1, 6);//z
	buf7 = BufRd.kr(1, 7);//y

	x = LinLin.ar(buf1,0,1,5,-5);
	y = LinLin.ar(buf3,-1,1,-5,5);
	z = LinLin.ar(buf2,0,1,-pi/2,pi/2);

	z_rid = LinLin.ar(buf2,0,1,pi/2,3*(pi/2));

		z_rid = z_rid.sin;



//sig = BrownNoise.ar(0.2)*SinOsc.kr(0.5);



//	sig = GrainFM.ar(1,Dust.kr(10*buf5),1,buf5*5000,buf6*2000,buf7*10,mul: 0.5);

	sig = SinOsc.ar(SinOsc.kr(2000,0,buf5*2000),SinOsc.kr(200)*buf6*pi,SinOsc.kr(5000*buf7));




	#w, x, y, z = BFEncode2.ar(sig*1,x+z_rid,y+z_rid,z,0.3);

	Out.ar(out,[w,x,y,z]);


}.play
)



i.run(false);












//EEG CONTROL

o[0] = OSCresponderNode(nil, "/BrainWave/Alpha1", {|time, resp, msg|p.set(\alpha1, msg);}).add;
o[1] = OSCresponderNode(nil, "/BrainWave/Alpha2", {|time, resp, msg| p.set(\alpha2, msg);}).add;
o[2] = OSCresponderNode(nil, "/BrainWave/Beta1", {|time, resp, msg| p.set(\beta1, msg);}).add;
o[3] = OSCresponderNode(nil, "/BrainWave/Beta2", {|time, resp, msg| p.set(\beta2, msg);}).add;
o[4] = OSCresponderNode(nil, "/BrainWave/Gamma1", {|time, resp, msg| p.set(\gamma1, msg);}).add;
o[5] = OSCresponderNode(nil, "/BrainWave/Gamma2", {|time, resp, msg| p.set(\gamma2, msg);}).add;
o[6] = OSCresponderNode(nil, "/BrainWave/Delta", {|time, resp, msg| p.set(\delta, msg);}).add;
o[7] = OSCresponderNode(nil, "/BrainWave/Theta", {|time, resp, msg| p.set(\theta, msg);}).add;
o[8] = OSCresponderNode(nil, "/BrainWave/Attention", {|time, resp, msg| p.set(\attention, msg);}).add;
o[9] = OSCresponderNode(nil, "/BrainWave/Meditation", {|time, resp, msg| p.set(\meditation, msg);}).add;
o[10] = OSCresponderNode(nil, "/BrainWave/SignalQuality", {|time, resp, msg| p.set(\signal, msg);}).add;