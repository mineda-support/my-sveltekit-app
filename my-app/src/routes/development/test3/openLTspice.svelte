<script>
    async function openLTspice(dir, file) {
        console.log(`openLTspice dir='${dir}' file='${file}'`);
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/open?dir=${dir}&file=${file}`,
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
