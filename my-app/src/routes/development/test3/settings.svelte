<script>
  import { probes_name, equation_name, settings_store } from "./stores.js";
  let probes, equation, settings;
  probes_name.subscribe((value) => {
    probes = value;
  });
  equation_name.subscribe((value) => {
    equation = value;
  });
  settings_store.subscribe((value) => {
    settings = value;
  });

  async function save_settings(data, settings_name, ckt) {
    const props = data.props;
    props.settings_name = settings_name;
    props.ckt = ckt;
    for (const [item, value] of Object.entries(settings)) {
      props[item] = value;
    }
    const response = await fetch("/development/test3/settings", {
      method: "POST",
      body: JSON.stringify(props),
      headers: {
        "Content-Type": "application/json",
      },
    });
    const setting_names = await response.json();
    console.log("settings:");
    console.log(setting_names);
    if (setting_names.includes(settings_name)) {
      alert(`${settings_name} saved`);
      data.props.setting_names = setting_names;
    }
  }

  async function load_settings(settings_name, dir) {
    // alert(`load ${settings_name}`)
    const response = await fetch(
      `/development/test3/settings?dir=${encodeURIComponent(
        dir,
      )}&settings_name=${settings_name}`,
    );
    // const result = await response.json();
    const new_settings = await response.json();
    // probes_name.set(probes);
    console.log("result");
    // console.log(new_settings);
    console.log([new_settings.equation, new_settings.probes]);
    equation_name.set(new_settings.equation);
    probes_name.set(new_settings.probes);
    for (const [item, value] of Object.entries(settings)) {
      settings[item] = new_settings[item];
    }
    settings_store.set(settings);
    console.log(settings);
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
  <button
    on:click={() => load_settings(settings_name, data.props.wdir)}
    class="button-1"
    >Load settings from:
  </button>
  <select bind:value={settings_name} style="border:darkgray solid 1px;">
    {#each data.props.setting_names as setting}
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
