<script lang="ts">
 import Plot from 'svelte-plotly.js';
 export let data;
 let plotdata = data.plotdata;
 /* data = data.plotdata; */
 console.log(plotdata);
</script>
  
<Plot
  data = {plotdata}
  layout={{
    margin: { t: 0 }
  }}
  fillParent='width'
  debounce={250}
/>