# Course 350 Exercises

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
