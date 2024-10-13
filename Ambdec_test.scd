// I ex
(

p ={ arg out = 0,x1,y1,z1,z_rid,active;


	x = MouseX.kr(-3,3);
	y = MouseY.kr(-3,3);
	z = 0;




	#w, x, y, z = BFEncode2.ar(WhiteNoise.ar(0.2)*SinOsc.kr(1),x,y,z,0.3);

	Out.ar(out,[w,x,y,z]);

}.scope(8);
)


p.run(false);
p.run(true);