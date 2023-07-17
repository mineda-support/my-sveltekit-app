import fs from 'fs';
const home = process.env.HOME.replaceAll('\\', '/');
const json_file = home + '/Seafile/PTS06_2022_8/BGR_TEG/tsd_TEG_tb.json';
const [vars, plotdata] = JSON.parse(fs.readFileSync(json_file));
    
export function load() {
    return {
       vars: vars,
       plotdata: plotdata
    }
}
