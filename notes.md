# Launch School Course 350 Notes

## The File System

### Lesson 1: Working with Paths

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
