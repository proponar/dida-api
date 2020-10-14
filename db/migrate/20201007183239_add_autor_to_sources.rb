class AddAutorToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :autor, :string
  end
end
