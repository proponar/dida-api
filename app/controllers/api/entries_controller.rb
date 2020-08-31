class Api::EntriesController < Api::BaseController
  # The total number of entries in in the rage of lower hundreds (< 1.000)
  # therefor no pagination is needed.
  def index
    entries = Entry.all
    render json: {message: 'Loaded all entries', data: entries}, status: 200
  end

  def show
    render json: Entry.includes(:exemps).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'could not find entry' }, status: 404
  end

  def create
    soft_params = params.permit!
    entry = Entry.new(
      { user => current_user }
        .update(soft_params.slice(:rod, :druh, :heslo, :vetne, :kvalifikator, :vyznam)))
    entry.save!

    exemps_data = soft_params[:exemps].permit!

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
  rescue
    render json: { message: 'could not create entry' }, status: 422
  end

  def update
    entry = Entry.find(params[:id])
    entry.update(entry_params)
    render json: { message: 'entry updated', data: entry }
  rescue
    render json: { message: 'could not update entry' }, status: 400
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
