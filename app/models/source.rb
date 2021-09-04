class Source < ApplicationRecord
  belongs_to :location_text, primary_key: 'cislo', required: false

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
  def self.csv_import(data, db)
    counter = 0
    CSV.parse(data, headers: true) do |rec|
      next if rec[0] !~ /^\d+$/ # safeguard for invalid rows or duplicate header

      #                 0                       4                 7          8
      # attributes = %i(cislo autor name nazev2 typ rok rok_sberu lokalizace lokalizace_text)

      lokalizace = rec[7]
      if lokalizace
        kod_obec, kod_cast = Location::guess_lokalizace(lokalizace)
      else
        kod_obec = nil
        kod_cast = nil
      end

      lokalizace_text = rec[8]
      location_text = LocationText.where(:identifikator => lokalizace_text)&.first

      s = Source.create({
        cislo: rec[0],
        autor: rec[1],
        name: rec[2],
        nazev2: rec[3],
        typ: rec[4],
        rok: rec[5],
        rok_sberu: rec[6],

        lokalizace: lokalizace,    # textova lokalizace
        lokalizace_obec: kod_obec, # parsovana obec
        lokalizace_cast_obce: kod_cast, # a cast

        lokalizace_text: lokalizace_text, # textova varianta LocationText
        location_text: location_text,     # vazba pres 'cislo' LocationText

        bibliografie: nil, # rec[5],

        db: db,
      })
      s.save!
      counter += 1
    end
    counter
  end

  def json_short
    attributes
  end

  def format_json
    attributes.update(
      lokalizace_obec_text: Location.naz_obec_with_zkr(lokalizace_obec),
      lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
    )
  end
end
