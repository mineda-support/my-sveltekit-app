<script>
    // import { get_results } from "./+page.server.js";
	import {goto} from "$app/navigation";

	import Plot from "svelte-plotly.js";
    export let plotdata;
	export let data;

	async function openLTspice() {
		let response = await fetch("http://localhost:9292/api/ltspctl/open", {
			mode: "no-cors",
		});
		let res2 = await response.json();
		console.log(res2);
		return res2;
	}

	async function goLTspice() {
		let response = await fetch(
			"http://localhost:9292/api/ltspctl/simulate",
			{
				mode: "no-cors",
			}
		);
		let res2 = await response.json();
		console.log(res2);
		// plotdata = get_results();
		return res2;
	}
</script>

<h2>
	{data.title}
	{data.body}
</h2>
<div><button on:click={openLTspice}> Click here to Open LTspice</button></div>

<div>
	<button on:click={goLTspice()}>
		Click here to Start LTspice simulation</button
	>
</div>
<a href="http://localhost:5173/cockpit">Plot</a>
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