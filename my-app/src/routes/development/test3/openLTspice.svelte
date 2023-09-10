<script>
    async function openLTspice(file) {
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/open?file=${file}`,
            {}
        );
        let res2 = await response.json();
        console.log(res2);
        return res2;
    }
    let files;
    export let data;
    function fakeOpen(file){
        alert(`you have chosen ${file}`);
    }
    let scoops;
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

<div><button on:click={openLTspice(scoops)}>  Click here to Open LTspice</button></div>
<!-- input bind:files id="many" multiple type="file" / -->
