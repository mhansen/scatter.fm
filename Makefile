all:
	coffee -c views/*.coffee models/*.coffee test/*.coffee *.coffee
	haml index.haml index.html
	haml graph.haml graph.html
clean:
	rm views/*.js models/*.js *.js test/*.js
	rm index.html graph.html
