<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import ConvertSchematic from "./convertSchematic.svelte";
	import Experiment, { set_trace_names } from "./experiment.svelte";
	// import OpenLTspice, {update_elements} from "./openLTspice.svelte";
	import OpenLTspice, { get_control } from "./openLTspice.svelte";
	import Settings from "./settings.svelte";
	// import Plot from "svelte-plotly.js";
	import PlotResults from "./plotResults.svelte";

	import {
		ckt_name,
		dir_name,
		ckt_store,
		elements_store,
		settings_store,
		//models_store,
	} from "./stores.js";
	//import { stringify } from "postcss";
	//import { A } from "plotly.js-dist";
	let file;
	let dir;
	let ckt;
	let elements;
	//let models;

	ckt_name.subscribe((value) => {
		file = value;
	});
	dir_name.subscribe((value) => {
		dir = value;
	});
	ckt_store.subscribe((value) => {
		ckt = value;
	});
	elements_store.subscribe((value) => {
		elements = value;
	});
	elements_store.set({});
	//models_store.subscribe((value) => {
	//	models = value;
	//});
	//models_store.set({});
	let settings;
	settings_store.subscribe((value) => {
		settings = value;
	});
	ckt_store.set(undefined);

	export let data;

	let results_data = [];
	results_data[0] = [];

	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}

	let calculated_value;
	// $: calculated_value = calculated_value;
	$: results_data = results_data;
    let current_plot;
	function plot_results() {
		if (variations == {}) {
			return;
		}
		let vals;
		for (const [ckt_name, elms] of Object.entries(elements)) {
			for (const [elm, props] of Object.entries(elms)) {
				if (elm.match(/#$/) && (vals = variations[elm])) {
					vals.forEach((val) => {
						current_plot = current_plot + 1;
					});
					return;
				}
			}
		}
	}

	function clear_all_plots() {
		ckt_data = {
			measdata: [],
			plotdata: [],
			db_data: [],
			ph_data: [],
			calculated_value: [],
		};
	}

	settings = {
		plot_number: 0,
		plot_showhide: [],
		meas_group: undefined,
		measfile: [],
		step_precision: [],
		title: [],
		title_x: [],
		title_y: [],
		title_y1: [],
		title_y2: [],
		yaxis_is_log: [],
		xaxis_is_log: [],
		equation: [],
		performance_names: [],
		probes: [],
		selection: [],
		reverse: [],
		invert_x: [],
		invert_y: [],
		tracemode: [],
		par_name: [],
		sweep_type: [],
		start_lin_val: [],
		stop_lin_val: [],
		lin_incr: [],
		src_value: [],
		start_dec_val: [],
		stop_dec_val: [],
		dec_points: [],
		start_oct_val: [],
		stop_oct_val: [],
		oct_points: [],
		src_title: [],
		src_precision: [],

		src: [],
		src_plus: [],
		src_values: [],
		sweep_title: [],
		result_title: [],
	};
	let ckt_data = {
		measdata: [],
		plotdata: [],
		db_data: [],
		ph_data: [],
		calculated_value: [],
	};
	settings.plot_showhide = [true];
	settings.probes = [""]
	ckt_data.measdata = [[]];
	let variations = {};

	async function load_measurement_group_file() {
		const pickerOpts = {
			types: [
				{ description: "CSV(.csv)", accept: { "csv/*": [".csv"] } },
			],
			multiple: false,
		};
		let fileHandle;
		[fileHandle] = await window.showOpenFilePicker(pickerOpts);
		const file = await fileHandle.getFile();
		const decoder = new TextDecoder("sjis");
		const filedata = await file.arrayBuffer(); //text()
		settings.meas_group = decoder.decode(new Uint8Array(filedata)).split(/\n/);
		//measgrp_filedata = await file.arrayBuffer();
		console.log("measurement group file=", settings.meas_group);
	}

	function setup_measurement_group() {
		let line, file, sel, inv_x, inv_y, elm, val;
		current_plot = 0;
		settings.meas_group.forEach((line) => {
			[file, sel, inv_x, inv_y, elm, val] = line.split(",");
			console.log('file=', file, 'sel=', sel);
			settings.plot_showhide[current_plot] = true;
			settings.measfile[current_plot] = file;
			settings.selection[current_plot] = sel;
			settings.invert_x[current_plot] = inv_x;
			settings.invert_y[current_plot] = inv_y;
			current_plot = current_plot + 1;
		});
	}

	function clear_measurement_group() {
		settings.meas_group = undefined;
		current_plot = 0;
	}

	function add_plot() {
		settings.plot_showhide.push(true);
		console.log('settings.plot_showhide=', settings.plot_showhide);
		// console.log('length=', settings.plot_showhide.length);
		current_plot = settings.plot_showhide.length - 1;
		settings = settings;
		console.log('settings.plot_showhide=', settings.plot_showhide, 'current_plot=', current_plot);
	}

	function delete_plot() {
		console.log('current_plot to delete=', current_plot);
		for (const [obj] of Object.entries(settings)) {
			// console.log(`settings.${obj}=`, settings[obj]);
			if (Array.isArray(settings[obj])){
				settings[obj].splice(current_plot, 1);
			}
		}
		settings = settings;
	}
</script>

<ConvertSchematic {dir} />
<OpenLTspice
	{data}
	bind:probes={settings.probes[current_plot]}
	bind:variations
/>
<!--	plot_on:open_end={plot_results} -->
<Settings {data} {ckt} bind:variations bind:settings />
<div>
	<Simulate
		bind:probes={settings.probes[current_plot]}
		bind:variations
		on:sim_end={plot_results}
		on:sim_start={clear_all_plots}
	/>
	<!-- Testplot / -->
</div>
<hr />
<div>
	<button on:click={load_measurement_group_file} class="button-2"
		>Load measurement group file</button
	>
	<!-- ConvertSchematic / -->
	{#if settings.meas_group != undefined}
		<button on:click={setup_measurement_group} class="button-1"
			>Setup</button
		>
		<button on:click={clear_measurement_group} class="button-1"
			>Clear</button
		>
		{#each settings.meas_group as line}
			<div>{line}</div>
		{/each}
	{/if}
</div>
{#each settings.plot_showhide as _, i}
	<PlotResults
	    bind:current_plot={current_plot}
		plot_number={i}
		bind:plot_showhide={settings.plot_showhide[i]}
		bind:results_data
		bind:dir
		bind:file
		bind:elements
		bind:measfile={settings.measfile[i]}
		bind:step_precision={settings.step_precision[i]}
		bind:title={settings.title[i]}
		bind:title_x={settings.title_x[i]}
		bind:title_y={settings.title_y[i]}
		bind:title_y1={settings.title_y1[i]}
		bind:title_y2={settings.title_y2[i]}
		bind:yaxis_is_log={settings.yaxis_is_log}
		bind:xaxis_is_log={settings.xaxis_is_log}
		bind:equation={settings.equation[i]}
		bind:performance_names={settings.performance_names[i]}
		bind:probes={settings.probes[i]}
		bind:plotdata={ckt_data.plotdata[i]}
		bind:db_data={ckt_data.db_data[i]}
		bind:ph_data={ckt_data.ph_data[i]}
		bind:measdata={ckt_data.measdata[i]}
		bind:calculated_value={ckt_data.calculated_value[i]}
		bind:selection={settings.selection[i]}
		bind:reverse={settings.reverse[i]}
		bind:invert_x={settings.invert_x[i]}
		bind:invert_y={settings.invert_y[i]}
		bind:tracemode={settings.tracemode[i]}
	></PlotResults>
{/each}

<button
	on:click={add_plot}
	class="button-2">Add plot</button
>
<button
	on:click={delete_plot}
	class="button-2">Delete plot</button
>

{#if settings.equation[current_plot] != undefined}
	<Experiment
		bind:settings
		bind:results_data
		{elements}
		bind:probes={settings.probes[current_plot]}
		bind:equation={settings.equation[current_plot]}
		bind:performance_names={settings.performance_names[
			current_plot
		]}
	/>
{/if}
