class AddMultipleToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :heslo, :string
    add_column :entries, :kvantifikator, :string
    add_column :entries, :vyznam, :string
    add_column :entries, :vetne, :bool
    add_column :entries, :druh, :int
    add_column :entries, :rod, :int
  end
end
