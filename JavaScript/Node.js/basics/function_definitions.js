// Define function something returns
function say_hello(name) {
    return "Hello " + name;
}
// Define function without returns
function do_nothing() {
    return;
    // unreachable code
    console.log("Hello World !!");
}

// Call functions defined
let result = say_hello("Hiroyuki");
console.log(result); //-> Hello Hiroyuki
console.log(do_nothing());  //-> undefined

// Spread syntax
function print_all(x, y, z) {
    console.log(x);
    console.log(y);
    console.log(z);
}
const array = ["JavaScript", "Python", "C++"];
print_all(...array);    // Same as : print_all(array[0], array[1], array[2])

// Rest parameters and Spread syntax
function print_info(name, ...kwargs) {
    console.log(name);
    console.log(kwargs);
}
const info = ["Hiroyuki", 28, "Engineer"];
print_info(...info);