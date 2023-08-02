<script lang="ts">
  //import { findBestTextLocation } from "plotly.js-dist";
  import Plot from "svelte-plotly.js";

  let files = [];
  let texts = [];
  $: if (files) {
    console.log(files);
    for (const file of files) {
      console.log(`${file.name}: ${file.size} bytes`);
      /*
      (async () => {
        //const text = await fetchText(file);
        let text = await file.text();
        texts.push(text);
        texts = texts; // necessary to make texts reactive
      })();
      */
    }
  }

  let text_data = "1\t2\n3\t4\n5\t1";
  let start = 0;
  let stop = text_data.length;
  let left;
  let right;
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
  //const coordinates = [];
  // 回帰直線を求める（最小二乗法）
  const lsm = (coordinates) => {
    const n = coordinates.length;
    const sigX = coordinates.reduce((acc, c) => acc + c.x, 0);
    const sigY = coordinates.reduce((acc, c) => acc + c.y, 0);
    const sigXX = coordinates.reduce((acc, c) => acc + c.x * c.x, 0);
    const sigXY = coordinates.reduce((acc, c) => acc + c.x * c.y, 0);
    // a(傾き)を求める
    const a = (n * sigXY - sigX * sigY) / (n * sigXX - Math.pow(sigX, 2));
    // b(切片)を求める
    const b = (sigXX * sigY - sigXY * sigX) / (n * sigXX - Math.pow(sigX, 2));
    return { a, b };
  };
  let is;
  let nvt;
  function lsm_fit(data, xmin, xmax) {
    const coordinates = [];
    for (let i = 0; i < data.x.length; i++) {
      if (data.x[i] < xmin || data.x[i] > xmax) continue;
      coordinates.push({ x: data.x[i], y: Math.log10(data.y[i]) });
    }
    const { a, b } = lsm(coordinates); // y = a*x + b
    console.log("data=", data);
    console.log("coordinates=", coordinates);
    console.log("a=", a, " b=", b);
    is = 10 ** b;
    nvt = Math.log10(Math.E) / a;
    console.log("is=", is, " nvt=", nvt);

    let sim_data = { x: [], y: [] };
    for (let c of coordinates) {
      sim_data.x.push(c.x);
      sim_data.y.push(is * Math.exp(c.x / nvt));
    }
    console.log(sim_data);
    return sim_data;
  }

  let xmin;
  let xmax;

  $: fit_data = lsm_fit(data, xmin, xmax);
  async function do_lsm_fit() {
    //console.log("start,stop,left,right"=[start,stop,left,right]);
    text_data = await files[0].text();
    console.log("text_data="+text_data);
    data = load_data(text_data, start, stop, left, right);

    return fit_data = lsm_fit(data, xmin, xmax);
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
      <p>e: {text} i: {i}</p>
    {/await}
  {/each}
  <p>files length: {files.length}</p>
{/if}

<textarea bind:value={text_data} />

<div>
  <label
    >xmin: <input
      type="number"
      step="0.01"
      bind:value={xmin}
      placeholder={data.x[0]}
    /></label
  >
  <label
    >xmax: <input
      type="number"
      step="0.01"
      bind:value={xmax}
      placeholder={data.x[data.x.length - 1]}
    /></label
  >
</div>

<label>is = {is} nvt = {nvt}</label>
<Plot
  data={[data, fit_data]}
  layout={{ yaxis: { type: "log" }, margin: { t: 0 } }}
  fillParent="width"
  debounce={250}
/>

<style>
  textarea {
    width: 100%;
    height: 200px;
  }
</style>
