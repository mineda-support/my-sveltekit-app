<script>
  /*
  import { settings_store } from "./stores.js";
  let settings;

  settings_store.subscribe((value) => {
    settings = value;
  });
  */
  export let settings;

  async function save_settings(data, settings_name, ckt) {
    const props = data.props;
    props.settings_name = settings_name;
    props.ckt = ckt;
    console.log("settings=", settings);
    props.settings = {};
    for (const [item, value] of Object.entries(settings)) {
      props.settings[item] = value;
    }
    console.log("props=", props);
    const response = await fetch("/development/test3/settings", {
      method: "POST",
      body: JSON.stringify(props),
      headers: {
        "Content-Type": "application/json",
      },
    });
    const setting_names = await response.json();
    console.log("setting names:", setting_names);
    if (setting_names.includes(settings_name)) {
      alert(`${settings_name} saved`);
      data.props.setting_names = setting_names;
    }
  }

  async function load_settings(settings_name, dir) {
    //alert(`load ${settings_name}`);
    const response = await fetch(
      `/development/test3/settings?dir=${encodeURIComponent(
        dir,
      )}&settings_name=${settings_name}`,
    );
    // const result = await response.json();
    const new_settings = await response.json();
    // probes_name.set(probes);
    console.log("new_settings=", new_settings);
    console.log([new_settings.equation, new_settings.probes]);
    equation = new_settings.equation;
    probes = new_settings.probes;
    // settings = {};
    for (const [item, value] of Object.entries(new_settings["settings"])) {
      settings[item] = value;
    }
    console.log("settings=", settings);
  }
  let settings_name = "default";
  export let data, ckt, equation, probes;
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
    {#if data.props != undefined}
      {#each data.props.setting_names as setting}
        <option value={setting}>{setting}</option>
      {/each}
    {/if}
  </select>
</div>

<style>
</style>
