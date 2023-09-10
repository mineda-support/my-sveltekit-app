<script context="module">
  export function handleMessage(event){
		 console.log('handleMessage');
		 alert(event.detail.text);
         plot_result();
	}
</script>
<script>
  import Plot from "svelte-plotly.js";

  let plotdata;

  async function plot_result() {
    const response = await fetch("/development/test_plot");
    plotdata = await response.json();
  }

</script>

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
