(function($) {
    var 
	fs		= require('fs'),
	path		= require('path'),
	Template	= require('./template.js').Template,
	EventEmitter	= require('events').EventEmitter;
	
    var 
	jsp = require("uglify-js").parser,
	pro = require("uglify-js").uglify;


	
    $.product = {
	author	    : 'Vladimir Tsvang',
	name	    : 'Vivid JS Builder',
	codeName    : 'builder',
	version	    : '0.0.2'
    };
    
    $.verbose = false;

    var 
	templates = [];
	
    $.result = '';
    
    $.add = function(tplPath) {
	try {
	    var tplRealPath = fs.realpathSync(tplPath);
	    
	} catch(err) {
	    var e = new Error('Template "' + err.path + '" not exists');
	    e.throwable = true;
	    throw e;
	}
	    
	var tpl = new Template(tplRealPath);
	tpl.Builder = $;
	templates.push(tpl);
	return this;
    };
    
    $.build = function() {
	templates.forEach(function(tpl, index, array) {
	    templates[index] = tpl.build();
	});
	
	$.result = templates.join('\n');
	
	return this;
    };
    
    $.uglify = function() {
	var ast = jsp.parse($.result); // parse code and get the initial AST
	ast = pro.ast_mangle(ast); // get a new AST with mangled names
	ast = pro.ast_squeeze(ast); // get an AST with compression optimizations
	
	$.result = pro.gen_code(ast);
    };
    
})(module.exports);
