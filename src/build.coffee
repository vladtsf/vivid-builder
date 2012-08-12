pkg = require '../package'
path = require 'path'
util = require 'util'
fs = require 'fs'
program = require 'commander'
colors = require 'colors'
Template = require './template'


# CLI args
program
	.version(pkg.version)
	.usage('[options] <file ...>')
	.option('-o, --out [dir]', 'Output directory')
	.option('-u, --uglify', 'Compress with ugilfy.js', on)
	.option('-v, --verbose', 'Display building messages', on)
	.option('-d, --deprecated', 'Use deprecated inclusion syntax', off)
	.option('-i, --include-function <function>', 'Including function name', 'include')
	.parse(process.argv);


templates = program.args

uglify = (code) ->
	jsp = require("uglify-js").parser
	pro = require("uglify-js").uglify

	ast = jsp.parse(code); # parse code and get the initial AST
	ast = pro.ast_mangle(ast); # get a new AST with mangled names
	ast = pro.ast_squeeze(ast); # get an AST with compression optimizations
	
	pro.gen_code(ast);

for template, idx in templates
	fs.realpath template, (err, resolvedPath) ->
		if err
			console.error "[building: error]".red + " no such file #{template}"
			process.exit(1)
		else
			tpl = new Template resolvedPath, program.includeFunction, program.deprecated
			tpl.on 'compiled', ->
				output = if program.uglify then uglify tpl.output else tpl.output

				if program.out?
					fs.realpath program.out, (err, out) ->
						if err
							console.error "[building: error]".red + " no such file or directory #{out}"
							process.exit(1)

						save = path.join(out, path.basename resolvedPath)
						fs.writeFile save, output, (err) ->
							if err
								console.error "[building: error]".red + " can't #{save} file #{template}"
								process.exit(1)
							else if program.verbose
								console.log "[building: success]".green + " #{template}"
				else
					util.print output
