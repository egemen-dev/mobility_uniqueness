require 'spec_helper'

RSpec.describe Book, type: :model do
  before do
    I18n.available_locales = [:en, :fr, :tr]
    Mobility.locale = :en
  end

  context 'when validating translated uniqueness for `new` and `create` actions' do
    it 'allows creating a record with a unique title in the default locale' do
      book = Book.new(title_en: 'A Unique Title')
      expect(book.save).to be true
    end

    it 'prevents creating a record with a duplicate title in the same locale' do
      Book.create!(title_en: 'Duplicate Title')
      duplicate_book = Book.new(title_en: 'Duplicate Title')

      expect(duplicate_book.save).to be false
      expect(duplicate_book.errors[:title_en]).to include('violates uniqueness constraint')
    end

    it 'allows creating records with the same title in different locales' do
      Book.create!(title_en: 'Shared Title')
      Mobility.locale = :fr
      book_fr = Book.new(title_fr: 'Shared Title')

      expect(book_fr.save).to be true
    end

    it 'handles creating records with nil titles without conflict' do
      Book.create!(title_en: nil)
      book_with_nil_title = Book.new(title_en: nil)

      expect(book_with_nil_title.save).to be true
    end
  end

  context 'when validating translated uniqueness for `update` action' do
    it 'allows updating a record with a unique title in the same locale' do
      book = Book.create!(title_en: 'Initial Title')
      expect(book.update(title_en: 'Updated Unique Title')).to be true
    end

    it 'prevents updating a record to a duplicate title in the same locale' do
      Book.create!(title_en: 'Existing Title')
      book = Book.create!(title_en: 'Another Title')

      expect(book.update(title_en: 'Existing Title')).to be false
      expect(book.errors[:title_en]).to include('violates uniqueness constraint')
    end

    it 'allows updating a title in one locale without affecting another locale' do
      book = Book.create!(title_en: 'English Title')
      Mobility.locale = :fr
      expect(book.update(title_fr: 'French Title')).to be true
    end

    it 'prevents updating a record when setting a title to nil if nil is already present and treated as duplicate' do
      Book.create!(title_en: nil)
      book = Book.create!(title_en: 'Non-Nil Title')

      expect(book.update(title_en: nil)).to be true
    end

    it 'handles updating records with special characters in titles' do
      book = Book.create!(title_en: 'Special @#$ Title')
      expect(book.update(title_en: 'Another Special Title')).to be true
    end

    it 'allows swapping titles between two records in the same locale' do
      book1 = Book.create!(title_en: 'Title A')
      book2 = Book.create!(title_en: 'Title B')

      expect(book1.update(title_en: 'Title B')).to be false
      expect(book2.update(title_en: 'Title A')).to be false
    end
  end
end
