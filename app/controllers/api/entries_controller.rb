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
    render json: { message: 'could not find entry' }, status: 404
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

    render json: { message: 'entry created', data: entry }, status: 201
  rescue => e
    render json: { message: "could not create entry #{e.message}" }, status: 422
  end

  def update
    soft_params = params.permit!
    entry_data = soft_params[:entry].permit!

    entry = Entry.find(params[:id])
    entry.update(
      {
        :user => current_user,
        :rod  => Entry.map_rod(entry_data[:rod]),
        :druh => Entry.map_druh(entry_data[:druh]),
      }.update(entry_data.slice(:heslo, :vetne, :kvalifikator, :vyznam, :tvary, :urceni)))
    entry.save!

    if soft_params.key?(:exemps)
      exemps_data = soft_params[:exemps].permit!
      entry.exemps.delete_all
      exemps_data.keys.each do |k, o|
        kod_obec = exemps_data[k][:lokalizace_obec_id]
        e = Exemp.new(
          {
            :user => current_user,
            :entry => entry,
            :lokalizace_obec => kod_obec,
          }.update(
            exemps_data[k].slice(:rok, :kvalifikator, :exemplifikace, :vyznam, :vetne, :aktivni, :rok)
          )
        )
        e.save!
      end
    end

    render json: { message: 'entry updated', data: entry }
  rescue => e
    render json: { message: "could not update entry: #{e.message}" }, status: 400
  end

  def destroy
    Entry.find(params[:id]).destroy
    render status: 204
  rescue
    render json: { message: 'could not delete entry' }, status: 400
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
  end

  private
  def entry_params
    params.permit(%i(rod druh heslo vetne kvalifikator vyznam))
  end
end
