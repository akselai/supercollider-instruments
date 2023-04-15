(
SynthDef.new(\bassoon, {
	|freq = 58.27, vib_freq = 4.5, amp = 1, dur = 1, gate = 0.5, bus = 0|
	var vib, sig, out, env, reson_freq, reson_amp;
	freq = Lag.kr(freq, 0.05);
	// input
	vib = SinOsc.ar(SinOsc.ar(1, 3.rand, vib_freq/10, vib_freq), mul:freq*0.003);
	sig = Saw.ar(freq + vib, mul: vib / 10 + 1);
	out = 0;
	// resonate
	reson_freq = `[500, 800, 1300, 2100];
	reson_amp = `[1, 1, 0.3, 0.1];
	out = Mix.ar(MoogFF.ar(sig, reson_freq * ExpRand(0.9, 1.1), 3, mul:reson_amp));
	out = out + MoogFF.ar(sig, freq*2, 3);
	out = out + CombN.ar(sig, 1/freq, 1/freq, 0.01, 4 / freq);
	// "undrying"
	2.do({out = AllpassN.ar(out, 0.05.rand, [0.05.rand, 0.05.rand], 4, 0.8) });
	// envelope
	env = EnvGen.kr(Env.adsr(0.04, 0.2, 0.6, 0.1), gate, doneAction: Done.freeSelf);
	Out.ar(bus, out!2 * amp * env);
}).add;
)

x = Synth(\bassoon, [\freq, 34.midicps]); // sample
x.set(\freq, 48.midicps);
x.set(\freq, 72.midicps);
x.set(\gate, 0);

// standard bassoon repertoire
// basic register: overture to The Marriage of Figaro
(
PmonoArtic(
	\bassoon,
	\freq, Pseq(([
		50, 49, 50, 49, 50,
		50, 49, 50, 52, 54, 52, 54, 55,
		57, 56, 57, 56, 57,
		57, 56, 57, 58, 59, 57, 55, 54,
		52, 51, 52, 54, 55, 54, 52, 50,
		49, 50, 52, 50, 49, 45, 47, 49,
		50
	]).midicps * 1/1
	//   edit this ^ to 2 to get low register / contra
	, 1),
	\dur, Pseq([
		1, 1, 1, 1, 4,
		1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 4,
		1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1,
		2
	] / 10, 1),
	\legato, Pseq([
		4, 4, 4, 4, 2,
		4, 4, 4, 4, 4, 4, 4, 3.5,
		4, 4, 4, 4, 2,
		4, 4, 4, 4, 4, 4, 4, 3.5,
		4, 4, 4, 4, 4, 4, 4, 3.5,
		4, 4, 4, 4, 4, 4, 4, 3.5,
		4
	] / 4, 1),
	\amp, 0.9,
).play;
)

// high register: introduction to The Rite of Spring
(
PmonoArtic(
	\bassoon,
	\freq, Pseq(([
		72, 71, 72, 71, 67, 64, 71, 69, 72, 71, 72, 71, 67, 64, 71,
		69, 72, 71, 72, 71, 69, 74, 67, 69,
	]).midicps, 2),
	\dur, Pseq([
		20, 2/3, 1, 3, 3, 3.3, 3.6, 10, 4, 2/3, 1, 4, 4, 4.5, 5,
		7, 7, 2/3, 1, 6, 7, 7, 2/3, 6,
		2.5, 2/3, 1, 2.5, 2.5, 2.5, 2.7, 30
	] / 10, 1),
	\legato, Pseq([
		1, 1, 1, 1, 1, 1, 1, 0.9, 1, 1, 1, 1, 1, 1, 1,
		0.9, 1, 1, 1, 1, 0.95, 1, 1, 0.8,
	], 2),
	\amp, 0.9,
).play;
)