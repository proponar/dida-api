tvary = 'gynś- gynš- hos- ho̬s- hos-a ho̬s-a hus- hús- hus-a huš- huz- hos-e ho̬s-e̬ hus-e hus-i hus-í hus-y huš’-y huš-i gyňš-i hos-e ho̬s-e ho̬s-e̬ hus-e hus-i hus-y ho̬s- ho̬s-e̬ ho̬s-o̬ hus- hus-o hus-u huš- huz- hus-o hus-e hus-i hus-ó hus-ou hus-ú hos-e hos-e̬ ho̬s-e̬ hus-e hus-i huś-i hus-y huš’-y huš-i ho̬s- hos-é hos-í ho̬s-i hus- hus-e hus-é hus-ej hus-ejch hus-í hus-ích hus-ý hus-ych hus-am hus-ám hus-ejm hus-ím hus-om hus-am gyňś-i ho̬s-e̬ hus- hus’-i hus-e hus-i huś-i hús-i hus-y hús-y huš’-y huš-i huš-y ho̬s-e̬ hus-e hos-ách hus-ách hus-ejch hus-ama hus-ami hus-ámi hus-ima hus-ma'
urceni = '1 sg. 1 sg. 1 sg. 1 sg. 1 sg. 1 sg. 1 sg. 1 sg. 1 sg. 1 sg. '\
         '1 sg. 2 sg. 2 sg. 2 sg. 2 sg. 2 sg. 2 sg. 2 sg. 2 sg. 3 sg. '\
         '3 sg. 3 sg. 3 sg. 3 sg. 3 sg. 3 sg. 4 sg. 4 sg. 4 sg. 4 sg. '\
         '4 sg. 4 sg. 4 sg. 4 sg. 5 sg. 6 sg. 6 sg. 7 sg. 7 sg. 7 sg. '\
         '1 pl. 1 pl. 1 pl. 1 pl. 1 pl. 1 pl. 1 pl. 1 pl. 1 pl. 2 pl. '\
         '2 pl. 2 pl. 2 pl. 2 pl. 2 pl. 2 pl. 2 pl. 2 pl. 2 pl. 2 pl. '\
         '2 pl. 2 pl. 3 pl. 3 pl. 3 pl. 3 pl. 3 pl. 3 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 4 pl. 5 pl. 5 pl. 6 pl. 6 pl. 6 pl. 7 pl. 7 pl. 7 pl. 7 pl. 7 pl.'

def jq(str)
  result = IO.popen('jq .', 'r+') do |io|
    io.write(str)
    io.close_write
    io.read
  end
end

if $0 == __FILE__
	require 'csv'
	require File.expand_path('./config/environment.rb')

  success, map = Entry.calculate_tvar_map(tvary, urceni)
  if success
    puts jq(map.to_json)
  else
    puts map
  end
end
