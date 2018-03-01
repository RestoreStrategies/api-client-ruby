# frozen_string_literal: true

require 'spec_helper'
require_relative '../support/factory_girl'

describe RestoreStrategies::Key do
  let(:client) do
    RestoreStrategies::Client.new(
      ENV['TOKEN'],
      ENV['SECRET'],
      ENV['HOST'],
      ENV['PORT']
    )
  end

  let(:user) do
    RestoreStrategies::User.find(1)
  end

  it 'creates a key for a user' do
    txt = "created on #{Time.now.to_f}"
    key = user.keys.create(active: true, description: txt, domain: 'test.com')
    expect(key.class).to be described_class
    expect(key.description).to eq txt
    expect(key.domain).to eq 'test.com'
  end

  it 'lists a user\'s keys' do
    keys = user.keys
    expect(keys.length).to be > 45
  end
end
