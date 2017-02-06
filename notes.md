# Launch School Course 350 Notes

## The File System

### Working with Paths

We can get a string of the current _absolute path_ of our currently running Ruby program with `Dir.pwd`.

```ruby
Dir.pwd # => "/Users/tyler/Documents/workspace/launch-school/350"
```

#### Joining Paths

It's a best practice to use the methods provided by `File` to manipulate file paths.

```ruby
File.join 'path', 'to', 'file' # => "path/to/file"
```

Doing this lets Ruby handle the differences between operating systems, which may use a different file path syntax from the one we're working with, for us.

#### Absolute Paths

```ruby
File.absolute_path 'notes.md' # => "/Users/tyler/Documents/workspace/launch-school/350/notes.md"
```

`File` gives us a method that returns the absolute path of a file we pass into it. The first argument is the relative path to the file we want the absolute path to, and the second argument is the file we want the path to be relative to. So, if we want to get the absolute path for a file that we know the path relative to the current file, we pass it the `__FILE__` "magic constant."

```ruby
File.absolute_path '../310/notes.md' # => "/Users/tyler/Documents/workspace/launch-school/310/notes.md"
```

#### Directory Listings

We can use `Dir.glob` to return all the files that match a specific pattern.

```ruby
Dir.glob './*' # => ["./check_me.txt", "./errors.txt", "./exercises.md", "./largest_download.rb", "./notes.md", "./README.md", "./spellcheck.rb", "./words.txt"]
```

We can use `*` as a wildcard character, and put it anywhere in the string we want to match.

### Lesson 2: Reading and Writing Files

Read an entire file:

```ruby
content = File.read 'path/to/file.txt'
```

Write to a file:

```ruby
File.write 'path/to/file.txt', content
```

This will truncate anything in the existing file, effectively deleting the entire thing. If we want to simply add lines to a file, we can use `File.open`:

```ruby
File.open 'path/to/file.log', 'a' do |file|
  file.write 'something happened'
end
```

The second argument is the mode of the file:

Mode | Meaning
--- | ---
r | Read-only, starts at beginning of file. This is the default mode.
r+ | Read-write, starts at beginning of file.
w | Write-only, truncates existing file to zero length or creates a new file for writing.
w+ | Read-write, truncates existing file to zero length or creates a new file for reading and writing.
a | Write-only, each write call appends data at end of file. Creates a new file for writing if file does not exist.
a+ | Read-write, each write call appends data at end of file. Creates a new file for reading and writing if file does not exist.

#### Large Files

If we need to read a large file, we can use `File.foreach`:

```ruby
File.foreach 'path/to/file.txt' do |line|
  # do something with the line
end
```

We can also do something with the `file` object passed into the block with a `File.open` call:

```ruby
File.open 'path/to/file.txt' do |file|
  file.each_line do |line|
    # do something with the line
  end
end
```

## Console Applications

### Arguments

When running a Ruby program at the command line, any arguments listed after the program name are made available in Ruby in a special array, `ARGV`. The following code listing shows a small program that prints out any arguments it receives:

```ruby
# argv.rb

ARGV.each_with_index do |arg, idx|
  puts "#{idx}: #{arg}"
end
```

```
$ ruby argv.rb 'hello' ./
0: hello
1: ./
```

#### Parsing Arguments

We can also pass flags (they're stored as strings):

```
$ ruby argv.rb -a b --c "d"
0: -a
1: b
2: --c
3: d
```

While we can parse this stuff manually, there are a lot of libraries out there which help us do this in a less error-prone way. `OptionParser` from the SDTLIB is one such example, which we'll use here:

```ruby
# program.rb

require "optparse"

verbose = false
number = 1

# Create a block to define options (which will return the configured object).
options = OptionParser.new do |opts|
  # Declare a default usage message to display.
  opts.banner = "Usage: program.rb [options]"

  # Define an option, v, that can be passed to the program. This block will be
  # run if the option is passed.
  opts.on("-v", "Enable verbose logging") do
    verbose = true
  end

  # This block is run if the option n is passed to the program, and the value
  # of n is yielded to the block. It will be a String initially, so note how it
  # is converted to a Fixnum in the block.
  opts.on("-n NUMBER", "Use number") do |n|
    number = Integer(n)
  end
end

options.parse!

puts "Verbose is #{verbose}"
puts "Number is #{number}"
```

We can now pass `-v` into the program:

```
ruby program.rb -v
Verbose is true
Number is 1
```

It'll also accept `-n` with a number:

```
ruby program.rb -n 3
Verbose is false
Number is 3
```

### Input and Output

#### Output

All ruby prints will print to STDOUT. `Kernel#puts` passes parameters along to `$stdout.puts`. `$stdout` (or `STDOUT`) is an instance of `IO`, which means it behaves similarly to a read-only `File` object.

#### Input

Ruby processes accept input from STDIN, which goes to the terminal in which the program was started. `gets` accepts a line of string from STDIN and returns it.

`gets` is defined in `Kernel`, and we can call it directly from `$stdin` or `STDIN`.

If we want a single keypress, we can require `io/console`, which gives us `getch`.

```ruby
require 'io/console'
char = STDIN.getch
```

### Adding Shebangs to Ruby Programs

Up until now, we've used the `ruby` executable to run a Ruby program. We can also run it like any other executable using a shebang.

```ruby
#!/usr/bin/env ruby
ARGV.each_with_index do |arg, idx|
  puts "#{idx}: #{arg}"
end
```

This tells the shell how to interpet the file's contents. We also need to `chmod` the file to make it executable. After that we can just type the filename into the command line. We don't even need to add the `.rb` extension if we want to run it just like any other program like `ls`.

### Exiting

We can call the `at_exit` and pass a block to it to run some code as the program exits.

```ruby
at_exit { puts 'goodbye' }
```

We can call `at_exit` multiple times, and the blocks are placed in a stack, which means they're run in reverse.

```ruby
at_exit { puts '1' }
at_exit { puts '2' }
```

When the above program exits, it will print the following:

```
2
1
```

If a program exits as a result of an `exit!` call, none of our `at_exit` blocks will be executed.

### External Programs

Ruby is really good at getting to programs to work with each other, being the 'glue' that joins them. We can easily execute another program from within a Ruby program.

To run an external program, we use the following to parts:

1. Execute the program with the proper arguments
2. Work with the streams connected to the process while it is running and after it is completed.

The easiest way to do this is to use backticks.

```ruby
puts `ls -lah`
```

Backticks are methods on `Kernel`, so it's available anywhere. The output can be collected and returned, so we can assign it to a variable.

```ruby
info = `uname -a`
```

If we try to execute a program that doesn't exist, it'll throw.

### Working with Exit Codes

In Unix, many programs return an exit code when they exit. If the code is `0`, then it ran and exited without error. All other exit codes indicate a failure or error. We can check this in the program that we ran using backticks using the global variable `$?`, which stores the exit code of the last external program that was run. It's stored as a `Process::Status` object, which provides a `#success?` method.

```ruby
`date`
$?.success? #=> true
`ls foo`
$?.success? #=> false
```

Ruby programs can specify an exit code by passing an integer into our `exit` call. Say we have the program `minion.rb`:

```ruby
# minion.rb

exit [0, 1].sample
```

Now let's write another program that runs `minion.rb` and gives a message based on whether or not that `minion.rb` exited successfully.

```ruby
# overseer.rb

`ruby minion.rb`
puts $?.success? ? 'It worked.' : "It failed with a status of #{$?.exitstatus}"
```

## Media Transcoding

### Intro to FFMPEG

Ruby isn't all too great at video processing, since it's a task that requires lots of low-level work involving a lot of data. We can instead use Ruby as a scripting language to automate the operation of other powerful programs.

FFMPEG is a video manipulation workhorse that runs on all platforms. We can run it with the command line:

```
ffmpeg -i $INPUT_PATH -vf scale=$SIZE:-1 $OUTPUT_PATH 2>&1
```

This is fairly self-explanatory. `2>&1` causes the error output of the program to be redirected to the same place as normal output so it can be captured easily by the program running the command.

## Data Serialization

### Introduction

Ruby needs a way to represent data for transmission between programs, since Ruby objects only exist in memory. A common way to represent these objects is text, which is nice, since text is versatile. The process of putting a Ruby object (or any kind of data, for that matter) is called serialization. Here we'll look at several such formats.

### Marshal

`Marshal` is a module that creates a string representation of any Ruby object and can use strings to recreate objects later, even in a different program on a different computer. This is only useful for internal purposes, and should never be used for input from the outside world. This is because converting a stringified Ruby object can cause arbitrary code to execute. This is a security risk.

Marshalled objects are meant as a means for temporary storage. Marshalled must be converted back into a Ruby object in order for the values to be inspected, which is why it is referred to as an "opaque" data format.

`Marshal.dump` creates a String representation of an object, and `Marshal.load` reverses the process. Notice that although the object can be restored, it creates a new, unique object in memory.

```ruby
class Phantom
  def initialize(name)
    @name = name
  end

  def hide
    puts "#{@name} is hidden."
  end
end

julia = Phantom.new 'Julia'
marshalled_julia = Marshal.dump julia
unmarshalled_julia = Marshal.load marshalled_julia

unmarshalled_julia.hide
#=> Julia is hidden

julia.object_id
#=> something

unmarshalled_julia.object_id
#=> something else
```

### Serializing Objects as YAML

YAML is a data serialization format that is commonly used for config files in Ruby objects. YAML has similar methods to Marshal, including `dump` and `load`.

A YAML document looks like the following:

```yaml
---
receipt:     Oz-Ware Purchase Invoice
date:        2012-08-06
customer:
    given:   Dorothy
    family:  Gale

items:
    - part_no:   A4786
      descrip:   Water Bucket (Filled)
      price:     1.47
      quantity:  4

    - part_no:   E1628
      descrip:   High Heeled "Ruby" Slippers
      size:      8
      price:     100.27
      quantity:  1
```

YAML is a good choice when we need to interchange data between Ruby and non-Ruby programs. YAML is easy for humans to read and edit, but its whitespace-activeness makes it a little unwieldy. YAML can in some cases serialize Ruby objects as Marshal, but the resulting file would only correctly load in other Ruby programs.

### Serializing Objects as JSON

Ruby gives us a JSON library for reading and writing the JSON format.

```ruby
require 'json'
h = { creature: 'falcon', level: 4 }
json = JSON.generate h
parsed_h = JSON.parse json #=> { 'creature' => 'falcon', 'level' => 4 }
```

Notice that the transition between a hash and JSON altered the data slightly. Since JSON does not supports symbols, the symbols in the hash get converted to strings.

If we put an object into our hash, `JSON` will attempt to call the `#to_json` method on that object. If it doesn't exist, it will call `#to_s` and use that value in the resulting object.

```ruby
json = JSON.generate [julia] # remember julia, the Phantom object we created earlier
#=> "[/"#<Phantom:0x007...>/"]"
JSON.parse json
#=> ["#<Phantom:0x007...>"]
```

We need to implement a `#to_json` instance method for `Phantom` in order to store information in a JSON string about that object.

```ruby
class Phantom
  def to_json(options=nil)
    {type: "phantom", name: @name}.to_json
  end
end

json = JSON.generate [julia]
JSON.parse json
#=> [{"type"=>"phantom", "name"=>"Julia"}]
```

JSON is an extremely popular standard for representation of data used by web services. Since it's based on JavaScript objects, the most similar representation in Ruby is a hash.

JSON's major drawback is that it doesn't support a datatype for dates and times. These are usually converted to a standard String representation when being transmitted.

## Interacting with the Web

### Making HTTP Requests

Ruby gives us a `Net` library that allows us to interact with network systems using various protocols. It operates at a fairly low level, so most people prefer to use a more convenient API. We'll be using `Faraday` here.

Here's how we retrieve a web page with Faraday.

```ruby
require 'faraday'

# Returns a `Faraday::Response` object.
response = Faraday.get 'http://google.com'

response.status #=> 301
response.headers #=> {'location' => 'http://www.google.com', ...}
response.body #=> '<HTML><HEAD><meta http-equiv=\"content-type\" ...'
```

We can fetch some JSON data from a web page too. The JSON lib is ready to take the JSON body returned by a JSON API.

```ruby
require 'faraday'
require 'json'

respone = Faraday.get 'http://api.openweathermap.org/data/2.5/weather?q=London,uk'
json = response.body

data = JSON.parse json
data['weather'][0]['description']
#=> 'Sky is clear'
```

### Parsing Web Pages

While many services nowadays use JSON APIs in order to make their data available, some data is only available on a website. The practice of collecting data from a public website is called "web scraping." It involves:

- Determining the URL for the desired web page.
- Fetching the HTML code for that page.
- Loading the HTML using a library that can parse it.
- Traversing the document structure and extracting the desired information.

If we want to parse out numerical data, we want to convert the data on the page (which is always text), to a Fixnum for Float. Thus there is a fifth step involved much of the time:

- Parsing the extracted information into other objects as needed.

One of the more popular gems for doing this is Nokogiri.

## Working with CSV

### Introduction to CSV

CSV is a common format that is used as an intermediary between a large number of different systems. Spreadsheets are often exported in CSV format, and database dumps and other data "releases" are often made available in CSV. This popularity is largely due to nearly universal support for the format across programming languagesand the simplicity of the format itself, which is represented in plaintext.

CSV is not a standard, and different implementations can have different behavior. It is a good idea to know what delimiters are used to divide the lines and values. For example, it is fairly commont to use tab characters instead of commas to divide values.

#### Sitepoint's guide to Ruby CSV

##### Avoiding common quirks

If we have a piece of data with commas in it, we need to surround the entire cell with double quotes:

```csv
Maria,55,5054,"Good, delicious food!"
```

If we have double quotes within such a cell, we need to escape those characters with an additional double quote character.

```csv
Carlos,22,4352,"I am ""pleased"", but could be better"
```

##### How Ruby Sees CSV Files

First we require the 'csv' lib, which is included in Ruby

```ruby
require 'csv'
```

The CSV lib gives us the option to either import the entire file at once (in memory), or read from it line by line. With larger files, we'll probably need to do the latter. Ruby stores each row as an array. Let's use `CSV.read` to read in the entire file `customers.csv`:

```ruby
require 'csv'
customers = CSV.read 'customers.csv'
#=>
# [ ...
# ["Maria", "55", "5054", "Good, delicious food."]
# ... ]
```

Other lines omitted. Note that we've created a 2D array. We can read line-by-line with `CSV.foreach`:

```ruby
CSV.foreach('customers.csv') do |row|
  puts row.inspect
end
```

##### The CSV Lib Can Also Process Strings, Not Just Files

We can store comma-separated data into a `String` object in Ruby.

```ruby
a_string = "Dan,34\nMaria,55"
CSV.parse a_string #=> [['Dan', '34'], ['Maria', '55']]
```

We can also pass a block into `CSV.parse`:

```ruby
CSV.parse(a_string) { |row| puts row.inspect }
```

This will produce ['Dan', '34'] and ['Maria', '55'] on separate lines. Without a block, `CSV.parse` is similar to `CSV.read`; the difference being that `parse` takes a string and `read` takes a (path to a) file. The output is the same.

##### What to do When Your CSV is SSV (Semicolon-separated values)

If we use a different character to separate our columns, we need to pass an options hash into `read`, `parse`, `foreach`, etc.. In this case, we pass a hash with the key `:col_sep`, with the value being whatever we want our character to be. For example, we use `col_sep: ';'` if our file is semicolon-delimited.

```ruby
new_customers = CSV.read 'customers.csv', col_sep: ';'
```

##### Let's Do Some Manipulation

Let's say we want to take the CSV with most frequent customers (`customers.csv`) and calculate the average money spent for each arrival, dividing the total money the customer spent with the total times they visited. We already have that data in column 3 and 2.

```ruby
average_money_spent = []
CSV.foreach 'customers.csv' do |row|
  average_money_spent << row[2] / row[1]
end
```

The third line here will throw, since the data in each column gets parsed as a string. We could use `Integer` or a similar technique whenever we take data from a cell, but the `CSV` lib gives us the option to pass in a `:converters` option in the opts hash. Since we want to convert all numeric values to `Fixnum` or its ilk, we can make the value for that `:numeric`:

```ruby
CSV.foreach('customers.csv', converters: :numeric) do |row|
  # ...
end
```

##### Outputting our Results in a File

So we have our dataset here:

```csv
Dan,34,2548,Lovin it!
Maria,55,5054,"Good, delicious food"
Carlos,22,4352,"I am ""pleased"", but could be better"
Stephany,34,6542,I want bigger steaks!!!!!
```

Now let's add a 5th column for the data we're putting in `average_money_spent`. To do this, we'll need to open the file in different modes. `CSV` gives us the `#open` method, much like the one in `File`.

So let's read the contents of the CSV file into memory and add the corresponding value of `average_money_spent` to each row. Then let's save the file using `CSV.open` in `w` mode.

```ruby
# Continuing from the above code...

customers_array = CSV.read 'customers.csv'
customers_array.each do |customer|
  customer << average_money_spent.shift
end

CSV.open 'new_customers_file.csv', 'w' do |csv_obj|
  customers_array.each do |row_array|
    csv_obj << row_array
  end
end
```

So let's step through this. First we have an array `average_money_spent` from earlier. Each element in this array corresponds to a row in our table, so its length is equal to the number of rows in the table. From the same data, we're reading and parsing it into `customers_array`, which is a 2d array. To each element in this array we're adding another element from `average_money_spent`. We then open a new file `new_customers_file.csv` and write each row from `customers_array` into this file.

## Building an IRC Bot

### Introduction to IRC

Internet Relay Chat is a text-based protocol for sending messages between clients and servers.

### The IRC Protocol

#### A quick, basic guide on the IRC protocol

The first part of the IRC protocol is the rough layout of messages. The first, optional part is the source (username and hostmask, or server) preceded by a colon, as in `:holmes.freenode.net`. This is rarely included in the message by a client, while it is almost always included in a message by the server.

The next part is the command name, which is in all caps. These are mostly the same as what the user types in after a `/`. For example, `/join` becomes `JOIN`. After this are the arguments, which are mostly limited to one-word values. The exception is the last argument, which is started with a colon character.

Most channels are of the `#channel` variety.

The command is terminated by `\r\n`, not `\n`. Most servers will accept either, though.

An example of a full message is:

```irc
:Macha!~macha@unaffiliated/macha PRIVMSG #botwar :Test response
```

The first part of any IRC connection is sending the `NICK` and `USER` messages. The first of these is simple, just `NICK name`. The next is the `USER` message.

An example of a `USER` message is:

```irc
USER username 0 * :Real name
```

The `*` is a remnant of earlier days, and will not be changed. The `0` is a bitmask of the user's mode, but with just one switch. Change it to `8` to be invisible to those not in a channel with you.

The next part of the protocol is the `PING` message, because some servers need one immediately after those two messages. The server will send you a message in the format `PING :message` to which it needs a response of `PONG :message`. This is the most common case of a server not sending a source. Most servers use the server name as the message part, but this isn't always the case.

For all the rest of these messages, there is a source on the other messages fom the server side. This is a user and hostmask for a user's message, and a server name otherwise. If you are writing a client, do not send the `:source` part.

The next message to deal with is `JOIN`. The basic format of this message from most servers is:

```irc
:source JOIN :#channel
```

Although the spec says otherwise regarding the need for the colon. `JOIN 0` leaves all channels.

Its counterpart is `PART`. Its format is

```irc
:source PART #channel :reason
```

`:reason` is optional, and some servers cut it off, since it did not exist in earlier versions of the protocol.

Both of these messages can also accept a list of channels, separated by commas.

```irc
:source PART #channel1,#channel2 :reason
```

Don't put spaces between these.

The most important command in the IRC protocol is `PRIVMSG`. This is used for sending messages to channels and between users. Here's the format:

```irc
:source PRIVMSG <target> :Message
```

The target is either a user's nick, or a channel's name. To send a message to a channel:

```irc
:source PRIVMSG #channel :Hello, world
```

and to a user:

```irc
:source PRIVMSG Nick :Hi Nick.
```

The final message you will see in basic usage is `QUIT`. Its format is:

```irc
:source QUIT :reason
```

where `:reason` is optional.

#### Video Notes

Here's a list of IRC commands that we'll be using:

```irc
USER <username> <hostname> <servername> :<realname>
NICK <nickname>
JOIN <channel>
PRIVMSG <target> :<message>

PONG <arg1> <arg2> <etc>
PART <channel>
QUIT
```

Each command begins with the name, followed by a bunch of arguments. The last command is preceeded by a colon, because it might contain a space. There are an unlimited number of arguments, but the most we'll see is 4 or 5.

Since IRC is text-based, we can use telnet to interact with it.

```
telnet chat.freenode.net 6667
```

This will connect us to the server. From here we need to tell the server who we are in order to fully connect to the IRC server itself. If we don't indentify ourselves within a reasonable amount of time, the server will close the connection.

```irc
USER rubyircbot localhost localhost :rubyircbot
NICK rubyircbot
```

Once we've identified ourselves the server will send us a bunch of text describing the server we're connected to and the rules we're expected to follow as a user. We can join a channel on the server using the `JOIN` command.

```irc
JOIN #rubyircbottest
```

The server sends back a message acknowledging that we've joined the channel.

In the video the instructor connects to the channel using a browser-based IRC client. If we send a message through the client, we should see it in our terminal running telnet.

Looking at the terminal, we see the following message:

```irc
:rubybottestuser!<information about the server> PRIVMSG #rubyircbottest :Hello there!
```

Let's reply to the message via the terminal:

```irc
PRIVMSG #rubyircbottest :leguin.freenode.net
  Hi!
```

### IRC Web Clients

There are a lot of IRC clients that can connect to IRC servers. Here we'll use kiwiirc, which is a nice free GUI for communicating over IRC.

To connect to an IRC server and a channel, we just select "Freenode" from the list of networks and choose an nick and a channel. For this lesson we want to make sure we have an empty channel.

### Connect to a Server with TCPSocket

We want to accomplish three things:

- Connect to an IRC server by opening a TCP Socket
- Send USER, NICK, and JOIN to log into the server and join a room.
- Print out messages that are received.

In order to connect to an IRC server, we need three things: the server's hostname, the port to connect on, and the nickname our bot can use to identify itself.

### IRC Command Parsing

Say we have the following commands from the server:

```irc
PING :sendak.freenode.net

:EllenRipley!~ripley@nostromo.biz PRIVMSG #lobby :Hello, world

:sendak.freenode.net NOTICE * :*** Looking up your hostname...
```

The first is the most basic kind of command, so if we can parse more complex ones this should be trivial.

The second contains some information about who sent the PRIVMSG. First is the NICK (`EllenRipley`), then we have the actual username (`ripley@nostromo.biz`). We also have two arguments, `#lobby` and `:Hello, world`.

Let's see how we can parse this second option. We need to extract the nick, the user, the name of the command, and its arguments.

If the command begins with a colon, then we know the command contains the nick, the user, or both. We parse out the first part, and from that we can extract two items from that: the nick and the user. If the string contains an `!`, then we know it has a user.

```
:EllenRipley!~ripley@nostromo.biz -> nick & user
:EllenRipley         -> nick
~ripley@nostromo.biz -> user
```

Then we have the command itself with its arguments, which are separated by spaces. The problem is that the trailing argument can also contain spaces. So we can find a colon, and if it's there we can split the string there. That'll give us the trailing argument and everythign else, so we can split everythign else by spaces.

```
PRIVMSG #lobby :Hello, world
:Hello, world -> trailing arg
PRIVMSG #lobby -> everything else
PRIVMSG -> command
#lobby, ... -> args
```

## Working with Images

### Introduction to RGB Color

The tristimulous theory of color perception is used in photography, film, television and printing. We will use the theory to explain how the mixing of different light colors is achieved.

With additive color, we are mixing colored light. The additive primary colors are red, green, and blue. The secondary colors are obtained when we mix two primary colors together. Red + Blue = Magenta, Red + Green = Yellow, and Blue + Green = Cyan. All three colors come together to produce white light.

When we add together complimentary colors, we get white.

### ChunkyPNG

PNG is al ossless image format that works across a variety of modern browsers. It supports transparency and up to 256 bits of color per channel. We'll be working with the ChunkyPNG lib in this lesson. It allows us to read and modify each pixel's data in a PNG image.

```ruby
require 'chunky_png'

png = ChunkyPNG::Image.new 50, 50 ChunkyPNG::Color::Transparent
cells = 50

cells.times do |n|
  if n % 2 == 0
    cells.times do |x|
      if x % 2 != 0
        png[x, n] = ChunkyPNG::Color.rgba(10, 20, 30, 128)
      end
    end
  end
end

png.save 'smile.png', interlace: true
```

The above script gave us a bunch of squares. Let's modify it a bit.

```ruby
require 'chunky_png'

png = ChunkyPNG::Image.new 50, 50 ChunkyPNG::Color::Transparent
cells = 50

cells.times do |n|
  if n % 2 == 0
    cells.times do |x|
      if x % 2 != 0
        png[x, n] = ChunkyPNG::Color.rgba(10, 20, 30, 128)
      end
    end
  end
end

color = ChunkyPNG::Color.from_hex '#0066FF'

png.circle 15, 10, 5, color, color
png.circle 35, 20, 3, color, color
png.circle 25, 20, 3, color, color

png.save 'smile.png', interlace: true
```

The calls to `#circle` creates circles. The arguments are: `x, y, radius, fill_color, stroke_color`. In this case, we get eyes and a nose.

We'll add the following lines before the save:

```ruby
pgn.line 5, 25, 25, 40, color, color
png.line 25, 40, 45, 25, color, color
```

## Scraping Data from the Web

### Load a CSV into SQLite

Here are the commands used in the video:

```
bundle install
rake setup
sqlite3 scraper.sqlite3

# In sqlite3 prompt:

.mode csv # change to CSV mode
.import ../dining_chairs.csv items
.mode column # change to column (sql) mode
SELECT * FROM items;
```
