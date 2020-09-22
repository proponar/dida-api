class Api::SourcesController < Api::BaseController
  # The total number of entries in in the rage thousands (< 10.000)
  # therefor no pagination is needed.
  def index
    sources = Source.all
    render json: {message: 'Loaded all entries', data: sources}, status: 200
  end

  def upload
    counter = 0
    csv_data = request.body.read
    # FIXME using https://mattboldt.com/importing-massive-data-into-rails/
    begin
      CSV.parse(csv_data, headers: true) do |row|
        #Source.create(row.to_h)
        counter += 1
      end
      render json: {message: "#{counter} zdroje importovány", count: counter}, status: 200
    rescue CSV::MalformedCSVError => e
      render json: {message: "#{e.message} Zdroje nebyly importovány."}, status: 422
    end
  end

  def download
    send_data(Source.to_csv, :filename => 'zdroje.csv')
  end
end
