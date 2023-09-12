<script>
   	import {ckt_name, dir_name} from './stores.js';
    let file;
    let dir;
    ckt_name.subscribe((value) => {
      file = value;
    })
    dir_name.subscribe((value) => {
      dir = value;
    })
    import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();
    
    async function goLTspice() {
        console.log(`openLTspice dir='${dir}' ckt='${file}'`);
        const encoded_params = `dir=${encodeURIComponent(dir)}&file=${encodeURIComponent(file)}`;
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/simulate?${encoded_params}`,
            {}
        );
        let res2 = await response.json();
        console.log(res2);
        dispatch('sim_end', {text: 'LTspice simulation ended!'});
        // plotdata = get_results();
        return res2;
    }
    
</script>

<div>
    <button on:click={goLTspice}>
        Click here to Start LTspice simulation</button
    >
</div>
