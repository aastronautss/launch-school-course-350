sizes = [320, 480, 640]
videos_path = File.join ENV['HOME'], 'Downloads', 'videos'
output_path = File.join videos_path, 'output'
videos = Dir.glob(File.join videos_path, '*.mp4')

convert_videos videos_path, sizes

def convert_videos(videos, sizes, output_path)
  videos.each { |video| convert_to_sizes video, sizes, output_path }
end

def convert_to_sizes(video, sizes, output_path)
  sizes.each { |size| convert video, size, output_path }
end

def convert(video, size, output_path)
  basename = File.basename video
  puts "converting #{video} at #{size}x..."
  `ffmpeg -i #{video} -vf scale=#{size}:-1 #{output_path}/#{basename}_#{size} 2>&1`
end

