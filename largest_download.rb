download_path = "C:/Users/ctyler/Downloads/*"
files = Dir.glob download_path
largest_file = files.max_by { |file| File.size file }

puts "The largest file in #{download_path} is #{File.basename largest_file}, and its size is #{File.size largest_file} bytes."
