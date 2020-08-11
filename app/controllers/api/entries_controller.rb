class Api::EntriesController < Api::BaseController
  # The total number of entries in in the rage of lower hundreds (< 1.000)
  # therefor no pagination is needed.
  def index
    entries = Entry.all
    render json: {message: 'Loaded all entries', data: entries}, status: 200
  end 

  def show
    render json: Entry.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'could not find entry' }, status: 404
  end

  def create
    entry = Entry.new(entry_params)
    entry.user = current_user
    entry.save!
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
    params.permit(%i(heslo kvalifikator vyznam))
  end
end
