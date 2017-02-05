class MessageResponse
  SUPPORTED_COMMANDS = ['reverse', 'method_name']

  def initialize(command, text)
    @command = command
    @text = text
  end

  def self.respond_to(message)
    command, text = message.match(/\A\!(.+?)\s(.+)/)[1..-1]
    new(command, text).respond
  end

  def respond
    begin
      self.send @command if SUPPORTED_COMMANDS.include? @command
    rescue NoMethodError
      'Command not found!'
    end
  end

  def echo
    @text
  end

  def reverse
    @text.reverse
  end

end
