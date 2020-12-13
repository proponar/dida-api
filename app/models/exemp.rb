class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :source, foreign_key: 'zdroj_id', required: false, primary_key: 'cislo'
  has_many_attached :attachments

  def json_hash
    {
      id: id,
      rod: rod && Entry::ROD_MAP[rod],
      rok: rok,
      kvalifikator: kvalifikator || '',
      exemplifikace: exemplifikace,
      vyznam: vyznam,
      vetne: vetne,
      aktivni: !! aktivni,
      zdroj_id: source && source.cislo,
      zdroj_name: source && source.name,
      lokalizace_obec_id: lokalizace_obec,
      lokalizace_obec_text: Location.naz_obec_with_zkr(lokalizace_obec),
      lokalizace_cast_obce_id: lokalizace_cast_obce,
      lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
      lokalizace_text: lokalizace_text,  # unused
      lokalizace_format: Location.location_format(lokalizace_obec, lokalizace_cast_obce),
      urceni: urceni,
      time: updated_at&.localtime&.strftime('%d.%m.%Y %H:%M:%S'),
    }
  end
end
