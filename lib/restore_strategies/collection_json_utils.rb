# frozen_string_literal: true

require 'json'

module RestoreStrategies
  # Collection+JSON untilities
  class CollectionJson
    def self.build_template(postable)
      return nil unless postable.post_fields
      data = []

      postable.post_fields.each do |field|
        if value_is_present? postable, field
          data.push(build_element(field.id2name, postable.send(field)))
        end
      end

      { 'template' => { 'data' => data } }
    end

    def self.build_element(key, value)
      if value.is_a? Array
        { 'name' => key.camelize(:lower), 'array' => value }
      elsif value.is_a? Hash
        { 'name' => key.camelize(:lower), 'object' => value }
      elsif value.is_a? RestoreStrategies::ApiObject
        { 'name' => key.camelize(:lower), 'object' => value.to_payload(false) }
      else
        { 'name' => key.camelize(:lower), 'value' => value }
      end
    end

    def self.parse_element(json)
      { json['name'].underscore => json['value'] }
    end

    private_class_method

    def self.value_is_present?(obj, field)
      if !obj.respond_to?(field) # doesn't respond to field
        false
      elsif obj.send(field).nil? # value is nil
        false
      elsif obj.send(field).class == FalseClass # value is false
        true
      elsif obj.send(field).class == Array # value is Array
        true
      elsif obj.send(field).present? # value is present
        true
      else
        false
      end
    end
  end

  # Mixin for creating a POSTable representation of
  # data to the api
  module POSTing
    attr_reader :post_fields

    def field_attr(*args)
      @post_fields = []
      args.each do |arg|
        @post_fields.push arg
      end
    end

    def to_payload(string = true)
      json_obj = CollectionJson.build_template(self)
      if string
        JSON.generate json_obj
      else
        json_obj
      end
    end
  end
end
