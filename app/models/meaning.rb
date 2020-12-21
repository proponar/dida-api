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
end
