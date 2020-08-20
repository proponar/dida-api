class Api::LocationsController < Api::BaseController
  def search
    # binding.pry
    # jednoduche hledani v nazvu obce
    locations = Location.find_by_sql([
      "select * from #{Location.table_name} where naz_obec ilike ?",
      params[:id] + '%'
    ])
    render json: {message: 'Loaded all matching locations', data: locations}, status: 200

    # potrebujeme i casti obci
    # Location.connection.select_all( ... ) .to_hash
  end
end
