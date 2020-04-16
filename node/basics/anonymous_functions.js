console.log("// anonymous functions: function literals");
const message = function() {
  return "Hello JavaScript !!";
}
console.log(message);
console.log(message());

console.log("// non-anonymous functions");
const factorial = function innerFact(n) {
    if (n === 0) {
        return 1;
    }
    return n * innerFact(n - 1);
}
console.log(factorial);
console.log(factorial(0));
console.log(factorial(5));  //-> 5 * 4 * 3 * 2 * 1 = 120
// console.log(innerFact(0));
// will be error, since named function could not be called from outside of the literals.
