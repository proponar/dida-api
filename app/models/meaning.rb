class Meaning < ApplicationRecord
  belongs_to :entry

  def json_hash
    {
      id: id,
      cislo: cislo,
      vyznam: vyznam,
      kvalifikator: kvalifikator,
    }
  end

  def cislo_not_null
    cislo ? cislo : 0
  end
end
