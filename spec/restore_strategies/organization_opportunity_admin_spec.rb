# frozen_string_literal: true

require 'spec_helper'
require_relative '../support/factory_girl'

describe RestoreStrategies::OrganizationOpportunity do
  let(:client) do
    RestoreStrategies::Client.new(
      ENV['TOKEN'],
      ENV['SECRET'],
      ENV['HOST'],
      ENV['PORT']
    )
  end

  let(:user) do
    RestoreStrategies::User.find(17_603)
  end

  it 'lists a user\'s opportunities' do
    user.opportunities.each { |o| expect(o.class).to be described_class }
  end

  it 'has a person as the coordinator' do
    opp = user.opportunities.last
    expect(opp.coordinator.class).to be RestoreStrategies::OrganizationPerson
  end

  it 'initializes a coordinator hash to a person' do
    email = Faker::Internet.email
    opp = described_class.new(
      name: 'Test', regions: %w[North South], times: ['Morning'],
      coordinator: {
        given_name: Faker::Name.first_name, family_name: Faker::Name.last_name,
        email: email, telephone: Faker::PhoneNumber.phone_number
      },
      ongoing: true,
      location: "#{Faker::Address.street_address} #{Faker::Address.city}",
      status: 'Removed by nonprofit',
      cities: [Faker::Address.city], days: %w[Sunday Friday],
      level: ['Walk'],
      description: Faker::Hipster.paragraph(1, false, 2),
      issues: %w[Education Homelessness], type: 'Service',
      group_types: %w[Family Group], municipalities: %w[Round Rock Hyde Park],
      organization_id: 662
    )

    expect(opp.coordinator.class).to be RestoreStrategies::OrganizationPerson
    expect(opp.coordinator.email).to eq email
  end

  it 'can create an opportunity' do
    opp = described_class.new(
      name: 'Test', regions: %w[North South], times: ['Morning'],
      coordinator: RestoreStrategies::OrganizationPerson.new(
        given_name: Faker::Name.first_name, family_name: Faker::Name.last_name,
        email: Faker::Internet.email, telephone: Faker::PhoneNumber.phone_number
      ),
      ongoing: true,
      location: "#{Faker::Address.street_address} #{Faker::Address.city}",
      status: 'Removed by nonprofit',
      cities: [Faker::Address.city], days: %w[Sunday Friday],
      level: ['Walk'],
      description: Faker::Hipster.paragraph(1, false, 2),
      issues: %w[Education Homelessness], type: 'Service',
      group_types: %w[Family Group], municipalities: %w[Round Rock Hyde Park],
      organization_id: 662,
      max_items_needed: ''
    )

    expect(opp.save).to be true
    expect(opp.id.to_i > 0).to be true
  end

  it 'can create a one-time opportunity' do
    opp = build(
      :opportunity,
      organization_id: 662,
      ongoing: false,
      coordinator: RestoreStrategies::OrganizationPerson.new(
        given_name: Faker::Name.first_name, family_name: Faker::Name.last_name,
        email: Faker::Internet.email, telephone: Faker::PhoneNumber.phone_number
      )
    )

    expect(opp.save).to be true
    expect(opp.ongoing).to be false
  end

  it 'updates an opportunity' do
    opp = user.opportunities.where(id: '1').first
    type = %w[Service Event Gift].sample
    telephone = Faker::PhoneNumber.phone_number
    expect(
      opp.update(
        type: type,
        municipalities: ['Waco'],
        max_items_needed: 88,
        coordinator: {
          id: opp.coordinator.id,
          telephone: telephone
        }
      )
    ).not_to be false

    opp = user.opportunities.refresh!.where(id: '1').first

    expect(opp.type).to eq type
    expect(opp.coordinator.telephone).to eq telephone
  end

  it 'updates the coordinator' do
    opp = user.opportunities.where(id: '1').first

    name = Faker::Name.first_name
    uuid = opp.coordinator.uuid
    opp.coordinator.given_name = name
    opp.save

    opp = user.opportunities.refresh!.where(id: '1').first
    expect(opp.coordinator.given_name).to eq name
    expect(opp.coordinator.uuid).to eq uuid
  end
end
