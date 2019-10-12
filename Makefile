
PICO8 = "/c/Program Files (x86)/PICO-8/pico8.exe"
DIR = nothing_html

all: ld45-mini.p8
	$(PICO8) $^ -export "-f nothing.html"
	zip nothing.zip -r $(DIR)

ld45-mini.p8: ld45.p8
	cat $^ |\
	  grep -v 'include.*debug' |\
	  awk '{ if (/^ *#include/) { system("cat "$$2) } else { print $$0 } }' |\
	  grep . | sed 's/^  *//; s/--.*//' \
	  > $@

