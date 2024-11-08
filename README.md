# Mobility Uniqueness

Mobility Uniqueness is a Ruby gem that extends the [Mobility](https://github.com/shioyama/mobility) gem by enabling uniqueness validation on translated attributes across multiple locales. With this gem, you can validate the uniqueness of translations on attributes in ActiveRecord models, ensuring consistency and preventing duplicate entries in different languages. It's designed to work seamlessly with **Mobility's default :key_value backend**, integrating directly into your model validations.

## Methods
* `validates_uniqueness_of_translated(*args, message: 'custom message')` - Validates that the specified attributes are unique across all locales

Default error message is _'violates uniqueness constraint'_ if the error message is not specified.

## Usage

### Basic Usage

```rb
class Book < ApplicationRecord
  extend Mobility

  translates :name, type: :string
  translates :description, type: :text

  validates_uniqueness_of_translated :name, :description
end
```

### Custom Error Messages

You can customize the error message for all:
```rb
class Book < ApplicationRecord
  extend Mobility

  translates :name, type: :string
  translates :description, type: :text

  validates_uniqueness_of_translated :name, :description, message: 'custom message'
end
```

### Attribute-Specific Error Messages

Specify different error messages per attribute for more granular feedback:
```rb
class Book < ApplicationRecord
  extend Mobility

  translates :name, type: :string
  translates :description, type: :text

  validates_uniqueness_of_translated :name,        message: 'name is not unique'
  validates_uniqueness_of_translated :description, message: 'description should be unique'
end
```

## Purpose
This gem was initially developed as a Rails concern but was later extracted into a standalone gem to support reuse across projects. Its purpose is to address the common requirement of enforcing uniqueness for multilingual content, especially when data is stored in different locales. By encapsulating this functionality in a gem, developers can easily enforce unique translations without having to implement custom validation logic repeatedly.

As the Mobility gem maintainer stated in the issue comments that the gem has no support of validating uniqueness, so I went ahead and created this gem for all the developers who use mobility gem in their project.

Below mobility issues were my main motivation to create this gem.

* [Unique Validation didn't work with locale_accessors on every locales](https://github.com/shioyama/mobility/issues/603)

* [Uniqueness validation does not work](https://github.com/shioyama/mobility/issues/20)

# Summary

This gem provides an easy way to add uniqueness validation to translated fields in ActiveRecord models that use the Mobility gem. It ensures that translations are unique across locales, improving data integrity in multilingual applications.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/egemen-dev/mobility_uniqueness.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
