// yaml-to-properties.js

var yaml = require('js-yaml');
var fs = require('fs');

var isArray;

var source = process.argv[2];
var destination = process.argv[3];

// Get document, or throw exception on error
try {
    if (Array.isArray) {
        isArray = Array.isArray;
    } else {
        isArray = function(object) {
            return Object.prototype.toString.call(object) === '[object Array]';
        }
    }

    var doc = yaml.safeLoad(fs.readFileSync(source, 'utf8'));

    var consumer;
    if (destination) {
        var fd = fs.openSync(destination, 'w')
        consumer = function(line) {
            fs.write(line);
            fs.write('\n');
        }
    } else {
        consumer = console.log;
    }

    flatten('', doc, consumer);
} catch (e) {
    console.log(e);
}

function flatten(object_name, object, consumer) {
    var i;
    var itemType;
    var key;
    var keys;
    var line_number;
    var lines;
    var prefix;
    var string;
    var value;

    prefix = object_name ? (object_name + '.') : '';
    if (isArray(object)) {
        itemType = 'simple';
        for (i = 0; i < object.length; i++) {
            value = object[i];
            if (typeof value === 'object') {
                itemType = 'complex';
                break;
            }
        }
        consumer(object_name + '[]:' + itemType + '::' + object.length);
        for (i = 0; i < object.length; i++) {
            value = object[i];
            flatten(object_name + '[' + i + ']', value, consumer)
        }
    } else if (typeof object === 'object') {
        keys = [];
        for (key in object) {
            if (object.hasOwnProperty(key)) {
                keys.push(key);
            }
        }
        keys.sort();
        for (i = 0; i < keys.length; i++) {
            key = keys[i];
            value = object[key];
            flatten(prefix + key, value, consumer)
        }
    } else if (typeof object === 'string') {
        string = object.replace('\r', '');
        string = string.replace(/\n$/, '');
        lines = string.split('\n');
        if (lines.length <= 1) {
            consumer(object_name + ':' + typeof(object) + ':: ' + object);
        } else {
            for (i = 0; i < lines.length; i++) {
                line_number = i + 1;
                if (line_number === lines.length) {
                    line_number = '' + line_number + '*';
                }
                consumer(object_name + ':line:' + line_number + ': ' + lines[i]);
            }
        }
    } else {
        consumer(object_name + ':' + typeof(object) + ':: ' + object);
    }
}
