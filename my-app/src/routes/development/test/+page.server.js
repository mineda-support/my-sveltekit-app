export async function load({fetch}){
    let response = await fetch("http://localhost:9292/api/blog/article", {mode: 'no-cors'});
    let res2 = await response.json();
    console.log(res2);
return ( res2)
}
