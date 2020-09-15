class Api::EntriesController < Api::BaseController
  # The total number of entries in in the rage of lower hundreds (< 1.000)
  # therefor no pagination is needed.
  def index
    entries = Entry.includes(:user).all.map &:json_entry
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
    exemps_data = soft_params[:exemps].permit!

    entry = Entry.new(
      {
        :user => current_user,
        :rod  => Entry.map_rod(entry_data[:rod]),
        :druh => Entry.map_druh(entry_data[:druh]),
      } .update(entry_data.slice(:heslo, :vetne, :kvalifikator, :vyznam)))
    entry.save!

    exemps_data.keys.each do |k, o|
      { :user => current_user, :entry => entry }.update(exemps_data["0"])
      e = Exemp.new(
        {
          :user => current_user,
          :entry => entry
        }.update(
          exemps_data[k].permit(%i(rok kvalifikator exemplifikace vyznam vetne))
        )
      )
      e.save!
    end

    render json: { message: 'entry created', data: entry }, status: 201
  rescue => e
    render json: { message: "could not create entry #{e.message}" }, status: 422
  end

  def update
    entry = Entry.find(params[:id])
    entry.update(entry_params)
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

  private
  def entry_params
    # {"rod"=>"m", "druh"=>"subst", "heslo"=>"klesloxxx", "vetne"=>true, "kvalifikator"=>"kvlf.", "vyznam"=>"vyznam...ss",
    params.permit(%i(rod druh heslo vetne kvalifikator vyznam))
  end
end
