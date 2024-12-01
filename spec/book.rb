# frozen_string_literal: true

require 'active_record'
require 'mobility'
require 'mobility_uniqueness'

# Configure mobility
Mobility.configure do
  plugins do
    backend :key_value

    active_record

    reader
    writer

    locale_accessors %i[en tr fr]
  end
end

class Book < ActiveRecord::Base
  extend Mobility

  translates :title, type: :string
  translates :description, type: :text

  validates_uniqueness_of_translated :title
end
