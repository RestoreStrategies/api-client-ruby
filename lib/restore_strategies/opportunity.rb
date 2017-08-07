require_relative 'signup'

module RestoreStrategies
  # Objectification of the API's opportunity
  class Opportunity < ApiObject
    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Naming
    include ActiveModel::Conversion

    attr_reader :name, :type, :featured, :description, :location,
                :items_committed, :items_given, :max_items_needed, :ongoing,
                :organization, :instructions, :gift_question, :days,
                :group_types, :issues, :regions, :supplies, :skills,
                :municipalities

    @path = '/api/opportunities'

    def initialize(json, response)
      json['links'].each do |link|
        @signup_href = link['href'] if link['rel'] == 'signup'
      end
      super(json, response)
    end

    def self.where(params)
      items_from_response(RestoreStrategies.client.search(params))
    end
  end
end
