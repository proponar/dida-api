#!/usr/bin/env ruby

class SourceImporter
  def self.import(file)
    data = File.read(file,nil)
    #data.sub!(/^L.*$/m,'')
    CSV.parse(data, headers: true) do |rec|
      s = Source.create({
        cislo: rec[0],
        autor: rec[1],
        name: rec[2],
        nazev2: rec[3],
        rok: rec[4],
        bibliografie: rec[5],
        typ: rec[6],
        lokalizace_text: rec[7],
        lokalizace: rec[8],
        rok_sberu: rec[9],
      })
      s.save!
    end
  end
end

if $0 == __FILE__
  require 'csv'
  require File.expand_path('./config/environment.rb')
  Source.delete_all
  SourceImporter.import('/home/martin/dida-sources.csv')
end
