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

	function plot_results() {
		if (variations == {}) {
			return;
		}
		let vals;
		for (const [ckt_name, elms] of Object.entries(elements)) {
			for (const [elm, props] of Object.entries(elms)) {
				if (elm.match(/#$/) && (vals = variations[elm])) {
					vals.forEach((val) => {
						settings.plot_number = settings.plot_number + 1;
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
		reject: [],
		reverse: [],
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
	settings.plot_showhide[settings.plot_number] = true;
	settings.probes[settings.plot_number] = "";
	ckt_data.measdata[settings.plot_number] = [];
	let variations = {};
</script>

<ConvertSchematic />
<OpenLTspice
	{data}
	bind:probes={settings.probes[settings.plot_number]}
	bind:variations
	/>
<!--	plot_on:open_end={plot_results} -->
<Settings {data} {ckt} bind:variations bind:settings />
<div>
	<Simulate
		bind:probes={settings.probes[settings.plot_number]}
		bind:variations
		on:sim_end={plot_results}
		on:sim_start={clear_all_plots}
	/>
	<!-- Testplot / -->
</div>

	{#each Array(settings.plot_number + 1) as _, i}
	<!-- {#if ckt_data.plotdata[i] != undefined} -->
	<PlotResults
			plot_number={i}
			bind:plot_showhide={settings.plot_showhide[i]}
			bind:results_data
			bind:dir
			bind:file
			bind:elements
			bind:measfile={settings.measfile[i + 1]}
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
			bind:reject={settings.reject[i]}
			bind:reverse={settings.reverse[i]}
			bind:tracemode={settings.tracemode[i]}
		></PlotResults>
		<!-- {/if} -->
		{/each}

<button
	on:click={() => (settings.plot_number = settings.plot_number + 1)}
	class="button-2">Add plot</button
>
<button
	on:click={() => (settings.plot_number = settings.plot_number - 1)}
	class="button-2">Remove plot</button
>

{#if settings.equation[settings.plot_number] != undefined}
	<Experiment
		bind:settings
		bind:results_data
		{elements}
		bind:probes={settings.probes[settings.plot_number]}
		bind:equation={settings.equation[settings.plot_number]}
		bind:performance_names={settings.performance_names[
			settings.plot_number
		]}
	/>
{/if}
