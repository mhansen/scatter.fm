all:
	coffee -c views/*.coffee models/*.coffee AppRouter.coffee
	haml graph.haml graph.html
clean:
	rm views/*.js models/*.js AppRouter.js
	rm graph.html
