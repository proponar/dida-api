class Api::LocationTextsController < Api::BaseController
  # The total number of entries in in the rage hundreds (< 1.000)
  # therefor no pagination is needed.
  def index
    locs = LocationTexts.order(:cislo).all.map(&:format_json)
    render json: {message: 'Loaded all entries', data: locs}, status: 200
  end
end
