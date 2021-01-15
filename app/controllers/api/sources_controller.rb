class Api::SourcesController < Api::BaseController
  # The total number of entries in in the rage thousands (< 10.000)
  # therefor no pagination is needed.
  def index
    sources = Source.order(:cislo).all
    render json: {message: 'Loaded all entries', data: sources}, status: 200
  end

  def upload
    begin
      Source.delete_all
      counter = Source.csv_import(request.body.read.force_encoding('utf-8'))

      render json: {message: "#{counter} zdroje importovány", count: counter}, status: 200
    rescue CSV::MalformedCSVError => e
      render json: {message: "#{e.message} Zdroje nebyly importovány."}, status: 422
    end
  end

  def download
    send_data(Source.to_csv, :filename => 'zdroje.csv')
  end
end
