<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import ConvertSchematic from "./convertSchematic.svelte";
	import Experiment, {
		set_trace_names,
	} from "./experiment.svelte";
	// import OpenLTspice, {update_elements} from "./openLTspice.svelte";
	import OpenLTspice, { get_control } from "./openLTspice.svelte";
	import Settings from "./settings.svelte";
	// import Plot from "svelte-plotly.js";
	import BodePlot from "./utils/bode_plot.svelte";
	import SinglePlot from "./utils/single_plot.svelte";
	import ResultsPlot from "./utils/results_plot.svelte";

	let measdata = [];

	let results_data = [];
	results_data[0] = [];
	let plotdata;
	$: {
		if (plotdata != undefined) {
			data.props.plotdata = plotdata;
		}
	}
	let db_data;
	let ph_data;
	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}
	import {
		ckt_name,
		dir_name,
		probes_name,
		equation_name,
		ckt_store,
		elements_store,
		settings_store,
	} from "./stores.js";
	import { stringify } from "postcss";
	import { A } from "plotly.js-dist";
	let file;
	let dir;
	let probes;
	let equation;
	let ckt;
	let elements;

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
	elements_store.subscribe((value) => {
		elements = value;
	});
	elements_store.set({});
	let settings = {}; //let title, title_x, title_y;
	settings_store.subscribe((value) => {
		settings = value;
	});
	ckt_store.set(undefined);
	// settings_name.set({equation: equation, probes: probes})
	const options = {
		types: [
			{
				description: "CSV Files",
				accept: {
					"text/plain": [".csv", ".txt", ".text"],
				},
			},
		],
	};
	async function measurement_results(
		measfile,
		reject_list,
		reverse,
		tracemode,
	) {
		if (measfile == undefined || measfile == "") {
			const [handle] = await window.showOpenFilePicker(options);
		}
		console.log(measfile);
		console.log(`reverse=${reverse}, tracemode: ${tracemode}`);
		//console.log(handle.name);
		//const file = await handle.getFile();
		//console.log(file);
		const encoded_params = `dir=&file=${encodeURIComponent(measfile)}&reject=${reject_list}`;
		let response = await fetch(
			`http://localhost:9292/api/misc/measured_data?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		measdata = reverse ? res2.traces.reverse() : res2.traces;
		for (const trace of measdata) {
			trace.checked = true;
			trace.mode = tracemode;
		}
		console.log("measdata:", measdata);
	}

	async function plot_result(event) {
		// cookies.et('probes', probes, { path: '/conditions'});
		console.log(
			`Plot results@dir='${dir}' file='${file}' probes=${probes}`,
		);
		if (probes != probes.trim()) {
			alert("probes have unwanted leading space(s)");
			return;
		}
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes,
		)}&equation=${encodeURIComponent(equation)}`;
		let response = await fetch(
			`http://localhost:9292/api/ltspctl/results?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		console.log(res2);
		[plotdata, db_data, ph_data] = set_trace_names(res2, probes, elements, settings.step_precision);
	}

	/*
	function set_trace_names(plotdata) {
		console.log("plotdata in set_trace_names:", plotdata);
		for (const [ckt_name, elms] of Object.entries(elements)) {
			for (const [elm, props] of Object.entries(elms)) {
				//console.log([elm, props]);
				if (elm == "step") {
					parse_step_command(props, settings.step_precision).forEach(
						function (src_value, index) {
							plotdata[index].name = src_value;
						},
					);
					return;
				}
			}
		}
	}
	*/
	export let data;
	//probes_name.set(data.props.probes);
	$: probes_name.set(probes);
	$: {
		if (probes != undefined) {
			data.props.probes = probes;
		}
	}
	settings.step_precision = 3;
	settings.yaxis_is_log = false;
	settings.xaxis_is_log = false;
	function clear_plot() {
		plotdata = db_data = ph_data = undefined;
	}
	function clear_measdata() {
		measdata = [];
	}
	function checkall_measdata() {
		console.log(measdata);
		for (const trace of measdata) {
			trace.checked = true;
		}
	}
	async function update_elements(dir) {
		for (const [ckt_name, elms] of Object.entries(ckt.elements)) {
			if (ckt_name[0] == ".") {
				continue;
			}
			let target = ckt_name + ".asc";
			console.log(
				"update elements=",
				elements,
				` here @ dir= ${dir} file=${target}`,
			);
			let update_elms = "";
			for (const [elm, props] of Object.entries(elms)) {
				if (elements[ckt_name][elm] != get_control(props)) {
					update_elms =
						update_elms +
						elm +
						":'" +
						elements[ckt_name][elm] +
						"',";
				}
			}
			if (update_elms != "") {
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

				for (const [elm, props] of Object.entries(ckt.elements)) {
					if (elements[ckt_name][elm] != get_control(props)) {
						console.log(
							`Update error! ${elm}: ${get_control(props)}vs.${
								elements[ckt_name][elm]
							}`,
						);
					}
				}
			}
		}
		ckt_store.set(ckt);
		elements_store.set(elements);
	}

	function get_sweep_values(plotdata) {
		let values = [];
		let sweep, value;
		console.log('plotdata in get_sweep_values=', plotdata);
		plotdata.forEach((trace) => {
			[sweep, value] = trace.name.split("=");
			values.push(Number(value));
		});
		return values;
	}

	function get_performance(rows, index) {
		let values = [];
		rows.forEach(row => {
			values.push(row[index]);
		})
		return values;
	}

	function calculate_equation() {
		submit_equation(
			equation,
			dir,
			file,
			plotdata,
			db_data,
			ph_data,
			measdata.filter((trace) => trace.checked),
		);
		console.log("values in calculate_equation:", calculated_value);
		const equation_array = equation.split(",");
		performances.forEach(function (perf, index) {
			//console.log("perf, index=", [perf, index]);
			//console.log('results_data:', results_data);
			//if (calculated_value != undefined) {
			if (results_data[0][perf] == undefined) {
				results_data[0][perf] = [];
			}
			results_data[0][perf].push({
				x: get_sweep_values(plotdata != undefined ? plotdata : db_data),
				y: get_performance(calculated_value, index),
				name: equation_array[index],
			});
			//} else {
			//	console.log('Error: calculate value is not available yet');
			//}
			//console.log(`results_data[0][${perf}]=`, results_data[0][perf]);
		});
		console.log("results_data=", results_data);
	}

	async function submit_equation(
		equation,
		dir,
		file,
		plotdata,
		db_data,
		ph_data,
		measdata,
	) {
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}`;
		console.log(`equation to send: ${equation}`);
		console.log(
			"plotdata:",
			plotdata,
			"db_data:",
			db_data,
			"ph_data:",
			ph_data,
		);
		const res = await fetch(
			`http://localhost:9292/api/ltspctl/measure?${encoded_params}`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					equation: equation,
					plotdata: plotdata ? plotdata.concat(measdata) : [],
					db_data: db_data ? db_data : [],
					ph_data: ph_data ? ph_data : [],
				}),
			},
		);
		let result = await res.json();
		//console.log('result in submit_equation:', result);
		if (plotdata != undefined) {
			calculated_value = result.calculated_value.slice(
				0,
				plotdata.length,
			);
			if (measdata.length > 0) {
				alert(
					result.calculated_value.slice(plotdata.length).join("\n"),
				);
			}
		} else {
			calculated_value = result.calculated_value.slice(0);
		}
		console.log(calculated_value);
		// return calculated_value; // maybe useless
	}
	equation = "x.where(y, 2.5){|x, y| x > 1e-6}";
	$: {
		if (equation != undefined && data.props != undefined) {
			data.props.equation = equation;
		}
	}
	$: equation_name.set(equation);
	let calculated_value;
	// $: calculated_value = calculated_value;
	$: settings.probes = probes;
	let performances;
	$: {
		if (settings.performance_names != undefined) {
			performances = Array.isArray(settings.performance_names)
				? settings.performance_names
				: settings.performance_names.split(",").map((a) => a.trim());
		}
	}
	$: results_data = results_data;
</script>

<ConvertSchematic />
<OpenLTspice {data} on:open_end={plot_result} />
<Settings {data} {ckt} />
<div>
	<Simulate
		on:sim_end={plot_result}
		on:sim_start={clear_plot}
		on:elm_update={update_elements(dir)}
	/>
	<!-- Testplot / -->
</div>
<div>
	{#if data.props != undefined}
		<button
			on:click={measurement_results(
				data.props.measfile.trim().replace(/^"/, "").replace(/"$/, ""),
				data.props.reject,
				data.props.reverse,
				data.props.tracemode,
			)}
			class="button-1">Get measured data:</button
		>
		<input
			bind:value={data.props.measfile}
			style="border:darkgray solid 1px;width: 40%;"
		/>
		<label
			>Reject:<input
				bind:value={data.props.reject}
				style="border:darkgray solid 1px;"
			/></label
		>
		<label
			>Reverse<input
				type="checkbox"
				bind:checked={data.props.reverse}
			/></label
		>
		<button>Trace mode</button>
		<input name="tracemodes" value={data.props.tracemode} type="hidden" />
		<select
			bind:value={data.props.tracemode}
			style="border:darkgray solid 1px;"
		>
			<option value="lines">lines</option>
			<option value="markers">markers</option>
			<option value="lines+markers">lines+markers</option>
		</select>
	{/if}
</div>
<button on:click={plot_result} class="button-1">Plot with probes:</button>
<input bind:value={probes} style="border:darkgray solid 1px;" />
{#if probes == undefined || !probes.startsWith("frequency")}
	<label>
		<input type="checkbox" bind:checked={settings.xaxis_is_log} />
		xaxis is log
	</label>
	<label>
		<input type="checkbox" bind:checked={settings.yaxis_is_log} />
		yaxis is log
	</label>
{/if}
<label>
	<button on:click={clear_plot} class="button-1">clear</button>
</label>
<label
	>step precision:
	<input bind:value={settings.step_precision} />
</label>
<div>
	<label
		>Title
		<input bind:value={settings.title} style="border:darkgray solid 1px;" />
	</label>
	<label
		>X title
		<input
			bind:value={settings.title_x}
			style="border:darkgray solid 1px;"
		/>
	</label>
	{#if probes == undefined || !probes.startsWith("frequency")}
		<label
			>Y title
			<input
				bind:value={settings.title_y}
				style="border:darkgray solid 1px;"
			/>
		</label>
	{:else}
		<label
			>Y1 title
			<input
				bind:value={settings.title_y1}
				style="border:darkgray solid 1px;"
			/>
		</label>
		<label
			>Y2 title
			<input
				bind:value={settings.title_y2}
				style="border:darkgray solid 1px;"
			/>
		</label>
	{/if}
</div>
{#if plotdata !== undefined}
	<SinglePlot {plotdata} {measdata} {settings} />
	<!-- Plot
		data={plotdata.concat(measdata.filter((trace) => trace.checked))}
		layout={{
			title: settings.title,
			xaxis: {
				type: xaxis_is_log ? "log" : "",
				autorange: "true",
				title: settings.title_x,
			},
			yaxis: {
				type: yaxis_is_log ? "log" : "",
				autorange: "true",
				title: settings.title_y,
			},
			margin: { t: 30 },
		}}
		fillParent="width"
		debounce={250}
	/ -->
{/if}
{#if probes != undefined && probes.startsWith("frequency") && db_data !== undefined && ph_data !== undefined}
	<BodePlot {db_data} {ph_data} {settings} />
	<!-- Plot
		data={db_data}
		layout={{
			title: settings.title,
			xaxis: {
				type: "log",
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
			yaxis: {
				autorange: "true",
				linewidth: 1,
				mirror: true,
				title: settings.title_y1,
			},
			margin: { t: 30 },
		}}
		fillParent="width"
		debounce={250}
	/>
	<Plot
		data={ph_data}
		layout={{
			xaxis: {
				type: "log",
				autorange: "true",
				linewidth: 1,
				mirror: true,
				title: settings.title_x,
			},
			yaxis: {
				autorange: "true",
				linewidth: 1,
				mirror: true,
				title: settings.title_y2,
			},
			margin: { t: 30 },
		}}
		fillParent="width"
		debounce={250}
	/ -->
{/if}

{#if measdata != undefined && measdata != "" && measdata != []}
	<div style="border:green solid 2px;">
		{#each measdata as trace}
			<label
				>{trace.name}
				<input
					style="border:darkgray solid 1px;"
					type="checkbox"
					bind:checked={trace.checked}
				/>
			</label>
		{/each}
		<button on:click={checkall_measdata} class="button-1">check all</button>
		<button on:click={clear_measdata} class="button-1">clear all</button>
	</div>
{/if}

<div>
	<label>
		Performance name(s)
		<input
			bind:value={settings.performance_names}
			style="border:darkgray solid 1px;"
		/>
	</label>
</div>

<div>
	<label
		>Equation(s)
		<input bind:value={equation} style="border:darkgray solid 1px;" />
		<button on:click={calculate_equation(results_data[0])} class="button-1">
			Calculate</button
		>
		=>
		{#if Array.isArray(calculated_value)}
			{#each calculated_value as val}
				<div>
					{val}
				</div>
			{/each}
		{/if}
	</label>
</div>

<!-- {#if results_data != undefined && results_data[0].length > 0}>
	{#each Object.entries(results_data[0]) as [performance, plot_data]}
     <ResultsPlot plot_data={plot_data} title={performance} {performance} />
{/each}
<{/if} -->

<Experiment {results_data} />

<style>
	.button-1 {
		/* width: 25%; */
		background: lightblue;
		text-align: left;
		padding: 5px 10px;
		border: 5px solid #ddd;
	}
</style>
