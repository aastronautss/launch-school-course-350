dictionary = File.read('/usr/share/dict/words').split '\n'
words_to_check = File.read('check_me.txt').split '\n'

misspelled = []

words_to_check.each do |the_word|
  misspelled << the_word unless dictionary.include?(the_word)
end

File.open 'errors.txt', 'w' do |file|
  file.puts "There are #{misspelled.count} misspelled words:"
  misspelled.each { |word| file.puts word }
end
