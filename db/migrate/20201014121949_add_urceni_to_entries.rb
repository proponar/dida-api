class AddUrceniToEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :entries, :urceni, :string
  end
end
