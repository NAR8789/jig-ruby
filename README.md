# Qig

[![Gem Version](https://badge.fury.io/rb/qig.svg)](https://badge.fury.io/rb/qig)
[![CircleCI](https://circleci.com/gh/NAR8789/qig-ruby/tree/main.svg?style=shield)](https://circleci.com/gh/NAR8789/qig-ruby/tree/main)

qig is dig extended with jq's "value iterator" `[]` operator and some other goodies.

## Usage

```ruby
Qig.qig(subject, *path) # => contents of subject at path
```

examples:
```ruby
# dig-like usage
Qig.qig({a: { b: { c: 1 } } }, :a, :b, :c) # => 1

# dig-like usage augmented with jq's [] operator
Qig.qig({a: { b: [ { c: 1 }, { c: 2 } ] } }, :a, :b, [], :c) # => [1, 2]

# after expanding values, collect them back into an array for indexing into with `[[]]`
Qig.qig({ a: { b: [{ c: 1 }, { c: 2 }] } }, :a, :b, [], :c, [[]], 1) # => 2
```

More documentation in the [literate specs](spec/literate)

## Features

- [x] compatible with dig (see (dig conformance specs)[spec/literate/qig/02_conformance/dig_conformance_spec.rb])
- [x] jq-like value iteration (`[]` operator)
- [x] invoke ruby methods during inside the filter chain
- [x] value collect: `[[]]`, inverse of the `[]` operator. Collect streamed values back into an array
- [x] `Qig::Qiggable` mixin for more dig-like `subject.qig(*path)` syntax
- [ ] extensive literate specs
  - [ ] works with lazy collections

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'qig'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install qig

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/NAR8789/qig-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/NAR8789/qig-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Qig project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/NAR8789/qig-ruby/blob/main/CODE_OF_CONDUCT.md).
