console.log("// missing arguments");
function add_nums(x, y) {
    console.log(`Adding ${x} and ${y}`);
    return x + y;
}
console.log(add_nums(1, 2)); //-> 3
console.log(add_nums(1));  //-> NaN: Not a Number(since num=1 + undefined could not be added)

console.log("// default arguments");
function say_name(name = "JavaScript") {
    return `Hello ${name}`
}
console.log(say_name("Hiroyuki"));  //-> Hello Hiroyuki
console.log(say_name());  //-> Hello JavaScript

console.log("// Overfloating parameters");
console.log(add_nums(1, 2));
console.log(add_nums(1, 2, 3));

console.log("// Rest parameters");
function print_info(name, ...misc) {
  console.log(name);
  console.log(misc);  //-> Rest parameters will store as array datatype.
}
print_info("Hiroyuki", 28, "Engineer");

console.log("// Using arguments variables");
function echo_somethings() {
  console.log(`Number of args for this function is ${arguments.length}`);
  console.log(arguments[0]);
  console.log(arguments[1]);
  console.log(arguments[2]);
  console.log(arguments[10]);
}
echo_somethings("Hiroyuki", 28, "Engineer");
