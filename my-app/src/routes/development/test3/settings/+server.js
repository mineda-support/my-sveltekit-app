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

export async function POST({ request, cookies }) {
    // console.log(request);
	const props = await request.json();
    const wdir = props.wdir;
    console.log(wdir);
    fs.writeFileSync(wdir+'default_settings.json', JSON.stringify(props));
    console.log(props);
	return json({ status: 201 });
}
