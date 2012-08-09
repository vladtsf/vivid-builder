fs = require 'fs'
path = require 'path'
events = require 'events'

class Template extends events.EventEmitter
	includeExp = /\<\!include\s+file\="[^"]*"\-\-\>/gi
	fileExp = /file="([^"]*)"/i
	position = 0

	output: ''
	deps: {}

	constructor: (@file) ->
		fs.readFile @file, 'utf8', (err, @rawContent) => 
			if err
				throw err
			else
				@basedir = path.dirname @file
				@parse()
				@compile()

	parse: ->
		matches = @rawContent.match includeExp
		@includes = if matches then (inc.match(fileExp)[1] for inc in matches) else []
		@

	dep: (file, cb) ->
		fullPath = path.join @basedir, file
		tpl = new Template fullPath
		tpl.on 'compiled', =>
			@deps[file] = tpl.output
			
			if ++position < @includes.length
				@dep @includes[position], cb
			else
				cb()

	compile: ->
		if @includes.length
			@dep @includes[position], =>
				@output = @rawContent.replace includeExp, (include, offset, all) =>
					file = include.match(fileExp)[1]
					@deps[file]
				@emit 'compiled'
		else
			@output = @rawContent
			@emit 'compiled'

		@

module.exports = Template