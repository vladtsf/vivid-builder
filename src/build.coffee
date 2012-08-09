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
	.option('-v, --verbose', 'Display building status', on)
	.parse(process.argv);


templates = program.args

for template, idx in templates
	fs.realpath template, (err, resolvedPath) ->
		if err
			console.error "[building: error]".red + " no such file #{template}"
			process.exit(1)
		else
			tpl = new Template(resolvedPath)
			tpl.on 'compiled', ->
				if program.out?
					fs.realpath program.out, (err, out) ->
						if err
							console.error "[building: error]".red + " no such file or directory #{out}"
							process.exit(1)

						save = path.join(out, path.basename resolvedPath)
						fs.writeFile save, tpl.output, (err) ->
							if err
								console.error "[building: error]".red + " can't #{save} file #{template}"
								process.exit(1)
							else if program.verbose
								console.log "[building: success]".green + " #{template}"
				else
					util.print tpl.output
