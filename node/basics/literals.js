// basic literals: numbers/strings
let name = "Hiroyuki";
let age = 28;
// console.log("My name is " + name + " and " + age + " years old.");
console.log(`My name is ${name} and its length is ${name.length}`);

// --- function literals can be used if it returns some value
// function literals #1: handle numbers
let getDouble = function(n){
    return n * 2;
};
console.log("Double of 3 is " + getDouble(3));

// function literals #2: handle strngs
let getMessage = function(name){
  return "Hello " + name;
};
console.log("Message is: " + getMessage("Hiroyuki"));
