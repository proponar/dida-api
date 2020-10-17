class AddNameProcessedToSources < ActiveRecord::Migration[6.0]
  def change
    add_column :sources, :name_processed, :string
  end
end
