// stdout
console.log('Hello World !!');

// stdin
const readline = require('readline');
let stream = {
    input: process.stdin,
    output: process.stdout
};
let prompt = '>>> Enter some strings: ';
const lines = readline.createInterface(stream);
lines.question(
    prompt,
    function(ans){
        console.log(ans);
        lines.close();
    }
);

// ----
// $ node hello_world.js 
// Hello World !!
// >>> Enter some strings: hello world !!
// hello world !!
