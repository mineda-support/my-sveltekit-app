<script>
	import Plot from "svelte-plotly.js";
	import InputValue from "./Utils/input_value.svelte";
	import {
		ckt_name,
		dir_name,
		probes_name,
		equation_name,
		ckt_store,
		elements_store,
		settings_store,
	} from "./stores.js";
	import { bindAll, dot$1, number } from "plotly.js-dist";
	let ckt;
	let file, dir, probes, equation;

	ckt_name.subscribe((value) => {
		file = value;
	});
	dir_name.subscribe((value) => {
		dir = value;
	});
	probes_name.subscribe((value) => {
		probes = value;
	});
	equation_name.subscribe((value) => {
		equation = value;
	});
	ckt_store.subscribe((value) => {
		ckt = value;
	});
	let elements;
	elements_store.subscribe((value) => {
		elements = value;
	});
	let settings = {};
	settings_store.subscribe((value) => {
		settings = value;
	});

	//	settings.src1 = "V2";
	//	settings.src1_values =
	//		"PULSE(2.4 2.6 200n 100n 100n 200n 700n), PULSE(2.45 2.55 200n 100n 100n 200n 700n), PULSE(2.475 2.525 200n 100n 100n 200n 700n)";
	//	let src2, src2_values;
	//	function wrap_with_apostrophe(a) {
	//		if (a != undefined && a != null) {
	//			return a
	//				.split(/, */)
	//				.map((x) => `'${x}'`)
	//				.join(", ");
	//		}
	//	}
	//	$: settings.program = `new_traces = []
	//src1_values = [${wrap_with_apostrophe(settings.src1_values)}]
	//src1_values.each{|p|
	//  ckt.set ${settings.src1}: p
	//  puts "${settings.src1} = #{ckt.get('${settings.src1}')}"
	//  ckt.simulate
	//  vars, traces =ckt.get_traces ${wrap_with_apostrophe(probes)}
	//  traces[0][:name] = p.sub ' 200n 100n 100n 200n 700n', ''
	//  new_traces << traces[0]
	//}
	//new_traces
	//`;

	async function submit_program(program, dir, file) {
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}`;
		// console.log(`program to send: ${program}`);
		const res = await fetch(
			`http://localhost:9292/api/ltspctl/execute?${encoded_params}`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ program: program }),
			},
		);
		plot_data = await res.json();
		console.log(plot_data);
	}
	let plot_data;
	let src1;
	$: settings.src1 = src1;

	import { createEventDispatcher } from "svelte";
    const dispatch = createEventDispatcher();

	function postprocess(settings) {
		eval(settings.postprocess);
	}
	let result_data;
	function execute_script(script, dir, settings, elements) {
		eval(script);
	}
	async function goLTspice2(ckt) {
        console.log(`openLTspice dir='${dir}' file='${file}'`);
        /* dispatch("elm_update", { text: "Update elements" });
        const my_sleep = (ms) =>
            new Promise((resolve) => setTimeout(resolve, ms));
        await my_sleep(3000); */
        const encoded_params = `dir=${encodeURIComponent(
            dir
        )}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes,
		)}&equation=${encodeURIComponent(equation)}`;
        // dispatch("sim_start", { text: "LTspice simulation started!" });
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/simulate?${encoded_params}`,
            {}
        );
        let res2 = await response.json();
        console.log('res2=', res2);
        //dispatch("sim_end", { text: "LTspice simulation ended!" });
        // plotdata = get_results();
        return res2.calculated_value;
    }	

	async function go(dir, settings, elements) {
		plot_data = [];
		plot_data[0] = {x: [], y: []};
		result_data = [];
		result_data[0] = {x: [], y:[]};
		//alert(settings.src1);
		let var_name;
		let target;
		[target, var_name] = settings.src1.split(":");
		//console.log(target, var_name);
		const keep = elements[target][var_name];
		let gb = []; // Gain Bandwidth product
		let pm = []; // Phase Margin
		for (const value of settings.src1_values) {
			if (keep.match(/\.par/)) {
				console.log(`${var_name}: ${keep.replace(/(\.par\S+ *\S+ *= *)(\S+)/, '$1'+value)}`);
                let updates = [`${var_name}: '${keep.replace(/(\.par\S+ *\S+ *= *)(\S+)/, '$1'+value)}'`];
console.log(updates);
                await update_elms(dir, target+'.asc', updates);
			} else {
			    console.log(`${var_name}: ${value}`);
            }
			dispatch("sim_start", { text: "LTspice simulation started!" });
            let calculated_value = await goLTspice2(ckt) ;
			gb.push(calculated_value[0][0]);
			pm.push(calculated_value[0][1]);
			dispatch("sim_end", { text: "LTspice simulation ended!" });
			plot_data[0].x.push(Number(value));
			result_data[0].x.push(Number(value));
		}
		console.log('gb=', gb);
		console.log('pm=', pm);
		plot_data[0].y = gb;
		result_data[0].y =pm;
		console.log('plot_data=', plot_data);
	}
// plot_data = [{x:[1,2,3,4], y:[1,2,4,3]}];


	function set_src_values() {
		console.log("sweep type:", settings.sweep_type1);
		settings.src1_values = [];
		switch (settings.sweep_type1) {
			case "Linear":
				console.log("start:", settings.start_lin_val1);
				console.log("stop:", settings.stop_lin_val1);
				console.log("increment:", settings.lin_incr1);
				for (
					let val = Number(settings.start_lin_val1);
					val <= Number(settings.stop_lin_val1);
					val = val + Number(settings.lin_incr1)
				) {
					settings.src1_values.push(val);
				}
				break;
			case "Decade":
				console.log("Decade");
				let log10start = Math.log10(Number(settings.start_dec_val1));
				console.log("start=", log10start);
				let log10stop = Math.log10(Number(settings.stop_dec_val1));
				console.log("stop=", log10stop);
				let incr = 1.0 / Number(settings.dec_points1);
				console.log("incr=", incr);
				for (let i = log10start; i <= log10stop; i = i + incr) {
					console.log(i);
					settings.src1_values.push(Math.pow(10, i));
				}
				break;
		}
		console.log(settings.src1_values);
	}

	async function update_elms(dir, target, update_elms) {
		console.log("let me update ", target, " with:", update_elms);
		update_elms = encodeURIComponent(`{${update_elms}}`);
		let encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(target)}`;
		const command = `http://localhost:9292/api/ltspctl/update?${encoded_params}&updates=${update_elms}`;
		console.log(command);
		let response = await fetch(command, {});
		let ckt = await response.json(); // ckt = {elements}
		console.log("ckt=", ckt);
	}
</script>

<div>Make Experiments</div>
<div>
	<label
		>1st source
		<select bind:value={settings.src1} style="border:darkgray solid 1px;">
			{#each Object.entries(elements) as [ckt_name1, elms]}
				{#each Object.keys(elms) as elm1}
					<!-- option value={[ckt_name1, elm1]}
				>{String([ckt_name1, elm1].join(":"))}</option
			-->
					<option value={[ckt_name1, elm1].join(":")}
						>{[ckt_name1, elm1].join(":")}</option
					>
				{/each}
			{/each}
		</select>
		<select
			bind:value={settings.sweep_type1}
			style="border:darkgray solid 1px;"
		>
			<option value="Linear">Linear</option>
			<option value="Octave">Octave</option>
			<option value="Decade">Decade</option>
			<option value="List">List</option>
		</select>
		{#if settings.sweep_type1 == "Linear"}
			<!-- label>Start
			<input
				bind:value={settings.start_value1}
				style="border:darkgray solid 1px;"
			/></label -->
			<InputValue lab="Start" bind:val={settings.start_lin_val1} />
			<InputValue lab="Stop" bind:val={settings.stop_lin_val1} />
			<InputValue lab="Increment" bind:val={settings.lin_incr1} />
		{/if}
		{#if settings.sweep_type1 == "Decade"}
			<InputValue
				lab="# of points /dec."
				bind:val={settings.dec_points1}
			/>
			<InputValue lab="Start" bind:val={settings.start_dec_val1} />
			<InputValue lab="Stop" bind:val={settings.stop_dec_val1} />
		{/if}
		{#if settings.sweep_type1 == "Octave"}
			<InputValue
				lab="# of points /oct."
				bind:val={settings.oct_points1}
			/>
			<InputValue lab="Start value" bind:val={settings.start_oct_val1} />
			<InputValue lab="Stop value" bind:val={settings.stop_oct_val1} />
		{/if}
		{#if settings.sweep_type1 == "List"}
			<label
				>List
				<input
					bind:value={settings.list1}
					style="border:darkgray solid 1px;"
				/></label
			>
		{/if}
		<button on:click={set_src_values} class="button-1"
			>Set source values</button
		>
		{settings.src1} =&gt;{settings.src1_values}
	</label>
</div>
<div>
	<label
		>2nd source
		<input bind:value={settings.src2} style="border:darkgray solid 1px;" />
		values
		<input
			bind:value={settings.src2_values}
			style="border:darkgray solid 1px;width: 50%;"
		/>
	</label>
</div>
<div>
	<label>
		<button on:click={go(dir, settings, elements)} class="button-1">Go</button>
	</label>
</div>
<div>
	<!-- label>
		<button
			on:click={execute_script(settings.script, dir, settings, elements)}
			class="button-1"
		>
			Execute below script</button
		>
		<textarea
			bind:value={settings.script}
			style="border:darkgray solid 1px; height: 200px; 
width: 90%;"
		/>
	</label -->
	<!-- label>
		<button
			on:click={submit_program(settings.program, dir, file)}
			class="button-1"
		>
			Submit below program</button
		>
		<textarea
			bind:value={settings.program}
			style="border:darkgray solid 1px; height: 200px; 
width: 90%;"
		/>
	</label -->
</div>
{#if plot_data !== undefined}
	<Plot
		data={plot_data}
		layout={{
			title: "title",
			xaxis: { title: "capacitor", autorange: "true", linewidth: 1, mirror: true, },
			yaxis: { title: "Gain Bandwidth product", autorange: "true", linewidth: 1, mirror: true, },
		}}
		fillParent="width"
		debounce={250}
	/>
{/if}
<!-- div>
	<label>
		<button on:click={postprocess(settings)} class="button-1">
			Postprocess</button
		>
		<textarea
			bind:value={settings.postprocess}
			style="border:darkgray solid 1px; height: 200px; 
width: 90%;"
		/>
	</label>
</div -->
{#if result_data !== undefined}
	<Plot
		data={result_data}
		layout={{
			title: "title",
			xaxis: { title: "capacitor", autorange: "true", linewidth: 1, mirror: true, },
			yaxis: { title: "Phase Margin", autorange: "true", linewidth: 1, mirror: true,  },
		}}
		fillParent="width"
		debounce={250}
	/>
{/if}

<style>
	.button-1 {
		/* width: 25%; */
		background: lightblue;
		text-align: left;
		padding: 5px 10px;
		border: 5px solid #ddd;
	}
</style>
