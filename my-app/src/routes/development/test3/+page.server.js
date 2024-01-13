import fs from 'fs';
import glob from 'glob';
import path from 'path';

/*
import { goto } from '$app/navigation';
export const actions = {
    default: async (event) => {
        console.log('form sent'); //alert('form sent');
        goto('/development/test3/');
    }
};    
*/
export function load({ url }) {
    // const probes = cookies.get('probes')
    const home = process.env.HOME.replaceAll('\\', '/');
    home + '/Seafile/PTS06_2022_8/BGR_TEG/';
    let wdir = url.searchParams.get('wdir') || home + '/Seafile/PTS06_2022_8/BGR_TEG/';
    let ckt = url.searchParams.get('ckt');
    let probes = url.searchParams.get('probes');
    console.log(`wdir: ${wdir}`);
    if (!wdir.endsWith('/')) wdir = wdir + '/';
    if (fs.existsSync(wdir)) {
        fs.readdir(wdir, (err, files) => {
            files.forEach(file => {
                console.log(file);
            });
        });

        const files = glob.sync(wdir + '*.asc');
        files.forEach(file => {
            console.log(file);
        });
        return {
            props: {
                wdir: wdir, ckt: ckt, probes: probes, files: files.map(a => path.basename(a)) //, probes: probes
            }
        };
    }
}
