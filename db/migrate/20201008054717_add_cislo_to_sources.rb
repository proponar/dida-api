class AddCisloToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :cislo, :int
  end
end
