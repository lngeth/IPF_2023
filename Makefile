all: clean obj/main exec

windows: clean_windows obj/main exec

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
	powershell -Command "Remove-Item -Force -ErrorAction SilentlyContinue obj/*.cmi"
	powershell -Command "Remove-Item -Force -ErrorAction SilentlyContinue obj/*.cmo"
	powershell -Command "Remove-Item -Force -ErrorAction SilentlyContinue obj/main"