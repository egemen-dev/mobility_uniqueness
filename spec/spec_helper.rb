# frozen_string_literal: true

require 'active_record'
require 'mobility'
require 'rspec'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'

load "#{File.dirname(__FILE__)}/schema.rb"
require "#{File.dirname(__FILE__)}/book.rb"
