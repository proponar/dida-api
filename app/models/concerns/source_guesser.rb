module SourceGuesser
  extend ActiveSupport::Concern

  class_methods do
    # Bachmannová, Za života se stane ledacos
    def guess_source(str)
      return nil if str.blank?

      # zdroj konci rokem
      if md = str.match(/(\d\d\d\d)\s*$/)
        rok = md[1]
        str = str.sub(/\.?\s*(\d\d\d\d)\s*$/, '')
      end

      # guessing from 2 parts
      # try splitting after the 1st ","
      parts = str.split(/, */, 2)
      ret = Source.guess_source_from_2parts(parts, rok)
      return ret if ret.present?

      # try spliting after the last ","
      (pre, _del, post) = str.rpartition(/, */)
      ret = Source.guess_source_from_2parts([pre, post], rok)
      return ret if ret.present?

      # try splitting by ":" or '.'
      parts = str.split(/[:.] */, 2)
      ret = Source.guess_source_from_2parts(parts, rok)
      return ret if ret.present?

      # try spliting after the last ":" or '.'
      (pre, _del, post) = str.rpartition(/[:.] */)
      ret = Source.guess_source_from_2parts([pre, post], rok)
      return ret if ret.present?

      # guessing from 3 parts
      # try splitting after the 2st ","
      parts = str.split(/, */, 3)
      ret = Source.guess_source_from_3parts(parts, rok)
      return ret if ret.present?

      # try spliting after the last ","
      (pre, _del, post) = str.rpartition(/, */)
      (pre, _del, mid) = pre.rpartition(/, */)
      ret = Source.guess_source_from_3parts([pre, mid, post], rok)
      return ret if ret.present?

      $stderr.puts("Chybi zdroj: #{str}")
      ret
    end

    def guess_source_from_3parts(parts, rok)
      s = Source.where(:autor => parts[0], :name => parts[1], :nazev2 => parts[2])
      return s.first if s.present?

      # shoda prefixu, autor i nazev i nazev2
      if parts[0].present? && parts[1].present? && parts[2].present?
        s = Source.where(
          "name ilike ? and nazev2 ilike ? and autor ilike ?",
          parts[1]+'%', parts[2]+'%', parts[0]+'%'
        ).or(
          Source.where(
            "name ilike ? and nazev2 ilike ? and autor ilike ?",
            parts[2]+'%', parts[1]+'%', parts[0]+'%'
          ))
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end
    end

    def guess_source_from_2parts(parts, rok)
      # FIXME: vice hitu zatim resime, jakoby nic nebylo nalezeno
      
      # presna shoda autor i nazev
      s = Source.where(:autor => parts[0], :name => parts[1])
      return s.first if s.present?

      # shoda prefixu, autor i nazev
      if parts[0].present? && parts[1].present? # matchujeme jen neprazdne
        s = Source.where(
          "(name ilike ? or nazev2 ilike ?) and autor ilike ?",
          n = parts[1]+'%', n, parts[0]+'%'
        )
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      # shoda prefixu, autor a nazev bez diakritiku
      # zkousime i spojeni nazev + nazev2
      if parts[0].present? && parts[1].present? # matchujeme jen neprazdne
        s = Source.where(
          "(name_processed ilike ? or \
            nazev2_processed ilike ? or \
            name_processed || ' ' || nazev2_processed ilike ?) and \
            autor ilike ?",
          n = I18n.transliterate(parts[1]) + '%',
          n,
          n,
          parts[0] + '%'
        )
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      # matchujeme jen nazev bez diakritiky
      # TODO: toto je asi blbe, protoze prazdna part[0] nejspis nebude, muzelo by byt ",nazev"
      if parts[0].blank? && parts[1].present? # matchujeme jen neprazdne
        s = Source.where(
          "(name_processed ilike ? or nazev2_processed ilike ?)",
          n = I18n.transliterate(parts[1]) + '%', n
        )
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      # matchujeme jen nazev bez diakritiky
      # TODO: toto udajne nefungije (poznamka d) )
      if parts[0].present? && parts[1].blank? # matchujeme jen neprazdne
        s = Source.where(
          "(name_processed ilike ? or nazev2_processed ilike ?)",
          n = I18n.transliterate(parts[0]) + '%', n
        )
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      # TODO: toto je asi blbe, opet, protoze by muselo byt ",autor"
      # matchujeme jen autora
      if parts[0].blank? && parts[1].present? # matchujeme jen neprazdne
        s = Source.where("autor ilike ?", parts[1] + '%')
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      # matchujeme jen autora
      if parts[0].present? && parts[1].blank? # matchujeme jen neprazdne
        s = Source.where("autor ilike ?", parts[0] + '%')
        s = s.where(:rok => rok) if rok.present?
        return nil if s.count > 1
        return s.first if s.present?
      end

      nil
    end
  end
end
