all:
	coffee -c views/*.coffee models/*.coffee AppRouter.coffee
	haml index.haml index.html
clean:
	rm views/*.js models/*.js AppRouter.js
	rm index.html
