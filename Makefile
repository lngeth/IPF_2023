all: clean obj/main exec

windows: obj/main exec

obj/main: obj/Logique.cmo obj/Main.cmo
	ocamlc -o obj/main $^

obj/Main.cmo: src/Main.ml
	ocamlc -o $@ -c $^ -I obj

obj/Logique.cmo: src/utils/Logique.ml
	ocamlc -o $@ -c $^

debug:
	obj/main exec

exec:
	./obj/main

clean:
	rm -f obj/*.cmo obj/*.cmi obj/main

clean_windows:
	del .\obj\*.cmi
	del .\obj\*.cmo
	del .\obj\main