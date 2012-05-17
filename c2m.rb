#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

if RUBY_VERSION < "1.9.0"
  require 'rubygems'
end

require 'mongo'
require 'optparse'
require 'ostruct'
require 'pp'
require 'open-uri'
require 'yajl'

class OptparseCouch2Mongo
  Version = [0, 0, 1]
  #
  # return a structure describing the options
  #
  def self.parse(args)
    # the options specified on the command line will be collected in *options*.

    # set default values
    options = OpenStruct.new
    options.couchport = 5984
    options.couchdatabase = "bazasoft"
    options.couchhost = "localhost"
 
    options.mongoport = 27017
    options.mongodatabase = "bcouch"
    options.mongocollection = "couch"
    options.mongohost = "localhost"

    options.verbose = false
    
    @opts = OptionParser.new do |opts|
      opts.banner = "Użycie: #{$0} [OPCJE]"
      opts.separator ""
      opts.separator "---------------------------------------------------------------"
      opts.separator " Skrypt kopiuje bazę danych z CouchDB do MongoDB"
      opts.separator ""
      opts.separator " Przykłady:"
      opts.separator ""
      opts.separator " #{$0} -p 4000 -d qq"
      opts.separator ""
      opts.separator " #{$0} -p 4000 -v \\"
      opts.separator " -d qq -a 192.168.0.1 -o 13000 -m foo -c bar -j 192.168.0.2"

      opts.separator "---------------------------------------------------------------"
      opts.separator ""

      opts.on("-p", "--portc N", Numeric, "port na którym uruchomiono CouchDB (domyślnie: 5984)") do |n|
        options.couchport = n
      end
     
      opts.on("-d", "--databasec NAZWA", "nazwa bazy danych CouchDB w której sa zapisane dane (domyślnie: bazasoft)") do |name|
        options.couchdatabase = name
      end

      opts.on("-a", "--hostnamec ADRES", "nazwa hosta/adres serwera na którym umieszczona jest baza CouchDB (domyślnie: localhost)") do |host|
        options.couchhost = host
      end

      opts.on("-o", "--portm N", Numeric, "port na którym uruchomiono MongoDB (domyślnie: 27017)") do |n|
        options.mongoport = n
      end

      opts.on("-m", "--databasem NAZWA", "nazwa bazy danych MongoDB do której zostaną skopiowane dane (domyślnie: bcouch)") do |dname|
        options.mongodatabase = dname
      end

      opts.on("-c", "--collection NAZWA", "nazwa kolekcji w której zostaną zapisane dane (domyślnie: couch)") do |cname|
        options.mongocollection = cname
      end

      opts.on("-j", "--hostnamem ADRES", "nazwa hosta/adres serwera na którym umieszczona jest baza MongoDB (domyślnie: localhost)") do |host|
        options.mongohost = host
      end

      opts.separator ""
      opts.separator "Pozostałe opcje:"
      opts.separator ""

      opts.on_tail("-h", "--help", "wypisz pomoc") do
        puts opts
        exit
      end

      opts.on_tail("--version", "wypisz wersję") do
        puts OptparseCouch2Mongo::Version.join('.')
        exit
      end

      opts.on_tail("-v", "--[no-]verbose", "run verbosely") do |v|
        options.verbose = v
      end
    end

    @opts.parse!(args)
    options
  end # parse()

end # class Optparse

options = OptparseCouch2Mongo.parse(ARGV)

if options.verbose
  puts "Mongo #{options.mongohost}:#{options.mongoport}/#{options.mongodatabase}/#{options.mongocollection}"
  puts "Couch #{options.couchhost}:#{options.couchport}/#{options.couchdatabase}"
end
@mongo = Mongo::Connection.new(options.mongohost, options.mongoport).db(options.mongodatabase).collection(options.mongocollection)

@start="0"
@limit = 10000

begin

@records = Yajl::Parser.new.parse(open("http://#{options.couchhost}:#{options.couchport}/#{options.couchdatabase}/_all_docs?include_docs=true&ascending=true&limit=#{@limit}&startkey=" + URI.escape("\"#{@start}\"",Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))).read)

if @start != "0"
@records["rows"].shift(1)
else
puts "Rekordow do skopiowania: #{@records["total_rows"]}"
end

if options.verbose
puts "Kopiuje dane od rekordu id: #{@start}"
end

@records["rows"].delete_if { |e|
e["id"].include?("_design")
}

@records["rows"].each_slice(100) { |slice|
slice.map! { |item|
item["doc"].delete "_rev"
item["doc"].delete "chunk"
item = item["doc"]
}
@mongo.insert(slice)
}

if @records["rows"].length == 0
break
end

@start = (@records["rows"].last)["id"]

end while true

puts "Rekordów po skopiowaniu: #{@mongo.count}"


