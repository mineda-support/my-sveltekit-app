<script lang="ts">
    import Plot from 'svelte-plotly.js';
    // import data from './data.js'
    let text = "1\t2\n3\t4\n5\t1";

   function load_data(text) {
     let data = {x: [], y: []};
     let lines = text.split("\n");
     let a, b;
     for (let line of lines) {
       console.log('line:'+line);
       //[a, b] = line.replace(/ +/, ' ').split(' ').map(a => Number(a));
       [a, b] = line.split("\t").map(a => Math.abs(Number(a)));
       data.x.push(a);
       data.y.push(b);
     };
     console.log(data);
     return data;
    }

    $: data = load_data(text);
  </script>
  <textarea bind:value={text} />
 
  <style>
    textarea {
      width: 100%;
      height: 200px;
    }
  </style>

  <Plot
    data = {[data]}
    layout={{ yaxis: { type: 'log', autorange: 'true'},
      margin: { t: 0 }
    }}
    fillParent='width'
    debounce={250}
  />