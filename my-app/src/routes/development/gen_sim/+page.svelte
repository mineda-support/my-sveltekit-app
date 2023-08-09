<script>
    let dir = 'c:/Users/seijirom/Seafile/PTS06_2022_8/BGR_TEG/';
    let ckt = 'tsd_TEG_tb';
    let traces = "'temperature', 'V(vout)'";

    $: program = `
$:.unshift File.join(ENV['HOME'], '/work/alb2/lib')
$:.unshift '.'
puts "hello world from ruby"
puts $0
work_dir = File.dirname $0
Dir.chdir(work_dir){
puts Dir.pwd
require 'compact_model'
require 'lib_util'
require 'ltspice'
require 'postprocess'
require 'ltspctl'
ckt = LTspiceControl.new '${ckt}.asc'
#ckt.open
puts "simulate '${ckt}.asc'"
ckt.simulate
puts "simulation done"
vars, traces = ckt.get_traces ${traces}
ckt.save_traces vars, traces, '${ckt}.json'
puts "got traces"
}
    `;
    console.log(program); 
    function handleClick() {
        program = program;
    }
    function simulate() {
        alert('simulation!')
    }
</script>

<div><button on:click={simulate}>Simulate</button></div>
<ul>
<li> 
    <!-- input bind:value={dir} type="file" id="folder" webkitdirectory="" directory="" multiple/-->
    <input bind:value={path} type="file" id="folder" directory="" />
    <!-- input bind:value={dir}  / -->
    <!-- input bind:value={dir} type="file" id="folder" / -->
</li>
<li><input bind:value={ckt}  /></li>
<li><input bind:value={traces}  /></li>
</ul>
<h1><pre>{program}</pre></h1>
 