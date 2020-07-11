class Api::EntriesController < ApplicationController

  # The total number of entries in in the rage of lower hundreds (< 1.000) therefor no pagination is needed.
  def index
    entries = Entry.all
    render json: {status: 'SUCCESS', message: 'Loaded all entries', data: enries}, status: :ok
  end 
end
