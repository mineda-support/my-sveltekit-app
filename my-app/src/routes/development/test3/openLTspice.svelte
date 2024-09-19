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
  // import { end_hydrating } from "svelte/internal";
  import { createEventDispatcher } from "svelte";
  export let data;
  export let probes;

  const dispatch = createEventDispatcher();

  async function openLTspice(dir, file, showup) {
    if (file == undefined) {
      alert("Please choose the circuit to open");
      return;
    }
    ckt_name.set(file);
    dir_name.set(dir);
    console.log(`openLTspice dir='${dir}' file='${file}'`);
    let encoded_params;
    if (showup) {
      encoded_params = `dir=${encodeURIComponent(
        dir,
      )}&file=${encodeURIComponent(file)}&showup=true`;
    } else {
      encoded_params = `dir=${encodeURIComponent(
        dir,
      )}&file=${encodeURIComponent(file)}`;
    }
    console.log(encoded_params);
    let response = await fetch(
      `http://localhost:9292/api/ltspctl/open?${encoded_params}`,
      {},
    );
    let res2 = await response.json();
    console.log(res2);
    console.log("probes:", probes);
    if (probes != undefined) {
      // goLTspice();
      // plot_result();
      dispatch("open_end", { text: "fake simulation ended!" });
    }
    ckt = res2;
    console.log("ckt=", ckt);
    if (ckt != undefined) {
      elements = {};
      for (const [ckt_name, elms] of Object.entries(ckt.elements)) {
        console.log(ckt_name, "=", elms);
        if (ckt_name[0] == ".") {
          console.log("skip:", ckt_name);
          continue;
        }
        elements[ckt_name] = {};
        for (const [elm, props] of Object.entries(elms)) {
          //console.log([elm, props]);
          elements[ckt_name][elm] = get_control(props);
        }
      }
      console.log("elements=", elements);
      models = {};
      for (const [model_name, model_params] of Object.entries(ckt.models)) {
        console.log(model_name, "=", model_params[1]);
        models[model_name] = {};
        for (const [par, value] of Object.entries(model_params[1])) {
          models[model_name][par] = value;
        }
      }
      console.log("models=", models);
    }
    ckt_store.set(ckt);
    elements_store.set(elements);
    models_store.set(models);
    alter = [{}];
    alter_src = undefined;
    return res2;
  }

  function fakeOpen(file) {
    alert(`you have chosen ${file}`);
  }
  let scoops;
  if (data.props != undefined && data.props.ckt != undefined) {
    scoops = data.props.ckt;
  }
  import {
    ckt_name,
    dir_name,
    ckt_store,
    elements_store,
    models_store,
  } from "./stores.js";
  let ckt;
  ckt_store.subscribe((value) => {
    ckt = value;
  });
  let elements = {};
  elements_store.subscribe((value) => {
    elements = value;
  });
  let models = {};
  models_store.subscribe((value) => {
    models = value;
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
  }
  function switch_wdir(wdir) {
    //const handle = await window.showDirectoryPicker();
    //wdir = handle.name; # does not return path
    goto("/development/test3?wdir=" + wdir);
  }
  let alter_src;
  let alter = [{}];
  let c, e;
  $: {
    if (alter_src != undefined) {
      [c, e] = alter_src.split(":");
      if (alter[0][alter_src] == undefined) {
        alter[0][alter_src] = elements[c][e];
      }
    }
  }

  function add_alter() {}

  function check_alter() {
    console.log("alter=", alter);
  }
  let variations={};
</script>

<h2>
  Work directory:
  {#if data.props != undefined}
    <input
      bind:value={data.props.wdir}
      style="border:darkgray solid 1px;width: 50%;"
    />
  {/if}
  <button on:click={switch_wdir(data.props.wdir)} class="button-1"
    >Switch Wdir</button
  >
</h2>
<div class="sample">
  {#if data.props != undefined}
    {#each data.props.files as file}
      <label class="box-item">
        <input type="radio" name="scoops" value={file} bind:group={scoops} />
        {file}<br />
      </label>
    {/each}
  {/if}
</div>
<div>
  <button
    on:click={openLTspice(data.props.wdir, scoops, showup)}
    class="button-1"
  >
    Click here to read-in</button
  >
  <label>
    <input type="checkbox" bind:checked={showup} />
    show schematic
  </label>
  <!-- ConvertSchematic / -->
</div>
{#if ckt != undefined}
  <!-- div style="border:red solid 2px;">
    {#each Object.entries(ckt.elements) as [elm, props]}
      <div>{elm}:{get_control(props)}({elements[elm]})</div>
    {/each}
  </div -->
  <div class="tab-wrap">
    <input
      id="TAB-01"
      type="radio"
      name="TAB"
      class="tab-switch"
      checked="checked"
    />
    <label class="tab-label" for="TAB-01">Circuit info</label>
    <div class="tab-content" style="border:red solid 2px;">
      {#each Object.entries(elements) as [ckt_name, elms]}
        [{ckt_name}]<br />
        {#each Object.entries(elms) as [elm]}
          <label
            >{elm}:
            <input
              style="border:darkgray solid 1px;"
              bind:value={elements[ckt_name][elm]}
            /><br /></label
          >
        {/each}
      {/each}
    </div>
    <input id="TAB-02" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="TAB-02">SPICE models</label>
    <div class="tab-content" style="border:green solid 2px;">
      {#each Object.entries(models) as [model_name, model_params]}
        [{model_name}]<br />
        {#each Object.entries(model_params) as [param]}
          <label
            >{param}:
            <input
              style="border:darkgray solid 1px;"
              bind:value={models[model_name][param]}
            /><br /></label
          >
        {/each}
      {/each}
    </div>
    <input id="TAB-03" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="TAB-03">Alter</label>
    <div class="tab-content" style="border:blue solid 2px;">
      <div>Add Alter</div>
      <select bind:value={alter_src} style="border:darkgray solid 1px;">
        {#each Object.entries(elements) as [ckt_name, elms]}
          {#each Object.keys(elms) as elm}
            <option value={[ckt_name, elm].join(":")}
              >{[ckt_name, elm].join(":")}</option
            >
          {/each}
        {/each}
      </select>
      <input
        style="border:darkgray solid 1px;"
        bind:value={alter[0][alter_src]}
      /><br />
      <button on:click={add_alter} class="button-item">New Tab</button>
      <button on:click={check_alter} class="button-item">Check Alter</button>
    </div>
    <input id="TAB-04" type="radio" name="TAB" class="tab-switch" />
    <label class="tab-label" for="TAB-04">Variation</label>
    <div class="tab-content" style="border:yellow solid 2px;">
      <div>Add Variation</div>
      <div>
        {#each Object.entries(elements) as [ckt_name, elms]}
          {#each Object.entries(elms) as [elm]}
            {#if elm.match(/#$/)}
              <div>{elm}</div>
            {/if}
          {/each}
        {/each}
      </div>
      <input
        style="border:darkgray solid 1px;"
        bind:value={alter[0][alter_src]}
      /><br />
      <button on:click={add_alter} class="button-item">New Tab</button>
      <button on:click={check_alter} class="button-item">Check Alter</button>
    </div>    
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
  .tab-wrap {
    display: flex;
    flex-wrap: wrap;
  }
  .tab-label {
    color: White;
    background: LightGray;
    margin-right: 5px;
    padding: 3px 12px;
    order: -1;
  }
  .tab-content {
    width: 100%;
    display: none;
  }
  /* アクティブなタブ */
  .tab-switch:checked + .tab-label {
    background: DeepSkyBlue;
  }
  .tab-switch:checked + .tab-label + .tab-content {
    display: block;
  }
  /* ラジオボタン非表示 */
  .tab-switch {
    display: none;
  }
</style>
