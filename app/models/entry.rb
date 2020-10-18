class Entry < ApplicationRecord
  belongs_to :user, foreign_key: 'author_id'
  has_many :exemps
  has_paper_trail

  validates :heslo, presence: true, uniqueness: true

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
    }
  end

  # Bachmannová, Za života se stane ledacos
  def guess_source(str)
    return nil if str.blank?

    parts = str.split(/, */)

    # FIXME: osetrit vice hitu
    s = Source.where(:autor => parts[0], :name => parts[1])
    return s.first if s.present?

    if parts[0].present? && parts[1].present? # matchujeme jen neprazdne
      s = Source.where("name like ? and autor ilike ?", parts[1]+'%', parts[0]+'%')
      return s.first if s.present?
    end

    nil
  end

  # Držkov JH
  def guess_lokalizace(str)
    md = str.match(/^(.*)\s+(\w\w)$/)
    if md
      # md[0]
      loc = Location.where(:naz_obec => md[1]).first # FIXME, kdyz je vic, matchovat pres zkratku okresu
      return loc
    else
    end
    nil
  end

  def parsed_tvary
    @parsed_tvary ||= tvary.split(/\s+/).map { |t| t.sub(/-/, '') }
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
      binding.pry if md.nil?
      { pad: md[1], cislo: md[2] }
    end

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

  def parse_ex_inline(str)
    # FIXME
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

      ex = entry.parse_exemp(line, user)
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

  def json_hash
    {
      entry: json_entry,
      exemps: exemps.map { |e| e.json_hash }
    }
  end
end
