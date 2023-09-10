import fs from 'fs';
import { json } from '@sveltejs/kit';

export function GET() {
    //const dir = process.env.HOME + '/Seafile/PTS06_2022_8/BGR_TEG/';
	const home = process.env.HOME.replaceAll('\\', '/');
    const json_file = home + '/Seafile/PTS06_2022_8/BGR_TEG/tsd_TEG_tb.json';
    console.log(json_file);
    console.log('comparison: ' + (json_file == 'C:/Users/seijirom/Seafile/PTS06_2022_8/BGR_TEG/tsd_TEG_tb.json'));
    const [vars, plotdata] = JSON.parse(fs.readFileSync(json_file));
    console.log(plotdata);
    return json(plotdata);
}

