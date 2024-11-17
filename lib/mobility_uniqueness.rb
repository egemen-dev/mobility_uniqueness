module MobilityUniqueness
  extend ActiveSupport::Concern

  class_methods do
    def validates_uniqueness_of_translated(*args)
      return unless defined?(Mobility)

      opitons = args.extract_options!

      before_validation do
        message = opitons[:message] || 'violates uniqueness constraint'

        query_classes = args.group_by { |attr| mobility_query_class(attr) }
        query_classes.each do |query_class, attributes|
          values = Mobility.available_locales.map do |locale|
            attributes.map { |attr| send(:"#{attr}_#{locale}") }
          end.flatten

          count_by_group = query_class.where(locale: Mobility.available_locales)
                                      .where(translatable_type: self.class.to_s)
                                      .where(key: attributes, value: values)
                                      .where.not(translatable_id: id)
                                      .group(:key, :locale, :value)
                                      .count

          count_by_group.each do |(key, locale, _value), count|
            errors.add(:"#{key}_#{locale}", message) unless count.zero?
          end
        end
      end
    end
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
