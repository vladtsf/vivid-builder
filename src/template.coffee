fs = require 'fs'
path = require 'path'
events = require 'events'

class Template extends events.EventEmitter
	includeExp = null
	fileExp = /\(\s*[\'\"]([.\/\\\w\s]+)[\'\"]\s*\)/i
	headExp = /(^|[^\\w])/
	position = 0

	output: ''
	deps: {}

	constructor: (@file, @token) ->
		includeExp = new RegExp "(^|[^\\w])#{@token||'include'}\\s*\\(\\s*[\\'\\\"][.\\/\\\\\\w\\s]+[\\'\\\"]\\s*\\);?", 'gi'

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
		# @todo: fix circular dependencies
		fullPath = path.join @basedir, file
		tpl = new Template fullPath, @token
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
					include.match(headExp)[0] + @deps[file]
				@emit 'compiled'
		else
			@output = @rawContent
			@emit 'compiled'

		@

module.exports = Template