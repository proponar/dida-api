class AddTvarMapToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :tvar_map, :string
  end
end
