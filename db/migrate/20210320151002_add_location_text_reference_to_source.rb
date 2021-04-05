class AddLocationTextReferenceToSource < ActiveRecord::Migration[6.0]
  def change
    add_reference :sources, :location_text, null: true, foreign_key: false
  end
end
