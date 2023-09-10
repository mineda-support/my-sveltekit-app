<script>
    import { createEventDispatcher } from "svelte";

    const dispatch = createEventDispatcher();

    async function goLTspice() {
        let response = await fetch(
            "http://localhost:9292/api/ltspctl/simulate",
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
