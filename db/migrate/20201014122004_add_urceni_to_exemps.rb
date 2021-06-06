class AddUrceniToExemps < ActiveRecord::Migration[6.0]
  def change
    add_column :exemps, :urceni, :jsonb
  end
end
