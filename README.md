# PryMacro

Record command line actions for replaying.

## How is this different from play and history?

You can dynamically make your own command sets and have them saved for
later, as well as use pry commands.

## Basic Usage

Start recording:

```ruby
[1] pry(main)> record-macro
[2] pry(main)> 1
=> 1
[3] pry(main)> 'foo'
=> "foo"
[4] pry(main)> ls
self.methods: inspect  to_s
locals: _  __  _dir_  _ex_  _file_  _in_  _out_  _pry_
```

Stop the recording and name it:

```ruby
[5] pry(main)> stop-macro
Macro Name: testing
```

Run it like any other command:

```ruby
[6] pry(main)> testing
=> 1
=> "foo"
self.methods: inspect  to_s
locals: _  __  _dir_  _ex_  _file_  _in_  _out_  _pry_
```

Like it? You can save it and have it automatically append to your PryRC:

```ruby
[10] pry(main)> save-macro testing
```

...and here it is, nice and formatted:

```ruby
Pry::Commands.block_command 'testing', 'no description' do
  _pry_.input = StringIO.new(
    <<-MACRO.gsub(/^ {4,6}/, '')
      1
      'foo'
      ls
    MACRO
  )
end
```

## More Advanced Usage

We're working on getting the Wiki up to date to cover more advanced usage.

## Why?

* Cycling next to check a variable or content? Macro it.
* Repeating yourself for a workflow? Macro it.
* Auto retry after edits? Macro it.
* Error? Get the source, the stacktrace, and post it? Macro it.
* Going to Google that error? Fetch the error message, and Macro it.
* Someone wrote a bad method? Git blame, irc bot, and Macro it.
* Clever code? Shoot it to hubot to karma that person, and Macro it.

The possibilities here are endless. Make your own command sets as you
REPL along from what you've already written.

## To do

Next step is finding out how to properly test Pry and getting RSPEC written up for this.

## Installation

Add this line to your application's Gemfile:

    gem 'pry-macro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pry-macro


## Contributing

1. Fork it ( http://github.com/baweaver/pry-macro/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
