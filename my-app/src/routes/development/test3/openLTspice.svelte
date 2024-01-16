<script context="module">
	import { goto } from "$app/navigation";
  export function get_control(props) {
    if (Array.isArray(props)) {
      return props[0].control;
    } else {
      return props.value;
    }
  }
</script>
<script>
  import { end_hydrating } from "svelte/internal";
  import ConvertSchematic from "./convertSchematic.svelte";
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
      // plot_result();
      dispatch("open_end", { text: "fake simulation ended!" });
    }
    ckt = res2;
    console.log(`ckt=${ckt}`)
    if (ckt != undefined) {
      elements = {};
      for (const [elm, props] of Object.entries(ckt.elements)) {
        if (elm != "") {
          // elements_text = elements_text + elm + ":" + get_control(props) + "\n";
          elements[elm] = get_control(props);
        }
      }
      console.log(`elements=${elements}`)
    }
    ckt_store.set(ckt);
    elements_store.set(elements);
    return res2;
  }
  let files;
  export let data;
  function fakeOpen(file) {
    alert(`you have chosen ${file}`);
  }
  let scoops = data.props.ckt;
  import { ckt_name, dir_name, probes_name, ckt_store, elements_store } from "./stores.js";
  let probes;
  probes_name.subscribe((value) => {
    probes = value;
  });
  let ckt;
  ckt_store.subscribe((value) => {
    ckt = value;
  });
  let elements = {};
  elements_store.subscribe((value) => {
    elements = value;
  });
  
  let traces = "";
  let showup = false;
  if (scoops != undefined) {
    openLTspice(data.props.wdir, scoops, showup);
  }
  function push_button(node) {
    console.log(`${probes}, ${node}`);
    if (probes == null || probes == undefined || probes == "") {
      probes = node;
    } else {
      probes = probes + ", " + node;
    }
    probes_name.set(probes);
  }
  function switch_wdir(wdir){
    goto('/development/test3?wdir=' + wdir);
  }
  async function save_settings(data){
    const props = data.props
    console.log("gave up");
    console.log(JSON.stringify({props}));
    const response = await fetch('/development/test3/settings', {
      method: 'POST',
      body: JSON.stringify(props),
      headers: {
        'Content-Type': 'application/json'
      }
    })
  }
</script>

<h2>
  Work directory: <input bind:value={data.props.wdir} style="border:darkgray solid 1px;width: 50%;"/>
  <button on:click={switch_wdir(data.props.wdir)} class="button-1">Switch Wdir</button>
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
  <button
    on:click = {save_settings(data)}
    class="button-1">
    Save settings</button>
  <ConvertSchematic />
</div>
{#if ckt != undefined}
  <!-- div style="border:red solid 2px;">
    {#each Object.entries(ckt.elements) as [elm, props]}
      <div>{elm}:{get_control(props)}({elements[elm]})</div>
    {/each}
  </div -->
  <div style="border:red solid 2px;">
    {#each Object.entries(elements) as [elm]}
      <label
        >{elm}:
        <input
          style="border:darkgray solid 1px;"
          bind:value={elements[elm]}
        /><br /></label
      >
    {/each}
  </div>
  <!-- div class="grid">
    <textarea bind:value={elements_text} />
  </div -->
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
