class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :source, foreign_key: 'zdroj_id', required: false, primary_key: 'cislo'
  has_many_attached :attachments
  belongs_to :meaning, required: false
  belongs_to :location_text, primary_key: 'cislo', required: false

  def json_hash
    {
      id: id,
      kvalifikator: meaning&.kvalifikator || '',
      vyznam: meaning&.vyznam || '',
      meaning_id: meaning_id,
      heslo: entry&.text || '',

      rod: rod && Entry::ROD_MAP[rod],
      rok: rok,
      exemplifikace: exemplifikace,
      vetne: vetne,
      aktivni: !! aktivni,
      zdroj_id: source && source.cislo,
      zdroj_name: source && source.name,
      lokalizace_obec_id: lokalizace_obec,
      lokalizace_obec_text: Location.naz_obec_with_zkr(lokalizace_obec),
      lokalizace_cast_obce_id: lokalizace_cast_obce,
      lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
      lokalizace_text_id:  location_text&.cislo,
      lokalizace_text: location_text&.identifikator,
      lokalizace_format: Location.location_format(lokalizace_obec, lokalizace_cast_obce),
      urceni: urceni,
      time: updated_at&.localtime&.strftime('%d.%m.%Y %H:%M:%S'),
      attachments: attachments.map { |a, i|
        {filename: a.filename.to_s, content_type: a.content_type, id: a.id}
      },
      meaning_id: meaning_id,
    }
  end

  def coordinates
    l = Location.find_obec(self.lokalizace_obec)
    { lng: l.point_x, lat: l.point_y }
  end
end
