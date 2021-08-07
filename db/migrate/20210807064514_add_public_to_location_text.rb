class AddPublicToLocationText < ActiveRecord::Migration[6.0]
  def change
    add_column :location_texts, :public, :int
  end
end
