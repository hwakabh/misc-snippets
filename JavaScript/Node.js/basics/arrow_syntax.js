// // basic function-literal
// let getTriangleArea = function(base, height) {
//     let area = base * height / 2;
//     // return base * height / 2;
//     return area;
// };
// console.log("Area is " + getTriangleArea(10, 2)); //-> Area is 10

// -- Function literals with arrow-syntax
// Basic arrow-syntax would omit the `function` statement.
let getTriangleArea = (base, height) => {
    let area  = base * height / 2;
    return area;
};
console.log("Area is " + getTriangleArea(10, 2));

// If function would do only returns, can be omit {}.
let getSquareArea = (base, height) => base * height;
console.log("Square area is " + getSquareArea(10, 2));

// If function get single arg, could omit the ().
let getDouble = n => n * 2;
console.log("Double of 3 is " + getDouble(3));

// But required (), if function would not get any arg.
let say_hello_world = () => console.log("Hello World");
say_hello_world();
