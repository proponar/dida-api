class LocationText < ApplicationRecord
  def format_json
    attributes #.update()
    #  t.int :cislo
    #  t.string :identifikator
    #  t.string :presentace
    #  t.text :definice
    #  t.string :zdroje
  end

  def self.all_allowed
    Rails.configuration.public ?
      LocationText.order(:cislo).where(:public => 1) : LocationText.order(:cislo).all
  end

  # číslo,seznam lokalit - oblastí,,číslo,lok. - oblast,+ č. zdroje,definovaná oblast,definice
  # 1,Blanensko,,1,Blanensko,,Blanensko,
  def self.csv_import(data)
    counter = 0
    CSV.parse(data, headers: true) do |rec|
      next if rec[1].to_s.strip.blank?
      s = LocationText.create({
        cislo: rec[0],
        identifikator: rec[1],
        presentace: rec[2],
        definice: rec[3],
        # zdroje: rec[4], // nemame
        public: rec[4] =~ /^ve/ ? 1 : 0
      })
      s.save!
      counter += 1
    end
    counter
  end
end
