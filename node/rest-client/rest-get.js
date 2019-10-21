var request = require('request');
var headers = {
    'Content-Type': 'application/json',
}

var url = "https://swapi.co/api/people/1/";
var wrong_url = "https://localhost:8000";


console.log("Starting HTTP GET Request...");

request.get(url, function(err, res, body) {
    if (err) {
        console.log('Failed to GET : ' + err.message);
        return;
    }
    console.log(body);
});

// note that not-sequential
console.log("HTTP GET Done.");

