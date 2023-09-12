<script>
  	import {ckt_name, dir_name} from './stores.js';
    async function openLTspice(dir, file) {
        ckt_name.set(file.replace(/\.*$/, ''));
        dir_name.set(dir);
        console.log(`openLTspice dir='${dir}' file='${file}'`);
        const encoded_params = `dir=${encodeURIComponent(dir)}&file=${encodeURIComponent(file)}`;
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
    export let program;
    let traces = '';
    $: program = `
$:.unshift File.join(ENV['HOME'], '/work/alb2/lib')
$:.unshift '.'
puts "hello world from ruby"
puts $0
work_dir = File.dirname $0
Dir.chdir(work_dir){
puts Dir.pwd
require 'compact_model'
require 'lib_util'
require 'ltspice'
require 'postprocess'
require 'ltspctl'
ckt = LTspiceControl.new '${ckt}.asc'
#ckt.open
puts "simulate '${ckt}.asc'"
ckt.simulate
puts "simulation done"
vars, traces = ckt.get_traces ${traces}
ckt.save_traces vars, traces, '${ckt}.json'
puts "got traces"
}
    `;    
</script>
<h2>
	Work directory: {data.props.wdir}
</h2>
<div class="sample">
{#each data.props.files as file}
  <label class="box-item">
	<input
	  type="radio"
	  name="scoops"
	  value={file}
      bind:group={scoops}
	/>
	{file}<br/>
  </label>
  {/each}
</div>
<div><button on:click={openLTspice(data.props.wdir, scoops)}>  Click here to Open LTspice</button></div>
<!-- input bind:files id="many" multiple type="file" / -->
{#if ckt != undefined}
   <div style="border:red solid 5px;">
   {#each Object.entries(ckt.elements) as [elm, props]}
     <div>{elm}:{props.value}</div>
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
    flex-wrap:wrap;
    border:green solid 5px;
    height:200px;
    /* background:yellow; */
    overflow: scroll;
  }
  .box-item{
      width: 25%;
      background:orange;
      text-align: left;
      padding:5px 10px;
      border:5px solid #ddd;
    }    
</style>
