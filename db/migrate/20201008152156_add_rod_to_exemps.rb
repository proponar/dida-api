class AddRodToExemps < ActiveRecord::Migration[6.0]
  def change
    add_column :exemps, :rod, :int
  end
end
