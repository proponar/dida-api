class Entry < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  has_many :exemps
  has_many :meanings
  has_paper_trail

  validates :heslo, presence: true, uniqueness: { scope: :db }

  before_save :process_tvar_map

  ROD_MAP = %w(m f n mf fn mn mplt fplt nplt mfplt fnplt mnplt)
  DRUH_MAP = ['subst', 'adj', 'sloveso', 'zajmeno', 'cislovka']

  def self.map_rod(str)
    ROD_MAP.index(str)
  end

  def self.map_druh(str)
    DRUH_MAP.index(str)
  end

  def json_entry
    {
      id: id,
      text: text || '',
      author_id: author_id,
      author_name: user.name,
      created_at: created_at,
      updated_at: updated_at,
      heslo: heslo,
      kvalifikator: kvalifikator || '',
      vyznam: vyznam || '',
      vetne: vetne,
      druh: DRUH_MAP[druh || 0],
      rod: ROD_MAP[rod || 0],
      tvary: tvary || '',
      urceni: urceni || '',
      tvar_map: tvar_map,
      meanings: meanings.map { |m| m.json_hash },
    }
  end

  def parsed_tvary
    @parsed_tvary ||= tvary.to_s.split(/\s+/).map { |t| t.sub(/-/, '') }
  end

  def parse_ex(str)
    str =~ /^\(/ ? parse_ex_bracket(str) : parse_ex_inline(str)
  end

  # (1 pl.) dejte si pozor,
  # (1 sg., 7 sg.) proč jen
  def parse_ex_bracket(str)
    md = str.match(/^\(([^)]+)\)\s+(.*)$/) # urceni a exemplifikace
    urceni_str = md[1]
    exemplifikace = md[2]

    urceni_list = urceni_str.strip.split(/,/).map(&:strip).map do |u|
      md = u.match(/^(\d)\.?\s+(pl|sg)\.?$/)
      md.nil? ? nil : { pad: md[1], cislo: md[2] }
    end.compact

    parts = exemplifikace.split(/([\s\.,!?]+)/)

    counter = 0
    filtered_parts = parts.collect do |part|
      if parsed_tvary.index(part)
        u = urceni_list[counter]
        counter += 1
        if u.present?
          "{#{part}, #{u[:pad]} #{u[:cislo]}.}"
        else
          "{#{part}}"
        end
      else
        part
      end
    end

    [filtered_parts.join(''), urceni_list]
  end

  # jedna {husa, 1 sg.}; Luhačovice ZL; Kolařík, Slovník Luhačovického Zálesí
  def parse_ex_inline(str)
    matched = str.scan(/[^{}]+(?=\})/)

    # => ["husách, 6 pl.", "husách, 1 sg."]
    urceni_list = matched.map(&:strip).map do |wu|
      word, u = wu.split(/,\s+/, 2)

      md = u&.match(/^(\d)\.?\s+(pl|sg)\.?$/)
      md.nil? ? nil : { pad: md[1], cislo: md[2] }
    end.compact

    [str, urceni_list]
  end

  # (1 pl.) dejte si pozor, je tam taková louš, co se husi v leťe koupou; Držkov JN; Bachmannová, Za života se stane ledacos
  # (1 sg., 7 sg.) proč jen se mu tolik chťelo na ten prašskej jarmark? Husa přeleťela móře a zústala přec jen husou; Jilemnice SM; Horáček, Nic kalýho zpod Žalýho
  def parse_exemp(line, user, meaning_id, vetne)
    parts = line.split(/;\s*/)

    exemplifikace, urceni = parse_ex(parts[0])
    if parts[1]
      kod_obec, kod_cast = Location.guess_lokalizace(parts[1])
    else
      kod_obec = nil
      kod_cast = nil
    end
    lokalizace_text = kod_obec.nil? ? (parts[1] || '') : ''
    location_text = LocationText.where(:identifikator => lokalizace_text)&.first

    source = Source.guess_source(parts[2]) # zdroj

    Exemp.new(
      db: user.db,
      user: user,
      entry_id: id,
      source: source,
      rok: source&.rok,
      lokalizace_obec: kod_obec,
      lokalizace_cast_obce: kod_cast,
      location_text: location_text,
      lokalizace_text: location_text && location_text.identifikator || '', # lokalizace_text,
      exemplifikace: exemplifikace,
      urceni: urceni.to_json,

      meaning_id: meaning_id,
      vetne: vetne,

      rod: self.rod,
      kvalifikator: self.kvalifikator,
      aktivni: true,
      chybne: false,
    )
  end

  def import_text(user, text_data, meaning_id, vetne, dry_run)
    # check if meaning_id is valid for this entry
    meaning = meanings.find { |m| m.id = meaning_id }
    raise "Neplatný význam." unless meaning.present?

    text_data.split("\n")
      .map(&:strip)
      .filter(&:present?)
      .each_with_object([]) do |line, results|

      begin
        ex = parse_exemp(line, user, meaning_id, vetne)
      rescue
        next unless dry_run

        # create fake record to report problem to the user
        ex = Exemp.new(
          user: user,
          entry_id: id,
          exemplifikace: "PROBLÉM: #{line}",
        )
      end

      if dry_run
        ex.id = results.length # temporary id
      else
        ex.save!
      end

      results << ex
    end
  end

  def self.calculate_tvar_map(tv, ur)
    tvary = tv.to_s.split(/\s+/).map { |t| t.gsub(/-/, '') }
    urceni = ur.to_s.split(/\.\s+/).map do |u|
      md = u.match(/^(\d)\.?\s+(pl|sg)\.?$/)
      md.nil? ? nil : { pad: md[1], cislo: md[2] }
    end

    if tvary.length != urceni.length
      return [:fail, "Počet tvaru #{tvary.length} neodpovídá počtu určení #{urceni.length}"]
    end

    tvar_map = {}
    tvary.each_with_index do |t, i|
      u = urceni[i]

      tvar_map[t] ||= []
      tvar_map[t] << u
    end

    [:ok, tvar_map]
  end

  def process_tvar_map
    code, tv_map = Entry.calculate_tvar_map(tvary, urceni)
    if code == :ok
      self.tvar_map = tv_map.to_json
    else
      logger.error("Failed to calculate tvar_map: '#{tv_map}'")
    end
  end

  def json_hash
    {
      entry: json_entry,
      exemps: exemps.map { |e| e.json_hash },
      meanings: meanings.map { |m| m.json_hash }
    }
  end

  # pokud existuje meaning s danym ID u TOHOTO hesla, aktualizujeme:
  #   cislo, vyznam, exemplifikaci
  #   musime zkontrolovat, ze mezi vstupnimi daty neni vic vyznamu se stejnym cislem
  #
  # pokud mazeme vyznam, musime se ujistit, ze u nej nejsou zadne exemplifikace
  def valid_meanings_data?(md)
    meaning_hash = md.each_with_object({}) do |m, acc|
      # kontrola duplicitnich cisel vyznamu
      cislo = m['cislo'].to_i
      if acc.key?(cislo)
        return [false, 'Duplicitní číslo významu.']
      end
      acc[cislo] = m

      # kontrola prislusnosti k heslu
      if m['id'].present?
        mn = Meaning.find(m['id'])
        if mn.entry_id != self.id
          return [false, 'Význam patří k jinému heslu.']
        end
      end
    end

    # kontola, ze nemazeme nejaky vyznam, ktery ma exemps
    vyznamy_ids = Exemp.where(entry_id: self.id, meaning_id: 'not null').pluck(:meaning_id)
    if 0 > (vyznamy_ids - meaning_hash.keys).length
      return [false, 'Nelze odstranit význam, pro který existují exemplifikace.']
    end

    [true, '']
  end

  def replace_meanings(md)
    seen_ids = md.each_with_object({}) do |m, acc|
      new_m = replace_or_create_meaning(m)
      acc[new_m.id] = new_m
    end

    # delete unseen
    delete_ids = meanings.pluck(:id) - seen_ids.keys
    unless delete_ids.empty?
      Meaning.delete(delete_ids)
    end
  end

  def replace_or_create_meaning(m)
    existing = m['id'].present? && Meaning.find(m['id'])
    if existing.present?
      existing.update(cislo: m['cislo'], kvalifikator: m['kvalifikator'], vyznam: m['vyznam'], db: self.db)
      return existing
    end
    Meaning.create(entry: self, cislo: m['cislo'], kvalifikator: m['kvalifikator'], vyznam: m['vyznam'], db: self.db)
  end
end
