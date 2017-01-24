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
