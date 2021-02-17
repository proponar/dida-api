class Location < ApplicationRecord
  self.table_name = 'n3_obce_body'

  def self.find_obec(kod_obec)
    @obec ||= {}
    unless @obec.key?(kod_obec)
      @obec[kod_obec] ||=
        Location.find_by_sql([
          "select naz_obec, kod_obec, kod_okres, point_x, point_y from #{table_name} where kod_obec::integer = ?",
          kod_obec.to_i
        ]).first
    end
    @obec[kod_obec]
  end

  def self.naz_obec(kod_obec)
    find_obec(kod_obec).try(:naz_obec)
  end

  def self.naz_obec_with_zkr(kod_obec)
    ob = find_obec(kod_obec)
    if ob.present?
      kod_okres = self.kodOk2names[ob.kod_okres.to_i]&.at(1)
      "#{ob.naz_obec} #{kod_okres}"
    else
      nil
    end
  end

  def self.naz_cast(kod_cast)
    @naz_cast ||= {}
    unless @naz_cast.key?(kod_cast)
      @naz_cast[kod_cast] = (
        result = Location.connection.select_one(
          "select naz_cob, kod_cob from n3_casti_obce_polygony where kod_cob::integer = $1",
          'SQL',
          [[nil, kod_cast.to_i]]
        )
        result && result['naz_cob']
      )
    end
    @naz_cast[kod_cast]
  end

  def self.location_format(kod_ob, kod_cast)
    return '' unless kod_ob.present?
    ob = find_obec(kod_ob)
    return '' unless ob.present?
    kod_okres = self.kodOk2names[ob.kod_okres.to_i]&.at(1)

    if kod_cast.present?
      naz_cast = Location.naz_cast(kod_cast)
      "#{ob.naz_obec} #{kod_okres} (#{naz_cast})"
    else
      "#{ob.naz_obec} #{kod_okres}"
    end
  end

  def parts
    Location.connection.select_all(
      "select naz_cob, kod_cob from n3_casti_obce_polygony where kod_obec = $1 order by naz_cob",
      'SQL',
      [[nil, self.kod_obec]]
    ).to_a
  end

  def self.okres2zkratka
    @okres2zkratka ||= {
      'Semily'              => 'SM',
      'Sokolov'             => 'SO',
      'Strakonice'          => 'ST',
      'Karlovy Vary'        => 'KV',
      'Kladno'              => 'KL',
      'Tábor'               => 'TA',
      'Tachov'              => 'TC',
      'Kolín'               => 'KO',
      'Teplice'             => 'TP',
      'Trutnov'             => 'TU',
      'Liberec'             => 'LB',
      'Litoměřice'          => 'LT',
      'Ústí nad Labem'      => 'UL',
      'Louny'               => 'LN',
      'Mělník'              => 'ME',
      'Mladá Boleslav'      => 'MB',
      'Most'                => 'MO',
      'Náchod'              => 'NA',
      'Blansko'             => 'BK',
      'Brno-venkov'         => 'BO',
      'Břeclav'             => 'BV',
      'Zlín'                => 'ZL',
      'Hodonín'             => 'HO',
      'Jihlava'             => 'JI',
      'Kroměříž'            => 'KM',
      'Prostějov'           => 'PV',
      'Třebíč'              => 'TR',
      'Uherské Hradiště'    => 'UH',
      'Vyškov'              => 'VY',
      'Znojmo'              => 'ZN',
      'Žďár nad Sázavou'    => 'ZR',
      'Jindřichův Hradec'   => 'JH',
      'Bruntál'             => 'BR',
      'Frýdek-Místek'       => 'FM',
      'Karviná'             => 'KA',
      'Nový Jičín'          => 'NJ',
      'Jičín'               => 'JC',
      'Olomouc'             => 'OL',
      'Opava'               => 'OP',
      'Ostrava-město'       => 'OV',
      'Šumperk'             => 'SU',
      'Vsetín'              => 'VS',
      'Svitavy'             => 'SY',
      'Brno-město'          => 'BM',
      'Ústí nad Orlicí'     => 'UO',
      'Ostrava'             => 'OV',
      'Pelhřimov'           => 'PE',
      'Havlíčkův Brod'      => 'HB',
      'Jeseník'             => 'JE',
      'Benešov'             => 'BN',
      'Beroun'              => 'BE',
      'Nymburk'             => 'NB',
      'Pardubice'           => 'PA',
      'Česká Lípa'          => 'CL',
      'Písek'               => 'PI',
      'České Budějovice'    => 'CB',
      'Plzeň'               => 'PM',
      'Plzeň-jih'           => 'PM',
      'Plzeň-sever'         => 'PM',
      'Plzeň-město'         => 'PM',
      'Český Krumlov'       => 'CK',
      'Děčín'               => 'DC',
      'Domažlice'           => 'DO',
      'Praha'               => 'PH',
      'Hlavní město Praha'  => 'PH',
      'Praha-východ'        => 'PY',
      'Praha-západ'         => 'PZ',
      'Prachatice'          => 'PT',
      'Hradec Králové'      => 'HK',
      'Cheb'                => 'CH',
      'Chomutov'            => 'CV',
      'Příbram'             => 'PB',
      'Chrudim'             => 'CR',
      'Rakovník'            => 'RA',
      'Jablonec nad Nisou'  => 'JN',
      'Rokycany'            => 'RO',
      'Rychnov nad Kněžnou' => 'RK',
      'Přerov'              => 'PR',
      'Klatovy'             => 'KT',
      'Kutná Hora'          => 'KH',
    }.freeze
  end

  def self.zkratka2okres
    @zkratka2okres ||= self.okres2zkratka.invert.freeze
  end

  def self.kodOk2names
    @kodOk2names ||= {
      40169 => ['Benešov'                         ,'BN'],
      40177 => ['Beroun'                          ,'BE'],
      40703 => ['Blansko'                         ,'BK'],
      40738 => ['Břeclav'                         ,'BV'],
      40711 => ['Brno-město'                      ,'BM'],
      40720 => ['Brno-venkov'                     ,'BO'],
      40860 => ['Bruntál'                         ,'BR'],
      40525 => ['Česká Lípa'                      ,'CL'],
      40282 => ['České Budějovice'                ,'CB'],
      40291 => ['Český Krumlov'                   ,'CK'],
      40428 => ['Cheb'                            ,'CH'],
      40461 => ['Chomutov'                        ,'CV'],
      40614 => ['Chrudim'                         ,'CR'],
      40452 => ['Děčín'                           ,'DC'],
      40355 => ['Domažlice'                       ,'DO'],
      40878 => ['Frýdek-Místek'                   ,'FM'],
      40657 => ['Havlíčkův Brod'                  ,'HB'],
      40746 => ['Hodonín'                         ,'HO'],
      40568 => ['Hradec Králové'                  ,'HK'],
      40533 => ['Jablonec nad Nisou'              ,'JN'],
      40771 => ['Jeseník'                         ,'JE'],
      40576 => ['Jičín'                           ,'JC'],
      40665 => ['Jihlava'                         ,'JI'],
      40304 => ['Jindřichův Hradec'               ,'JH'],
      40436 => ['Karlovy Vary'                    ,'KV'],
      40886 => ['Karviná'                         ,'KA'],
      40185 => ['Kladno'                          ,'KL'],
      40363 => ['Klatovy'                         ,'KT'],
      40193 => ['Kolín'                           ,'KO'],
      40827 => ['Kroměříž'                        ,'KM'],
      40207 => ['Kutná Hora'                      ,'KH'],
      40541 => ['Liberec'                         ,'LB'],
      40479 => ['Litoměřice'                      ,'LT'],
      40487 => ['Louny'                           ,'LN'],
      40215 => ['Mělník'                          ,'ME'],
      40223 => ['Mladá Boleslav'                  ,'MB'],
      40495 => ['Most'                            ,'MO'],
      40584 => ['Náchod'                          ,'NA'],
      40894 => ['Nový Jičín'                      ,'NJ'],
      40231 => ['Nymburk'                         ,'NB'],
      40789 => ['Olomouc'                         ,'OL'],
      40908 => ['Opava'                           ,'OP'],
      40916 => ['Ostrava-město'                   ,'OV'],
      40622 => ['Pardubice'                       ,'PA'],
      40673 => ['Pelhřimov'                       ,'PE'],
      40312 => ['Písek'                           ,'PI'],
      40380 => ['Plzeň-jih'                       ,'PM'],
      40371 => ['Plzeň-město'                     ,'PM'],
      40398 => ['Plzeň-sever'                     ,'PM'],
      40321 => ['Prachatice'                      ,'PT'],
      40924 => ['Praha'                           ,'PH'],
      40240 => ['Praha-východ'                    ,'PY'],
      40258 => ['Praha-západ'                     ,'PZ'],
      40801 => ['Přerov'                          ,'PR'],
      40266 => ['Příbram'                         ,'PB'],
      40797 => ['Prostějov'                       ,'PV'],
      40274 => ['Rakovník'                        ,'RA'],
      40401 => ['Rokycany'                        ,'RO'],
      40592 => ['Rychnov nad Kněžnou'             ,'RK'],
      40550 => ['Semily'                          ,'SM'],
      40444 => ['Sokolov'                         ,'SO'],
      40339 => ['Strakonice'                      ,'ST'],
      40819 => ['Šumperk'                         ,'SU'],
      40631 => ['Svitavy'                         ,'SY'],
      40347 => ['Tábor'                           ,'TA'],
      40410 => ['Tachov'                          ,'TC'],
      40509 => ['Teplice'                         ,'TP'],
      40681 => ['Třebíč'                          ,'TR'],
      40606 => ['Trutnov'                         ,'TU'],
      40835 => ['Uherské Hradiště'                ,'UH'],
      40517 => ['Ústí nad Labem'                  ,'UL'],
      40649 => ['Ústí nad Orlicí'                 ,'UO'],
      40843 => ['Vsetín'                          ,'VS'],
      40754 => ['Vyškov'                          ,'VY'],
      40690 => ['Žďár nad Sázavou'                ,'ZR'],
      40851 => ['Zlín'                            ,'ZL'],
      40762 => ['Znojmo'                          ,'ZN'],
    }.freeze
  end

  # Držkov JH
  # Brno BM (Kohoutovice)
  def self.guess_lokalizace(str)
    md = str.match(/^(.*)\s+(\w\w)(\s*\((.*)\)\s*)?$/)
    return [nil, nil] unless md

    obec = md[1]
    zkr_okres = md[2]
    cast = md[4]

    # musi sedet nazev obce i zkratka
    okres = Location.zkratka2okres[zkr_okres]
    locs = Location.where(naz_obec: obec, naz_lau1: okres)
    return [nil, nil] if locs.length != 1

    loc = locs.first
    # jen lokalizace, zadna cast
    return [loc.kod_obec, nil] unless cast.present?

    part_pair = loc.parts.find do |part|
      # part: {"naz_cob"=>"Hoření Paseky", "kod_cob"=>"160563"},
      part['naz_cob'] == cast
    end

    # FIXME: opravdu chceme cele blbe, pokud je blbe jen cast?
    #[loc.kod_obec, part_pair && part_pair['kod_cob']]
    part_pair.present? ? [loc.kod_obec, part_pair['kod_cob']] : [nil, nil]
  end
end
