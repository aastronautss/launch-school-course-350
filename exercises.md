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
