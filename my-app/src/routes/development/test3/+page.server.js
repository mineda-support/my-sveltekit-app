import fs from 'fs';
import glob from 'glob';
import path from 'path';

export function load({ url }) {
    // const probes = cookies.get('probes')
    const home = process.env.HOME.replaceAll('\\', '/');
    home + '/Seafile/PTS06_2022_8/BGR_TEG/';
    let wdir = url.searchParams.get('wdir') || home + '/Seafile/PTS06_2022_8/BGR_TEG/';
    console.log(`wdir: ${wdir}`);
    if (!wdir.endsWith('/')) wdir = wdir + '/';
    fs.readdir(wdir, (err, files) => {
        files.forEach(file => {
            //console.log(file);
        });
    });

    const files = glob.sync(wdir + '*.asc');
    files.forEach(file => {
        console.log(file);
    });

    return {
        props: {
          wdir: wdir, files: files.map(a => path.basename(a)) //, probes: probes
        }
    };
}