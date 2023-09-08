<script lang="ts">
  import Plot from "svelte-plotly.js";
  export let data;
  let plotdata = data.plotdata;
  /* data = data.plotdata; */
  console.log(data);
</script>

<h1>{data.dir}</h1>
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
