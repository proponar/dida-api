#!/usr/bin/env ruby

class LocationTextsImporter
  def self.import(file)
    data = File.read(file,nil)
    #data.sub!(/^L.*$/m,'')
    LocationText.csv_import(data)
  end
end

if $0 == __FILE__
  require 'csv'
  require File.expand_path('./config/environment.rb')
  LocationText.delete_all
  LocationTextsImporter.import('db/seed/lokalizace-textova.csv')
end
