module.exports = (grunt)->
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		coffee:
			compile:
				files:
					'src/resources/scripts/all.js': ['src/client/*.coffee']

	grunt.loadNpmTasks('grunt-contrib-coffee')

