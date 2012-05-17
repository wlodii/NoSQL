
 
m = function() {
	emit(this.Developer=='Microsoft', 1);
};

r = function(key, values) {
var sum = 0;
values.forEach(function(count) {
sum += count;
});
return sum;
};

wynik = db.couch.mapReduce(m, r, {out: "solution"});
printjson(wynik);
