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
    }
  end

  # Bachmannová, Za života se stane ledacos
  def guess_source(str)
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

  def parse_ex(str)
    md = str.match(/^\((\d)\s(pl|sg)\.\)\s(.*)$/) # pad a exemplifikace
    pad = md[1]
    cislo = md[2]
    exemplifikace = md[3]
    [pad, cislo, exemplifikace]
  end

  # (1 pl.) dejte si pozor, je tam taková louš, co se husi v leťe koupou; Držkov JN; Bachmannová, Za života se stane ledacos
  def parse_exemp(line, user)
    parts = line.split(/;\s*/)
    pad, cislo, exemplifikace = parse_ex(parts[0])

    lokalizace = guess_lokalizace(parts[1]) # lokalizace
    lokalizace_text = lokalizace.nil? ? parts[1] : ''

    source = guess_source(parts[2]) # zdroj
    Exemp.new(
      user: user,
      entry_id: id,
      source: source,
      lokalizace_obec: lokalizace.kod_obec,
      lokalizace_text: lokalizace_text,
      exemplifikace: exemplifikace,

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
    text_data.split("\n").each do |line|
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
