class Location < ApplicationRecord
  self.table_name = 'n3_obce_body'

  def self.naz_obec(kod_obec)
    Location.find_by_sql([
      "select naz_obec, kod_obec from #{table_name} where kod_obec = ?",
      kod_obec.to_s
    ]).first.try(:naz_obec)
  end

  def self.naz_cast(kod_cast)
    result = Location.connection.select_one(
      "select naz_cob, kod_cob from n3_casti_obce_polygony where kod_cob = $1",
      'SQL',
      [[nil, kod_cast]]
    )
    result && result['naz_cob']
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
    @zkratka2okres ||= self.okres2zkratka.reverse.freeze
  end
end
