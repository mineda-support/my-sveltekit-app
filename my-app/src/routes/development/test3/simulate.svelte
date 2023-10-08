<script>
    import { ckt_name, dir_name } from "./stores.js";
    let file;
    let dir;
    ckt_name.subscribe((value) => {
        file = value;
    });
    dir_name.subscribe((value) => {
        dir = value;
    });
    import { createEventDispatcher } from "svelte";
    const dispatch = createEventDispatcher();
    export async function goLTspice() {
        console.log(`openLTspice dir='${dir}' file='${file}'`);
        dispatch("elm_update", { text: "Update elements" });
        const my_sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));
        await my_sleep(3000);
        const encoded_params = `dir=${encodeURIComponent(
            dir
        )}&file=${encodeURIComponent(file)}`;
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/simulate?${encoded_params}`,
            {}
        );
        let res2 = await response.json();
        console.log(res2);
        dispatch("sim_end", { text: "LTspice simulation ended!" });
        // plotdata = get_results();
        return res2;
    }
</script>

<div>
    <button on:click={goLTspice} class="button-1">
        Click here to Start LTspice simulation</button
    >
</div>

<style>
	.button-1 {
	  /* width: 25%; */
	  background: lightblue;
	  text-align: left;
	  padding: 5px 10px;
	  border: 5px solid #ddd;
	}
  </style>