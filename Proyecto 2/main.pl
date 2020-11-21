:- dynamic ejemplo/3.
construirAD(InputFile,OutputFile):- 
                                    \+checkEmpty(InputFile), 
                                    consult(InputFile), 
                                    findall(X, ejemplo(_,_,X), L),
                                    length(L,S),
                                    S>0,
                                    sort(L,ListaFinal), 
                                    length(ListaFinal,Size), 
                                    buscarDefault(ListaFinal,Default),!.
construirAD(InputFile,OutputFile):- write("Ocurrio un error.").
checkEmpty(File):-open(File,read,Str),isEmpty(Str).
/*
Tengo que hacer algun metodo para revisar cual es el predicado que mas veces aparece para el default
Debo recorrer la lista final, llamando a findall contando todos los ids que aparezcan con el nombre indicado en la lista. 
Para cada uno entonces debo guardar en una lista el par (Nombre,Cantidad) y una vez que termino entonces recorro y veo el mayor.
Sort creo que los ordena.
*/

buscarDefault(ListaInput, Default):-buscarApariciones(ListaInput,ListaOutput),buscarMayor(ListaOutput,Default),write(Default),generarArbolDecisionShell(Default).
buscarApariciones(ListaInput,ListaOutput):-buscarAparicionesAux(ListaInput,[],ListaOutput).
buscarAparicionesAux([],ListaIntermedia,ListaOutput):-append(ListaNueva,ListaIntermedia,ListaOutput),!.
buscarAparicionesAux([H|T],ListaIntermedia,ListaOutput) :-
                                                        findall(ID, ejemplo(ID,_,H),ListaAux),
                                                        length(ListaAux,Cantidad),ListaNueva=[(Cantidad,H)],
                                                        append(ListaIntermedia,ListaNueva,ListaNueva2),
                                                        buscarAparicionesAux(T,ListaNueva2,ListaOutput).
/*
En la lista final tengo todo ordenado, sin repeticiones, y el primero es el que mas apariciones tiene
*/
buscarMayor(ListaOutput,Default):-sort(ListaOutput,ListaOrdenada),reverse(ListaOrdenada,ListaFinal),obtenerMayor(ListaFinal,Default).
obtenerMayor([(A,(B,C))|T],Default):- Default = C.

/*
Ahora tengo que generar el arbol de decision
ALGORITMO:

    generarArbolDecision(ejemplos,atributos,default)
        si ejemplos esta vacio
            retornar default
        sino
            si todos los ejemplos tienen la misma clasificacion
                retornar clasificacion
            sino
                best = elegirAtributo(atributos,ejemplos)
                arbol = arbol con raiz best
                para cada Vi de best hacer
                    ejemplos = {elementos de examples con best = Vi}
                    subArbol = generarArbolDecision(ejemplos,atributos-best,majority_values(ejemplosI))
                    añadir una rama a arbol con etiqueta Vi y subarbol subArbol
                fin
        retornar arbol
*/

generarArbolDecisionShell(Default) :- 
                                    findall((ID,Atributos,Clasificacion),ejemplo(ID,Atributos,Clasificacion),ListaEjemplos),
                                    findall(Atributos,ejemplo(1,Atributos,_),ListaAtributos),
                                    nth0(0,ListaAtributos,Lista),
                                    recuperarAtributosShell(Lista,ListaFinalAtributos),
                                    nl,
                                    writeln(ListaFinalAtributos),
                                    generarArbolDecision(ListaEjemplos,ListaFinalAtributos,Default).

generarArbolDecision(ListaEjemplos,ListaAtributos,Default):-length(ListaEjemplos,Size),Size==0,writeln(Default).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default):-verificarIgualesShell(ListaEjemplos).
generarArbolDecision(ListaEjemplos,ListaAtributos,Default):-writeln("Caso General").

recuperarAtributosShell(ListaAtributos,ListaFinal):-recuperarAtributos(ListaAtributos,_,ListaFinal).
recuperarAtributos([],ListaIntermedia,ListaFinal):- ListaFinal = ListaIntermedia.
recuperarAtributos([(Atributo,Valor)|T],ListaIntermedia,ListaFinal):- ListaAux=[Atributo],append(ListaIntermedia,ListaAux,ListaNueva),recuperarAtributos(T,ListaNueva,ListaFinal).

/*
Tengo que buscar en la lista de ejemplos, todos los que tengan el atributo actual
*/
auxiliar(ListaAtributos,ListaEjemplos):-searchAttribute(ListaAtributos,ListaEjemplos).
searchAttribute([],ListaEjemplos).
searchAttribute([Attr|Tail],ListaEjemplos):-findall((Attr,Valor,Calificacion),(member((ID,L,(_,Calificacion)),ListaEjemplos),member((Attr,Valor),L)),ListaNueva),
                    findall(Clasificacion,member((_,_,(_,Clasificacion)),ListaEjemplos),ListaClasificacion),
                    sort(ListaClasificacion,ListaClasificacionSinRepetidos),
                    write("Atributo: "),
                    writeln(Attr),
                    buscarTotalAtributosPorClasificacion(ListaClasificacionSinRepetidos,Attr,ListaNueva),searchAttribute(Tail,ListaEjemplos).
buscarTotalAtributosPorClasificacion([],Attr,Lista).
buscarTotalAtributosPorClasificacion([Clasificacion|T],Attr,Lista):-findall(Value,member((_,Value,_),Lista),ListaValores),
                                                                    sort(ListaValores,ListaValoresSinRepetidos),
                                                                    buscarTotal(ListaValoresSinRepetidos,Lista),
                                                                    write("Clasificacion: "),
                                                                    write(Clasificacion),
                                                                    buscarParcial(Clasificacion,ListaValoresSinRepetidos,Attr,Lista),
                                                                    buscarTotalAtributosPorClasificacion(T,Attr,Lista).
buscarTotal([],Lista).
buscarTotal([Valor|T],Lista):-
                            findall(Valor,member((_,Valor,_),Lista),ListaNueva),
                            length(ListaNueva,Size),
                            write("Valor: "),
                            write(Valor),
                            write(" Total: "),
                            writeln(Size),
                            buscarTotal(T,Lista).
buscarParcial(Clasificacion,[],Attr,Lista).
buscarParcial(Clasificacion,[Valor|T],Attr,Lista):-
                            findall(Valor,member((Attr,Valor,Clasificacion),Lista),ListaEncontrada),
                            length(ListaEncontrada,Size),
                            write(" Valor: "),
                            write(Valor),
                            write(" Cantidad: "),
                            writeln(Size),
                            buscarParcial(Clasificacion,T,Attr,Lista).

/*Utilidades*/
isEmpty(Str):-at_end_of_stream(Str).
leer(InputFile) :- open(InputFile, read, Str), read_file(Str,Lines), close(Str),!.
read_file(Stream,[]) :- at_end_of_stream(Stream).
read_file(Stream,[X|L]) :- \+ at_end_of_stream(Stream), read(Stream,X), call(X), read_file(Stream,L).
verificarIgualesShell([(_,_,(_,E))|T]):-verificarIguales(T,E).
verificarIguales([],E).
verificarIguales([(_,_,(_,Calificacion))|T],E):-Calificacion==E,verificarIguales(T,E).
replaceP(_, _, [], []).
replaceP(O, R, [O|T], [R|T2]) :- replaceP(O, R, T, T2).
replaceP(O, R, [H|T], [H|T2]) :- dif(H,O), replaceP(O, R, T, T2).