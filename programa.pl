
canal(ana, youtube, 3000000).
canal(ana, instagram, 2700000).
canal(ana, tiktok, 1000000).
canal(ana, twitch, 2).
canal(beto, twitch, 120000).
canal(beto, youtube, 6000000).
canal(beto, instagram, 1100000).
canal(cami, tiktok, 2000).
canal(dani, youtube, 1000000).
canal(evelyn, instagram, 1).

% influencer/1 se cumple para un usuario que tiene más de 10.000 seguidores en total entre todas sus redes.

influencer(Influencer):-
    usuario(Influencer),
    findall(Seguidor, canal(Influencer, _, Seguidor), Seguidores),
    sum_list(Seguidores, Suma),
    Suma > 10000.

usuario(Quien) :- distinct(Quien,canal(Quien, _, _)).

:- begin_tests(influencer).
 
 test(influencer, set(Influencer = [ana, beto, dani])) :-
   influencer(Influencer).
 
:- end_tests(influencer).


/*
omnipresente/1 se cumple para un influencer si está en cada red que existe (se consideran como existentes aquellas redes en las que haya al menos un usuario).
Por ejemplo, ana es omnipresente.
*/

omnipresente(Quien):-
    influencer(Quien),
    forall(red(Red), canal(Quien,Red,_)).

red(Red):- distinct(Red, canal(_, Red, _)).

:- begin_tests(omnipresente).
 
 test(omnipresente, set(Omni = [ana])) :-
   omnipresente(Omni).
 
:- end_tests(omnipresente).

/*exclusivo/1 se cumple cuando un influencer sólo está en una red. 
Por ejemplo, dani
*/

exclusivo(Quien):-
    influencer(Quien),
    not(estaEnDosRedes(Quien)).

estaEnDosRedes(Quien):-
    canal(Quien, Red1, _),
    canal(Quien, Red2, _), 
    Red1 \= Red2.

:- begin_tests(exclusivo).
 
 test(exclusivo, set(Exclu = [dani])) :-
   exclusivo(Exclu).
 
:- end_tests(exclusivo).


publicacion(ana, tiktok, video([beto, evelyn], 1)).
publicacion(ana, tiktok, video([ana], 1)).
publicacion(ana, instagram, foto([ana])). 
publicacion(beto, instagram, foto([])).
publicacion(cami, youtube, video([cami], 5)).
publicacion(cami, twitch, stream(leagueOfLegends)).
publicacion(evelyn, instagram, foto([cami, evelyn])).

esJuego(leagueOfLegends).
esJuego(minecraft).
esJuego(aoe).

/*
adictiva/1 se cumple para una red cuando sólo tiene contenidos adictivos (Un contenido adictivo es un video de menos de 3 minutos, un stream sobre una temática relacionada con juegos, o una foto con menos de 4 participantes).
*/

adictiva(Red):-
    red(Red),
    forall(publicacion(_,Red,Contenido), esAdictivo(Contenido)).

esAdictivo(stream(Tema)):-
    esJuego(Tema).
esAdictivo(video(_,Duracion)):-
    Duracion < 3.
esAdictivo(foto(Quienes)):-
    length(Quienes, Cant), 
    Cant < 4.

:- begin_tests(adictiva).
 
 test(adictiva, set(Red = [tiktok, instagram, twitch])) :-
   adictiva(Red).
 
:- end_tests(adictiva).

/*
colaboran/2 se cumple cuando un usuario aparece en las redes de otro (en alguno de sus contenidos). En un stream aparece sólo quien creó el contenido.
 Esta relación debe ser simétrica. (O sea, si a colaboró con b, entonces también debe ser cierto que b colaboró con a)*/

colaboran(Alguien, Otro):- 
    publicoContenidoCon(Alguien, Otro).
colaboran(Alguien, Otro):- 
    publicoContenidoCon(Otro, Alguien).

publicoContenidoCon(Alguien, Otro) :-
    publicacion(Alguien, _, Contenido), 
    estaEn(Alguien, Contenido, Otro).

estaEn(_, foto(Quienes), Quien):-
    member(Quien, Quienes).
estaEn(_, video(Quienes,_), Quien):-
    member(Quien, Quienes).
estaEn(Autor, stream(_), Autor).


/*
caminoALaFama/1 se cumple para un usuario no influencer cuando un influencer publicó contenido en el que aparece el usuario, o bien el influencer publicó contenido donde aparece otro usuario que a su vez publicó contenido donde aparece el usuario. Debe valer para cualquier nivel de indirección.
*/

caminoALaFama(Usuario):-
    publicoContenidoCon(Influencer, Usuario),
    influencer(Influencer),
    not(influencer(Usuario)).

caminoALaFama(Usuario):- 
    publicoContenidoCon(Otro, Usuario),
    Usuario \= Otro,
    not(influencer(Usuario)),
    caminoALaFama(Otro).

:- begin_tests(caminoALaFama).
 
 test(caminoALaFama, set(Caminante = [cami, evelyn])) :-
   caminoALaFama(Caminante).
 
:- end_tests(caminoALaFama).