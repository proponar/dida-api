class CreateExemps < ActiveRecord::Migration[6.0]
  def change
    create_table :exemps do |t|
      t.string :exemplifikace
      t.integer :author_id
      t.integer :entry_id
      t.integer :author_id
      t.boolean :vetne
      t.integer :zdroj_id
      t.integer :lokalizace_obec #(vazebni: cislo obce, cislo casti obce, ), alternativne okres? a text
      t.integer :lokalizace_cast_obce
      t.string :lokalizace_text
      t.string :rok # rok, nebo rozmezi let, nebo prazdne
      t.string :vyznam
      t.boolean :aktivni
      t.boolean :chybne

      t.timestamps
    end
  end
end
