<script context="module">
    function get_sweep_values(plotdata) {
        let values = [];
        let sweep, value;
        console.log("plotdata in get_sweep_values=", plotdata);
        plotdata.forEach((trace) => {
            [sweep, value] = trace.name.split("=");
            values.push(Number(value));
        });
        return values;
    }

    function get_performance(rows, index) {
        let values = [];
        rows.forEach((row) => {
            values.push(row[index]);
        });
        return values;
    }
</script>

<script>
    import BodePlot from "./utils/bode_plot.svelte";
    import SinglePlot from "./utils/single_plot.svelte";
    import { set_trace_names } from "./experiment.svelte";
    import Settings from "./settings.svelte";

    export let dir, file, measfile, plot_showhide, plot_number;
    export let reject, reverse, tracemode;
    export let title, title_x, title_y, title_y1, title_y2;
    export let equation, probes, performance_names;
    export let xaxis_is_log, yaxis_is_log;
    export let step_precision, calculated_value;
    export let plotdata, db_data, ph_data, measdata;
    export let results_data, elements;

	let sweep_name;
    let performances;
	$: {
		if (performance_names != undefined) {
			performances = Array.isArray(performance_names)
				? performance_names
				: performance_names.split(",").map((a) => a.trim());
		}
	}

    const options = {
        types: [
            {
                description: "CSV Files",
                accept: {
                    "text/plain": [".csv", ".txt", ".text"],
                },
            },
        ],
    };
    async function measurement_results(
        measfile,
        reject_list,
        reverse,
        tracemode,
    ) {
        if (measfile == undefined || measfile == "") {
            const [handle] = await window.showOpenFilePicker(options);
        }
        console.log(measfile);
        console.log(`reverse=${reverse}, tracemode: ${tracemode}`);
        //console.log(handle.name);
        //const file = await handle.getFile();
        //console.log(file);
        const encoded_params = `dir=&file=${encodeURIComponent(measfile)}&reject=${reject_list}`;
        let response = await fetch(
            `http://localhost:9292/api/misc/measured_data?${encoded_params}`,
            {},
        );
        let res2 = await response.json();
        measdata = reverse ? res2.traces.reverse() : res2.traces;
        for (const trace of measdata) {
            trace.checked = true;
            trace.mode = tracemode;
        }
        console.log("measdata:", measdata);
    }

    async function plot_result(event) {
        // cookies.et('probes', probes, { path: '/conditions'});
        console.log(
            `Plot results@dir='${dir}' file='${file}' probes=${probes}`,
        );
        if (probes == undefined) {
            alert("Simulation completed but probes for plot are not defined");
            return;
        }
        if (probes != probes.trim()) {
            alert("probes have unwanted leading space(s)");
            return;
        }
        const encoded_params = `dir=${encodeURIComponent(
            dir,
        )}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
            probes,
        )}&equation=${encodeURIComponent(equation)}`;
        let response = await fetch(
            `http://localhost:9292/api/ltspctl/results?${encoded_params}`,
            {},
        );
        let res2 = await response.json();
        console.log(res2);
        [plotdata, db_data, ph_data, sweep_name] = set_trace_names(
            res2,
            probes,
            elements,
            step_precision,
        );
    }

    step_precision = 3;
    yaxis_is_log = false;
    xaxis_is_log = false;
    function clear_plot() {
        plotdata = db_data = ph_data = undefined;
    }
    function clear_measdata() {
        measdata = [];
    }
    function checkall_measdata() {
        console.log(measdata);
        for (const trace of measdata) {
            trace.checked = true;
        }
    }

    function calculate_equation() {
        submit_equation(
            equation,
            dir,
            file,
            plotdata,
            db_data,
            ph_data,
            (measdata == undefined) ? [] : measdata.filter((trace) => trace.checked),
        );
        console.log("values in calculate_equation:", calculated_value);
        const equation_array = equation.split(",");
        if (performances == undefined) {
            alert('Performance name(s) for equation(s) not defined');
            return;
        }
        performances.forEach(function (perf, index) {
            //console.log("perf, index=", [perf, index]);
            //console.log('results_data:', results_data);
            //if (calculated_value != undefined) {
            if (results_data[0][perf] == undefined) {
                results_data[0][perf] = [];
            }
            results_data[0][perf].push({
                x: get_sweep_values(plotdata != undefined ? plotdata : db_data),
                y: get_performance(calculated_value, index),
                name: equation_array[index],
            });
            //} else {
            //	console.log('Error: calculate value is not available yet');
            //}
            //console.log(`results_data[0][${perf}]=`, results_data[0][perf]);
        });
        results_data[0] = results_data[0];
        console.log("results_data=", results_data);
    }

    async function submit_equation(
        equation,
        dir,
        file,
        plotdata,
        db_data,
        ph_data,
        measdata,
    ) {
        const encoded_params = `dir=${encodeURIComponent(
            dir,
        )}&file=${encodeURIComponent(file)}`;
        console.log(`equation to send: ${equation}`);
        console.log(
            "plotdata:",
            plotdata,
            "db_data:",
            db_data,
            "ph_data:",
            ph_data,
        );
        const res = await fetch(
            `http://localhost:9292/api/ltspctl/measure?${encoded_params}`,
            {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({
                    equation: equation,
                    plotdata: plotdata ? plotdata.concat(measdata) : [],
                    db_data: db_data ? db_data : [],
                    ph_data: ph_data ? ph_data : [],
                }),
            },
        );
        let result = await res.json();
        //console.log('result in submit_equation:', result);
        if (plotdata != undefined) {
            calculated_value = result.calculated_value.slice(
                0,
                plotdb_datadata.length,
            );
            if (measdata.length > 0) {
                alert(
                    result.calculated_value.slice(plotdata.length).join("\n"),
                );
            }
        } else {
            calculated_value = result.calculated_value.slice(0);
        }
        console.log(calculated_value);
        // return calculated_value; // maybe useless
    }
    equation = "x.where(y, 2.5){|x, y| x > 1e-6}";
</script>

<button on:click={() => (plot_showhide = !plot_showhide)} class="button-2"
    >Show/hide</button
> {plot_number}
{#if plot_showhide}
    <div>
        <button
            on:click={measurement_results(
                measfile.trim().replace(/^"/, "").replace(/"$/, ""),
                reject,
                reverse,
                tracemode,
            )}
            class="button-1">Get measured data:</button
        >
        <input
            bind:value={measfile}
            style="border:darkgray solid 1px;width: 40%;"
        />
        <label
            >Reject:<input
                bind:value={reject}
                style="border:darkgray solid 1px;"
            /></label
        >
        <label>Reverse<input type="checkbox" bind:checked={reverse} /></label>
        <button>Trace mode</button>
        <input name="tracemodes" value={tracemode} type="hidden" />
        <select bind:value={tracemode} style="border:darkgray solid 1px;">
            <option value="lines">lines</option>
            <option value="markers">markers</option>
            <option value="lines+markers">lines+markers</option>
        </select>
    </div>
    <button on:click={plot_result} class="button-1">Plot with probes:</button>
    <input bind:value={probes} style="border:darkgray solid 1px;" />
    {#if probes == undefined || !probes.startsWith("frequency")}
        <label>
            <input type="checkbox" bind:checked={xaxis_is_log} />
            xaxis is log
        </label>
        <label>
            <input type="checkbox" bind:checked={yaxis_is_log} />
            yaxis is log
        </label>
    {/if}
    <label>
        <button on:click={clear_plot} class="button-1">clear</button>
    </label>
    <label
        >step precision:
        <input bind:value={step_precision} />
    </label>
    <div>
        <label
            >Title
            <input bind:value={title} style="border:darkgray solid 1px;" />
        </label>
        <label
            >X title
            <input bind:value={title_x} style="border:darkgray solid 1px;" />
        </label>
        {#if probes == undefined || !probes.startsWith("frequency")}
            <label
                >Y title
                <input
                    bind:value={title_y}
                    style="border:darkgray solid 1px;"
                />
            </label>
        {:else}
            <label
                >Y1 title
                <input
                    bind:value={title_y1}
                    style="border:darkgray solid 1px;"
                />
            </label>
            <label
                >Y2 title
                <input
                    bind:value={title_y2}
                    style="border:darkgray solid 1px;"
                />
            </label>
        {/if}
    </div>
{/if}
{#if plotdata !== undefined}
    <SinglePlot
        {plotdata}
        {measdata}
        {title}
        {title_x}
        {title_y}
        {xaxis_is_log}
        {yaxis_is_log}
    />
{/if}
{#if probes != undefined && probes.startsWith("frequency") && db_data !== undefined && ph_data !== undefined}
    <BodePlot {db_data} {ph_data} {title} {title_x} {title_y1} {title_y2} />
{/if}

{#if measdata != undefined && measdata != "" && measdata != []}
    <div style="border:green solid 2px;">
        {#each measdata as trace}
            <label
                >{trace.name}
                <input
                    style="border:darkgray solid 1px;"
                    type="checkbox"
                    bind:checked={trace.checked}
                />
            </label>
        {/each}
        <button on:click={checkall_measdata} class="button-1">check all</button>
        <button on:click={clear_measdata} class="button-1">clear all</button>
    </div>
{/if}
{#if plot_showhide}
    <div>
        <label>
            Performance name(s)
            <input
                bind:value={performance_names}
                style="border:darkgray solid 1px;"
            />
        </label>
    </div>

    <div>
        <label
            >Equation(s)
            <input bind:value={equation} style="border:darkgray solid 1px;" />
            <button
                on:click={calculate_equation(results_data[0])}
                class="button-1"
            >
                Calculate</button
            >
            {#if Array.isArray(calculated_value)}
                <table>
                    <tr>
                        {#each performances as perf}
                            <th>{perf}</th>
                        {/each}
                    </tr>
                    {#each calculated_value as vals}
                        <tr>
                            {#each vals as val}
                                <td>{val}</td>
                            {/each}
                        </tr>
                    {/each}
                </table>
            {/if}
        </label>
    </div>
    <hr>
{/if}

<style>
</style>
