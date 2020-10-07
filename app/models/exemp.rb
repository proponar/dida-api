class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :source, foreign_key: 'zdroj_id', required: false

  def json_hash
    {
      id: id,
      rok: rok,
      kvalifikator: kvalifikator || '',
      exemplifikace: exemplifikace,
      vyznam: vyznam,
      vetne: vetne,
      aktivni: !! aktivni,
      # lokalizaceObec: "somewhere"
      lokalizace_obec_id: lokalizace_obec,
      lokalizace_obec_text: Location.naz_obec(lokalizace_obec),
      lokalizace_cast_obce_id: lokalizace_cast_obce,
      lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
      lokalizace_text: lokalizace_text,                # unused
    }
  end
end
