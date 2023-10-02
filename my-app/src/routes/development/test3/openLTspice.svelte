<script>
  	import {ckt_name, dir_name} from './stores.js';
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
          encoded_params = `dir=${encodeURIComponent(dir)}&file=${encodeURIComponent(file)}&showup=true`;
        } else {
          encoded_params = `dir=${encodeURIComponent(dir)}&file=${encodeURIComponent(file)}`;
        }
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/open?${encoded_params}`,
            {}
        );
        let res2 = await response.json();
        console.log(res2);
        ckt = res2;
        return res2;
    }
    let files;
    export let data;
    function fakeOpen(file){
        alert(`you have chosen ${file}`);
    }
    let scoops;
    let ckt;
    let ckt_store;
    ckt_name.subscribe((value) => {
      ckt_store = value;
    })
    let traces = '';
    let showup = false;
    function get_control(props){
      if (Array.isArray(props)){
        return props[0].control;
      } else {
        return props.value;
      }
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
  <button on:click={openLTspice(data.props.wdir, scoops, showup)}>
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
      <div>{node}</div>
    {/each}
  </div>
{/if}

<style>
  .sample {
    display: flex;
    flex-wrap: wrap;
    border: green solid 5px;
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
</style>
