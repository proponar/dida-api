class AddLokalizaceCastObceToSource < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :lokalizace_cast_obce, :integer
  end
end
