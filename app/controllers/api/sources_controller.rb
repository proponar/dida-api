class Api::SourcesController < Api::BaseController
  # The total number of entries in in the rage thousands (< 10.000)
  # therefor no pagination is needed.
  def index
    sources = Source.all
    render json: {message: 'Loaded all entries', data: sources}, status: 200
  end 
end
