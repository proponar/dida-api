class AddTvaryToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :tvary, :string
  end
end
