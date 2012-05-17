
##DANE

Dane zostały pobrane z :
http://www.freebase.com/view/computer/views/software
w postaci pliku .CSV (software).
Dane zawierają informacje na temat oprogramowania komputerowego .

##Import danych do bazy Couchdb
Uzywamy skryptu csv2couchdb.rb :
```
$  ruby csv2couchdb.rb
```
Domyślnie ustawione pobieranie danych z pliku  "software" i zapisu danych do bazy CouchDB o nazwie "bazasoft".
Domyślny port 5984 dla Couchdb.
## Przenoszenie danych z baz CouchDB do MongoDB

Korzystamy ze skryptu c2m.rb :
```
$  ruby c2m.rb
```
Domyślnie konwertuje dane z bazy CouchDB "bazasoft" do bazy MongoDB "bcouch" i kolekcji "couch".

## MapReduce 
Funkcja MapReduce zwraca ilość wystąpień (domyslnie ustawionego "Microsoft") oprogramowania danego producenta. 

Dla MongoDB uzywamy skryptu:
```
$ mongo mongoMapReduce.js --shell
```
Dane zapisywane są w kolekcji "solution".
Uruchamiamy powłokę mongo :
```
> db.solution.find();
```

Dla CouchDB uzywamy polecenia :
```
$ node couchMapReduce.js
```
Wyniki zostaną przedstawione na ekranie.