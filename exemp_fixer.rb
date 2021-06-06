#!/usr/bin/env ruby

class ExempFixer
  def self.fix_exemps
    Exemp.all.each do |e|
      puts("#{e.id} : #{e.exemplifikace}")
      e.save
    end
  end
end

if $0 == __FILE__
  require File.expand_path('./config/environment.rb')
  ExempFixer.fix_exemps
end
