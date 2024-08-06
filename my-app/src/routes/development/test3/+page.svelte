<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import ConvertSchematic from "./convertSchematic.svelte";
	import Experiment from "./experiment.svelte";
	// import OpenLTspice, {update_elements} from "./openLTspice.svelte";
	import OpenLTspice, { get_control } from "./openLTspice.svelte";
	import Plot from "svelte-plotly.js";
	import Settings from "./settings.svelte";

	let measdata = [];

	let plotdata;
	$: data.props.plotdata = plotdata;
	let db;
	let phase;
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
	} from "./stores.js";
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
	async function measurement_results(measfile, reject_list) {
		if (measfile == undefined || measfile == "") {
			const [handle] = await window.showOpenFilePicker(options);
		}
		console.log(measfile);
		//console.log(handle.name);
		//const file = await handle.getFile();
		//console.log(file);
		const encoded_params = `dir=&file=${encodeURIComponent(measfile)}&reject=${reject_list}`;
		let response = await fetch(
			`http://localhost:9292/api/misc/measured_data?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		measdata = res2.traces;
		for (const trace of measdata) {
			trace.checked = true;
			trace.mode = 'line+markers';
		}
		console.log(measdata);
	}

	async function plot_result(event) {
		// cookies.et('probes', probes, { path: '/conditions'});
		console.log(
			`Plot results@dir='${dir}' file='${file}' probes=${probes}`,
		);
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes,
		)}`;
		let response = await fetch(
			`http://localhost:9292/api/ltspctl/results?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		console.log(res2);
		plotdata = res2.traces;
		console.log(`probes=${probes}`);
		if (probes != null && probes.startsWith("frequency")) {
			phase = res2.phase;
			db = res2.db;
			console.log(`db=${db}`);
		}
		return res2;
	}
	export let data;
	//probes_name.set(data.props.probes);
	$: probes_name.set(probes);
	$: data.props.probes = probes;

	let yaxis_is_log = false;
	let xaxis_is_log = false;
	function clear_plot() {
		plotdata = undefined;
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
	async function update_elements(dir, file) {
		console.log(
			`let me update elements=${elements} here @ dir= ${dir} file=${file}`,
		);
		let update_elms = "";
		for (const [elm, props] of Object.entries(ckt.elements)) {
			if (elm != "") {
				if (elements[elm] != get_control(props)) {
					// console.log(`${elm}: ${get_control(props)}->${elements[elm]}`);
					update_elms =
						update_elms + elm + ":'" + elements[elm] + "',";
				}
			}
		}
		if (update_elms != "") {
			update_elms = encodeURIComponent(`{${update_elms}}`);
			let encoded_params = `dir=${encodeURIComponent(
				dir,
			)}&file=${encodeURIComponent(file)}`;
			const command = `http://localhost:9292/api/ltspctl/update?${encoded_params}&updates=${update_elms}`;
			console.log(command);
			let response = await fetch(command, {});
			let ckt = await response.json();
			for (const [elm, props] of Object.entries(ckt.elements)) {
				if (elm != "") {
					if (elements[elm] != get_control(props)) {
						console.log(
							`Update error! ${elm}: ${get_control(props)}vs.${
								elements[elm]
							}`,
						);
					}
				}
			}
		}
		ckt_store.set(ckt);
		elements_store.set(elements);
	}
	async function submit_equation(equation, dir, file, plotdata, measdata) {
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}`;
		// console.log(`program to send: ${equation}`);
		const res = await fetch(
			`http://localhost:9292/api/ltspctl/measure?${encoded_params}`,
			{
				method: "POST",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({
					equation: equation,
					plotdata: plotdata.concat(measdata),
				}),
			},
		);
		let result = await res.json();
		console.log(result);
		alert(result.calculated_value);
		//calculated_value = result.calculated_value[0..(plotdata.size-1)];
		console.log(calculated_value);
	}
	equation = "x.where(y, 2.5){|x, y| x > 1e-6}";
	$: data.props.equation = equation;
	let calculated_value;
	// $: calculated_value = calculated_value;
	let settings = {}; //let title, title_x, title_y;
	$: settings.probes = probes;
</script>

<ConvertSchematic />
<OpenLTspice {data} on:open_end={plot_result} />
<Settings {data} {ckt} />
<div>
	<Simulate
		on:sim_end={plot_result}
		on:elm_update={update_elements(dir, file)}
	/>
	<!-- Testplot / -->
</div>
<div>
	<button
		on:click={measurement_results(data.props.measfile.trim().replace(/^"/, '').replace(/"$/,''), data.props.reject)}
		class="button-1">Get measured data:</button
	>
	<input
		bind:value={data.props.measfile}
		style="border:darkgray solid 1px;width: 50%;"
	/>
	<label>Reject:<input bind:value={data.props.reject} style="border:darkgray solid 1px;"/></label>
</div>
<button on:click={plot_result} class="button-1">Plot with probes:</button>
<input bind:value={probes} style="border:darkgray solid 1px;" />
<label>
	<input type="checkbox" bind:checked={xaxis_is_log} />
	xaxis is log
</label>
<label>
	<input type="checkbox" bind:checked={yaxis_is_log} />
	yaxis is log
</label>
<label>
	<button on:click={clear_plot} class="button-1">clear</button>
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
	<label
		>Y title
		<input
			bind:value={settings.title_y}
			style="border:darkgray solid 1px;"
		/>
	</label>
</div>
{#if plotdata !== undefined}
	<Plot
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
	/>
{/if}
{#if probes != undefined && probes.startsWith("frequency")}
	<Plot
		data={db}
		layout={{
			xaxis: {
				type: "log",
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
			yaxis: { autorange: "true", linewidth: 1, mirror: true },
			margin: { t: 30 },
			linewidth: 1,
			mirror: true,
		}}
		fillParent="width"
		debounce={250}
	/>
	<Plot
		data={phase}
		layout={{
			xaxis: {
				type: "log",
				autorange: "true",
				linewidth: 1,
				mirror: true,
			},
			yaxis: { autorange: "true", linewidth: 1, mirror: true },
			margin: { t: 30 },
		}}
		fillParent="width"
		debounce={250}
	/>
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
	<label
		>Measure
		<input bind:value={equation} style="border:darkgray solid 1px;" />
		<button
			on:click={submit_equation(equation, dir, file, plotdata,
			              measdata.filter((trace) => trace.checked))}
			class="button-1"
		>
			Calculate</button
		>
		=> {calculated_value}
	</label>
</div>

<Experiment {probes} />

<style>
	.button-1 {
		/* width: 25%; */
		background: lightblue;
		text-align: left;
		padding: 5px 10px;
		border: 5px solid #ddd;
	}
</style>
