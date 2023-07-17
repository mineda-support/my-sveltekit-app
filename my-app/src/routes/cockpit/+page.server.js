import fs from 'fs';
import {execa} from "execa";

export async function load () {
    const cwd = process.cwd();
    console.log(`current directory is ${cwd}`);
    const dir =  process.env.HOME + '/Seafile/PTS06_2022_8/BGR_TEG/';
    // process.chdir(dir);
    try {
	  const {stdout, stderr} = await execa('ruby', [dir + 'dio_sim.rb']);
	  /* console.log(stdout); */
	  /* console.log(stderr); */
    } catch (error) {
	console.error(
	    `ERROR: The command failed. stderr: ${error.stderr} (${error.exitCode})`
	);
    }
	// process.chdir(cwd);
    const home = process.env.HOME.replaceAll('\\', '/');
    const json_file = home + '/Seafile/PTS06_2022_8/BGR_TEG/tsd_TEG_tb.json';
    console.log(json_file);
	console.log('comparison: ' + (json_file== 'C:/Users/seijirom/Seafile/PTS06_2022_8/BGR_TEG/tsd_TEG_tb.json'));
    const [vars, plotdata] = JSON.parse(fs.readFileSync(json_file));
    console.log(plotdata);
	return {
      /* props: { plotdata, dir, }, */
	  plotdata, dir
    }
}