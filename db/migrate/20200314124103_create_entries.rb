class CreateEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :entries do |t|
      t.text :text
      t.integer :author_id

      t.timestamps
    end
  end
end
