module MobilityUniqueness
  extend ActiveSupport::Concern

  class_methods do
    def validates_uniqueness_of_translated(*args)
      return unless defined?(Mobility)

      opitons = args.extract_options!

      before_validation do
        message = opitons[:message] || 'violates uniqueness constraint'

        self.current_locales&.each do |locale|
          args.each do |attr|
            passed      = false
            query_class = self.mobility_query_class(attr)

            next unless query_class

            records = query_class
                        .where(locale: locale)
                        .where(translatable_type: self.class.to_s)
                        .where(key: attr, value: send(:"#{attr}_#{locale}"))

            count = records.count

            passed = if self.persisted?
                        only_one_record = count <= 1
                        belongs_to_self = count.zero? || id == records.first.translatable_id
                        only_one_record && belongs_to_self
                      else
                        count.zero?
                      end

            self.errors.add(:"#{attr}_#{locale}", message) unless passed
          end
        end
      end
    end
  end

  def current_locales
    locales = []

    Mobility.available_locales.each do |locale|
      locales << locale if self.send("language_code_#{locale}")&.present?
    end

    locales
  end

  def mobility_query_class(attr)
    attr_type = self.class.attribute_types[attr&.to_s].type

    translations = {
      string: Mobility::Backends::ActiveRecord::KeyValue::StringTranslation,
      text: Mobility::Backends::ActiveRecord::KeyValue::TextTranslation
    }
    
    translations[attr_type]
  end
end

# Automatically include the in all ActiveRecord models
ActiveSupport.on_load(:active_record) do
  include MobilityUniqueness
end
