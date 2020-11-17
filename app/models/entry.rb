class Entry < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  has_many :exemps
  has_paper_trail

  validates :heslo, presence: true, uniqueness: true

  before_save :process_tvar_map

  ROD_MAP = ['m', 'f', 'n']
  DRUH_MAP = ['subst', 'adj']

  def self.map_rod(str)
    ROD_MAP.index(str)
  end

  def self.map_druh(str)
    DRUH_MAP.index(str)
  end

  def json_entry
    {
      id: id,
      text: text,
      author_id: author_id,
      author_name: user.name,
      created_at: created_at,
      updated_at: updated_at,
      heslo: heslo,
      kvalifikator: kvalifikator || '',
      vyznam: vyznam,
      vetne: vetne,
      druh: DRUH_MAP[druh],
      rod: ROD_MAP[rod],
      tvary: tvary,
      urceni: urceni,
      tvar_map: tvar_map,
    }
  end

  # Bachmannová, Za života se stane ledacos
  def guess_source(str)
    return nil if str.blank?

    # zdroj konci rokem
    if md = str.match(/(\d\d\d\d)\s*$/)
      rok = md[1]
      str.sub!(/\s*(\d\d\d\d)\s*$/, '')
    end

    parts = str.split(/, */)

    # FIXME: vide hitu zatim resime, jakoby nic nebylo nalezeno
    s = Source.where(:autor => parts[0], :name => parts[1])
    return s.first if s.present?

    if parts[0].present? && parts[1].present? # matchujeme jen neprazdne
      s = Source.where("name ilike ? and autor ilike ?", parts[1]+'%', parts[0]+'%')
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    if parts[0].present? && parts[1].present? # matchujeme jen neprazdne
      s = Source.where(
        "name_processed ilike ? and autor ilike ?",
        I18n.transliterate(parts[1]) + '%',
        parts[0] + '%'
      )
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    # matchujeme jen nazev
    if parts[0].blank? && parts[1].present? # matchujeme jen neprazdne
      s = Source.where(
        "name_processed ilike ?",
        I18n.transliterate(parts[1]) + '%'
      )
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    if parts[0].present? && parts[1].blank? # matchujeme jen neprazdne
      s = Source.where(
        "name_processed ilike ?",
        I18n.transliterate(parts[0]) + '%'
      )
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    # matchujeme jen autora
    if parts[0].blank? && parts[1].present? # matchujeme jen neprazdne
      s = Source.where("autor ilike ?", parts[1] + '%')
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    if parts[0].present? && parts[1].blank? # matchujeme jen neprazdne
      s = Source.where("autor ilike ?", parts[0] + '%')
      s = s.where(:rok => rok) if rok.present?
      return nil if s.count > 1
      return s.first if s.present?
    end

    $stderr.puts("Chybi zdroj: #{str}")

    nil
  end

  # Držkov JH
  def guess_lokalizace(str)
    md = str.match(/^(.*)\s+(\w\w)$/)
    if md
      obec = md[1]
      zkr_okres = md[2]
      locs = Location.where(:naz_obec => obec)
      return nil if locs.length === 0
      return locs.first if locs.length === 1

      okres = Location.zkratka2okres[zkr_okres]
      return locs.where(:naz_lau1 => okres).first
    end
    nil
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
  def parse_exemp(line, user)
    parts = line.split(/;\s*/)
    exemplifikace, urceni = parse_ex(parts[0])

    lokalizace = parts[1] && guess_lokalizace(parts[1]) || nil
    lokalizace_text = lokalizace.nil? ? (parts[1] || '') : ''

    source = guess_source(parts[2]) # zdroj
    Exemp.new(
      user: user,
      entry_id: id,
      source: source,
      rok: source&.rok,
      lokalizace_obec: lokalizace && lokalizace.kod_obec || nil,
      lokalizace_text: lokalizace_text,
      exemplifikace: exemplifikace,
      urceni: urceni.to_json,

      vetne: self.vetne,
      rod: self.rod,
      kvalifikator: self.kvalifikator,
      aktivni: true,
      chybne: false,
    )
  end

  def self.import_text(entry_id, user, text_data, dry_run)
    entry = Entry.find(entry_id)

    results = []
    text_data.split("\n").map(&:strip).filter(&:present?).each do |line|
      next if line.blank?

      begin
        ex = entry.parse_exemp(line, user)
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
        # temporary id
        ex.id = results.length
      else
        ex.save! unless dry_run
      end
      results << ex
    end

    results
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
    end
  end

  def json_hash
    {
      entry: json_entry,
      exemps: exemps.map { |e| e.json_hash }
    }
  end
end
