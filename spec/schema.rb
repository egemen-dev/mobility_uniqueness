# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :books, force: true do |t|
    t.string :title
    t.text :description

    t.timestamps
  end

  create_table :mobility_string_translations, force: true do |t|
    t.string :locale, null: false
    t.string :key, null: false
    t.string :value
    t.references :translatable, polymorphic: true, index: true, null: false

    t.timestamps null: false
  end

  create_table :mobility_text_translations, force: true do |t|
    t.string :locale, null: false
    t.string :key, null: false
    t.text :value
    t.references :translatable, polymorphic: true, index: true, null: false

    t.timestamps null: false
  end
end
