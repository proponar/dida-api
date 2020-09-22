class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :source, foreign_key: 'zdroj_id', required: false

  def json_hash
    {
      rok: rok,
      kvalifikator: kvalifikator || '',
      exemplifikace: exemplifikace,
      vyznam: vyznam,
      vetne: vetne,
      # lokalizaceObec: "somewhere"
      lokalizace_obec: lokalizace_obec,
      lokalizace_cast_obce: lokalizace_cast_obce,
      lokalizace_text: lokalizace_text,
    }
  end
end
