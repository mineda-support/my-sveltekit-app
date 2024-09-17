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
    import PlotResults from "./plotResults.svelte"
	import ResultsPlot from "./utils/results_plot.svelte";

	import {
		ckt_name,
		dir_name,
		ckt_store,
		elements_store,
		settings_store,
		//models_store,
	} from "./stores.js";
	import { stringify } from "postcss";
	import { A } from "plotly.js-dist";
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
	let sweep_name;
	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}

	let calculated_value;
	// $: calculated_value = calculated_value;
	let performances;
	$: {
		if (settings.performance_names != undefined) {
			performances = Array.isArray(settings.performance_names)
				? settings.performance_names
				: settings.performance_names.split(",").map((a) => a.trim());
		}
	}
	$: results_data = results_data;

	function plot_results() {

	}
	function clear_all_plots() {
		ckt_data = {measdata: [], plotdata: [], 
			db_data: [], ph_data: [], calculated_value: []};
	}

	settings = {plot_number: 0, plot_showhide: [],
		measfile: [], step_precison: [], 
		step_precision: [], title: [], title_x: [], title_y: [],
		title_y1: [], title_y2: [], yaxis_is_log: [], xaxis_is_log: [],
		equation: [], performance_names: [], probes: [],
		reject: [], reverse: [], tracemode: []
	};
	let ckt_data = {measdata: [], plotdata: [], db_data: [],
		ph_data: [], calculated_value: []
	};
settings.plot_showhide[settings.plot_number] = true;
</script>

<ConvertSchematic />
<OpenLTspice {data} on:open_end={plot_results} />
<Settings {data} {ckt} />
<div>
	<Simulate on:sim_end={plot_results} on:sim_start={clear_all_plots} />
	<!-- Testplot / -->
</div>
{#each Array(settings.plot_number + 1) as _, i}
	<PlotResults
	    bind:plot_showhide = {settings.plot_showhide[i]}
		bind:results_data = {results_data}
		bind:dir = {data.props.dir}
		bind:file = {data.props.file}
		bind:measfile = {settings.measfile[i]}
        bind:step_precision = {settings.step_precision[i]}
		bind:title = {settings.title[i]}
		bind:title_x = {settings.title_x[i]}
		bind:title_y = {settings.title_y[i]}
		bind:title_y1 = {settings.title_y1[i]}
		bind:title_y2 = {settings.title_y2[i]}		
		bind:yaxis_is_log = {settings.y_axis_is_log}
		bind:xaxis_is_log = {settings.x_axis_is_log}
        bind:equation = {settings.equation[i]}
		bind:performance_names = {settings.performance_names[i]}
		bind:probes={settings.probes[i]}
		bind:plotdata = {ckt_data.plotdata[i]}
		bind:db_data = {ckt_data.db_data[i]}
		bind:ph_data = {ckt_data.ph_data[i]}
		bind:measdata = {ckt_data.measdata[i]}
		bind:calculated_value = {ckt_data.calculated_value[i]}	
		bind:reject = {settings.reject[i]}
		bind:reverse = {settings.reverse[i]}
		bind:tracemode = {settings.tracemode[i]}
	></PlotResults>
{/each}

<!-- {#if results_data != undefined && results_data[0].length > 0}>
	{#each Object.entries(results_data[0]) as [performance, plot_data]}
     <ResultsPlot plot_data={plot_data} title={performance} {performance} />
{/each}
<{/if} -->

<Experiment {results_data} {sweep_name} />
