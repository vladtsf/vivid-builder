(function($) {
	var 
		fs		= require('fs'),
		path		= require('path'),
		EventEmitter	= require('events').EventEmitter;
	
	var expressions = {
		include		: /\/\/\<\!include\s*file\="[^"]*"\-\->/g,
		filename	: /file="([^"]*)"/i
	}
	
	function proxy (fn, context) {
		return function() {
			return fn.apply(context, arguments);
		};
	}
	
	function include (match, index, text) {
		var
			file = this.root + '/' + match.match(expressions.filename)[1];
		
		try {
			var f = fs.realpathSync(file);
			return fs.readFileSync(f, 'utf8');
		} catch(err) {
			if(this.Builder.verbose) {
				console.error(err.toString());
				return '';
			}
		}
	}
	
	$.Template = function(tplPath) {
		if(this instanceof $.Template) {
			this.path = tplPath;
			this.root = path.dirname(tplPath);
			this.events = new EventEmitter();
			this.code = '';
			this.matches = null;
			
			return this;
		}
		
		return new $.Template(tplPath);
	};
	
	$.Template.prototype = {
		build: function() {
			return fs.readFileSync(this.path, 'utf8').replace(expressions.include, proxy(include, this));
		}
	};
	
})(module.exports);
