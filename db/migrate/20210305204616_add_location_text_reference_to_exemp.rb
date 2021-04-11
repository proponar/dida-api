class AddLocationTextReferenceToExemp < ActiveRecord::Migration[6.0]
  def change
    add_reference :exemps, :location_text, null: true, foreign_key: false
  end
end
