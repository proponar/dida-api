class Api::ExempsController < Api::BaseController
  # The number of exemps for entry is in thousands, but each record is relatively short (hundreds bytes?)
  # Do we need pagination here? What is the average length of the exemplification?
  def index
    entries = Exemp.where(:entry_id => params[:entry_id]).order(:id).includes(:user).map(&:json_hash)
    # entry = Entry.includes(:exemps => :user).where(:id => params[:entry_id])

    #entries = entry.exemps.map(&:json_hash)
    #   Entry.includes(:exemps => :user).where(:id => params[:entry_id])
    #   Entry.includes(:exemps, :exemps => :user).where(:id => params[:entry_id]).map(&:json_hash)
    render json: {message: 'Loaded all entries', data: entries}, status: 200
  end


  # POST   /api/entries/:entry_id/exemps(.:format)  api/exemps#create
  #        /api/entries/9/exemps
  def create
    soft_params = params.permit!
    kod_obec = params[:lokalizace_obec_id]
    kod_cast = params[:lokalizace_cast_obce_id]
    e = Exemp.new({
      :user => current_user,
      :entry_id => params[:entry_id],
      :zdroj_id => params[:zdroj_id],
      :lokalizace_obec => kod_obec,
      :lokalizace_cast_obce => kod_cast,
    }.update(
      soft_params.slice(*%i(rok kvalifikator exemplifikace vyznam vetne aktivni rok urceni lokalizace_text))
    ))
    e.save!
    render json: { message: 'exemp created', data: e }, status: 201
  end

  def update
    e = Exemp.find(params[:id])

    soft_params = params.permit!
    kod_obec = params[:lokalizace_obec_id]
    kod_cast = params[:lokalizace_cast_obce_id]
    e.update({
      :user => current_user,
      :zdroj_id => params[:zdroj_id],
      :lokalizace_obec => kod_obec,
      :lokalizace_cast_obce => kod_cast,
    }.update(
      soft_params.slice(*%i(rok kvalifikator exemplifikace vyznam vetne aktivni rok urceni lokalizace_text))
      )
    )
    render json: { message: 'exemp updated', data: e }, status: 200
  rescue => e
    render json: { message: "could not update exemp: #{e.message}" }, status: 400
  end

  def destroy
    e = Exemp.find(params[:id])
    e.delete
    render json: { message: "exemp deletes" }, status: 200
  rescue => e
    render json: { message: "could not update exemp: #{e.message}" }, status: 400
  end

  # /api/entries/:entry_id/exemps/:exemp_id/attach(.:format)
  def attach
    attachment_data_io = request.body #.read
    e = Exemp.find(params[:exemp_id])

    e.attachments.attach( #attachment_data)
      io: attachment_data_io, #File.open('/path/to/file'),
      filename: request.headers['X-File-Name'],
      #content_type: 'application/pdf',
      identify: true # automatically figure content_type? TODO: verify
    )

    render json: {message: "Příloha byla připojena"}, status: 200
  rescue => e
    render json: { message: "Nepodařilo se připojit soubor: #{e.message}" }, status: 400
  end

  def detach
    e = Exemp.find(params[:exemp_id])

    parms = JSON.parse(request.body.read)
    attachment_id = parms['attachment_id']
    filename = parms['filename']

    a = ActiveStorage::Attachment.find(parms['attachment_id'])
    unless a.filename == parms['filename']
      raise "Nesprávné parametry přílohy #{attachment_id}, #{filename}"
    end

    a.delete

    render json: {message: "Příloha byla odstraněna"}, status: 200
  rescue => e
    render json: { message: "Nepodařilo se odstranit přílohu: #{e.message}" }, status: 400
  end

end
