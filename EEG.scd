n = NetAddr.new("127.0.0.1", NetAddr.langPort);
n.free;


//test
(
o = OSCFunc({ arg msg, time, addr, recvPort;
[msg, time, addr, recvPort].postln; }, '/brain', n);
)
o.free;

OSCFunc.trace(true); // Turn posting on
OSCFunc.trace(false); // Turn posting off
//test


(var a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11,o12,o13,o14,o15,b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13,b14,b15;


w = Window("EEG", Rect(10, Window.screenBounds.height-200,1000,1000)).front.background_(Color.black);

t = StaticText(w, Rect(150,1,700,100)).align_(\center);
t.string="EEG  Electroencephalography";
t.font = Font("Monaco", 40);
t.stringColor_(Color.blue);

a1 = StaticText(w, Rect(40, 100, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a1.string = " Alpha 1 ";
a2 = StaticText(w, Rect(40, 150, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a2.string = " Alpha 2 ";
a3 = StaticText(w, Rect(40, 200, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a3.string = " Beta 1 ";
a4 = StaticText(w, Rect(40, 250, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a4.string = " Beta 2 ";
a5 = StaticText(w, Rect(270, 100, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a5.string = " Gamma 1 ";
a6 = StaticText(w, Rect(270, 150, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a6.string = " Gamma 2 ";
a7 = StaticText(w, Rect(270, 200, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a7.string = " Delta  ";
a8 = StaticText(w, Rect(270, 250, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a8.string = " Theta ";
a9 = StaticText(w, Rect(520, 100, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a9.string = " Attention ";
a10 = StaticText(w, Rect(520, 150, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a10.string = " Meditation ";
a11 = StaticText(w, Rect(520, 200, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a11.string = " Blink ";
a12 = StaticText(w, Rect(520, 250, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a12.string = " Total Activity ";
a13 = StaticText(w, Rect(770, 150, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a13.string = " Raw";
a14 = StaticText(w, Rect(770, 250, 200, 50)).background_(Color.black).stringColor_(Color.blue).font = Font(size:20);
a15.string = " Signal Quality ";


Button.new(w, Rect(770, 100, 100, 40)).states_([["CLOSE",Color.red,Color.black]]).action_({w.close});

s.waitForBoot({


//BrainWave/SignalQuality
//BrainWave/Contact
//BrainWave/Attention
//BrainWave/Meditation
//BrainWave/Raw
//BrainWave/Blink
//BrainWave/TotalActivity
//BrainWave/Delta
//BrainWave/Theta
//BrainWave/Alpha1
//BrainWave/Alpha2
//BrainWave/Beta1
//BrainWave/Beta2
//BrainWave/Gamma1
//BrainWave/Gamma2

o1 = OSCresponderNode(nil, "/BrainWave/Alpha1", {|time, resp, msg| q.set(\alpha1, msg);}).add;
o2 = OSCresponderNode(nil, "/BrainWave/Alpha2", {|time, resp, msg| q.set(\alpha2, msg);}).add;
o3 = OSCresponderNode(nil, "/BrainWave/Beta1", {|time, resp, msg| q.set(\beta1, msg);}).add;
o4 = OSCresponderNode(nil, "/BrainWave/Beta2", {|time, resp, msg| q.set(\beta2, msg);}).add;
o5 = OSCresponderNode(nil, "/BrainWave/Gamma1", {|time, resp, msg| q.set(\gamma1, msg);}).add;
o6 = OSCresponderNode(nil, "/BrainWave/Gamma2", {|time, resp, msg| q.set(\gamma2, msg);}).add;
o7 = OSCresponderNode(nil, "/BrainWave/Delta", {|time, resp, msg| q.set(\delta, msg);}).add;
o8 = OSCresponderNode(nil, "/BrainWave/Theta", {|time, resp, msg| q.set(\theta, msg);}).add;
o9 = OSCresponderNode(nil, "/BrainWave/Attention", {|time, resp, msg| q.set(\attention, msg);}).add;
o10 = OSCresponderNode(nil, "/BrainWave/Meditation", {|time, resp, msg| q.set(\meditation, msg);}).add;
o11 = OSCresponderNode(nil, "/BrainWave/Blink", {|time, resp, msg| q.set(\blink, msg);}).add;
o12 = OSCresponderNode(nil, "/BrainWave/TotalActivity", {|time, resp, msg| q.set(\totalactivity, msg);}).add;
o13 = OSCresponderNode(nil, "/BrainWave/Raw", {|time, resp, msg| q.set(\raw, msg);}).add;
o14 = OSCresponderNode(nil, "/BrainWave/Contact", {|time, resp, msg| q.set(\contact, msg);}).add;
o15 = OSCresponderNode(nil, "/BrainWave/SignalQuality", {|time, resp, msg| q.set(\signal, msg);}).add;


    b1=Bus.new(\control,0,1);
    b2=Bus.new(\control,1,1);
	b3=Bus.new(\control,2,1);
    b4=Bus.new(\control,3,1);
	b5=Bus.new(\control,4,1);
    b6=Bus.new(\control,5,1);
	b7=Bus.new(\control,6,1);
    b8=Bus.new(\control,7,1);
	b9=Bus.new(\control,8,1);
    b10=Bus.new(\control,9,1);
	b11=Bus.new(\control,10,1);
    b12=Bus.new(\control,11,1);
	b13=Bus.new(\control,12,1);
    b14=Bus.new(\control,13,1);
	b15=Bus.new(\control,14,1);


    q=SynthDef(\brain, {arg alpha1,alpha2,beta1,beta2,gamma1,gamma2,delta,theta,attention,meditation,blink,totalactivity,raw,contact,signal,snd;


        Out.kr([b1.index,b2.index,b3.index,b4.index,b5.index,b6.index,b7.index,b8.index,b9.index,b10.index,b11.index,b12.index,b13.index,b14.index,b15.index],[alpha1,alpha2,beta1,beta2,gamma1,gamma2,delta,theta,attention,meditation,blink,totalactivity,raw,contact,signal]); // output the frequency to a control bus

  }).play;



    r= Routine{
        {           // Set the value of the StaticText to the value in the control bus.
                    // Setting GUI values is asynchronous, so you must use .defer in the system clock.
                    // Also you must check if the window is still open, since Routine will continue for at least
                    // one step after you close the window.
			b1.get( {arg v; {w.isClosed.not.if{ a1.string= " Alpha 1: "++v.round(0.01)}; }.defer} );
			b2.get( {arg v; {w.isClosed.not.if{ a2.string= " Alpha 2: "++v.round(0.01)}; }.defer} );
			b3.get( {arg v; {w.isClosed.not.if{ a3.string= " Beta 1: "++v.round(0.01)}; }.defer} );
			b4.get( {arg v; {w.isClosed.not.if{ a4.string= " Beta 2: "++v.round(0.01)}; }.defer} );
			b5.get( {arg v; {w.isClosed.not.if{ a5.string= " Gamma 1: "++v.round(0.01)}; }.defer} );
			b6.get( {arg v; {w.isClosed.not.if{ a6.string= " Gamma 2: "++v.round(0.01)}; }.defer} );
			b7.get( {arg v; {w.isClosed.not.if{ a7.string= " Delta: "++v.round(0.01)}; }.defer} );
			b8.get( {arg v; {w.isClosed.not.if{ a8.string= " Theta: "++v.round(0.01)}; }.defer} );
			b9.get( {arg v; {w.isClosed.not.if{ a9.string= " Attenction: "++v.round(0.01)}; }.defer} );
			b10.get( {arg v; {w.isClosed.not.if{ a10.string= " Meditation: "++v.round(0.01)}; }.defer} );
			b11.get( {arg v; {w.isClosed.not.if{ a11.string= " Blink "++v.round(0.01)}; }.defer} );
			b12.get( {arg v; {w.isClosed.not.if{ a12.string= " Total Activity: "++v.round(0.01)}; }.defer} );
			b13.get( {arg v; {w.isClosed.not.if{ a13.string= " Raw: "++v.round(0.01)}; }.defer} );
			b14.get( {arg v; {w.isClosed.not.if{ a14.string= " Contact: "++v.round(0.01)}; }.defer} );
			b15.get( {arg v; {w.isClosed.not.if{ a15.string= " Signal: "++v.round(0.01)}; }.defer} );


        0.01.wait;
        }.loop

    }.play
});

CmdPeriod.doOnce({w.close});
w.onClose={r.stop; q.free; b1.free; b2.free; b3.free;b4.free; b5.free; b6.free;b7.free; b8.free; b9.free;b10.free;b11.free; b12.free;b13.free; b14.free; b15.free;   }; //clean up if the window closes

)

o1.killAll;
