<script>
    async function openLTspice(dir, file) {
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
    import path from 'path';
    let ckt;
</script>
<h2>
	{data.props.wdir}
	{data.title}
	{data.body}
</h2>
{#each data.props.files as file}
  <label>
	<input
	  type="radio"
	  name="scoops"
	  value={file}
      bind:group={scoops}
	/>
	{file}<br/>
  </label>
  {/each}

<div><button on:click={openLTspice(data.props.wdir, scoops)}>  Click here to Open LTspice</button></div>
<!-- input bind:files id="many" multiple type="file" / -->
{#if ckt != undefined}
   <div>
   {#each Object.entries(ckt.elements) as [elm, props]}
     <div>{elm}:{props.value}</div>
   {/each}
  </div> 
   <div>
   {#each ckt.info as node}
     <div>{node}</div>
   {/each}
  </div>
{/if}
