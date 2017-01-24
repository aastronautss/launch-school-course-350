# Course 350 Exercises

# Second Go

## Lesson 1

### Working with Paths

#### 1.

The `File` method that returns the filename part of a full path is `File.basename`.

```ruby
File.basename '/home/theuser/stuff.rb' # => 'stuff.rb'
```

#### 2.

We can use `File.basename` with a second argument to return the name of the file without the extension. For example:

```ruby
File.basename '/home/theuser/stuff.rb', '.rb' # => 'stuff'
File.basename '/home/theuser/stuff.rb', '.*'  # => 'stuff'
```

#### 3.

We have the following file structure:

```
├── data
│   ├── income-2013.csv
│   ├── income-2014.csv
│   ├── income-2015.csv
│   ├── income-modified.csv
│   ├── income.csv
│   └── sources
│       ├── development
│       │   ├── fusion.txt
│       │   └── tidal.txt
│       ├── fossil_fuels.txt
│       ├── solar.txt
│       └── wind.txt
└── reports
    └── year_end.rb
```

##### a.

From `year_end.rb` we would want to run the following code to determine the absolute path to the `data` dir:

```ruby
File.absolute_path '../data', __FILE__
```

##### b.

To get a list of all files within the `data` dir with a `.txt` extension, we would need to run the following code from `year_end.rb`:

```ruby
Dir.glob(File.join(File.absolute_path('../data', __FILE__), '**/*.txt'))
```

##### c.

To get a list of all files in `data` with a `.csv` extension as well as a number, we would need to run the following code from `year_end_.rb`:

```ruby
data_path = File.join File.absolute_path('../data', __File__)
Dir.glob File.join(data_path, '**/*[0-9][0-9][0-9][0-9]*.csv')

# Per the solution, we could use the following if we know for a fact that such files follow the pattern of `income-yyyy.csv`:

Dir.glob File.join(data_path), '**/income-????.csv'
```

#### 4.

We can change the current working directory by calling `Dir.chdir`:

```ruby
Dir.chdir '/var'
Dir.pwd # => '/var'
```

#### 5.

Given `"/Users/captain/ruby/data/sources/development/fusion.txt"` we can extract the following:

First let's set the variable:

```ruby
the_file = '/Users/captain/ruby/data/sources/development/fusion.txt'
```

Extension:

```ruby
File.extname the_file
```

Basename:

```ruby
File.basename the_file
File.basename the_file, File.extname(the_file)
```

Absolute path for the parent directory:

```ruby
File.dirname the_file
```

## Lesson 2

### 1.

To delete a file:

```ruby
File.delete 'path/to/garbage.db'

# or...

File.unlink 'path/to/garbage.db'
```

### 2.

#### a.

The options for `File.mode` are listed here:

https://ruby-doc.org/core-2.2.0/IO.html#method-c-new

#### b.

Use `w` or `w+` mode to truncate an existing file or to create a new one.

```ruby
File.open 'path/to/file', 'w'
```

### 3.

When an error is raised in a `File.open` block, the it uses the equivalent to `ensure` to make sure the file is closed.

### 4.

Without using `Dir.[]` or `Dir.glob`, we can get an array of filenames that match certain conditions using `Dir.entries` with a `select` call:

```ruby
Dir.entries('.').select do |path|
  File.extname(path) == '.rb'
end
```

### 5.

Write some Ruby code that prints out the number of files and directories in the home directory:

```ruby
# home_catalog.rb

home_dir = ENV['HOME']
dir_count = 0
file_count = 0

Dir.entries(home_dir).each do |entry|
  next if ['.', '..'].include? entry
  path_to_entry = File.join home_dir, entry

  if File.directory? path_to_entry
    dir_count += 1
  else
    file_count += 1
  end
end

puts "Files: #{file_count}"
puts "Directories: #{dir_count}"
```

### 6.

#### a.

`Dir.mkdir` returns 0 if the directory is successfully created. It throws if it is not.

#### b.

`Errno::EEXIST` is raised if the dir already exists.

## Lesson 2: console Applications

### Arguments

#### 1.

```ruby
# echo.rb

ARGV.each_with_index do |arg, idx|
  puts "#{idx}: #{arg}"
end
```

#### 2.

```ruby
# program.rb

require 'optparse'

verbose = false
number = 1

OptionParser.new do |opts|
  opts.banner = "Usage: program.rb [options]"

  opts.on '-v', "Enable verbose logging" do
    verbose = true
  end

  opt.on '-n NUMBER', 'Use number' do |n|
    number = Integer(n)
  end
end.parse!

puts "Verbose is #{verbose}"
puts "Number is #{number}"
```

#### 3.

```ruby
# alpha_opt.rb

require 'optparse'

OptionParser.new do |opts|
  opts.banner = "Usage: program.rb [options]"

  ('a'..'z').each do |letter|
    opts.on("-#{letter}", "Option #{letter.upcase}") do
      a = true
    end
  end
end.parse!
```

#### 4.

First we parse the flagged options with `OptionParser`. After `#parse!` is called, `ARGV` is left with the leftover options:

```ruby
# positional_opts.rb

require 'optparse'

OptionParser.new do |opts|
  opts.banner = 'Usage: positional_opts.rb [options]'

  opts.on '-v', 'Enable verbose mode'
  opts.on '-o OUTFILE', 'Use specified output file'
end.parse!

ARGV.each do |file|
  puts file
end
```

### Input and Output

#### 1.

`Kernel.putc` can print a single character.

#### 2.

The difference between `putc` and `print` is that `putc` returns the value it printed, while `print` and `puts` return `nil`.


### Exiting

#### 1.

```ruby
# counter.rb

#!/usr/bin/env ruby

n = 1

loop do
  puts n
  sleep 1
  n += 1
end
```

With `at_exit` call:

```ruby
# counter.rb

#!/usr/bin/env ruby

n = 1

at_exit { puts "At least I got to #{n}!" }

loop do
  puts n
  sleep 1
  n += 1
end
```

#### 2.

We can use `exit!` to exit without executing our `at_exit` blocks.

### External Programs

#### 1.

Use `ls /` to get a list of filenames in an array.

```ruby
`ls /`.split
```

#### 2.

##### a.

```ruby
# commitall

#!/usr/bin/env ruby

commit_message = ARGV.first

`git add -A`
`git commit -m "#{commit_message}"`
```

##### b.

Double quotes in commit messages need to be escaped. We can do this using `shellwords`:

```ruby
require 'shellwords'

commit_message = ARGV.first

`git add -A`
`git commit -m #{Shellwords.escape(commit_message)}`
```

Note that we don't have to add quotes to the resulting string, as `Shellwords.escape` already adds them.
