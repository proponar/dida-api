class AddUrceniSortToExemps < ActiveRecord::Migration[6.0]
  def change
    add_column :exemps, :urceni_sort, :int
  end
end
