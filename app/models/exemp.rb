class Exemp < ApplicationRecord
  belongs_to :entry
  belongs_to :user, foreign_key: 'author_id'
  belongs_to :source, foreign_key: 'zdroj_id', required: false, primary_key: 'cislo'
  has_many_attached :attachments
  belongs_to :meaning, required: false
  belongs_to :location_text, primary_key: 'cislo', required: false

  belongs_to :location,      primary_key: 'kod_obec', required: false, foreign_key: 'lokalizace_obec'
  belongs_to :location_part, primary_key: 'kod_cob',  required: false, foreign_key: 'lokalizace_cast_obce'

  include ExempParser
  before_save :process_urceni

  def process_urceni
    self.urceni = Exemp.extract_urceni(exemplifikace)
    self.urceni_sort = Exemp.simplify_urceni(self.urceni)
  end

  def json_hash
    {
      id: id,
      kvalifikator: meaning&.kvalifikator || '',
      vyznam: meaning&.vyznam || '',
      meaning_id: meaning_id,
      heslo: entry&.heslo || '',
      druh: entry && Entry::DRUH_MAP[entry.druh || 0],
      #rod: entry && Entry::ROD_MAP[entry.rod || 0]#

      rod: rod && Entry::ROD_MAP[rod],
      rok: rok,
      exemplifikace: exemplifikace,
      vetne: vetne,
      aktivni: !! aktivni,
      zdroj_id: source && source.cislo,
      zdroj_name: source && source.name,
      lokalizace_obec_id: lokalizace_obec,
      #lokalizace_obec_text: Location.naz_obec_with_zkr(lokalizace_obec),
      lokalizace_obec_text: location&.naz_obec_with_zkr,
      lokalizace_cast_obce_id: lokalizace_cast_obce,
      #lokalizace_cast_obce_text: Location.naz_cast(lokalizace_cast_obce),
      lokalizace_cast_obce_text: location_part&.naz_cob,
      lokalizace_text_id:  location_text&.cislo,
      lokalizace_text: location_text&.identifikator,
      #lokalizace_format: Location.location_format(lokalizace_obec, lokalizace_cast_obce),
      lokalizace_format: location_format,
      urceni_sort: urceni_sort,
      urceni: Exemp::expand_urceni(urceni_sort),
      time: updated_at&.localtime&.strftime('%d.%m.%Y %H:%M:%S'),
      attachments: attachments.map { |a, i|
        {
          filename: a.filename.to_s,
          content_type: a.content_type,
          id: a.id,
          url: Rails.application.routes.url_helpers.rails_blob_path(a, only_path: true),
        }
      },
    }
  end

  def json_hash_full
    json_hash.update(
      entry_full: entry.json_entry,
      urceni_full: urceni,
      vyznam_full: meaning,
      source_full: source && source.json_short,
    )
  end


  #  * exemplifikace (viz DB entita),
  # * informace z vyznamu
  #     * text
  # * informace ze zdroje
  #     * nazev
  #     * rok sberu
  #  * seznam priloh? nebo jedna (prvni) priloha?, ktera je daneho typu? zvukova?
  def json_hash_s
    {
      id: id,
      exemplifikace: exemplifikace,
      lokalizace_obec: lokalizace_obec,
      lokalizace_cast_obce: lokalizace_cast_obce,
    }
  end

  def location_format
    return '' unless self.location.present?

    nazev = self.location.naz_obec
    kod_okres = Location::kodOk2names[self.location.kod_okres.to_i]&.at(1)

    if self.location_part.present?
      naz_cast = self.location_part.naz_cob
      "#{nazev} #{kod_okres} (#{naz_cast})"
    else
      "#{nazev} #{kod_okres}"
    end
  end

  def coordinates
    l = Location.find_obec(self.lokalizace_obec)
    { lng: l.point_x, lat: l.point_y }
  end
end
