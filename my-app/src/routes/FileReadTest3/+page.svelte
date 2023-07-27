<script>
    //import { onMount } from "svelte"
  
    let files;
    let texts = [];
    let text;
    $: if (files) {
      console.log(files);
      for (const file of files) {
        console.log(`${file.name}: ${file.size} bytes`);
        (async () => {
          //const text = await fetchText(file);
          text = await file.text();
          texts.push(text);
          texts = texts; // necessary to make texts reactive
          console.log('text=' + text);
          //texts.push(text);
          //file.data = text; // this did not work
          //console.log('text=' + file.data);
        })()
          //console.log('result=' + result);
        //texts.push(result);
      }
    }
    /*
    function fetchText(file) {
      let text = file.text();
      return text;
    }
    */
  </script>
  
  <p>...from test</p>
  
  <input type='file' bind:files>
  
  {#if files}
      <h2>Selected files:</h2>
      {#each Array.from(files) as file,i}
          <p>{file.name} ({file.size} bytes)</p>
          <p>e: {texts[i]}              
             i: {i}</p>
      {/each}
      <p>files length: {files.length}</p>
  {/if}