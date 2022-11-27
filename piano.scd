(
SynthDef.new(\comb_piano, {
	arg out = 0, force = 1, freq = 440, rel = 4, sustain = 0, amp = 1,
	noise_freq = 20000, noise_attack = 0.002, noise_decay = 0.06,
	detune = 1.0005, string_decay = 16,
	lpf_ratio = 1, lpf_rq = 1.0, damp = 0.0, damp_time = 16;

	var noise, string, delaytime, lpf, noise_env, snd, damp_mul, freq_comp, hpf_c;
	var stretch_coef = 1.005, reson = 0, reson_amp;
	var hpf_f, env;
	damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);

	noise_env = Decay2.ar(Impulse.ar(0), 0.01); // TODO attack time
	noise = LFNoise2.ar(noise_freq) * noise_env * 0.2;

	delaytime = 1.0 / (freq * if(freq < 33.midicps, [1], [1/detune, 1, detune]));

	freq_comp = 1000/freq;

	string = Mix.new([
		CombC.ar(noise, delaytime, delaytime, string_decay * damp_mul),
	]);
	snd = RLPF.ar(string, lpf_ratio * freq * freq_comp, lpf_rq) * force;// * freq_comp;

	hpf_c = if(freq < 40, 20, 1/(0.191192 * log(freq) - 0.660568));
	// ^ equal amplitude
	hpf_f = freq * hpf_c * force / 2;

	reson_amp = min(force.squared, force / 8);
	reson = Mix.ar(Resonz.ar(string, freq*
		(1..9).pow(stretch_coef),
        //[20]/1000; // control;
	    [20, 10, 8, 7, 6, 5, 4, 3, 2] /1000;
	) * [20, 10, 8, 7, 6, 5, 4, 3, 2] / 20);
	// ^ simulates inharmonic partials
	snd = snd + (reson * reson_amp);

	snd = HPF.ar(LPF.ar(LeakDC.ar(snd), XLine.ar(hpf_f, hpf_f / 8, damp_time)), 0);

	env = EnvGen.ar(Env.adsr(0.01, 0.2, 0.2, 0.3, 3), Trig.ar(1, rel));
	snd = (snd) * (((1 - sustain) * env) + (sustain * 1));
	Out.ar(out, snd.dup * amp);
	DetectSilence.ar(snd, doneAction:2);
}).add();
)

(
SynthDef.new(\comb_piano_prototype, {
	arg out=0, force=0.125, hz=440, rel=1, sustain=0, amp=1,
	noise_hz = 20000, noise_attack=0.002, noise_decay=0.06,
	detune = 1.0001, string_decay=5.0,
	lpf_ratio=1, lpf_rq = 1.0, damp=0.0, damp_time=1;

	var noise, string, delaytime, lpf, noise_env, snd, damp_mul, freq_comp, hpf_c;
	var stretch_coef = 1.005, reson = 0, reson_amp = 3;
	var hpf_f, env;
	damp_mul = LagUD.ar(K2A.ar(1.0 - damp), 0, damp_time);

	noise_env = Decay2.ar(Impulse.ar(0), 0.01); // TODO attack time
	noise = LFNoise2.ar(noise_hz) * noise_env * 0.2;

	delaytime = 1.0 / (hz * [1/detune, 1, detune]);

	freq_comp = 1000/hz;

	string = Mix.new([
		CombC.ar(noise, delaytime, delaytime, string_decay * damp_mul),
	]);
	snd = RLPF.ar(string, lpf_ratio * hz * freq_comp, lpf_rq) * force;// * freq_comp;

	hpf_c = 21.2 * exp(-0.000834 * hz);
	hpf_f = hz * hpf_c * force / 2;
	snd = HPF.ar(LPF.ar(LeakDC.ar(snd), XLine.ar(hpf_f, hpf_f / 8, damp_time)), 0);
	reson = Mix.ar(BPF.ar(string, hz*
		[1, 3, 5, 7, 9, 11, 13, 15, 17].pow(stretch_coef),
        //[20]/1000; // control;
	    [20, 10, 8, 7, 6, 5, 4, 3, 2]/1000;
	) / (3..12));
	// TODO: resonation filter on the white noise, not the combed sound
	// ^ simulates inharmonic partials
	snd = snd + (reson * reson_amp);

	env = EnvGen.ar(Env.adsr(0.01, 0.2, 0.2, 0.3, 3), Trig.ar(1, rel));
	snd = (snd) * (((1 - sustain) * env) + (sustain * 1));

	snd = FreeVerb.ar(snd) * amp;
	Out.ar(out, snd.dup);
	DetectSilence.ar(snd, doneAction:2);
}).add();
)