<script>
    import { goto } from '$app/navigation';
    import { dir_name } from "./stores.js";
    let dir;
    dir_name.subscribe((value) => {
        dir = value;
    });

    function convertSchematic(selected) {
        alert("conversion to " + selected);
    }
    let selected;
    let program;
    $: if (selected == "Xschem") {
        program = `
create_cdraw()
dir = Dir.pwd
cdraw2target 'xschem', File.join(dir,'cdraw'), File.join(dir,'./xschem')
`;
    }
    /*
    function convert_from_ltspice(program) {
        const encoded_params = `dir=${encodeURIComponent(dir)}`;
        console.log(program);
        `http://localhost:9292/api/ltspctl/convert_from_LTspice?${encoded_params}`;
    }
    */
    function encoded_params(dir) {
        console.log(`dir=${encodeURIComponent(dir)}`);
        return `dir=${encodeURIComponent(dir)}`;
    }
    function handleSubmit(){
        goto('/development/test3/');
    }
</script>

<!-- form method="POST" on:submit={handleSubmit} class='button-2'></form -->
<form
    method="POST"
    class="button-2"
    action={`http://localhost:9292/api/ltspctl/convert_from_LTspice?${encoded_params(dir)}`}

    >
    <button>Convert schematic</button> to
    <!--input name={selected} / -->
    <input name="program" value={program} type="hidden" />
    <select bind:value={selected}>
        <option value="Xschem">Xschem</option>
        <option value="EEschema">EEschema</option>
        <option value="Qucs">Qucs</option>
        <option value="Edif">Edif</option>
    </select>
</form>

<!-- button on:click={convertSchematic(selected)} class="button-2">
   Convert schematic</button> to 
<select bind:value={selected}>
    <option value='Xschem'>Xschem</option>
    <option value='EEschema'>EEschema</option>
    <option value='Qucs'>Qucs</option>
    <option value='Edif'>Edif</option>
</select -->
<style>
    .button-2 {
        /* width: 25%; */
        background: lightgreen;
        text-align: right;
        padding: 5px 10px;
        border: 5px solid #ddd;
    }
</style>
