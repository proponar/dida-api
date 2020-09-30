class Location < ApplicationRecord
  self.table_name = 'n3_obce_body'

  def self.naz_obec(kod_obec)
    Location.find_by_sql([
      "select naz_obec, kod_obec from #{table_name} where kod_obec = ?",
      kod_obec.to_s
    ]).first.try(:naz_obec)
  end

  def self.naz_cast(kod_cast)
    return "FIXME"
  end
end
