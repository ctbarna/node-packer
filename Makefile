all:
	@./node_modules/coffee-script/bin/coffee -o lib -c src/*.coffee

test1:
	@./node_modules/mocha/bin/mocha --compilers coffee:coffee-script test/*

test: test1
