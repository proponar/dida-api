module ExempParser
  extend ActiveSupport::Concern

  RODY = {
    ' ' =>     '-o-',
    'm' =>     'm.',
    'f' =>     'f.',
    'n' =>     'n.',
    'mf' =>    'm./f.',
    'fn' =>    'f./n.',
    'mn' =>    'm./n.',
    'mplt' =>  'm. plt.',
    'fplt' =>  'f. plt.',
    'nplt' =>  'n. plt.',
    'mfplt' => 'm./f. plt.',
    'fnplt' => 'f./n. plt.',
    'mnplt' => 'm./n. plt.',
  };
  RODY_RE = RODY.values.map { |v| v.gsub('.', '\\.') }.join('|')

  class_methods do
    def filter_tvar(t)
      t.gsub(/,.*/u, '')
    end

    def string2urceni(t)
      # 'obecním, f. 7 sg.'
      mtr = t.match(/^([’'\p{L}\p{M}\s]+),\s*($#{RODY_RE})\s*(\d)\s+(pl|sg)\.$/u)

      if mtr
        return {
          'tvar' => filter_tvar(mtr[1]),
          'rod'  => mtr[2].gsub(/[. \/]/, ''),
          'pad'  => mtr[3] + ((mtr[4] === 'pl' && 'p') || 's'),
        }
      end

      # 'huse, 1 pl.'
      mt = t.match(/^([’'\p{L}\p{M}\s]+),\s*(\d)\s+(pl|sg)\.$/u)
      if mt
        return {
          'tvar' => filter_tvar(mt[1]),
          'rod'  =>  ' ',
          'pad'  =>  mt[2] + ((mt[3] === 'pl' && 'p') || 's'),
        }
      end

      {
        'invalid' => true,
        'tvar' => filter_tvar(t),
        'rod'  => nil, # 'm', // blbe
        'pad'  => nil  # '1s', // blbe
      }
    end

    def extract_urceni(t)
      #parts = string.split(/(\{[^{}]+\})/u);
      parts = t.to_s.scan(/(?<=\{)[^{}]+(?=\})/u) || [];
      parts.map { |s| string2urceni(s) }
    end

    def simplify_urceni(u)
      return 0 if u.nil? || u.empty?
      return 0 if u[0]['invalid']
      md = u[0]['pad'].match(/^(\d)([ps])$/)
      return 0 unless md
      md[2] == 's' ? md[1].to_i : 100 + md[1].to_i
    end
  end
end

