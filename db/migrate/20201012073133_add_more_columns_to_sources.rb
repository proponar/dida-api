class AddMoreColumnsToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :rok_sberu, :int
    add_column :sources, :nazev2, :string
    add_column :sources, :bibliografie, :string
    add_column :sources, :lokalizace_text, :string
  end
end
