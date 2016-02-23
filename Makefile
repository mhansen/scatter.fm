all:
	coffee -c views/*.coffee models/*.coffee test/*.coffee *.coffee
clean:
	rm views/*.js models/*.js *.js test/*.js
