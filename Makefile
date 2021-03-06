all: clean build itch
build: html5 
html5: 
	mkdir -p build/html5
	godot3.1 project.godot --path src/ --export "HTML5" ../build/html5/index.html

itch: itch-html5
itch-html5: 
	cd build; butler push html5 murphy-slaw/blob-experiment:html5
clean:
	find build -type f -exec rm {} \;
status:
	cd .;  butler status murphy-slaw/blob-experiment
