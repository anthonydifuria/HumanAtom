
x.free;
y.free;
z.free;
d.free;
e.free;
f.free;
g.free;
h.free;
i.free;
l.free;

r.stop;




//mem size
(
~options = Server.local.options;

~options.memSize_(4096*64);
)


(
// Execute the following in order
//-----------------FIRST-ORDER-AMBISONIC----------------//
// periphonic (3D) decoder (8-channels arranged as a cube)
// define encoder / decoder matrices
~encoder = FoaEncoderMatrix.newOmni;
~decoder = FoaDecoderMatrix.newPeri;
// inspect
~encoder.kind;
~encoder.numChannels;
~encoder.dirChannels;

~decoder.kind;
~decoder.numChannels;
~decoder.dirChannels*180/pi;



//function scale

t = {
	arg a_min,a_max,s;
	var a_dif;


	a_dif =  (a_max-a_min);

	v = ((s)*a_dif+a_min);
};
)


(// allocate a Buffer
c = Array.fill(20);
s = Server.local;
c[0] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[1] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[2] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[3] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[4] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[5] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[6] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[7] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[8] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
c[9] = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer

)





//PROCESS
(

(
//VOX CONTROL TRIG

w = Window("Frequency Monitor", Rect(200, Window.screenBounds.height-200,300,150)).front;

a = StaticText(w, Rect(45, 10, 200, 20)).background_(Color.rand);
a.string = " Current Frequency ";

Button.new(w, Rect(45, 70, 200, 20)).states_([["close",Color.black,Color.rand]]).action_({w.close});

s.waitForBoot({

    b=Bus.new(\control,0,1);

    q=SynthDef(\Docs_FreqMonitor, {var gate0,gate1,gate2,gate3,in,recbuf ;//variables

	in = SoundIn.ar(0); //live input

	gate0 = Compander.ar(in, in,   //gate for all control
        thresh: 0.7,
        slopeBelow:  10,
        slopeAbove: 1,
        clampTime: 0.01,
        relaxTime: 0.01
    );

		gate1 = sqrt(gate0*gate0);
		gate2 = Trig1.kr(gate1);
		Out.kr(b.index,gate2);//gate for all control

	}).play;

	 k = Routine{
		{   b.get({arg v; { a.string= " Trigger: "++v.round(0.01);

			if((v == 1),{
				m.test = true;m.signal;

			});//trig on Routine

			}.defer} );

			0.01.wait;
		}.loop;

	}.play
});

CmdPeriod.doOnce({w.close});
w.onClose={k.stop; q.free; b.free }; //clean up if the window closes
);







//conditions for all process
m = Condition.new(false);






//START ROUTINE  -  PROCESS STARTS

//FIRST ROUTINE
r = Routine.new({


	2.wait;
	"now, you can play!".postln;




	//////
	m.test = false;//process STOP
	m.wait;
	/////





	1.do({ arg i;


		//FIRST RECORD
		(
			SynthDef(\record1, { arg out = 0, bufnum = 1;
				var formant,recbuf ;//variables

				formant = SoundIn.ar(0);//in mic

				RecordBuf.ar(formant, bufnum, doneAction: 2, loop: 0);
			}).play(s,[\out, 0, \bufnum, c[0]]);
		)


	});

	4.wait;


	//FIRST PLAYER
	x = SynthDef(\play1, { arg out = 0, bufnum = 1;

		var //osc control
		x1 = BufRd.kr(1, 11),//hand0 x
		y1 = BufRd.kr(1, 13),//hand0 y
		z1 = BufRd.kr(1, 12),//hand0 z
		active = BufRd.kr(1, 14),//hand0 active
		alpha1 = BufRd.kr(1, 0),//alpha1
		alpha2 = BufRd.kr(1, 1),//alpha2
		beta1 = BufRd.kr(1, 2),//beta1
		beta2 = BufRd.kr(1, 3),//beta2
		gamma1 = BufRd.kr(1, 4),//gamma1
		gamma2 = BufRd.kr(1, 5),//gamma2
		delta = BufRd.kr(1, 6),//delta
		theta = BufRd.kr(1, 7),//theta
		attention = BufRd.kr(1, 8),//attention
		meditation = BufRd.kr(1, 9),//meditation
		signal = BufRd.kr(1, 10),//signal quality
		z_rid;



		var playbuf,
		trig = Array.fill(20),
		env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

		//ENV for 1 min
		env[0] = Env([1,1,0], [20,10], \sin);//mic in
		envgen[0] = EnvGen.ar(env[0]);

		env[2] = Env([0, 0, 1,1], [25,5,30], \sin);//grain 1
		envgen[2] = EnvGen.ar(env[2]);





		//Trig for change instruments

		trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain


		//player without process
		playbuf = PlayBuf.ar(1,bufnum,loop: 1);



		//processing 1

		//grain 1
		pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
		//RM


		//sum
		outPlay = (playbuf*envgen[0]
			+(pro[1]*envgen[2])
		);



		//Leap control
		x = LinLin.ar(x1,0,1,-2,2);
		y = LinLin.ar(y1,-1,1,-2,2);
		z = LinLin.ar(z1,0,1,-1,1);

		z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

		z_rid = z_rid.sin;


		//ambisonc encode

			#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);




Out.ar(out,[w,x,y,z]);

	}).play(s,[\out, 0, \bufnum, c[0]]);



	"started I player".postln;

	60.wait;






	//FIRST PROCESS STOP'N'GO
	x.free;
	"I player stop".postln;






	(



		//I PLAYER RE-started - ORBITAL 1S

		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



		//Trig for change instruments

		trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain


		//player without process
		playbuf = PlayBuf.ar(1,bufnum,loop: 1);



		//processing 1

		//grain 1
		pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
		//RM


		//sum
		outPlay = (pro[1]);




			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out, outPlay*0.1);

		}).play(s,[\out, 0, \bufnum, c[0]]);




		"I player re-started".postln;













		//SECOND PROCESS
		"II can play".postln;
		//SECOND ROUTINE

		////
		m.test = false;
		m.wait;
		////








		1.do({ arg i;


			//SECOND RECORD
			(
				SynthDef(\record2, { arg out = 0, bufnum1 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum1, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum1, c[1]]);
			)


		});
		4.wait;


		//SECOND PLAYER
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[3] = Env([0, 0, 1, 1], [25,5,30], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);


			//sum
			outPlay = (playbuf*envgen[0]+(pro[2]*envgen[3]));


		//Leap control
		x = LinLin.ar(x1,0,1,-2,2);
		y = LinLin.ar(y1,-1,1,-2,2);
		z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
			#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);


			Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum1, c[1]]);




		"started II player".postln;


		60.wait;



		//I - II PLAYER STOP'N'GO
		x.free;
		y.free;
		"I - II player stop".postln;




		//I - II PLAYER RE-started




		//I PLAYER - ORBITAL 2S
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];

			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);

			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out, outPlay*0.1);

		}).play(s,[\out, 0, \bufnum, c[0]]);







		//SECOND PLAYER - ORBITAL 1S
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);


			//sum
			outPlay = pro[1];


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);

			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);



			//DECODER
			Out.ar(out, outPlay*0.1);

		}).play(s,[\out, 0, \bufnum1, c[1]]);







		"I - II player re-started".postln;







		//III PROCESS
		"III can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//III RECORD
			(
				SynthDef(\record3, { arg out = 0, bufnum2 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum2, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum2, c[2]]);
			)


		});
		4.wait;


		//III PLAYER
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 1 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[4] = Env([0,0,1,1], [20,5,35], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);


			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum2,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);


			//sum
			outPlay = (playbuf*envgen[0]+(pro[3]*envgen[4]));



			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
		#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);



Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum2, c[2]]);

"started III player".postln;


	10.wait;








		//I - II - III PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		"I - II - III player stop".postln;




		//I - II - III PLAYER RE-started




		//I PLAYER - 2Px
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//sum
			outPlay = pro[3];


			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out, outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);






		//II PLAYER - ORBITALE 2S
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);

			//sum
			outPlay = pro[1];

			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out, outPlay*0.1);




		}).play(s,[\out, 0, \bufnum1, c[1]]);






		//III PLAYER - ORBITAL 1S
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers






			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];

			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out, outPlay*0.1);





		}).play(s,[\out, 0, \bufnum2, c[2]]);


		"I - II - III player re-started".postln;





		//IV PROCESS
		"IV can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//IV RECORD
			(
				SynthDef(\record4, { arg out = 0, bufnum3 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum3, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum3, c[3]]);
			)


		});
		4.wait;


		//IV PLAYER
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1


			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = (playbuf*envgen[0]+(pro[4]*envgen[5]));


			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);


Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum3, c[3]]);

		"started IV player".postln;


		10.wait;









		//I - II - III PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;

		"I - II - III - IV player stop".postln;




		//I - II - III - IV PLAYER RE-started




		//I PLAYER - ORBITAL 2Py
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers




			//player without process
			playbuf = PlayBuf.ar(1,bufnum,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = pro[4];


			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum, c[0]]);





		//II PLAYER - ORBITAL 2Px
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);


			//sum
			outPlay = pro[2];


			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out, outPlay*0.1);


		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 2S
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);

			//sum
			outPlay = pro[1];


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);






		//IV PLAYER - ORBITAL 1S
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum3,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);


			//sum
			outPlay = pro[3];

			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);



		}).play(s,[\out, 0, \bufnum3, c[3]]);



		"I - II - III - IV player re-started".postln;






		//V PROCESS
		"V can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//V RECORD
			(
				SynthDef(\record5, { arg out = 0, bufnum4 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum4, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum4, c[4]]);
			)


		});



		4.wait;




		//V PLAYER
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[7] = Env([0,0,1,1], [20,5,35], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);



			//Trig for change instruments
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1
			//rate

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[2]);


			//sum
			outPlay = (playbuf*envgen[0]+(pro[6]*envgen[7])
				);


			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
			#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);



Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum4, c[4]]);

		"started V player".postln;


		10.wait;









		//I - II - III - IV - V PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		"I - II - III - IV - V player stop".postln;




		//I - II - III - IV - V PLAYER RE-started




		//I PLAYER - ORBITAL 2Pz
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers




			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[2]);

			//sum
			outPlay =pro[6];

			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);






		//II PLAYER - ORBITAL 2Py
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers




			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum1,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//sum
			outPlay = pro[3];


			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBTIAL 2Px
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);

			//sum
			outPlay = pro[1];


			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);



		//IV PLAYER - ORBITAL 2S
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum3, c[3]]);







		//V PLAYER - ORBILTAL 1S
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = pro[4];


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum4, c[4]]);



		"I - II - III - IV  - V player re-started".postln;




		//VI PROCESS
		"VI can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//VI RECORD
			(
				SynthDef(\record6, { arg out = 0, bufnum5 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum5, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum5, c[5]]);
			)


		});



		4.wait;




		//VI PLAYER
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[8] = Env([0,0,1,1], [25,5,30], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);




			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum5,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum5,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[3]);



			//sum
			outPlay = (playbuf*envgen[0]+(pro[7]*envgen[8]));


			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);



Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum5, c[5]]);


		"started VI player".postln;


		10.wait;









		//I - II - III - IV - V - VI PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		f.free;
		"I - II - III - IV - V - VI player stop".postln;




		//I - II - III - IV - V - VI PLAYER RE-started




		//I PLAYER - ORBITAL 3S
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain




			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[3]);


			//sum
			outPlay = pro[7];


			//ORBITAL - 3S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(1,1.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out, outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);






		//II PLAYER - ORBITAL 2Pz
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = pro[4];

			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 2Py
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers




			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];

			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);





		//IV PLAYER - ORBITAL 2Px
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);


			//sum
			outPlay = pro[1];


			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum3, c[3]]);








		//V PLAYER - ORBITAL 2S
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers






			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum4,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);


			//sum
			outPlay = pro[3];


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum4, c[4]]);







		//VI PLAYER - ORBITAL 1S
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum5,loop: 1);



			//processing 1
			//rate

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[2]);

			//sum
			outPlay = pro[6];


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum5, c[5]]);


		"I - II - III - IV  - V - VI player re-started".postln;




		//VII PROCESS
		"VII can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//VII RECORD
			(
				SynthDef(\record7, { arg out = 0, bufnum6 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum6, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum6, c[6]]);
			)


		});



		4.wait;




		//VII PLAYER
		g = SynthDef(\play7, { arg out = 0, bufnum6 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);


			env[9] = Env([0,0,1,1], [25,5,30], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);




			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum6,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[4]);


			//sum
			outPlay = (playbuf*envgen[0]+(pro[8]*envgen[9]));


			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);



Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum6, c[6]]);

		"started VII player".postln;


		10.wait;









		//I - II - III - IV - V - VI - VII PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		f.free;
		g.free;
		"I - II - III - IV - V - VI - VII player stop".postln;




		//I - II - III - IV - V - VI - VII PLAYER RE-started




		//I PLAYER - ORBITAL 3Px
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[4]);


			//sum
			outPlay = pro[8];


			//3Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);






		//II PLAYER - ORBITAL 3S
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[2]);

			//sum
			outPlay = pro[6];


			//ORBITAL - 3S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(1,1.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 2Pz
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers








			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum2,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);


			//sum
			outPlay = pro[3];


			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);



		//IV PLAYER - ORBITAL 2Py
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1
			//rate

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);


			//sum
			outPlay = pro[1];

			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum3, c[3]]);








		//V PLAYER - ORBITAL 2Px
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];

			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum4, c[4]]);







		//VI PLAYER - ORBITAL 2S
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum5,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = pro[4];



			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum5, c[5]]);





		//VII PLAYER - ORBITAL 1S
		g = SynthDef(\play7, { arg out = 0, bufnum6 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain





			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum6,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);

			//sum
			outPlay = pro[7];

			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out, outPlay*0.1);

		}).play(s,[\out, 0, \bufnum6, c[6]]);



		"I - II - III - IV  - V - VI - VII player re-started".postln;







		//VIII PROCESS
		"VIII can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//VIII RECORD
			(
				SynthDef(\record8, { arg out = 0, bufnum7 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum7, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum7, c[7]]);
			)


		});



		4.wait;




		//VIII PLAYER
		h = SynthDef(\play8, { arg out = 0, bufnum7 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[11] = Env([0,0,1,1], [25,5,30], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);





			//player without process
			playbuf = PlayBuf.ar(1,bufnum7,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]+(pro[10]*envgen[11]));


			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);


Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum7, c[7]]);

		"started VIII player".postln;


		10.wait;









		//I - II - III - IV - V - VI - VII - VIII PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		f.free;
		g.free;
		h.free;
		"I - II - III - IV - V - VI - VII - VIII player stop".postln;




		//I - II - III - IV - V - VI - VII - VIII PLAYER RE-started




		//I PLAYER - ORBITAL 3Py
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers





			//player without process
			playbuf = PlayBuf.ar(1,bufnum,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = pro[10];


			//3Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);








		//II PLAYER - ORBITAL 3Px
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum1,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[3]);


			//sum
			outPlay = pro[7];



			//3Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 3S
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = pro[4];



			//ORBITAL - 3S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(1,1.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out, outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);



		//IV PLAYER - ORBITAL 2Pz
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);


			//sum
			outPlay = pro[2];



			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum3, c[3]]);








		//V PLAYER - ORBITAL 2Py
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers




			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);


			//sum
			outPlay = pro[1];



			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum4, c[4]]);







		//VI PLAYER - ORBITAL 2Px
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers






			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum5,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//sum
			outPlay = pro[3];

			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum5, c[5]]);




		//VII PLAYER - ORBITAL 2S
		g = SynthDef(\play7, { arg out = 0, bufnum6 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum6,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[2]);


			//sum
			outPlay = pro[6];


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum6, c[6]]);





		//VIII PLAYER - ORBITAL 1S
		h = SynthDef(\play8, { arg out = 0, bufnum7 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum7,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[4]);


			//sum
			outPlay = pro[8];


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out, outPlay*0.1);


		}).play(s,[\out, 0, \bufnum7, c[7]]);



		"I - II - III - IV  - V - VI - VII - VIII player re-started".postln;









		//IX PROCESS
		"IX can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//IX RECORD
			(
				SynthDef(\record9, { arg out = 0, bufnum8 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum8, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum8, c[8]]);
			)


		});



		4.wait;




		//IX PLAYER
		i = SynthDef(\play9, { arg out = 0, bufnum8 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[12] = Env([0,0,1,1], [25,5,30], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);



			//player without process
			playbuf = PlayBuf.ar(1,bufnum8,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum8,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = (playbuf*envgen[0]+(pro[11]*envgen[12]));



			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);



Out.ar(out,[w,x,y,z]);

		}).play(s,[\out, 0, \bufnum8, c[8]]);

		"started IX player".postln;


		10.wait;









		//I - II - III - IV - V - VI - VII - VIII - IX PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		f.free;
		g.free;
		h.free;
		i.free;
		"I - II - III - IV - V - VI - VII - VIII - IX player stop".postln;




		//I - II - III - IV - V - VI - VII - VIII - IX PLAYER RE-started




		//I PLAYER - ORBITAL 3Pz
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers





			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));


			//sum
			outPlay = pro[11];


			//3Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum, c[0]]);





		//II PLAYER - ORBITAL 3Py
		y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);


			//sum
			outPlay = pro[8];

			//3Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 3Px
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);


			//sum
			outPlay = pro[6];


			//3Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);





		//IV PLAYER - ORBITAL 3S
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers





			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum3,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//sum
			outPlay = pro[3];



			//ORBITAL - 3S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(1,1.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum3, c[3]]);








		//V PLAYER - ORBITAL 2Pz
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);

			//sum
			outPlay = pro[1];

			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum4, c[4]]);







		//VI PLAYER - ORBITAL 2Py
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum5,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//sum
			outPlay = pro[2];


			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum5, c[5]]);





		//VII PLAYER - ORBITAL 2Px
		g = SynthDef(\play7, { arg out = 0, bufnum6 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum6,loop: 1);



			//processing 1

			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = pro[4];

			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum6, c[6]]);







		//VIII PLAYER - ORBITAL 2S
		h = SynthDef(\play8, { arg out = 0, bufnum7 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers



			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain






			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum7,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished

			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);

			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],pro[3]);


			//sum
			outPlay = pro[7];


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum7, c[7]]);





		//IX PLAYER - ORBITAL 1S
		i = SynthDef(\play9, { arg out = 0, bufnum8 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers


			//player without process
			playbuf = PlayBuf.ar(1,bufnum8,loop: 1);



			//processing 1

			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);

			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = pro[10];


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum8, c[8]]);



		"I - II - III - IV  - V - VI - VII - VIII - IX player re-started".postln;









		//X PROCESS
		"X can play".postln;


		////
		m.test = false;
		m.wait;
		////

		1.do({ arg i;


			//X RECORD
			(
				SynthDef(\record10, { arg out = 0, bufnum9 = 1;
					var formant,recbuf ;//variables

					formant = SoundIn.ar(0);//in mic

					RecordBuf.ar(formant, bufnum9, doneAction: 2, loop: 0);
				}).play(s,[\out, 0, \bufnum9, c[9]]);
			)


		});



		4.wait;




		//X PLAYER
		l = SynthDef(\play10, { arg out = 0, bufnum9 = 1;

			var //osc control
			x1 = BufRd.kr(1, 11),//hand0 x
			y1 = BufRd.kr(1, 13),//hand0 y
			z1 = BufRd.kr(1, 12),//hand0 z
			active = BufRd.kr(1, 14),//hand0 active
			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay;

			//ENV for 2 min
			env[0] = Env([1,1,0], [20,10], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);



			env[13] = Env([0,0,1,1], [25,5,30], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);





			//Trig for change instruments

			trig[1] = TRand.kr(0.01,0.3,Dust.kr(5*gamma1)); //trig dur grain


			//player without process
			playbuf = PlayBuf.ar(1,bufnum9,loop: 1);



			//processing 1

			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5*gamma2),trig[1],playbuf);

			//Delay grain
			pro[12] = DelayL.ar(pro[1],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]+(pro[12]*envgen[13]));



			//Leap control
			x = LinLin.ar(x1,0,1,-2,2);
			y = LinLin.ar(y1,-1,1,-2,2);
			z = LinLin.ar(z1,0,1,-1,1);

			z_rid = LinLin.ar(z1,0,1,pi/2,3*(pi/2));

			z_rid = z_rid.sin;


			//ambisonc encode
			#w, x, y, z = BFEncode2.ar(outPlay,x+z_rid,y+z_rid,z);


Out.ar(out,[w,x,y,z]);


		}).play(s,[\out, 0, \bufnum9, c[9]]);


		"started X player".postln;


		10.wait;









		//I - II - III - IV - V - VI - VII - VIII - IX - X PLAYER STOP'N'GO
		x.free;
		y.free;
		z.free;
		d.free;
		e.free;
		f.free;
		g.free;
		h.free;
		i.free;
		l.free;
		"I - II - III - IV - V - VI - VII - VIII - IX - X player stop".postln;




		//I - II - III - IV - V - VI - VII - VIII - IX - X PLAYER RE-started




		//I PLAYER - ORBITAL 3Dxy
		x = SynthDef(\play1, { arg out = 0, bufnum = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,sin1,randif,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,1,0], [30,10], \sin);//IN
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([1,1,0], [110,10], \sin);//TOTAL
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([1,1,0], [90,30], \sin);//GRAIN DUR
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0,0,1], [90,5], \sin);//GRAIN VOL
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0,0,1,1], [30,90], \sin);//SHIFT HIGH
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0,0,1,1,0], [30,10,40,5], \sin);//SHIFT VOL
			envgen[5] = EnvGen.ar(env[5]);

			//Trig for change instruments

			trig[0] = TRand.kr(0.01*env[2],0.5*env[2],Dust.kr(10*env[2])); //trig dur grain


			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum,loop: 1,rate: attention);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000);
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));


			//Shift high
			pro[13] = FreqShift.ar(pro[11],5000*env[4]);


			//grain 1
			pro[14] = GrainIn.ar(1,Dust.kr(10*env[2]),trig[0],playbuf);


			//sum
			outPlay = ((pro[11]*env[0])+(pro[13]*env[5])+(pro[14]*env[3]))*env[1];


			//ORBITALS  D

			randif=TIRand.kr(0,1,Dust.kr(1));

			//3Dxy
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			sin1 = (SinOsc.kr((gauss),0,gauss,1)/2);
			angle =  t.value(0.7,1.5,sin1);


			azim = 	if((TIRand.kr(0,1,Dust.kr(1))),
				(if (randif,
					(
						t.value(0.125pi,0.375pi,sin1);

					),
					(
						t.value(0.625pi,0.875pi,sin1);

					))
				),
				(if (randif,
					(
						t.value(-0.375pi,-0.125pi,sin1);

					),
					(
						t.value(-0.875pi,-0.625pi,sin1);

					))

			););



			elevation =  	if((TIRand.kr(0,1,Dust.kr(1))),
				(if (randif,
					(

						t.value(-0.125pi,0.125pi,sin1);
					),
					(

						t.value(-0.125pi,0.125pi,sin1);
					))
				),
				(if (randif,
					(
						t.value(-0.125pi,0.125pi,sin1);
					),
					(
						t.value(-0.125pi,0.125pi,sin1);
					))

			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out,  outPlay*0.1);

		}).play(s,[\out, 0, \bufnum, c[0]]);






		//II PLAYER - ORBITAL 3Pz
		 y = SynthDef(\play2, { arg out = 0, bufnum1 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum1,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum1,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//3Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum1, c[1]]);







		//III PLAYER - ORBITAL 3Py
		z = SynthDef(\play3, { arg out = 0, bufnum2 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum2,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum2,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//3Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum2, c[2]]);





		//IV PLAYER - ORBITAL 3Px
		d = SynthDef(\play4, { arg out = 0, bufnum3 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum3,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum3,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//3Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0.7,1.5,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum3, c[3]]);








		//V PLAYER - ORBITAL 3S
		e = SynthDef(\play5, { arg out = 0, bufnum4 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum4,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum4,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//ORBITAL - 3S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(1,1.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum4, c[4]]);







		//VI PLAYER - ORBITAL 2Pz
		f = SynthDef(\play6, { arg out = 0, bufnum5 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum5,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum5,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//2Pz
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if((TIRand.kr(0,1,Dust.kr(1))),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

				),
				(
					t.value(-5pi,5pi,(SinOsc.kr((gauss),0,gauss,1)/2));

			););

			elevation =	if((TIRand.kr(0,1,Dust.kr(1))),
				(

					t.value(0.375pi,0.5pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				),
				(

					t.value(-0.5pi,-0.375pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			););


			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum5, c[5]]);






		//VII PLAYER - ORBITAL 2Py
		g = SynthDef(\play7, { arg out = 0, bufnum6 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum6,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum6,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//2Py
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim	= if((TIRand.kr(0,1,Dust.kr(1))),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(0.875pi,1.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			elevation = if(TIRand.kr(0,1,Dust.kr(1)),

				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
				,
				t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum6, c[6]]);





		//VIII PLAYER - ORBITAL 2Px
		h = SynthDef(\play8, { arg out = 0, bufnum7 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum7,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum7,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//2Px
			gauss = TGaussRand.kr(0,1,Dust.kr(1));
			angle = t.value(0,0.7,(SinOsc.kr((gauss),0,gauss,1))/2);

			azim = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(0.375pi,0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.375pi,-0.625pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);

			elevation = if(
				TIRand.kr(0,1,Dust.kr(1)),
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
				,
				(t.value(-0.125pi,0.125pi,(SinOsc.kr((gauss),0,gauss,1)/2)));
			);



			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim,elevation);



			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum7, c[7]]);






		//IX PLAYER - ORBITAL 2S
		i = SynthDef(\play9, { arg out = 0, bufnum8 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum8,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum8,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//ORBITAL - 2S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0.5,1,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);

			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum8, c[8]]);




			//X PLAYER - ORBITAL 1S
		l = SynthDef(\play10, { arg out = 0, bufnum9 = 1;

			var //osc control

			alpha1 = BufRd.kr(1, 0),//alpha1
			alpha2 = BufRd.kr(1, 1),//alpha2
			beta1 = BufRd.kr(1, 2),//beta1
			beta2 = BufRd.kr(1, 3),//beta2
			gamma1 = BufRd.kr(1, 4),//gamma1
			gamma2 = BufRd.kr(1, 5),//gamma2
			delta = BufRd.kr(1, 6),//delta
			theta = BufRd.kr(1, 7),//theta
			attention = BufRd.kr(1, 8),//attention
			meditation = BufRd.kr(1, 9),//meditation
			signal = BufRd.kr(1, 10),//signal quality
			z_rid;

			var playbuf,
			trig = Array.fill(20),
			env = Array.fill(20),envgen = Array.fill(20), pro = Array.fill(20),outPlay,

			gauss,angle,azim,elevation,//ambisonics
			flu, blu, bru, fru,//speakers
			fld, bld, brd, frd;//speakers

			//ENV for 2 min
			env[0] = Env([1,0], [30], \sin);//mic in
			envgen[0] = EnvGen.ar(env[0]);

			env[1] = Env([0, 1], [20], \sin);//all process
			envgen[1] = EnvGen.ar(env[1]);

			env[2] = Env([0, 0, 1, 0, 0, 1, 0], [30,10,10,110,30,30], \sin);//grain 1
			envgen[2] = EnvGen.ar(env[2]);

			env[3] = Env([0, 0, 1, 0, 0, 1, 0], [20,10,10,190,10,10], \sin);//RM
			envgen[3] = EnvGen.ar(env[3]);

			env[4] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1, 0], [40,30,30,110,10,10,30,20,10], \sin);//Shift and stretch
			envgen[4] = EnvGen.ar(env[4]);

			env[5] = Env([0, 0, 1, 0, 0, 1, 0, 0, 1], [90,20,20,90,10,10,50,10], \sin);//Delay
			envgen[5] = EnvGen.ar(env[5]);

			env[6] = Env([0,1], [10], \sin);//filt
			envgen[6] = EnvGen.ar(env[6]);

			env[7] = Env([0,1], [10], \sin);//grain RM
			envgen[7] = EnvGen.ar(env[7]);

			env[8] = Env([0,1], [10], \sin);//grain Shift and stretch
			envgen[8] = EnvGen.ar(env[8]);

			env[9] = Env([0,1], [10], \sin);//grain delay
			envgen[9] = EnvGen.ar(env[9]);

			env[10] = Env([0,1], [10], \sin);//grain filt
			envgen[10] = EnvGen.ar(env[10]);

			env[11] = Env([0,1], [10], \sin);//Delay RM
			envgen[11] = EnvGen.ar(env[11]);

			env[12] = Env([0,1], [10], \sin);//Delay shift and streatch
			envgen[12] = EnvGen.ar(env[12]);

			env[13] = Env([0,1], [10], \sin);//Delay grain
			envgen[13] = EnvGen.ar(env[13]);

			env[14] = Env([0,1], [10], \sin);//Control Shift and stretch in one point of the time
			envgen[14] = EnvGen.ar(env[14]);

			env[15] = Env([0,1], [10], \sin);//Control all grain in one point of the time
			envgen[15] = EnvGen.ar(env[15]);



			//Trig for change instruments
			trig[0] = TRand.kr(0.1,0.5,Dust.kr(0.5)); //trig rate
			trig[1] = TRand.kr(0.01,0.3,Dust.kr(1)); //trig dur grain
			trig[2] = TRand.kr(100,1000,Dust.kr(0.1));//trig freq shift

			//player without process
			playbuf = PlayBuf.ar(1,bufnum9,loop: 1);



			//processing 1
			//rate
			pro[0] = PlayBuf.ar(1,bufnum9,loop: 1,rate: alpha1*10);
			FreeSelfWhenDone.kr(pro[0]); // frees the synth when the PlayBuf is finished
			//grain 1
			pro[1] = GrainIn.ar(1,Dust.kr(5),trig[1],playbuf);
			//RM
			pro[2] = playbuf*SinOsc.kr(2000*alpha2,200*beta2,1);
			//Shift
			pro[3] = FreqShift.ar(pro[0],5000*beta1);
			//Delay
			pro[4] = DelayL.ar(playbuf,5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Filt
			pro[5] = Resonz.ar(playbuf, 1000, 0.5);
			//Grain RM
			pro[6] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[2]);
			//Grain shift and stratch
			pro[7] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[3]);
			//Grain Delay
			pro[8] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[4]);
			//Grain filt
			pro[9] = GrainIn.ar(1,Dust.kr(5),trig[1],pro[5]);
			//Delay RM
			pro[10] = DelayL.ar(pro[2],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay shift and stretch
			pro[11] = DelayL.ar(pro[3],5,SinOsc.ar(gamma2*1000,0,gamma1));
			//Delay grain
			pro[12] = DelayL.ar(pro[4],5,SinOsc.ar(gamma2*1000,0,gamma1));

			//sum
			outPlay = (playbuf*envgen[0]
				+(pro[1]*envgen[2]*envgen[1])
				+(pro[2]*envgen[3]*envgen[1])
				+(pro[3]*envgen[4]*envgen[1])
				+(pro[4]*envgen[5]*envgen[1])
			);


			//ORBITAL - 1S

			gauss = TGaussRand.kr(0,1,Dust.kr(1));

			angle = t.value(0,0.5,((SinOsc.kr((gauss),0,gauss,1))/2));
			azim =  SinOsc.kr((gauss),0,gauss);
			elevation = SinOsc.kr(gauss,0,gauss);
			//encode
			outPlay = FoaEncode.ar(outPlay, ~encoder);
			//distance
			outPlay = FoaDirectO.ar(outPlay,angle*1pi);
			//azimut - elevation
			outPlay = FoaTransform.ar(outPlay, 'push', pi/2, azim*2pi,elevation*2pi);


			//DECODER
			Out.ar(out,  outPlay*0.1);


		}).play(s,[\out, 0, \bufnum9, c[9]]);



		"I - II - III - IV  - V - VI - VII - VIII - IX  - X player re-started".postln;


	)




});


r.play;

)










