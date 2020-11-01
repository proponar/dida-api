class Api::LocationsController < Api::BaseController
  def search
    # jednoduche hledani v nazvu obce
    locations =
      params[:id].present? ?
        Location.find_by_sql([
          "select naz_obec, kod_obec, kod_okres from #{Location.table_name} where naz_obec ilike ?",
          params[:id] + '%'
        ]) : Location.select(:naz_obec, :kod_obec, :kod_okres)

    locations = locations.as_json.map do |l|
      l['zk_okres'] = Location.kodOk2names[l['kod_okres'].to_i]&.at(1)
      l
    end

    render json: {message: 'Loaded all matching locations', data: locations}, status: 200
  end

  # GET /api/locations/:location_id/parts(.:format) api/locations#parts
  def parts
    obec_id = params[:location_id].to_s.strip

    if obec_id.present?
      obec_id = (obec_id =~ /^[0-9]+$/) ? obec_id : Location.where(:kod_obec => obec_id.to_s).select(:naz_obec).first
    end

    if obec_id.empty?
      render json: {message: "Obec nebyla nalezena."}, status: 422
    else
      results = Location.connection.select_all(
        "select naz_cob, kod_cob from n3_casti_obce_polygony where kod_obec = $1 order by naz_cob",
        'SQL',
        [[nil, obec_id]]
      ).to_a

      count = results.length
      render json: {message: "Nalezeno #{count} částí obce.", count: count, data: results}
    end
  end
end
