class AddNazev2ProcessedToSource < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :nazev2_processed, :string
  end
end
