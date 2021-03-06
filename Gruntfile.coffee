module.exports = (grunt)->

	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')
		
		coffee:
			client:
				options:
					join: true
				files:
					"src/resources/scripts/all.js": ["src/client/*.coffee"]

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

		compass:
			dev:
				options:
					config: 'config.rb'
					force: true
			prod:
				options:
					config: 'config.rb'
					environment: 'production'
					outputStyle: 'compressed'
					force: true

		clean:
			client: ["src/resources/scripts/","src/resources/styles/"]

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-compass'
	grunt.loadNpmTasks 'grunt-contrib-clean'
	grunt.loadNpmTasks 'grunt-simple-mocha'
	grunt.loadNpmTasks 'grunt-exec'

	grunt.registerTask 'client',['clean:client','compass:dev','simplemocha:client','coffee:client']
	grunt.registerTask 'server',['exec:stopMongo','exec:startMongo','simplemocha:server','exec:stopMongo']
	grunt.registerTask 'production',['clean:client','compass:prod','coffee:client']

	grunt.registerTask 'default',['server','client']

