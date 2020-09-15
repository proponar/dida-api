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
      kvalifikator: kvalifikator,
      vyznam: vyznam,
      vetne: vetne,
      druh: DRUH_MAP[druh],
      rod: ROD_MAP[rod],
    }
  end

  def json_hash
    {
      entry: json_entry,
      exemps: exemps.map { |e| e.json_hash }
    }
  end
end
