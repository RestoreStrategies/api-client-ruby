# frozen_string_literal: true

module RestoreStrategies
  # The objectification of an opportunity that belongs to an organization
  class OrganizationOpportunity < ApiCollectable
    include RestoreStrategies::Updateable

    validates :name, :type, :description, :cities, :days, :times, :group_types,
              :issues, :regions, :status, :coordinator, :organization_id,
              presence: true

    validates_inclusion_of :ongoing, in: [true, false]

    attr_accessor :name, :regions, :times, :coordinator, :ongoing, :location,
                  :status, :days, :level, :description, :issues, :type,
                  :organization_sfid, :organization_id, :group_types,
                  :municipalities, :closed, :items_committed, :items_given,
                  :max_items_needed, :instructions, :gift_question, :supplies,
                  :cities, :search_terms, :start_date, :end_date, :active

    def initialize(json: nil, response: nil, **data)
      if json && response
        super(json: json, response: response)

        if @coordinator
          @coordinator = RestoreStrategies::OrganizationPerson.new(
            json: @coordinator, response: response
          )
        end
      else
        self.instance_vars = data

        if @coordinator.is_a? Hash
          @coordinator = RestoreStrategies::OrganizationPerson.new(@coordinator)
        end

        @new_object = if !data[:new_object].nil?
                        data[:new_object]
                      else
                        true
                      end
      end

      @coordinator&.organization_id = data[:organization_id]

      @path = "/api/admin/organizations/#{data[:organization_id]}" \
              '/opportunities'

      field_attr :id, :name, :type, :closed, :description, :location,
                 :items_committed, :items_given, :max_items_needed, :ongoing,
                 :instructions, :gift_question, :level, :days, :times,
                 :group_types, :issues, :regions, :municipalities, :supplies,
                 :cities, :coordinator, :status, :search_terms, :start_date,
                 :end_date, :active
    end

    def update(**data)
      if data[:coordinator].is_a? Hash
        data[:coordinator] = RestoreStrategies::OrganizationPerson.new(
          data[:coordinator]
        )
      end

      super(**data)
    end

    def create_path
      "/api/admin/organizations/#{organization_id}/opportunities"
    end

    def update_path
      "/api/admin/organizations/#{organization_id}/opportunities/#{id}"
    end
  end
end
