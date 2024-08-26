<script>
    export let plot_data;
    export let title, performance;
    let sweep, value;
    function get_sweep() {
      [sweep, value] = plot_data.name.split('=');
      sweep.trim();
    }
    </script>

<Plot
    data={plot_data}
    layout={{
        title: {title},
        xaxis: {
            title: {get_sweep()},
            autorange: "true",
            linewidth: 1,
            mirror: true,
        },
        yaxis: {
            title: {performance},
            autorange: "true",
            linewidth: 1,
            mirror: true,
        },
    }}
    fillParent="width"
    debounce={250}
/>
