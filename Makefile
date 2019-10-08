
PICO8 = "/c/Program Files (x86)/PICO-8/pico8.exe"
DIR = nothing_html

all:
	cat ld45.p8 |\
	  grep -v 'include.*debug' |\
	  awk '{ if (/^ *#include/) { system("cat "$$2) } else { print $$0 } }' |\
	  grep . | sed 's/^  *//; s/--.*//' \
	  > tmp.p8
	$(PICO8) tmp.p8 -export "-f nothing.html"
	zip nothing.zip -r $(DIR)
	rm -f tmp.p8

