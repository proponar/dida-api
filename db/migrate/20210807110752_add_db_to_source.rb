class AddDbToSource < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :db, :bigint
    Source.update_all(:db => 1)
  end
end
