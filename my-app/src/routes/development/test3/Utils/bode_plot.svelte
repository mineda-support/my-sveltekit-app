<script>
    import Plot from "svelte-plotly.js";
    
    export let settings;
    export let db_data;
    export let ph_data;
</script>

<Plot
    data={db_data}
    layout={{
        title: settings.title,
        xaxis: {
            type: "log",
            autorange: "true",
            linewidth: 1,
            mirror: true,
        },
        yaxis: {
            autorange: "true",
            linewidth: 1,
            mirror: true,
            title: settings.title_y1,
        },
        margin: { t: 30 },
    }}
    fillParent="width"
    debounce={250}
/>
<Plot
    data={ph_data}
    layout={{
        xaxis: {
            type: "log",
            autorange: "true",
            linewidth: 1,
            mirror: true,
            title: settings.title_x,
        },
        yaxis: {
            autorange: "true",
            linewidth: 1,
            mirror: true,
            title: settings.title_y2,
        },
        margin: { t: 30 },
    }}
    fillParent="width"
    debounce={250}
/>
