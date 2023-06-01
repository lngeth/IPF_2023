all: clean main

main: Logique.cmx Main.cmx
	ocamlopt -o main $^
	./main

%.cmx: %.ml
	ocamlopt -c $^

clean:
	rm -f *.cmx *.cmi *.o