(
Task(
	{
		//SerialPort.devices;
		p = SerialPort.new(
			"/dev/cu.usbmodem3474366F35381",
			baudrate: 115200
		);
		1.wait;
		p.putAll("ii.jf.mode(1)\n");
		~timer = LinkClock.new(120/60).latency_(Server.default.latency).quantum_(0); //set up clock (put desired bpm where the current bpm is)
		~note = Array.fill(10, {0}); //we'll store our note sequences here
		~durs = Array.fill(10, {0}); //we'll store our timing sequences here
		~durTables = [
			[0.5,1,1.5,1,0.5,0.5,1,2],
			[0.5,0.5,1,2],
			[0.5,1,1.5,1],
			[1,1,1,1,1,1,1,1,1,1,1,1,2,2],
			[1,1,1,1,1,1,1,1,1,1,1,1,4],
			[1,2,1,2,1,2,1,1,1,1,1,1,1],
			[1,2,1,2,1,2,1,2,2,2],
			[1,1,1,6,1,1,1,2,2],
			[1,1,1,6,1,1,1,4],
			[1,7.5,7.5],
			[1.25,1.25,2.25,2.25,1,1,1,1,0.75,0.75,0.75,0.75,0.5,0.5,0.5,0.5],
			[1.5,1.5,6,1.5,1.5,2,2],
			[2,2,0.5,0.5,1,1,0.5,0.5],
			[2.25,2.25,2.25,2.25,2,2,1.5,1.5],
			[2.5,2.5,1,1,0.25,0.25,0.25,0.25],
			[2.5,2.5,2,1],
			[3,3,3,3,2,2],
			[3,3,3,3,4],
			[3,6,3,2,2],
			[3,6,3,4],
			[3,3,6,4],
			[3,3,4,6],
			[3.5,3.5,3.5,3.5,0.5,0.5,0.5,0.5],
			[3.5,3.5,0.5,0.5,2,3,1.5,1.5],
			[3.5,3.5,7,2],
			[4,2,1,1],
			[4.5,4.5,4,3],
			[5.5,5.5,2,3],
			[5.5,5.5,0.5,0.5,0.5,0.5,1.5,1.5],
			[6,2,2,6],
			[7.5,7.5,1],
			[0.25],
			[0.5],
			[0.5,7.5],
			[1],
			[1,1,2],
			[2],
			[2,2,4],
			[4],
			[4,4,8],
			[8],
			[8,8,16],
			[16],
			[32],
			[32,16,16],
			[64],
			[64,32,32],
			[128],
			[256],
			[512]
		];
		~weights = Array.fill(
			~durTables.size,
			{linrand(0.01,0.02)}
		).normalizeSum.sort.reverse;
		1.wait;
		4.do({
			arg i;
			Tdef((i+4).asSymbol, {
				loop {
					~note[i] = [
						32,37,39,44,49,51,56,61,63,66,68,73,75,80,85,87
					].scramble;
					~durs.put(
						i,
						PatternProxy(
							Pseq(
								~durTables.wchoose(
									~weights
					).scramble,inf)).asStream);
					("sequence " ++ i ++ " updated").postln;
					[16,32,64,128,256].wchoose([0.6,0.2,0.1,0.05,0.05]).wait
				}
			}).play(~timer, quant: 4)
		});
		1.wait;
		Tdef(\0, {
			var delta;
			loop {
				delta = ~durs[0].next;
				p.putAll("ii.wsyn.play_note(" ++ ((~note[0].choose-60)/12) ++ "," ++ rrand(1,4) ++ ");\n");
				"playing w/syn".postln;
				delta.yield;
			}
		}).play(~timer, quant: 4);
		Tdef(\1, {
			var delta;
			loop {
				delta = ~durs[1].next;
				p.putAll("ii.jf.play_note(" ++ ((~note[1].choose-60)/12) ++ "," ++ rrand(1,4) ++ ");\n");
				"playing jf".postln;
				delta.yield;
			}
		}).play(~timer, quant: 4);
		Tdef(\2, {
			var delta;
			loop {
				delta = ~durs[2].next;
				p.putAll("output[2](pulse());\n");
				"output 2 pulse".postln;
				delta.yield;
			}
		}).play(~timer, quant: 4);
		Tdef(\3, {
			var delta;
			loop {
				delta = ~durs[2].next;
				p.putAll("output[4](pulse());\n");
				"output 4 pulse".postln;
				delta.yield;
			}
		}).play(~timer, quant: 4)
	}
).play(AppClock)
)