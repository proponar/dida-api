class Api::ExempsController < Api::BaseController
  # The number of exemps for entry is in thousands, but each record is relatively short (hundreds bytes?)
  # Do we need pagination here? What is the average length of the exemplification?
  def index
    exemp = add_db_scope(Exemp)
    entries = exemp.where(:entry_id => params[:entry_id]).
      order(:id).
      left_joins([:location_text, :location, :location_part]).
      includes([:user, :meaning, :source, :location_text, :location, :location_part, {:entry => :meanings}]).
      with_attached_attachments.
      map(&:json_hash)

    render json: {message: 'Nahrány všechny exemplifikace.', data: entries}, status: 200
  end

  # POST   /api/entries/:entry_id/exemps(.:format)  api/exemps#create
  #        /api/entries/9/exemps
  def create
    soft_params = params.permit!
    kod_obec = params[:lokalizace_obec_id]
    kod_cast = params[:lokalizace_cast_obce_id]
    e = Exemp.new(add_db_field({
      :user => current_user,
      :entry_id => params[:entry_id],
      :zdroj_id => params[:zdroj_id], # cislo zdroje
      :meaning_id => params[:meaning_id],
      :lokalizace_obec => kod_obec,
      :lokalizace_cast_obce => kod_cast,
      :location_text_id => params[:lokalizace_text_id],
    }).update(
      soft_params.slice(*%i(rok kvalifikator exemplifikace vyznam vetne aktivni rok urceni lokalizace_text))
    ))
    e.save!
    render json: { message: 'exemp created', data: e }, status: 201
  end

  def update
    exemp = add_db_scope(Exemp)
    e = exemp.find(params[:id])

    soft_params = params.permit!
    kod_obec = params[:lokalizace_obec_id]
    kod_cast = params[:lokalizace_cast_obce_id]
    e.update({
      :user => current_user,
      :zdroj_id => params[:zdroj_id], # cislo zdroje
      :meaning_id => params[:meaning_id],
      :lokalizace_obec => kod_obec,
      :lokalizace_cast_obce => kod_cast,
      :location_text_id => params[:lokalizace_text_id],
    }.update(
      soft_params.slice(*%i(rok kvalifikator exemplifikace vyznam vetne aktivni rok urceni lokalizace_text))
      )
    )
    render json: { message: 'exemp updated', data: e }, status: 200
  rescue => e
    render json: { message: "could not update exemp: #{e.message}" }, status: 400
  end

  def destroy
    exemp = add_db_scope(Exemp)
    e = exemp.find(params[:id])
    e.delete
    render json: { message: "Exemplifikace smazána" }, status: 200
  rescue => e
    render json: { message: "Nepodařilo se smazat exemplifikaci: #{e.message}" }, status: 400
  end

  # /api/entries/:entry_id/exemps/:exemp_id/attach(.:format)
  def attach
    attachment_data_io = request.body #.read
    exemp = add_db_scope(Exemp)
    e = exemp.find(params[:exemp_id])

    e.attachments.attach( #attachment_data)
      io: attachment_data_io, #File.open('/path/to/file'),
      filename: URI::unescape(request.headers['X-File-Name']),
      #content_type: 'application/pdf',
      identify: true # automatically figure content_type? TODO: verify
    )

    render json: {message: "Příloha byla připojena"}, status: 200
  rescue => e
    render json: { message: "Nepodařilo se připojit soubor: #{e.message}" }, status: 400
  end

  def detach
    exemp = add_db_scope(Exemp)
    e = exemp.find(params[:exemp_id])

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

  def coordinates
    exemp = add_db_scope(Exemp)
    e = exemp.find(params[:exemp_id])
    render json: { coordinates: e.coordinates }
  rescue => e
    render json: { message: "Nepodařilo se najít exemplifikaci: #{e.message}" }, status: 400
  end

  def exemps_to_csv(l)
    attributes  = %i(exemplifikace druh heslo urceni lokalizace_format lokalizace_text zdroj_id zdroj_name rok vyznam vetne aktivni time)
    col_headers = %i(exemplifikace druh heslo urceni lokalizace_format oblast zdroj_id zdroj_name rok vyznam vetne aktivni time)

    CSV.generate(headers: true) do |csv|
      csv << col_headers
      l.each do |s|
        csv << attributes.map { |a| s[a.to_sym] }
      end
    end
  end

  DOC_EXPORTER = Rails.root.join('exporter', 'doc-exporter.sh')
  def exemps_to_word(l)
    IO.popen(DOC_EXPORTER.to_s, 'r+') do |io|
      io.write(l.to_json)
      io.close_write
      io.read
    end
  end

  MAX_RESULTS_UI = 2000
  MAX_RESULTS_EXPORT = 5000
  def search
    filter = params.permit({
      :entry => [:heslo, :id]},
      :vetne, :rok, :exemp,
      :oblast => [:cislo],
      :obec => [:lokalizace_obec_id],
      :castObce => [:lokalizace_cast_obce_id],
    )

    export_to_word = params[:w] == '1'
    export_to_csv = params[:d] == '1'

    query = add_db_scope(Exemp)
    query = query.where(:entry_id => filter[:entry][:id]) if filter.key?(:entry) && filter[:entry].key?(:id) # FIXME: povolit hvezdicky?
    query = query.where(:rok => filter[:rok])     if filter.key?(:rok)
    query = query.where(:vetne => filter[:vetne]) if filter.key?(:vetne)
    if filter.key?(:exemp)
      filter = filter[:exemp].gsub('*', '%')
      query = query.where('exemps.exemplifikace ilike ?', filter)
    end

    query = query.
      joins([:user, {:entry => :meanings}]).
      left_joins([:meaning, :source]).
      left_joins([:location_text, :location, :location_part]).
      preload(:location_text, :location, :location_part).
      includes(:user, :meaning, :source, {:entry => :meanings})

    query = query.where(:n3_obce_body => {:kod_obec => filter[:obec][:lokalizace_obec_id]}) if filter.key?(:obec)
    query = query.where(:location_texts => {:cislo => filter[:oblast][:cislo]}) if filter.key?(:oblast)
    query = query.where(:n3_casti_obce_body => {:kod_cob => filter[:castObce][:lokalizace_cast_obce_id]}) if filter.key?(:castObce)

    if export_to_word
      # V rámci hesla bychom chtěli seřadit podle významů,
      # v rámci významů podle pádů (určení) prvního výskytu pádu v exemplifikaci.
      # potom podle lokalizace
      query = query.order(
        :heslo, 'meanings.cislo', 'urceni_sort',
        "coalesce(#{Location.table_name}.naz_obec, location_texts.identifikator)")
    else
      # primárně podle hesla (abecedně)
      # sekundárně podle určení (předřadit 1, 2, 3 sg. před 1, 2, 3 pl.)
      # terciární podle lokalizace (abecedně)
      # (případně kvartérně podle zdroje)
      query = query.order(:heslo, 'urceni_sort', "#{Location.table_name}.naz_obec", 'sources.name')
    end

    total = query.count
    max_results = export_to_word || export_to_csv ? MAX_RESULTS_EXPORT : MAX_RESULTS_UI
    entries = query.limit(max_results).with_attached_attachments

    if export_to_csv
      send_data(exemps_to_csv(entries.map(&:json_hash)), :filename => 'exemps-filtered.csv')
    elsif export_to_word
      send_data(exemps_to_word(entries.map(&:json_hash_full)), :filename => 'exemps-filtered.docx')
    else
      message = total > max_results ?
        "Načteno #{max_results} výsledků z celkového počtu #{total}" : 'Načteny všechny výsledky.'
      render json: {message: message, data: entries.map(&:json_hash), total: total}, status: 200
    end
  end
end
