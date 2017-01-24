dictionary = File.read('/usr/share/dict/words').split '\n'
words_to_check = File.read('check_me.txt').split '\n'

misspelled = []

words_to_check.each do |the_word|
  misspelled << the_word unless dictionary.include?(the_word)
end

puts "There are #{misspelled.count} misspelled words:"
misspelled.each do |misspelled_word|
  puts misspelled_word
end
