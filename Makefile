all: clean main

main: obj/Logique.cmx obj/Main.cmx
	ocamlopt -o obj/main $^
	./obj/main

%.cmx: src/%.ml
	ocamlopt -o obj/$@ -c $^

%.cmx: src/utils/%.ml
	ocamlopt -o obj/$@ -c $^

clean:
	rm -f obj/*.cmx obj/*.cmi obj/*.o
