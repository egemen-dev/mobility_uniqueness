module MobilityUniqueness
  extend ActiveSupport::Concern

  class_methods do
    def validates_uniqueness_of_translated(*args)
      return unless defined?(Mobility)

      options = args.extract_options!
      message = options[:message] || 'violates uniqueness constraint'

      before_validation do
        query_classes = args.group_by { |attr| mobility_query_class(attr) }
        query_classes.each do |query_class, attributes|
          next unless query_class

          Mobility.available_locales.each do |locale|
            # Retrieve values for the current locale and attribute
            values = attributes.map { |attr| send(:"#{attr}_#{locale}") }.compact

            next if values.empty?

            # Checking for conflicts in the database
            conflicts = query_class
                        .where(locale: locale) # Only compare values in the same locale
                        .where(translatable_type: self.class.to_s)
                        .where(key: attributes, value: values)
                        .where.not(translatable_id: id)
                        .group(:key, :locale, :value)
                        .count

            # If there are conflicts, add a validation error for the key
            conflicts.each do |(key, _locale, _value), count|
              errors.add(:"#{key}_#{locale}", message) unless count.zero?
            end
          end
        end
      end
    end
  end

  def mobility_query_class(attr)
    # Dynamically retrieve the appropriate query class based on attribute type
    attr_type = self.class.attribute_types[attr.to_s]&.type
    translations = {
      string: Mobility::Backends::ActiveRecord::KeyValue::StringTranslation
    }

    translations[attr_type] || raise(ArgumentError, "Unsupported attribute type for #{attr}")
  end
end

ActiveSupport.on_load(:active_record) do
  include MobilityUniqueness
end
