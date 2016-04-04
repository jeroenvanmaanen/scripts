yaml = require('js-yaml');
fs   = require('fs');

var file = process.argv[2];

// Get document, or throw exception on error
try {
    var doc = yaml.safeLoad(fs.readFileSync(file, 'utf8'));
    console.log(doc);
} catch (e) {
    console.log(e);
}