build:
	# Compile .coffee to .js
	coffee --bare -o lib -c src

	# Ugly hack to prepend shebang line
	cp lib/generate.js lib/generate.js.tmp
	echo "#!/usr/bin/env node" > lib/generate.js.tmp
	cat lib/generate.js >> lib/generate.js.tmp
	mv lib/generate.js.tmp lib/generate.js

