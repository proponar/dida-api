class Source < ApplicationRecord
  def self.to_csv
    attributes = %i(cislo name autor typ rok lokalizace)

    CSV.generate(headers: true) do |csv|
      csv << attributes
      all.each do |s|
        csv << attributes.map { |a| s.send(a) }
      end
    end
  end

  def self.column_order
    %w(cislo autor name nazev2 rok bibliografie typ lokalizace_text lokalizace rok_sberu)
  end
end
