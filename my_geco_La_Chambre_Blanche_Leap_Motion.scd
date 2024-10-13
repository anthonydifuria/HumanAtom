s = Server.default.reboot;
(
s.waitForBoot({ {

	var cs, x, w, cc, o, r, g, q, sl=();
	~i=0; ~mapper = (0..10);


/////////////////Mapping///////////////
~cc=([
	(0:\gate, 1:\c_L_R_p, 2:\c_L_R_d, 3:\c_UP_DOWN_p, 4:\c_UP_DOWN_d, 5:\c_B_F_p, 6:\c_B_F_d, 7:\c_PITCH, 8:\c_ROLL, 9:\c_YAW),
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

		var sin;

		sin = SinOsc.ar(5000*c_L_R_p ,0,c_L_R_p );

		Out.ar(out,Pan2.ar(sin,c_UP_DOWN_p));

	}).play;


	//s.sync;
	x=Synth(\play);


	////////////////////////Slider Window///////////////////////////

	{
		w=Window.new("MAPPING LEAPMOTION - LA CHAMBRE BLANCHE", Rect(10, 20, 920, 120)).front;//x,y,width,height
		w.view.decorator=f=FlowLayout(w.view.bounds);
		w.alwaysOnTop_(true); w.background = Color.black.alpha = 0.6;


		[\c_L_R_p, \c_L_R_d, \c_UP_DOWN_p, \c_UP_DOWN_d, \c_B_F_p,\c_B_F_d, \c_PITCH, \c_ROLL, \c_YAW ].do(
			{|par|
			x.get(par, {|val|
				{sl[par]=EZSlider(w.view, 300@35, par, cs[par], {|ez| x.set(par, ez.value)}, val)
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

