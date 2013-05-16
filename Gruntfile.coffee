module.exports = (grunt)->

	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		
		coffee:
			client:
				compile:
					files:
						'src/resources/scripts/all.js': ["src/client/*.coffee"]

		simplemocha:
			client:
				compilers: 'coffee:coffee-script'
				src: 'test/client/**/*.coffee'
			server:
				compilers: 'coffee:coffee-script'
				src: 'test/server/**/*.coffee'

		exec:
			startMongo:
				command: 'ops/start-test-mongodb.sh'
			stopMongo:
				command: 'ops/stop-test-mongodb.sh'

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-simple-mocha'
	grunt.loadNpmTasks 'grunt-exec'

	grunt.registerTask 'client',['simplemocha:client','coffee:client']
	grunt.registerTask 'server',['exec:startMongo','simplemocha:server','exec:stopMongo']

	grunt.registerTask 'default',['server','client']

