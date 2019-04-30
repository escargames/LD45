
PICO8 = "/c/Program Files (x86)/PICO-8/pico8.exe"
DIR = findingcookie_html

all:
	$(PICO8) "$(APPDATA)/pico-8/carts/tmp.p8.png" -export "-f findingcookie.html"
	zip findingcookie.zip -r $(DIR)
	rm -rf "$(APPDATA)/pico-8/carts/tmp.p8.png"
