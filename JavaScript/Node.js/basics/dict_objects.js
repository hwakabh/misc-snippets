console.log('// Define dict-objects and refer its values with keys')
const company = {
    name: 'Microsoft',
    year: 1975,
    // use function as value of some keys
    message: () => {
        console.log('Hello from Microsoft !!');
    },
    search: q => {
        return `Bing result with ${q} ...`;
    }
};
company.message();  //-> Hello from Microsoft !!
let result = company.search('Node.js');
console.log(result);  //-> Bing result with Node.js ...


console.log('// Modify values of dict-object.');
const google = {
    name: 'Google.LCC',
    year: 1998,
    message: () => {
        return 'Hello from Google !!';
    }
};
// Add string properties to object
google.founder = 'Larry Page';
// Add function properties to object
google.search = q => {
    return `Displaying results with keyword: ${q}`;
}
console.log(google);
google.parent = 'Alphabets.Inc';
// New property will apply
console.log(google);
