class Api::SourcesController < Api::BaseController
  # The total number of entries in in the rage thousands (< 10.000)
  # therefor no pagination is needed.
  def index
    sources = add_db_scope(Source).order(:cislo).all.map(&:format_json)
    render json: {message: 'Loaded all entries', data: sources}, status: 200
  end

  def upload
    begin
      source = add_db_scope(Source)
      source.delete_all
      counter = source.csv_import(request.body.read.force_encoding('utf-8'))

      render json: {message: "#{counter} zdroje importovány", count: counter}, status: 200
    rescue CSV::MalformedCSVError => e
      render json: {message: "#{e.message} Zdroje nebyly importovány."}, status: 422
    end
  end

  def download
    send_data(add_db_scope(Source).to_csv, :filename => 'zdroje.csv')
  end
end
