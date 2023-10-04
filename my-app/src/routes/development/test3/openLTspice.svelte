<script>
  import { end_hydrating } from "svelte/internal";
  import { ckt_name, dir_name, probes_name } from "./stores.js";
  import { createEventDispatcher } from "svelte";
  const dispatch = createEventDispatcher();

  async function openLTspice(dir, file, showup) {
    if (file == undefined) {
      alert("Please choose circuit to open");
      return;
    }
    ckt_name.set(file);
    dir_name.set(dir);
    console.log(`openLTspice dir='${dir}' file='${file}'`);
    let encoded_params;
    if (showup) {
      encoded_params = `dir=${encodeURIComponent(
        dir
      )}&file=${encodeURIComponent(file)}&showup=true`;
    } else {
      encoded_params = `dir=${encodeURIComponent(
        dir
      )}&file=${encodeURIComponent(file)}`;
    }
    let response = await fetch(
      `http://localhost:9292/api/ltspctl/open?${encoded_params}`,
      {}
    );
    let res2 = await response.json();
    console.log(res2);
    console.log(`probes: ${probes}`);
    if (probes != undefined) {
      // goLTspice();
      //plot_result();
      dispatch("open_end", { text: "fake simulation ended!" });
    }
    ckt = res2;
    return res2;
  }
  let files;
  export let data;
  function fakeOpen(file) {
    alert(`you have chosen ${file}`);
  }
  let scoops = data.props.ckt;
  let ckt;
  /*
  let ckt_store;
  ckt_name.subscribe((value) => {
    ckt_store = value;
  });
  */
  let probes;
  probes_name.subscribe((value) => {
    probes = value;
  });
  let traces = "";
  let showup = false;
  if (scoops != undefined) {
    openLTspice(data.props.wdir, scoops, showup);
  }
  function get_control(props) {
    if (Array.isArray(props)) {
      return props[0].control;
    } else {
      return props.value;
    }
  }
  function push_button(node) {
    console.log(`${probes}, ${node}`);
    probes = probes + ", " + node;
    probes_name.set(probes);
  }
</script>

<h2>
  Work directory: {data.props.wdir}
</h2>
<div class="sample">
  {#each data.props.files as file}
    <label class="box-item">
      <input type="radio" name="scoops" value={file} bind:group={scoops} />
      {file}<br />
    </label>
  {/each}
</div>
<div>
  <button
    on:click={openLTspice(data.props.wdir, scoops, showup)}
    class="button-1"
  >
    Click here to Open LTspice</button
  >
  <label>
    <input type="checkbox" bind:checked={showup} />
    show up schematic
  </label>
</div>
{#if ckt != undefined}
  <div style="border:red solid 5px;">
    {#each Object.entries(ckt.elements) as [elm, props]}
      <div>{elm}:{get_control(props)}</div>
    {/each}
  </div>
  <div class="sample">
    {#each ckt.info as node}
      <button on:click={push_button(node)} class="button-item">{node}</button>
    {/each}
  </div>
{/if}

<style>
  .sample {
    display: flex;
    flex-wrap: wrap;
    /* border: green solid 5px; */
    height: 200px;
    /* background:yellow; */
    overflow: scroll;
  }
  .box-item {
    width: 25%;
    background: orange;
    text-align: left;
    padding: 5px 10px;
    border: 5px solid #ddd;
  }
  .button-item {
    /* width: 25%; */
    background: lightblue;
    text-align: left;
    padding: 2px 3px;
    border: 2px solid yellow;
  }
  .button-1 {
    /* width: 25%; */
    background: lightblue;
    text-align: left;
    padding: 5px 10px;
    border: 5px solid #ddd;
  }
</style>
