class AddColumnsToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :typ, :string
    add_column :sources, :rok, :int
    add_column :sources, :lokalizace, :string
  end
end
