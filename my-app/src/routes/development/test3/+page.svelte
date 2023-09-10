<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import OpenLTspice from "./openLTspice.svelte";
	import Plot from "svelte-plotly.js";

	export let plotdata;
	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}

	async function plot_result(event) {
		const response = await fetch("/development/test_plot");
		plotdata = await response.json();
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
</script>

<OpenLTspice data={data}/>
<Simulate on:sim_end={plot_result} />
<!-- div>
	<button on:click={goLTspice}>
		Click here to Start LTspice simulation</button>
</div -->
<!-- Testplot / -->
<button on:click={plot_result}>Plot simulation result</button>

{#if plotdata !== undefined}
	<Plot
		data={plotdata}
		layout={{
			width: 500,
			height: 500,
			yaxis: { type: "log", autorange: "true" },
			margin: { t: 0 },
		}}
		fillParent="width"
		debounce={250}
	/>
{/if}
