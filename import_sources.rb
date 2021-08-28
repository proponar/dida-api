#!/usr/bin/env ruby

class SourceImporter
  def self.import(file)
    data = File.read(file,nil)
    #data.sub!(/^L.*$/m,'')
    Source.csv_import(data)
  end
end

if $0 == __FILE__
  require 'csv'
  require File.expand_path('./config/environment.rb')
  Source.delete_all
  SourceImporter.import('./db/seed/dida-sources.csv')
end
