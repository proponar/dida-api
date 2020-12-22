class AddMeaningToExemps < ActiveRecord::Migration[6.0]
  def change
    # FIXME: need to update to 'null: false'
    add_reference :exemps, :meaning, null: true, foreign_key: true
  end
end
