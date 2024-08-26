<script>
    import Plot from "svelte-plotly.js";

    export let plotdata;
    export let measdata;
    export let settings;
</script>

<Plot
data={plotdata.concat(measdata.filter((trace) => trace.checked))}
layout={{
    title: settings.title,
    xaxis: {
        type: settings.xaxis_is_log ? "log" : "",
        autorange: "true",
        title: settings.title_x,
    },
    yaxis: {
        type: settings.yaxis_is_log ? "log" : "",
        autorange: "true",
        title: settings.title_y,
    },
    margin: { t: 30 },
}}
fillParent="width"
debounce={250}
/>