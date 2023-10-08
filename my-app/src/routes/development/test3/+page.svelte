<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import OpenLTspice, {update_elements} from "./openLTspice.svelte";
	import Plot from "svelte-plotly.js";

	export let plotdata;
	let db;
	let phase;
	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}
	/*
	async function plot_result(event) {
		const response = await fetch("/development/test_plot");
		plotdata = await response.json();
	}
*/
	import { ckt_name, dir_name, probes_name } from "./stores.js";
	let file;
	let dir;
	let probes;
	ckt_name.subscribe((value) => {
		file = value;
	});
	dir_name.subscribe((value) => {
		dir = value;
	});
	probes_name.subscribe((value) => {
		probes = value;
	});	
	async function plot_result(event) {
		// cookies.et('probes', probes, { path: '/'});
		console.log(
			`Plot results@dir='${dir}' file='${file}' probes=${probes}`
		);
		const encoded_params = `dir=${encodeURIComponent(
			dir
		)}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes
		)}`;
		let response = await fetch(
			`http://localhost:9292/api/ltspctl/results?${encoded_params}`,
			{}
		);
		let res2 = await response.json();
		console.log(res2);
		plotdata = res2.traces;
		console.log(`probes=${probes}`);
		if (probes.startsWith("frequency")) {
			phase = res2.phase;
			db = res2.db;
			console.log(`db=${db}`);
		}

		return res2;
	}
	/*
	async function goLTspice() {
		let response = await fetch(
			"http://localhost:9292/api/ltspctl/simulate",
			{
			}
		);
		let res2 = await response.json();
		console.log(res2);
		// plotdata = get_results();
		return res2;
    }
*/
	export let data;
    probes_name.set(data.props.probes);
	$: probes_name.set(probes);
	
	let yaxis_is_log = false;
	let xaxis_is_log = false;
    function clear_plot(){
		plotdata = undefined;
	}
</script>

<OpenLTspice {data} on:open_end={plot_result}/>
<Simulate on:sim_end={plot_result} on:elm_update={update_elements(dir, file)}/>
<!-- div>
	<button on:click={goLTspice}>
		Click here to Start LTspice simulation</button>
</div -->
<!-- Testplot / -->
<button on:click={plot_result} class="button-1"
	>Plot simulation result with probes setting:</button
>
<input bind:value={probes} style="border:darkgray solid 1px;"/>
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
{#if plotdata !== undefined}
	<Plot
		data={plotdata}
		layout={{
			xaxis: xaxis_is_log
				? { type: "log", autorange: "true" }
				: { autorange: "true" },
			yaxis: yaxis_is_log
				? { type: "log", autorange: "true" }
				: { autorange: "true" },
			margin: { t: 0 },
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
			margin: { t: 0 },
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
			margin: { t: 0 },
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