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

# First Go

## Lesson 1

### Working with Paths

#### 1.

```ruby
File.basename
```

#### 2.

```ruby
File.basename "file.txt", "txt"
```

#### 3.

##### a.

```ruby
File.absolute_path("../../data", __FILE__)
```

##### b.

```ruby
Dir.glob "../../data/*.txt"
```

Real answer:

```ruby
data_path = File.absolute_path("../../data", __FILE__)
puts Dir.glob(File.join(data_path), "**/*.txt")
```

##### c.

```ruby
data_path = File.absolute_path("../../data", __FILE__)
puts Dir.glob(File.join(data_path), "income-????.csv")
```

##### d.

```ruby
file_path = "/Users/captain/ruby/data/sources/development/fusion.txt"
File.extname file_path # => ".txt"
File.basename file_path, ".*" # => fusion
File.dirname file_path # => "/Users/captain/ruby/data/sources/development"
```

### Reading and Writing Files

#### 1.

```ruby
File.unlink "garbage.db"
```

#### 2.

##### a.

[http://ruby-doc.org/core-2.1.4/IO.html#method-c-new-label-IO+Open+Mode](http://ruby-doc.org/core-2.1.4/IO.html#method-c-new-label-IO+Open+Mode)

##### b.

Use `w` or `w+`.

#### 3.

No, passing a block to `File.open` will close the file after the block has finished executing.

#### 4.

```ruby
Dir.entries(".").select do |path|
  File.extname(p) == ".rb"
end
```

#### 5.

```ruby
home_dir = ENV["HOME"]
file_count = dir_count = 0

Dir.entries(home_dir).each do |path|
  next if path == "." || path == ".."
  fullpath = File.join(home_dir, path)

  if File.directory? fullpath
    dir_count += 1
  else
    file_count += 1
  end
end

puts "Files: #{file_count}"
puts "Directories: #{dir_count}"
```

#### 6.

##### a.

`Dir.mkdir` returns a `0` if it successfully makes a directory.

##### b.

`Dir.mkdir` will raise a `Errno::EEXIST` if it cannot be created.
