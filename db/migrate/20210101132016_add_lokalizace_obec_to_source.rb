class AddLokalizaceObecToSource < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :lokalizace_obec, :string
  end
end
