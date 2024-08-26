<script>
	import Plot from "svelte-plotly.js";
	import InputValue from "./Utils/input_value.svelte";
	import SweepSource from "./utils/sweep_source.svelte";
	import ResultsPlot from "./utils/results_plot.svelte";
	import {
		ckt_name,
		dir_name,
		probes_name,
		equation_name,
		ckt_store,
		elements_store,
		settings_store,
	} from "./stores.js";
	import { bindAll, dot$1, number, update } from "plotly.js-dist";
	let ckt;
	let file, dir, probes, equation;
	export let results_data;

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
	//settings.start_dec_val2 = unknown
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
	let plot_data2;
	let result_data = [];
	let result_number = 0;
	result_data[result_number] = {};
	function execute_script(script, dir, settings, elements) {
		eval(script);
	}
	async function goLTspice2(ckt) {
		console.log(`openLTspice dir='${dir}' file='${file}'`);
		/* dispatch("elm_update", { text: "Update elements" });
        const my_sleep = (ms) =>
            new Promise((resolve) => setTimeout(resolve, ms));
        await my_sleep(3000); */
		console.log("equation=", equation);
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes,
		)}&equation=${encodeURIComponent(equation)}`;
		// dispatch("sim_start", { text: "LTspice simulation started!" });
		let response = await fetch(
			`http://localhost:9292/api/ltspctl/simulate?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		console.log("res2=", res2);
		//dispatch("sim_end", { text: "LTspice simulation ended!" });
		// plotdata = get_results();
		return res2.calculated_value;
	}

	function create_updates(keep, var_name, par_name, value) {
		if (var_name.match(/^par/)) {
			return [
				`${var_name}: '${keep.replace(/(\.par\S+ *\S+ *= *)(\S+)/, "$1" + value)}'`,
			];
		} else if (var_name.match(/^M/)) {
			let rex = new RegExp(`${par_name} *= *(\\S+)`);
			return [
				`${var_name}: ` + keep.replace(rex, `${par_name}=${value}`),
			];
		} else {
			return [`${var_name}: ${value}`];
		}
	}

	function updates_plus(value, src, par_name, src_plus) {
		let target, var_name;
		console.log("src in updates_plus=", src);
		[target, var_name] = src.split(":");
		let updates = create_updates(
			elements[target][var_name],
			var_name,
			par_name,
			value,
		);
		if (src_plus == undefined) {
			return [updates, target];
		}
		for (const plus of src_plus) {
			[target, var_name, par_name] = plus.split(":");
			if (elements[target] == undefined) {
				alert(`${target} is not this circuit`);
				return;
			}
			console.log("plus=", plus);
			console.log(elements);
			updates = updates.concat(
				create_updates(
					elements[target][var_name],
					var_name,
					par_name,
					value,
				),
			);
		}
		return [updates, target];
	}
	// console.log("updates=", updates, `on ${dir}${target}.asc`);
	// await update_elms(dir, target+'.asc', updates);

	function preview_updates(dir, settings, elements) {
		plot_data = [];
		let var_name;
		let target;
		console.log("probes=", probes);
		console.log("equation=", equation);
		console.log("src1=", settings.src1);
		console.log("src1_plus=", settings.src1_plus);
		console.log("src1_values=", settings.src1_values);
		settings.sweep_title = settings.src1;
		settings.result_title = file;
		console.log("sweep_title=", settings.sweep_title);
		console.log("result_title=", settings.result_title);

		[target, var_name] = settings.src1.split(":");
		// console.log(target, var_name);
		if (
			elements[target] == undefined ||
			elements[target][var_name] == undefined
		) {
			return;
		}
		let plot_trace = { x: [], y: [] };
		let updates;
        let count = 0;
		if (settings.src1_plus == undefined) {
			settings.src1_plus = [];
		}
		if (settings.src2_plus == undefined) {
			settings.src2_plus = [];
		}
		let preview_table = `count: ${settings.src2} ${settings.src2_plus.join(' ')}, ${settings.src1} ${settings.src1_plus.join(' ')}\n`;
		for (const value2 of settings.src2_values) {
			//src, par_name, src_plus) {
			[updates, target] = updates_plus(
				value2,
				settings.src2,
				settings.par_name2,
				settings.src2_plus,
			);
			plot_trace.name = settings.src2 + ':' + value2;
			console.log('plot_trace!!!', count, plot_trace);
			console.log("updates=", updates, `on ${dir}${target}.asc`);
			//preview_table = preview_table + settings.src2 + ':' + value2 + "\n";
			//preview_table = preview_table + `plot_trace.name = ${settings.src2} + ':' + ${value2}\n`;

			for (const value of settings.src1_values) {
				[updates, target] = updates_plus(
					value,
					settings.src1,
					settings.par_name1,
					settings.src1_plus,
				);
				console.log("updates=", updates, `on ${dir}${target}.asc`);
				// await update_elms(dir, target+'.asc', updates);
				count = count + 1;
				preview_table = preview_table + `${count}: ${value2}, ${value}\n`
			}
			plot_data.push({...plot_trace});
			console.log('plot_trace=', count, plot_trace);
		}
		console.log('plot_data =', plot_data);
		let blob = new Blob([preview_table], {type:"text/plain"});
		const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'experiment_preview.txt';
        link.click();	
	}

	async function go(dir, settings, elements) {
		plot_data = [];
		let plot_trace = { x: [], y: [] };
		plot_data2 = [];
		let result_trace = { x: [], y: [] };
		//alert(settings.src1);
		let var_name;
		let target;
		[target, var_name] = settings.src1.split(":");
		//console.log(target, var_name);
		//const keep = elements[target][var_name];
		settings.sweep_title = settings.src1;
		settings.result_title = file;
		let updates;

		for (const value2 of settings.src2_values) {
			//src, par_name, src_plus) {
			[updates, target] = updates_plus(
				value2,
				settings.src2,
				settings.par_name2,
				settings.src2_plus,
			);
			const trace_name = settings.src2.replace(/^.*:/, '') + ':' + value2;
			plot_trace.name = trace_name;
			result_trace.name = trace_name;
			console.log("updates=", updates, `on ${dir}${target}.asc`);
			await update_elms(dir, target + ".asc", updates);
			let gb = []; // Gain Bandwidth product
			let pm = []; // Phase Margin
			plot_trace.x = [];
			result_trace.x = [];
			for (const value of settings.src1_values) {
				[updates, target] = updates_plus(
					value,
					settings.src1,
					settings.par_name1,
					settings.src1_plus,
				);
				console.log("updates=", updates, `on ${dir}${target}.asc`);
				await update_elms(dir, target + ".asc", updates);

				dispatch("sim_start", { text: "LTspice simulation started!" });
				let calculated_value = await goLTspice2(ckt);
				if (Array.isArray(calculated_value[0])) {
					gb.push(calculated_value[0][0]);
					pm.push(calculated_value[0][1]);
				} else {
					gb.push(undefined);
					pm.push(undefined);
				}
				dispatch("sim_end", { text: "LTspice simulation ended!" });
				plot_trace.x.push(Number(value));
				result_trace.x.push(Number(value));
			}
			console.log("gb=", gb);
			console.log("pm=", pm);
			plot_trace.y = gb;
			result_trace.y = pm;
			plot_data.push({...plot_trace});
			plot_data2.push({...result_trace});
			/*
			console.log(
					`${var_name}: ${keep.replace(/(\.par\S+ *\S+ *= *)(\S+)/, "$1" + value)}`,
				);
				let updates = [
					`${var_name}: '${keep.replace(/(\.par\S+ *\S+ *= *)(\S+)/, "$1" + value)}'`,
				];
				console.log(updates);
				await update_elms(dir, target + ".asc", updates);
			} else {
				console.log(`${var_name}: ${value}`);
			}
			dispatch("sim_start", { text: "LTspice simulation started!" });
			let calculated_value = await goLTspice2(ckt);
			gb.push(calculated_value[0][0]);
			pm.push(calculated_value[0][1]);
			dispatch("sim_end", { text: "LTspice simulation ended!" });
			plot_data[0].x.push(Number(value));
			plot_data2[0].x.push(Number(value));
*/
		}
		plot_data = plot_data;
		plot_data2 = plot_data2;
		console.log("plot_data=", plot_data);
	}
	// plot_data = [{x:[1,2,3,4], y:[1,2,4,3]}];

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

	function clear() {
		plot_data = plot_data2 = undefined;
		result_data[result_number] = undefined;
	}

	async function save() {
		const blob = JSON.stringify([settings, plot_data, plot_data2]);
		const handle = await window.showSaveFilePicker(); 
		const ws = await handle.createWritable();
		await ws.write(blob);
		await ws.close();
	}

	async function load() {
		const pickerOpts = {
          types: [{ description: 'JSON(.json)', accept: {'json/*': ['.json']} }],
          multiple: false,
		}
		let fileHandle;
		[fileHandle] = await window.showOpenFilePicker(pickerOpts); 
		const file = await fileHandle.getFile();
		/* const reader = new FileReader();
		reader.readAsText(file, 'UTF-8');
		let filedata;
		reader.onload = (event) => {
			filedata = (event.target.result);
		}*/
		let filedata = await file.text();
		let tempsettings;
		console.log(filedata);
		console.log('before:', plot_data);
		[tempsettings, plot_data, plot_data2] = JSON.parse(filedata);
		settings.result_title = tempsettings.result_title;
		settings.sweep_title = tempsettings.sweep_title;
		console.log('after:', plot_data);
	} 

</script>

{#if results_data != undefined && results_data[0].length > 0}
	{#each Object.entries(results_data[0]) as [performance, plot_data]}
     <ResultsPlot {plot_data} title={performance} {performance} />
{/each}
{/if}
<div>Make Experiments</div>
<SweepSource
	source_title="1st source"
	bind:src={settings.src1}
	bind:par_name={settings.par_name1}
	bind:src_values={settings.src1_values}
	bind:src_plus={settings.src1_plus}
	bind:sweep_type={settings.sweep_type1}
	bind:start_lin_val={settings.start_lin_val1}
	bind:stop_lin_val={settings.stop_lin_val1}
	bind:lin_incr={settings.lin_incr1}
	bind:src_value={settings.source_value1}
	bind:start_dec_val={settings.start_dec_val1}
	bind:stop_dec_val={settings.stop_dec_val1}
	bind:dec_incr={settings.dec_points1}
	bind:src_precision={settings.src_precision1}
	bind:elements
></SweepSource>
<SweepSource
	source_title="2nd source"
	bind:src={settings.src2}
	bind:par_name={settings.par_name2}
	bind:src_values={settings.src2_values}
	bind:src_plus={settings.src2_plus}
	bind:sweep_type={settings.sweep_type2}
	bind:start_lin_val={settings.start_lin_val2}
	bind:stop_lin_val={settings.stop_lin_val2}
	bind:lin_incr={settings.lin_incr2}
	bind:src_value={settings.source_value2}
	bind:start_dec_val={settings.start_dec_val2}
	bind:stop_dec_val={settings.stop_dec_val2}
	bind:dec_incr={settings.dec_points2}
	bind:src_precision={settings.src_precision2}
	bind:elements
></SweepSource>
<div>
	<label>
		<button
			on:click={preview_updates(dir, settings, elements)}
			class="button-1">Dry run</button
		>
	</label>
	<label>
		<button on:click={go(dir, settings, elements)} class="button-1"
			>Go</button
		>
	</label>
	<label>
		<button on:click={clear} class="button-1">clear</button>
	</label>
	<label>
		<button on:click={save} class="button-1">Save</button>
	</label>
	<label>
		<button on:click={load} class="button-1">Load</button>
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
			title: settings.result_title,
			xaxis: {
				title: settings.sweep_title,
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
			yaxis: {
				title: "Gain Bandwidth product",
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
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
{#if plot_data2 !== undefined}
	<Plot
		data={plot_data2}
		layout={{
			title: settings.result_title,
			xaxis: {
				title: settings.sweep_title,
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
			yaxis: {
				title: "Phase Margin",
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
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
