<script>
	import { goto } from "$app/navigation";
	import { json } from "@sveltejs/kit";
	// import Testplot, {handleMessage} from "./test_plot.svelte";
	// import { plot_result } from "./test_plot.svelte";
	import Simulate from "./simulate.svelte";
	import ConvertSchematic from "./convertSchematic.svelte";
	import Experiment from "./experiment.svelte";
	// import OpenLTspice, {update_elements} from "./openLTspice.svelte";
	import OpenLTspice, { get_control } from "./openLTspice.svelte";
	import Plot from "svelte-plotly.js";
	import Settings from "./settings.svelte";

	let measdata = [];

	let plotdata;
	$: data.props.plotdata = plotdata;
	let db_data;
	let ph_data;
	export function handleMessage(event) {
		console.log("handleMessage");
		alert(event.detail.text);
		plot_result();
	}
	import {
		ckt_name,
		dir_name,
		probes_name,
		equation_name,
		ckt_store,
		elements_store,
	} from "./stores.js";
	let file;
	let dir;
	let probes;
	let equation;
	let ckt;
	let elements;
	ckt_name.subscribe((value) => {
		file = value;
	});
	dir_name.subscribe((value) => {
		dir = value;
	});
	probes_name.subscribe((value) => {
		probes = value;
	});
	equation_name.subscribe((value) => {
		equation = value;
	});
	ckt_store.subscribe((value) => {
		ckt = value;
	});
	elements_store.subscribe((value) => {
		elements = value;
	});
	elements_store.set({});
	ckt_store.set(undefined);
	// settings_name.set({equation: equation, probes: probes})
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
		const encoded_params = `dir=${encodeURIComponent(
			dir,
		)}&file=${encodeURIComponent(file)}&probes=${encodeURIComponent(
			probes,
		)}`;
		let response = await fetch(
			`http://localhost:9292/api/ltspctl/results?${encoded_params}`,
			{},
		);
		let res2 = await response.json();
		console.log(res2);
		plotdata = res2.traces;
		console.log(`probes=${probes}`);
		if (probes != null && probes.startsWith("frequency")) {
			db_data = res2.db;
			ph_data = res2.phase;
			console.log("db_data=", db_data);
		}
		//return res2;
		calculate_equation();
	}
	export let data;
	//probes_name.set(data.props.probes);
	$: probes_name.set(probes);
	$: data.props.probes = probes;

	let yaxis_is_log = false;
	let xaxis_is_log = false;
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
	async function update_elements(dir) {
		for (const [ckt_name, elms] of Object.entries(ckt.elements)) {
			if (ckt_name[0] == ".") {
				continue;
			}
			let target = ckt_name + ".asc";
			console.log(
				"update elements=",
				elements,
				` here @ dir= ${dir} file=${target}`,
			);
			let update_elms = "";
			for (const [elm, props] of Object.entries(elms)) {
				if (elements[ckt_name][elm] != get_control(props)) {
					update_elms =
						update_elms +
						elm +
						":'" +
						elements[ckt_name][elm] +
						"',";
				}
			}
			if (update_elms != "") {
				console.log("let me update ", target, " with:", update_elms);
				update_elms = encodeURIComponent(`{${update_elms}}`);
				let encoded_params = `dir=${encodeURIComponent(
					dir,
				)}&file=${encodeURIComponent(target)}`;
				const command = `http://localhost:9292/api/ltspctl/update?${encoded_params}&updates=${update_elms}`;
				console.log(command);
				let response = await fetch(command, {});
				let ckt = await response.json(); // ckt = {elements}
				console.log("ckt=", ckt);

				for (const [elm, props] of Object.entries(ckt.elements)) {
					if (elements[ckt_name][elm] != get_control(props)) {
						console.log(
							`Update error! ${elm}: ${get_control(props)}vs.${
								elements[ckt_name][elm]
							}`,
						);
					}
				}
			}
		}
		ckt_store.set(ckt);
		elements_store.set(elements);
	}

	function calculate_equation() {
		const value = submit_equation(
			equation,
			dir,
			file,
			plotdata,
			db_data,
			ph_data,
			measdata.filter((trace) => trace.checked),
		);
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
					db_data: db_data ? db_data[0] : [],
					ph_data: ph_data ? ph_data[0] : [],
				}),
			},
		);
		let result = await res.json();
		console.log(result);
		if (plotdata != undefined) {
			calculated_value = result.calculated_value.slice(
				0,
				plotdata.length,
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
	}
	equation = "x.where(y, 2.5){|x, y| x > 1e-6}";
	$: data.props.equation = equation;
	let calculated_value;
	// $: calculated_value = calculated_value;
	let settings = {}; //let title, title_x, title_y;
	$: settings.probes = probes;
</script>

<ConvertSchematic />
<OpenLTspice {data} on:open_end={plot_result} />
<Settings {data} {ckt} />
<div>
	<Simulate
		on:sim_end={plot_result}
		on:sim_start={clear_plot}
		on:elm_update={update_elements(dir)}
	/>
	<!-- Testplot / -->
</div>
<div>
	<button
		on:click={measurement_results(
			data.props.measfile.trim().replace(/^"/, "").replace(/"$/, ""),
			data.props.reject,
			data.props.reverse,
			data.props.tracemode,
		)}
		class="button-1">Get measured data:</button
	>
	<input
		bind:value={data.props.measfile}
		style="border:darkgray solid 1px;width: 40%;"
	/>
	<label
		>Reject:<input
			bind:value={data.props.reject}
			style="border:darkgray solid 1px;"
		/></label
	>
	<label
		>Reverse<input
			type="checkbox"
			bind:checked={data.props.reverse}
		/></label
	>
	<button>Trace mode</button>
	<input name="tracemodes" value={data.props.tracemode} type="hidden" />
	<select
		bind:value={data.props.tracemode}
		style="border:darkgray solid 1px;"
	>
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
<div>
	<label
		>Title
		<input bind:value={settings.title} style="border:darkgray solid 1px;" />
	</label>
	<label
		>X title
		<input
			bind:value={settings.title_x}
			style="border:darkgray solid 1px;"
		/>
	</label>
	{#if probes == undefined || !probes.startsWith("frequency")}
		<label
			>Y title
			<input
				bind:value={settings.title_y}
				style="border:darkgray solid 1px;"
			/>
		</label>
	{:else}
		<label
			>Y1 title
			<input
				bind:value={settings.title_y1}
				style="border:darkgray solid 1px;"
			/>
		</label>
		<label
			>Y2 title
			<input
				bind:value={settings.title_y2}
				style="border:darkgray solid 1px;"
			/>
		</label>
	{/if}
</div>
{#if plotdata !== undefined}
	<Plot
		data={plotdata.concat(measdata.filter((trace) => trace.checked))}
		layout={{
			title: settings.title,
			xaxis: {
				type: xaxis_is_log ? "log" : "",
				autorange: "true",
				title: settings.title_x,
			},
			yaxis: {
				type: yaxis_is_log ? "log" : "",
				autorange: "true",
				title: settings.title_y,
			},
			margin: { t: 30 },
		}}
		fillParent="width"
		debounce={250}
	/>
{/if}
{#if probes != undefined && probes.startsWith("frequency") && db_data !== undefined && ph_data !== undefined}
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
			linewidth: 1,
			mirror: true,
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

<div>
	<label
		>Measure
		<input bind:value={equation} style="border:darkgray solid 1px;" />
		<button
			on:click={submit_equation(
				equation,
				dir,
				file,
				plotdata,
				db_data,
				ph_data,
				measdata.filter((trace) => trace.checked),
			)}
			class="button-1"
		>
			Calculate</button
		>
		=> {calculated_value}
	</label>
</div>

<Experiment {probes} />

<style>
	.button-1 {
		/* width: 25%; */
		background: lightblue;
		text-align: left;
		padding: 5px 10px;
		border: 5px solid #ddd;
	}
</style>
