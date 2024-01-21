<script>
  async function save_settings(data, settings_name, ckt) {
    const props = data.props;
    props.settings_name = settings_name;
    props.ckt = ckt;
    // props.probes = probes;
    // console.log(JSON.stringify({ props }));
    const response = await fetch("/development/test3/settings", {
      method: "POST",
      body: JSON.stringify(props),
      headers: {
        "Content-Type": "application/json",
      },
    });
    const settings = await response.json();
    console.log("settings:");
    console.log(settings);
    if (settings.includes(settings_name)) {
      alert(`${settings_name} saved`);
      data.props.settings = settings;
    }
  }

  async function load_settings(settings_name, dir){
    // alert(`load ${settings_name}`)
    const response = await fetch(`/development/test3/settings?dir=${encodeURIComponent(dir)}&settings_name=${settings_name}`);
    // const result = await response.json();
    const settings = await response.json();
    // probes_name.set(probes);
    console.log('result');
    // console.log(settings);
    console.log([settings.equation, settings.probes]);
    // equation = settings.equation;
    //console.log(result);
    //return {result};
  }
  let settings_name = "default";
  export let data, ckt;
</script>

<div>
  <button on:click={save_settings(data, settings_name, ckt)} class="button-1">
    Save settings in:</button
  >
  <label>
    <input
      type="text"
      autocomplete="off"
      on:keydown={async (e) => {
        if (e.key == "Enter") {
          save_settings(data, settings_name, ckt);
        }
      }}
      bind:value={settings_name}
      style="border:darkgray solid 1px;"
    />
  </label>
  <button on:click={() =>load_settings(settings_name, data.props.wdir)} class="button-1">Load settings from: </button>
  <select bind:value={settings_name} style="border:darkgray solid 1px;">
    {#each data.props.settings as setting}
      <option value={setting}>{setting}</option>
    {/each}
  </select>
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