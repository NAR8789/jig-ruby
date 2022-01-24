# 0.3.0 (Upcoming)

## BREAKING CHANGES

- drop ruby 2.6 support, because Ruby 2.6 will be EOL in 2 months, and Ruby 2.7 pattern matching syntax makes
  command parsing cases *much* easier to maintain, keeping the main switching logic a single-level `case`

## Features

- method invocation syntax (e.g. for filtering)
- quoting syntax to use operators as literal keys
- reboxing operator or value collection operator, inverse of the value iteration operator

## Documentation

- Reorganize and explain literate specs
- Specs for dig conformance

## Fixes

- On invalid access to struct, return nil, for better conformance to Struct#dig. Previously this raised error.

# 0.2.0 (January 14, 2022)

## Features

- Value iteration(`[]` over hashes)

## Documentation

- Initial yard documentation on method and module
- Document and spec that we can qig into Structs and OpenStructs

# 0.1.3 (January 13, 2022)

## Documentation

- fix changelog uri (again)

# 0.1.2 (January 13, 2022)

## Documentation

- fix changelog uri

# 0.1.1 (January 13, 2022)

## Documentation

- fix repository url
- initial changelog

# 0.1.0 (January 13, 2022)

## Features

- Ability to qig into arrays and hashes
- Value iteration (`[]`) over arrays
