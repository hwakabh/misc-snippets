console.log('// Array with Integer elements')
const numbers = [1, 2, 3, 4];
for (let i = 0; i < numbers.length; i++) {
    console.log(numbers[i]);
}
// console.log(numbers[0]);
// console.log(numbers[3]);
// console.log(numbers[4]);  //-> undefined
// console.log(numbers[5]);  //-> undefined

console.log('// Array with String elements')
const strings = ['alpha', 'bravo', 'charie'];
for (let i = 0; i < strings.length; i++) {
    console.log(strings[i]);
}

console.log('// Empty array')
const empty = [];
console.log(empty);
console.log(empty.length);  //-> 0
// Clear array elements
const emp = [1, 2, 3];
emp.length = 0;
console.log(emp); //-> []

console.log('// Using indexOf()');
const arr = ['Node.js', 'Python', 'C++', 123];
console.log(arr.indexOf('Python'));
console.log(arr.indexOf(123));
console.log(arr.indexOf('123'));    //-> datatype is not same
console.log(arr.indexOf('n/a'));    //-> element not exists

console.log('// Check existence of elements');
const nums = [1, 2, 3, 4, 5];
console.log(nums.includes(1)); //-> true
console.log(nums.includes(7)); //-> false
console.log(nums.includes('1')); //-> false
console.log(nums.includes(false));

console.log('// Modify elements');
// push() and pop() will modify elements of source array directly
const alphabets = ['A', 'B', 'C'];
alphabets.push('D');
console.log(alphabets); //-> ['A', 'B', 'C', 'D']
alphabets.pop();
alphabets.pop();
console.log(alphabets); //-> ['A', 'B']
// concat() will copy source array and modify its elements
const new_alphabets = alphabets.concat(1, 2, 3);
console.log(new_alphabets);
console.log(alphabets);
