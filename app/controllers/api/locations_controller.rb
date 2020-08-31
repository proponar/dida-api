class Api::LocationsController < Api::BaseController
  def search
    # binding.pry
    # jednoduche hledani v nazvu obce
    locations = (
      params[:id].present? ?
        Location.find_by_sql([
          "select naz_obec, kod_obec from #{Location.table_name} where naz_obec ilike ?",
          params[:id] + '%'
        ]) : Location
    ).select(:naz_obec, :kod_obec)

    render json: {message: 'Loaded all matching locations', data: locations}, status: 200

    # potrebujeme i casti obci
    # Location.connection.select_all( ... ) .to_hash
  end
end
