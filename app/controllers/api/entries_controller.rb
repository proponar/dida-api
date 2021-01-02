class Api::EntriesController < Api::BaseController
  # The total number of entries in in the rage of lower hundreds (< 1.000)
  # therefor no pagination is needed.
  def index
    entries = Entry.includes(:user).order(:heslo).all.map &:json_entry
    render json: {message: 'Loaded all entries', data: entries}, status: 200
  end

  def show
    render json: Entry.includes(:user, :exemps).find(params[:id]).json_hash
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Heslo nebylo nalezeno.' }, status: 404
  end

  def create
    soft_params = params.permit!
    entry_data = soft_params[:entry].permit!

    entry = Entry.new(
      {
        :user => current_user,
        :rod  => Entry.map_rod(entry_data[:rod]),
        :druh => Entry.map_druh(entry_data[:druh]),
      }.update(entry_data.slice(:heslo, :vetne, :kvalifikator, :vyznam, :tvary, :urceni)))
    entry.save!

    if soft_params.key?(:exemps)
      exemps_data = soft_params[:exemps].permit!
      exemps_data.keys.each do |k, o|
        kod_obec = exemps_data[k][:lokalizace_obec_id]
        e = Exemp.new(
          {
            :user => current_user,
            :entry => entry,
            :lokalizace_obec => kod_obec,
          }.update(
            exemps_data[k].permit(%i(rok kvalifikator exemplifikace vyznam vetne aktivni rok))
          )
        )
        e.save!
      end
    end

    render json: { message: 'Heslo uloženo.', data: entry }, status: 201
  rescue => e
    render json: { message: "Heslo nebylo možné uložit: #{e.message}" }, status: 422
  end

  def update
    soft_params = params.permit!
    entry_data = soft_params[:entry].permit!

    entry = Entry.find(params[:id])

    if soft_params.key?(:meanings)
      meanings_data = soft_params[:meanings] #.permit!
      (ok, message) = entry.valid_meanings_data?(meanings_data)
      if ok
        entry.replace_meanings(meanings_data)
      else
        render json: { message: "Významy nelze aktualitovat: #{message}", data: entry }
        return
      end
    end

    entry.update(
      {
        :user => current_user,
        :rod  => Entry.map_rod(entry_data[:rod]),
        :druh => Entry.map_druh(entry_data[:druh]),
      }.update(entry_data.slice(:heslo, :vetne, :kvalifikator, :vyznam, :tvary, :urceni)))
    entry.save!

    # if soft_params.key?(:exemps)
    #   exemps_data = soft_params[:exemps].permit!
    #   entry.exemps.delete_all
    #   exemps_data.keys.each do |k, o|
    #     kod_obec = exemps_data[k][:lokalizace_obec_id]
    #     e = Exemp.new(
    #       {
    #         :user => current_user,
    #         :entry => entry,
    #         :lokalizace_obec => kod_obec,
    #       }.update(
    #         exemps_data[k].slice(:rok, :kvalifikator, :exemplifikace, :vyznam, :vetne, :aktivni, :rok)
    #       )
    #     )
    #     e.save!
    #   end
    # end

    render json: { message: 'Heslo bylo aktualizováno', data: entry }
  rescue => e
    logger.error("Exception: #{e.message}")
    logger.error(e.backtrace.join("\n"))
    render json: { message: "Heslo nebylo možné aktualizovat: #{e.message}" }, status: 400
  end

  def destroy
    Entry.find(params[:id]).destroy
    render status: 204
  rescue => e
    render json: { message: "Heslo nebylo možné smazat: #{e.message}" }, status: 400
  end

  # import exemplifikaci do hesla
  # api_entry_import POST   /api/entries/:entry_id/import(.:format)   api/entries#import
  def import
    dry_run = params[:dry_run] != 'false'

    results = Entry.import_text(
      params[:entry_id],
      current_user,
      request.body.read.force_encoding('UTF-8'),
      dry_run
    )

    count = results.length
    render json: {
      message: "imported #{count} entries",
      count: count,
      data: results.map { |e| e.json_hash }
    }
  rescue => e
    render json: { message: "Exemplifikace nebylo možné importovat: #{e.message}" }, status: 400
  end

  def tvar_map
    e = Entry.find(params[:id])
    render json: {
      :map => Entry.calculate_tvar_map(e.tvary, e.urceni)
    }, status: 400
  end

  private
  def entry_params
    params.permit(%i(rod druh heslo vetne kvalifikator vyznam))
  end
end
