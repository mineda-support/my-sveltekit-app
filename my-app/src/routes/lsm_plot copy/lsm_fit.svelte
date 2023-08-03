  <script lang="ts">
  
  //const coordinates = [];
  // 回帰直線を求める（最小二乗法）
    export const lsm = (coordinates) => {
    // export function lsm(coordinates) {
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
  export function lsm_fit(data, xmin, xmax) {
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
export let xmin;
export let xmax;
//export let data;
//let fit_data = [];

</script>
<div>
  <label
    >xmin: <input
      type="number"
      step="0.01"
      bind:value={xmin}
      placeholder={"data.x[0]"}
    /></label
  >
  <label
    >xmax: <input
      type="number"
      step="0.01"
      bind:value={xmax}
      placeholder={"data.x[data.x.length - 1]"}
    /></label
  >
</div>

<label>is = {is} nvt = {nvt}</label>


