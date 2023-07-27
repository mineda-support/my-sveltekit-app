<script>
    import { onMount } from "svelte"
    // d3.csv(' http://127.0.0.1:8081/test.csv').then(function(data) {
    //   console.log(data[0])})
  
    let files;
    $: if (files) {
      console.log(files);
      for (const file of files) {
        console.log(`${file.name}: ${file.size} bytes`);
      }
    }
  
  </script>
  
  <p>...from test</p>
  
  <input type='file' bind:files>
  
  {#if files}
      <h2>Selected files:</h2>
      {#each Array.from(files) as file,i}
          <p>{file.name} ({file.size} bytes)</p>
          {#await file.text() then text}
                  <p>e: {text} i: {i}</p>
          {/await}
      {/each}
      <p>files length: {files.length}</p>
  {/if}