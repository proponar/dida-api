if $0 == __FILE__
	require File.expand_path('./config/environment.rb')

  Entry.all.each do |e|
    if e.meanings.empty?
      m = Meaning.create(entry_id: e.id, cislo: 1, vyznam: e.vyznam, kvalifikator: e.kvalifikator)

      e.exemps.each do |ex|
        ex.meaning = m
        ex.save!
      end
    end
  end
end
