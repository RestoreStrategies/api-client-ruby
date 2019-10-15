# frozen_string_literal: true

require 'faker'

cities = [
  'Asheboro', 'Austin', 'Brenham', 'Columbia', 'Dallas', 'Nashville',
  'Norman', 'Oklahoma City', 'Orlando', 'Redwood City', 'San Antonio',
  'Springfield', 'Tampa', 'Temple', 'Tulsa', 'Waco'
]

issue_list = [
  'Children/Youth', 'Education', 'Elderly', 'Family/Community',
  'Foster Care/Adoption', 'Healthcare', 'Homelessness', 'Housing',
  'Human Trafficking', 'International/Refugee', 'Job Training',
  'Sanctity of Life', 'Sports', 'Incarceration'
]

region_list = %w[North South East West Central Other]

def random_options(opt_array)
  results = []
  number = rand(opt_array.count) + 1
  number.times { results << opt_array[rand(opt_array.count - 1)] }
  results
end

FactoryGirl.define do
  factory :opportunity, class: RestoreStrategies::OrganizationOpportunity do
    name { Faker::Commerce.department }
    type { %w[Service Gift].sample }
    closed false
    description { Faker::Lorem.paragraph(2, true, 4) }
    ongoing true
    instructions { Faker::Lorem.sentence(2, true, 2) }
    gift_question { Faker::Lorem.sentence(2, true, 2) }
    cities { random_options(cities) }
    level { random_options(%w[Crawl Walk Run]) }
    days { random_options(Date::DAYNAMES) }
    times { random_options(['Morning', 'Mid-Day', 'Afternoon', 'Evening']) }
    group_types { random_options(%w[Individual Group Family]) }
    issues { random_options(issue_list) }
    regions { random_options(region_list) }
    municipalities { %w[Buda Taylor] }
    status 'Pending Review'
  end
end
