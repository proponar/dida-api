class AddDbToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :db, :bigint
    User.update_all(:db => 1)
    add_column :entries, :db, :bigint
    Entry.update_all(:db => 1)
    add_column :exemps, :db, :bigint
    Exemp.update_all(:db => 1)
    add_column :meanings, :db, :bigint
    Meaning.update_all(:db => 1)
  end
end
