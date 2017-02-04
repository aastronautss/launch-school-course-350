class Command
  attr_accessor :nick, :user, :name, :arguments

  def self.parse(command_string)
    cmd = command_string.dup
    nick, user = parse_sender_info! cmd
    nick, user = user, nick if user.nil?
    trailing_arg = parse_trailing_arg! cmd
    name, *args = cmd.split ' '
    args << trailing_arg if trailing_arg

    new nick: nick, user: user, name: name, arguments: args
  end

  def initialize(options = {})
    options.each do |key, val|
      send("#{key}=", val)
    end
  end

  private

  def self.parse_sender_info!(cmd)
    if cmd.start_with? ':'
      sender_info = cmd.slice!(/\A:.+?\s/)[1..-1]
      sender_info.split('!').map &:strip
    else
      nil
    end
  end

  def self.parse_trailing_arg!(cmd)
    cmd.slice!(/:.+\Z/)[1..-1] if cmd.include? ':'
  end
end
