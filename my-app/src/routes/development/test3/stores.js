import { writable } from 'svelte/store';

export const ckt_name = writable('');
export const dir_name = writable('');
export const probes_name = writable(undefined);
export const equation_name = writable(undefined);
export const ckt_store = writable({});
export const elements_store = writable({});
export const settings_store = writable({});