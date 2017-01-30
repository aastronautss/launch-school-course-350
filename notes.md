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
