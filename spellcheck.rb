words = File.read("check_me.txt").split "\n"
dictionary = File.read("words.txt").split "\n"

misspelled_words = words.select { |word| !dictionary.include? word }

File.open("errors.txt", "w") do |file|
  file.write "There are #{misspelled_words.length} misspelled words:\n"
  misspelled_words.each do |word|
    file.write word + "\n"
  end
end
