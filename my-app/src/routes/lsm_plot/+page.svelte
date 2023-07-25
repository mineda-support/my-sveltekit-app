<script lang="ts">
    import Plot from 'svelte-plotly.js';
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

    const coordinates = [];
    // 回帰直線を求める（最小二乗法）
    const lsm = coordinates => {
      const n = coordinates.length
      const sigX = coordinates.reduce((acc, c) => acc + c.x, 0)
      const sigY = coordinates.reduce((acc, c) => acc + c.y, 0)
      const sigXX = coordinates.reduce((acc, c) => acc + c.x * c.x, 0)
      const sigXY = coordinates.reduce((acc, c) => acc + c.x * c.y, 0)
      // a(傾き)を求める
      const a = (n * sigXY - sigX * sigY) / (n * sigXX - Math.pow(sigX, 2));
      // b(切片)を求める
      const b = (sigXX * sigY - sigXY * sigX) / (n * sigXX - Math.pow(sigX, 2));
      return { a, b }
    }
    function lsm_fit(data){
      const coordinates = [];
      for (let i = 0; i < data.x.length; i++){
        coordinates.push({x: data.x[i], y: Math.log10(data.y[i])});
      }
      const {a, b} = lsm(coordinates); // y = a*x + b
      console.log('a=', a, ' b=',b);
      let sim_data = {x:[], y:[]};
      for (let c of coordinates) {
          sim_data.x.push(c.x);
          console.log([c.x, a*(c.x)+b]);
          sim_data.y.push(a*(c.x)+b);
      }
      console.log(sim_data);
      return sim_data;
    }
    $: fit_data = lsm_fit(data);
    
</script>
  <textarea bind:value={text} />
 
  <style>
    textarea {
      width: 100%;
      height: 200px;
    }
  </style>

  <Plot
    data = {[data, fit_data]}
    layout={{ yaxis: { type: 'log', autorange: 'true'},
      margin: { t: 0 }
    }}
    fillParent='width'
    debounce={250}
  />