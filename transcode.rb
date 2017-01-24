sizes = [320, 480, 640]
videos_path = File.join ENV['HOME'], 'Downloads', 'videos'
output_path = File.join videos_path, 'output'
videos = Dir.glob(File.join videos_path, '*.mp4')

errors = []

videos.each do |video|
  basename = File.basename video

  sizes.each do |size|
    puts "converting #{video} at #{size}x..."
    output = `ffmpeg -i #{video} -vf scale=#{size}:-1 #{output_path}/#{basename}_#{size} 2>&1`
    unless $?.success?
      errors << "Failed to convert #{basename} at #{size}."
      errors << output
    end
  end
end

puts ''

if errors.empty?
  puts 'Completed successfully.'
else
  puts 'Completed with errors.'
  puts errors
end
