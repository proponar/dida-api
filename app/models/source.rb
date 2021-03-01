class Source < ApplicationRecord
  include SourceGuesser

  def self.to_csv
    attributes = %i(cislo autor name nazev2 typ rok rok_sberu lokalizace lokalizace_text)

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |s|
        csv << attributes.map { |a| s.send(a) }
      end
    end
  end

  before_save :process_name

  def process_string(str)
    I18n.transliterate(str.to_s.strip.sub(/[;\.;]$/, ''))
  end

  def process_name
    self.name_processed = process_string(self.name)
    self.nazev2_processed = process_string(self.nazev2)
  end

  # FIXME using https://mattboldt.com/importing-massive-data-into-rails/
  def self.csv_import(data)
    counter = 0
    CSV.parse(data, headers: true) do |rec|
      if rec[8]
        kod_obec, kod_cast = Location::guess_lokalizace(rec[8])
      else
        kod_obec = nil
        kod_cast = nil
      end

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
        lokalizace_obec: kod_obec,
        rok_sberu: rec[9],
        lokalizace_cast_obce: kod_cast,
      })
      s.save!
      counter += 1
    end
    counter
  end

  def format_json
    attributes.update(
      lokalizace_obec_text: Location.naz_obec_with_zkr(lokalizace_obec),
      lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
    )
  end
end
