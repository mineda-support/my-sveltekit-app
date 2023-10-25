<script>
	import {
		ckt_name,
		dir_name,
		probes_name,
		ckt_store,
		elements_store,
	} from "./stores.js";
	let file;
	let dir;
	let ckt;
	let probes;
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
	ckt_store.subscribe((value) => {
		ckt = value;
	});
	elements_store.subscribe((value) => {
		elements = value;
	});

	let src1 = "V2";
	let src1_values =
		"PULSE(2.4 2.6 200n 100n 100n 200n 700n), PULSE(2.45 2.55 200n 100n 100n 200n 700n), PULSE(2.475 2.525 200n 100n 100n 200n 700n)";
	let src2, src2_values;
	function wrap_with_apostrophe(a) {
		if (a != undefined && a != null) {
			return a
				.split(/, */)
				.map((x) => `'${x}'`)
				.join(", ");
		}
	}
	let program;
	$: program = `new_traces = []
src1_values = [${wrap_with_apostrophe(src1_values)}]
src1_values.each{|p|
  ckt.set V2: p
  puts "${src1} = #{ckt.get('${src1}')}"
  ckt.simulate
  vars, traces =ckt.get_traces ${wrap_with_apostrophe(probes)}
  traces[0][:name] = p.sub ' 200n 100n 100n 200n 700n', ''
  new_traces << traces[0]
}
new_traces
`;
	async function submit_program(program, dir, file) {
		const encoded_params = `dir=${encodeURIComponent(
			dir
		)}&file=${encodeURIComponent(file)}`;
		const body = program;
		const res = await fetch(
			`http://localhost:9292/api/ltspctl/execute?${encoded_params}`,
			{
				method: "POST",
				headers: {
					Accept: "application/json",
				},
				body: program, // JSON.stringify(body),
			}
		);
		console.log(await res.json());
	}
</script>

<div>Make Experiments</div>
<div>
	<label
		>1st source
		<input bind:value={src1} style="border:darkgray solid 1px;" />
		values
		<input
			bind:value={src1_values}
			style="border:darkgray solid 1px;width: 50%;"
		/>
	</label>
</div>
<div>
	<label
		>2nd source
		<input bind:value={src2} style="border:darkgray solid 1px;" />
		values
		<input
			bind:value={src2_values}
			style="border:darkgray solid 1px;width: 50%;"
		/>
	</label>
</div>
<div>
	<label>
		<button on:click={submit_program(program, dir, file)} class="button-1">
			Submit below program</button
		>
		<textarea
			bind:value={program}
			style="border:darkgray solid 1px; height: 200px; 
width: 90%;"
		/>
	</label>
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
