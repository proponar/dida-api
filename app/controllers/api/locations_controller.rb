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

  def parts
    obec_id = params[:id]
    obec_id = (obec_id =~ /^[0-9]+$/) ? obec_id : Location.where(:naz_obec => obec_id.to_s).select(:id).first

    binding.pry
    if obec_id.empty?
      render json: {message: "#{e.message} Obec nebyla nalezena."}, status: 422
    else
      binding.pry
      results = Location.connection.select_all(
        ["select * from n3_casti_obce_polygony where kod_obec = '?'", obec_id]
      ).to_hash

      # FIXME: pole, pocet
      render json: {message: "Nalezeno #{10} částí obce.", count: 10, data: results}
    end
  end
end
