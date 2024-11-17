# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Book, type: :model do
  before do
    I18n.available_locales = %i[en tr fr]
    Mobility.locale = :en
  end

  context 'when validating translated uniqueness for title' do
    it 'allows creation of a unique title in the same locale' do
      book = Book.create!(title_en: 'Unique Title')
      expect(book.errors[:title]).to be_empty
    end

    it 'prevents creating a duplicate title in the same locale' do
      Book.create!(title_en: 'Another Unique Title')
      duplicate_book = Book.new(title_en: 'Another Unique Title')
      duplicate_book.valid?

      expect(duplicate_book.errors[:title_en]).to include('violates uniqueness constraint')
    end

    it 'allows the same title in different locales' do
      Book.create!(title_en: 'Unique Title for Different Locale')
      Mobility.locale = :fr
      book_fr = Book.new(title_fr: 'Unique Title for Different Locale')
      expect(book_fr).to be_valid
    end

    it 'validates uniqueness of title on update' do
      Book.create!(title_en: 'Initial Title')
      book2 = Book.create!(title_en: 'Another Title')

      book2.update(title_en: 'Initial Title')
      expect(book2.errors[:title_en]).to include('violates uniqueness constraint')
    end
  end

  context 'when validating translated uniqueness for description' do
    it 'allows creation of a unique description in the same locale' do
      book = Book.create!(description_en: 'Unique Description')
      expect(book.errors[:description]).to be_empty
    end

    it 'prevents creating a duplicate description in the same locale' do
      Book.create!(description_en: 'Another Unique Description')
      duplicate_book = Book.new(description_en: 'Another Unique Description')
      duplicate_book.valid?

      expect(duplicate_book.errors[:description_en]).to include('violates uniqueness constraint')
    end

    it 'allows the same description in different locales' do
      Book.create!(description_en: 'Unique Description for Different Locale')
      Mobility.locale = :tr
      book_tr = Book.new(description_tr: 'Unique Description for Different Locale')
      expect(book_tr).to be_valid
    end

    it 'validates uniqueness of description on update' do
      Book.create!(description_en: 'Initial Description')
      book2 = Book.create!(description_en: 'Another Description')

      book2.update(description_en: 'Initial Description')
      expect(book2.errors[:description_en]).to include('violates uniqueness constraint')
    end
  end
end
