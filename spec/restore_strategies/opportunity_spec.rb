# frozen_string_literal: true

require 'net/http'
require 'spec_helper'
require 'json'
require 'signup'

describe RestoreStrategies::Opportunity do
  let(:client) do
    RestoreStrategies::Client.new(
      ENV['TOKEN'],
      ENV['SECRET'],
      ENV['HOST'],
      ENV['PORT']
    )
  end

  let(:opp) do
    described_class.find(1)
  end

  # rubocop:disable MultipleExpectations
  it 'sets array values during initalization' do
    opp = described_class.find(1)
    expect(opp.issues).to be_a(Array)
    expect(opp.days).to be_a(Array)
    expect(opp.group_types).to be_a(Array)
    expect(opp.regions).to be_a(Array)
    expect(opp.supplies).to be_a(Array)
    expect(opp.skills).to be_a(Array)
  end
  # rubocop:enable MultipleExpectations

  describe 'find' do
    it 'finds an opporunity from id' do
      opportunity = described_class.find(1)
      expect(opportunity).to be_a(described_class)
      expect(opportunity.id.to_i).to be(1)
    end

    it 'throws error if id is not integer' do
      expect { described_class.find('1') }
        .to raise_error(ArgumentError, 'id must be integer')
    end

    it 'throws error if id is not found' do
      expect { described_class.find(99_999) }
        .to raise_error(RestoreStrategies::NotFoundError)
    end
  end

  describe 'where' do
    it 'does full text search' do
      opps = described_class.where(q: 'foster care')

      expect(opps).to be_a(Array)
      expect(opps).to all be_a(described_class)
    end

    it 'does parameterized search' do
      opps = described_class.where(
        issues: %w[Education Children/Youth],
        region: %w[South Central]
      )

      expect(opps).to be_a(Array)
      expect(opps).to all be_a(described_class)
    end

    it 'does parameterized & full text search' do
      opps = described_class.where(
        q: 'foster care',
        issues: %w[Education Children/Youth],
        region: %w[South Central]
      )

      expect(opps).to be_a(Array)
      expect(opps).to all be_a(described_class)
    end

    it 'searches for featured opportunities' do
      opps = described_class.where(featured: true)

      expect(opps).to be_a(Array)
      expect(opps).to all be_a(described_class)
    end
  end

  describe 'all' do
    it 'gets all the opportunities' do
      opps = described_class.all

      expect(opps).to be_a(Array)
      expect(opps).to all be_a(described_class)
    end
  end

  describe 'feature' do
    it 'features an opportunity' do
      expect(described_class.feature(id: 1, user_id: 1)).to be true
    end

    it 'allows an admin to view a user\'s featured opportunities' do
      expect(described_class.featured(user_id: 1).length).to be 1
    end

    it 'allows users to view their own featured opportunities' do
      expect(described_class.featured.length).to be 1
    end

    it 'unfeatures an opportunity' do
      expect(described_class.unfeature(id: 1, user_id: 1)).to be true
    end
  end
end
