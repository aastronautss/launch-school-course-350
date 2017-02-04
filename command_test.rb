require "minitest/autorun"

require_relative "./command"

class CommandTest < Minitest::Test
  def test_ping_command
    command = Command.parse("PING :sendak.freenode.net")

    assert_equal nil, command.nick
    assert_equal nil, command.user
    assert_equal "PING", command.name
    assert_equal ["sendak.freenode.net"], command.arguments
  end

  def test_parse_command
    command = Command.parse(":EllenRipley!~ripley@nostromo.biz PRIVMSG #lobby :Hello, world!")

    assert_equal "EllenRipley", command.nick
    assert_equal "~ripley@nostromo.biz", command.user
    assert_equal "PRIVMSG", command.name
    assert_equal ["#lobby", "Hello, world!"], command.arguments
  end

  def test_parse_system_command
    command = Command.parse(":sendak.freenode.net NOTICE * :*** Looking up your hostname...")

    assert_equal nil, command.nick
    assert_equal "sendak.freenode.net", command.user
    assert_equal "NOTICE", command.name
    assert_equal ["*", "*** Looking up your hostname..."], command.arguments
  end

  def test_parse_system_command_without_trailing_arg
    command = Command.parse(":rajaniemi.freenode.net 004 rubytestbot rajaniemi.freenode.net ircd-seven-1.1.3 DOQRSZaghilopswz CFILMPQSbcefgijklmnopqrstvz bkloveqjfI")

    assert_equal nil, command.nick
    assert_equal "rajaniemi.freenode.net", command.user
    assert_equal "004", command.name
    assert_equal %w(rubytestbot rajaniemi.freenode.net ircd-seven-1.1.3 DOQRSZaghilopswz CFILMPQSbcefgijklmnopqrstvz bkloveqjfI), command.arguments
  end
end
