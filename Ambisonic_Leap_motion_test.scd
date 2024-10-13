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

(
z= {
	arg a_min,a_max,s;
	var a_dif;


	a_dif =  (a_max-a_min);

	v = ((s)*a_dif+a_min);
};
)


(
j=SynthDef(\play, {arg c_L_R_d,c_UP_DOWN_d,c_B_F_d;

	var sig1,out;                // audio signal.
	var
	gauss = Array.fill(5),
	angle = Array.fill(5),
	azim = Array.fill(5),
	elevation = Array.fill(5);           // angle and azimuth control



	// display encoder and decoder
	"Ambisonic encoding via % encoder".format(~encoder.kind).postln;
	"Ambisonic decoding via % decoder".format(~decoder.kind).postln;


	sig1 = BrownNoise.ar(0.1);







	//ORBITALS  S


	//1S

	//encode
	sig1 = FoaEncode.ar(sig1, ~encoder);
	//distance
	sig1 = FoaDirectO.ar(sig1,c_B_F_d*1pi);
	//azimut - elevation
	out = FoaTransform.ar(sig1, 'push', pi/2, c_L_R_d*pi, c_UP_DOWN_d*(pi/2));


	Out.ar(0,out);

}).add;
)





j = Synth(\play);






	//ORBITALS  S


	//1S

	gauss[0] = TGaussRand.kr(0,1,Dust.kr(1));

	angle[0] = z.value(0,0.3,((SinOsc.kr(1,0,gauss[0],1))/2));
	azim[0] =  SinOsc.kr(1,0,gauss[0]);
	elevation[0] = SinOsc.kr(1,0,gauss[0]);
	//encode
	sig1 = FoaEncode.ar(sig1, ~encoder);
	//distance
	sig1 = FoaDirectO.ar(sig1,angle[0]*1pi);
	//azimut - elevation
	out = FoaTransform.ar(sig1, 'push', pi/2, azim[0]*2pi,elevation[0]*2pi);





//LEAP MOTION CONTROL
(
s.waitForBoot({ {

	var cs, x, w, cc, o, r, g, q, sl=();
	~i=0; ~mapper = (0..10);


	/////////////////Mapping///////////////
	~cc=([
		(
			0:\gate,
			1:\c_L_R_p,
			2:\c_L_R_d,
			3:\c_UP_DOWN_p,
			4:\c_UP_DOWN_d,
			5:\c_B_F_p,
			6:\c_B_F_d,
			7:\c_PITCH,
			8:\c_ROLL,
			9:\c_YAW),
	]);

	///////////add Specs//////////////
	//0
	//1
	Spec.add(\c_L_R_p, [0.01, 0.99, \lin, 0.01, 0.5]);
	//2
	Spec.add(\c_L_R_d, [0.01, 0.99, \lin, 0.01, 0.6]);
	//3
	Spec.add(\c_UP_DOWN_p, [0.01, 0.5, 5, 0, 0.05]);
	//4
	Spec.add(\c_UP_DOWN_d, [-3, 4, \lin, 0.01, 0]);
	//5
	Spec.add(\c_B_F_p, [0.1, 10, \lin, 0.01, 1]);
	//6
	Spec.add(\c_B_F_d, [0.1, 4, \lin, 0.01, 1]);
	//7
	Spec.add(\c_PITCH, [0.03, 0.3, \lin, 0.01]);
	//8
	Spec.add(\c_ROLL, [0.1, 1.0, \lin, 0.01, 0.25]);
	//9
	Spec.add(\c_YAW, [1, 200, \lin, 0.01, 100]);



	cs=(
		c_L_R_p:\c_L_R_p.asSpec,
		c_L_R_d:\L_R_d.asSpec,
		c_Up_Down_p:\Up_Down_p.asSpec,
		c_Up_Down_d:\Up_Down_d.asSpec,
		c_B_F_p:\B_F_p.asSpec,
		c_B_F_d:\B_F_d.asSpec,
		c_PITCH:\PITCH.asSpec,
		c_ROLL:\ROLL.asSpec,
		c_YAW:\YAW.asSpec
	);

	//TEST MAPPING LEAP MOTION
	SynthDef(\play, { arg
		out = 0, gate=0, bufnum,
		c_L_R_p = 0.01,
		c_L_R_d = 0.99,
		c_UP_DOWN_p = 0.01,
		c_UP_DOWN_d = 0,
		c_B_F_p = 1,
		c_B_F_d = 1.0,
		c_PITCH = 0.1,
		c_ROLL = 0.1,
		c_YAW = 100,
		envbuf;


	}).play;

	//s.sync;
	j=Synth(\play);


	//SLIDER WINDOW
	{
		w=Window.new("MAPPING LEAPMOTION - LA CHAMBRE BLANCHE", Rect(10, 20, 920, 120)).front;//x,y,width,height
		w.view.decorator=f=FlowLayout(w.view.bounds);
		w.alwaysOnTop_(true); w.background = Color.black.alpha = 0.6;


		[
			\c_L_R_p,
			\c_L_R_d,
			\c_UP_DOWN_p,
			\c_UP_DOWN_d,
			\c_B_F_p,
			\c_B_F_d,
			\c_PITCH,
			\c_ROLL,
			\c_YAW ].do(
			{|par|
				j.get(par, {|val|
					{sl[par]=EZSlider(w.view, 300@35, par, cs[par], {|ez| j.set(par, ez.value)}, val)
						.round_(0.01)
						.setColors(Color.grey(0.3), Color.grey(0.7), Color.grey(alpha:0.5))
						.font_(Font("Monaco", 11));
					}.defer;
				});
		});

		w.front;
		w.refresh;
		w.onClose_({ f.free; x.free; ~midiControl.free; ~sounds.free; ~freq.free; });

	}.defer;





	~midiControl = MIDIFunc.cc({|val, num|
		//[val, num].postln;
		if(~cc.at(~i)[num]!=nil, {
			{sl[~cc.at(~i)[num]].valueAction_(sl[~cc.at(~i)[num]].controlSpec.map(val/127).lag(0.1))}.defer;
		});
	}, ~mapper);


	}.fork(AppClock);
	//s.plotTree.window(w);
});

/////some code to open GECO and connect MIDI automatically.

fork{
	"~/Documents/Dev/Projects/Greap/GECOScript/GECOMapSC.geco".openOS;
	8.0.wait; // wait for the amount of time that GECOMap.SC needs to start its midi ports
	MIDIClient.init;
	MIDIIn.connectAll;
}
)