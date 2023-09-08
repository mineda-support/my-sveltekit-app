<script lang="ts">
  import { onMount } from "svelte";
  import Lsm_fit from "./lsm_fit.svelte";

  let files = [];
  let texts = [];
  $: if (files) {
    console.log(files);
    for (const file of files) {
      console.log(`${file.name}: ${file.size} bytes`);
    }
  }

  let text_data = "1\t2\n3\t4\n5\t1";
  let start = 0;
  let stop = text_data.length;
  let left = 0;
  let right = 1;
  function load_data(text, start, stop, left, right) {
    let data = { x: [], y: [] };
    let lines = text.split("\n");
    let a, b;
    /* for (let line of lines) { */
    for (let i = 0; i < lines.length; i++) {
      if (i < start || i > stop) continue;
      let line = lines[i];
      if (line.length == 0) continue;
      // console.log("line:" + line);
      //[a, b] = line.replace(/ +/, ' ').split(' ').map(a => Number(a));
      console.log(line);
      [a, b] = line
        .split(/[\t ,] */)
        .map((a) => Math.abs(Number(a)))
        .slice(left, right + 1);
      data.x.push(a);
      data.y.push(b);
    }
    console.log(data);
    return data;
  }
  //$: data = load_data(text_data, start, stop);
  let data;
  $: if (files && files.size > 0) {
    text_data = texts[0];
    data = load_data(text_data, start, stop, left, right);
  } else {
    data = load_data(text_data, start, stop, left, right);
  }

  async function do_lsm_fit() {
    //console.log("start,stop,left,right"=[start,stop,left,right]);
    text_data = await files[0].text();
    console.log("text_data=" + text_data);
    data = load_data(text_data, start, stop, left, right);

    return (fit_data = lsm_fit(data, xmin, xmax));
  }
</script>

<input type="file" bind:files />
<button on:click={do_lsm_fit}>LSM FIT</button>

<div>
  <label>start line: <input type="number" bind:value={start} /></label>
  <label>stop line: <input type="number" bind:value={stop} /></label>
  <label>left column: <input type="number" bind:value={left} /></label>
  <label>right column: <input type="number" bind:value={right} /></label>
</div>

{#if files}
  <h2>Selected files:</h2>
  {#each Array.from(files) as file, i}
    <p>{file.name} ({file.size} bytes)</p>
    {#await file.text() then text}
      <p>e: {"text"} i: {i}</p>
    {/await}
  {/each}
  <p>files length: {files.length}</p>
{/if}

<textarea bind:value={text_data} />
<Lsm_fit data={data}/>

<style>
  textarea {
    width: 100%;
    height: 200px;
  }
</style>
