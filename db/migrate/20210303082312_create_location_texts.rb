class CreateLocationTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :location_texts do |t|
      t.int :cislo
      t.string :identifikator
      t.string :presentace
      t.text :definice
      t.string :zdroje

      t.timestamps
    end
  end
end
