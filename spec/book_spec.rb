# spec/book_spec.rb

require 'spec_helper'

RSpec.describe Book, type: :model do
  before do
    I18n.available_locales = %i[en tr fr]
    Mobility.locale = :en
  end

  after do
    Book.destroy_all
  end

  describe 'Validating translated uniqueness' do
    describe 'when creating records' do
      it 'allows creation of a unique title in the same locale' do
        book = Book.create!(title_en: 'Title A')
        expect(book.errors[:title]).to be_empty
      end

      it 'prevents creating a duplicate title in the same locale' do
        Book.create!(title_en: 'Title A')
        duplicate_book = Book.new(title_en: 'Title A')
        duplicate_book.valid?

        expect(duplicate_book.errors[:title_en]).to include('violates uniqueness constraint')
      end

      it 'allows the same title in different locales for the same record' do
        book = Book.create!(title_en: 'Title A', title_fr: 'Title A')
        expect(book.errors).to be_empty
        expect(book.title_en).to eq('Title A')
        expect(book.title_fr).to eq('Title A')
      end

      it 'does not allow the same title in different locales across different records' do
        Book.create!(title_en: 'Title A', title_fr: 'Title B')
        book = Book.new(title_en: 'Title A', title_fr: 'Title B')
        expect(book).to be_invalid
      end

      it 'allows different records to have the same values for the same keys in different locales' do
        book1 = Book.create!(title_en: 'Unique Title', title_fr: 'Titre Unique')
        book2 = Book.create!(title_en: 'Titre Unique', title_fr: 'Unique Title')
      
        expect(book2.valid?).to be_truthy
        expect(book2.save).to be_truthy
      end

      it 'prevents different records from having the same values for the same keys in the same locale' do
        Book.create!(title_en: 'Duplicate Title')
        book = Book.new(title_en: 'Duplicate Title')
      
        expect(book.valid?).to be_falsey
        expect(book.errors[:title_en]).to include('violates uniqueness constraint')
      end

      it 'allows the same value for different locales across records' do
        Book.create!(title_en: 'Shared Value')
        book = Book.new(title_fr: 'Shared Value')
      
        expect(book.valid?).to be_truthy
        expect(book.save).to be_truthy
      end

      it 'allows the same value for title and name attributes across different fields' do
        # Creating the book with same values for `title` and `name`
        book = Book.create!(title_en: 'Common Title', name_en: 'Common Title')

        # Ensuring no validation errors for both fields
        expect(book.errors[:title_en]).to be_empty
        expect(book.errors[:name_en]).to be_empty
        expect(book.title_en).to eq('Common Title')
        expect(book.name_en).to eq('Common Title')
      end

      it 'prevents creating a duplicate title and name with the same value across different records' do
        # Creating a book with the same title and name
        Book.create!(title_en: 'a', name_en: 'a', title_fr: 'a', name_fr: 'a')
        
        # Attempting to create a new book with the same title and name
        duplicate_book = Book.new(title_en: 'a', name_en: 'a', title_fr: 'a', name_fr: 'a')
        duplicate_book.valid?

        # Check for uniqueness constraint violation
        expect(duplicate_book.errors[:title_en]).to include('violates uniqueness constraint')
        expect(duplicate_book.errors[:name_en]).to include('violates uniqueness constraint')
        expect(duplicate_book.errors[:title_fr]).to include('violates uniqueness constraint')
        expect(duplicate_book.errors[:name_fr]).to include('violates uniqueness constraint')
      end
    end

    describe 'when updating records' do
      it 'updates the record with a unique title in the same locale' do
        book = Book.create!(title_en: 'Original Title')
        book.update(title_en: 'Updated Title')

        expect(book.errors[:title]).to be_empty
        expect(book.title_en).to eq('Updated Title')
      end

      it 'prevents updating a record with a duplicate title in the same locale' do
        Book.create!(title_en: 'Existing Title')
        book = Book.create!(title_en: 'Another Title')

        book.update(title_en: 'Existing Title')
        expect(book.errors[:title_en]).to include('violates uniqueness constraint')
      end

      it 'handles multiple atrr update across locales without conflicts' do
        book = Book.create!(title_en: 'Title One', title_fr: 'Title Two')

        book.update(title_en: 'Updated Title', title_fr: 'Updated Title')
        expect(book.errors[:title_en]).to be_empty
        expect(book.errors[:title_fr]).to be_empty
      end

      it 'ensures title uniqueness across records' do
        Book.create!(title_en: 'Shared Title', title_fr: 'Unique Title')
        another_book = Book.create!(title_en: 'Another Title', title_fr: 'Another Unique Title')

        another_book.update(title_en: 'Shared Title', title_fr: 'Unique Title')
        expect(another_book.errors[:title_en]).to include('violates uniqueness constraint')
      end

      it 'allows updating the same record with unique titles in each locale' do
        book = Book.create!(title_en: 'Title One', title_fr: 'Title Two')

        book.update(title_en: 'Updated Title En', title_fr: 'Updated Title Fr')
        expect(book.errors[:title_en]).to be_empty
        expect(book.errors[:title_fr]).to be_empty

        expect(book.title_en).to eq('Updated Title En')
        expect(book.title_fr).to eq('Updated Title Fr')
      end
    end

    describe 'edge cases with switching' do
      it 'allows switching titles between locales for the same record' do
        book = Book.create!(title_en: 'Title A', title_fr: 'Title B')

        book.update(title_en: 'Title B', title_fr: 'Title A')
        expect(book.errors[:title_en]).to be_empty
        expect(book.errors[:title_fr]).to be_empty 
      end

      it 'allows identical titles across locales on the same record' do
        book = Book.create!(title_en: 'Title A')
        book.update(title_fr: 'Title A')

        expect(book.errors[:title_fr]).to be_empty
        expect(book.title_en).to eq('Title A')
        expect(book.title_fr).to eq('Title A')
      end
    end
  end
end
