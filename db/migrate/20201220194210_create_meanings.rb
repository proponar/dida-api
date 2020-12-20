class CreateMeanings < ActiveRecord::Migration[6.0]
  def change
    create_table :meanings do |t|
      t.integer :cislo
      t.string :vyznam
      t.string :kvalifikatory
      t.references :entry, null: false, foreign_key: true

      t.timestamps
    end
  end
end
