<script>
    import { onMount } from "svelte"
  
    let files;
    let texts;
    $: if (files) {
      console.log(files);
      for (const file of files) {
        console.log(`${file.name}: ${file.size} bytes`);
      }
    }

    const fetchText = async function(file) {
      const text = await file.text();
      return text;
    }
  
  </script>
  
  <p>...from test</p>
  
  <input type='file' bind:files>
  
  {#if files}
      <h2>Selected files:</h2>
      {#each Array.from(files) as file,i}
          <p>{file.name} ({file.size} bytes)</p>
          <p>e: 
              {#await fetchText(file)}
              <p>loading ...</p>
              {:then text}
              {text}
              {/await}
             i: {i}</p>
      {/each}
      <p>files length: {files.length}</p>
  {/if}