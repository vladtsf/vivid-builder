#!/usr/bin/env node

(function() {
    
    var
	path = require('path'),
	util = require('util'),
	fs = require('fs'),
	optimist = require('optimist'),
	Builder = require(__dirname + '/lib/builder.js');

    process.on('uncaughtException', function (err) {
	if(err.throwable) {
	    console.error(err.toString());
	    process.exit();
	}
    });
    
    // command line configuration
    var argv = optimist
	.usage('Usage: vivid-build [-u] [-o=<path>] <files>')

	.string('o')
	.alias('o', 'out')
	.describe('o', 'Output file')

	.boolean('u')
	.alias('u', 'uglify')
	.describe('u', 'Compress with ugilfy.js')
	
	.boolean('v')
	.alias('v', 'verbose')
	.describe('verbose', 'Display building errors')
	
	.boolean('version')
	.describe('version', 'Show builder version')

	.argv;


     var
	templates = argv._


    if(argv.version) {
	util.print(Builder.product.codeName, ' version ', Builder.product.version, '\n');
	process.exit();
    }
	
    if(templates.length == 0) {
	optimist.showHelp(console.error);
	process.exit();
    }
    
    if(argv.verbose) {
	Builder.verbose = true;
    }
    
    templates.forEach(function(val, index, array) {
	Builder.add(val);
    });
    
    Builder.build();
	
    if(argv.uglify) {
	Builder.uglify();
    }
    
    if(argv.out) {
	fs.writeFile(argv.out, Builder.result, 'utf8', process.exit);
    } else {
	util.print(Builder.result);
    }
    
    
})();
