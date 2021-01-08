// primitive datatypes
console.log("// Primitives");
console.log(typeof true);// => "boolean"
console.log(typeof 42); // => "number"
console.log(typeof "JavaScript"); // => "string"
console.log(typeof Symbol("This is symbol"));// => "symbol"
console.log(typeof undefined); // => "undefined"
console.log(typeof null); // => "object"
// object datatypes
console.log("// Objects");
console.log(typeof [1, 2, 3]); // => "object"
console.log(typeof { "hoge": "fuga" }); // => "object"
console.log(typeof function() {}); // => "function"

console.log("// Integer Numbers");
// --- decimal
console.log(1);
console.log(10);
console.log(123);
// --- binary
console.log(0b1);
console.log(0b10);
console.log(0b10101);
// --- octal
console.log(0o777);
console.log(0o644);
console.log(0o400);
// --- hexadecimal
console.log(0xFF);
console.log(0x10ef);
console.log(0x1139);
console.log("// Floating Numbers");
console.log(0.12345); //-> 0.12345
console.log(2e8); //-> 200000000

// --- String
console.log("// Strings");
const name = "Hiroyuki";
console.log(`My name is ${name}.`);  //-> My name is Hiroyuki.
