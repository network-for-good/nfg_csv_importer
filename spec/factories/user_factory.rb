FactoryBot.define do
  factory :user do
    first_name { "Will" }
    last_name { "Smith" }
    email { "will@smith.com" }
    entity { Entity.first || FactoryBot.create(:entity) }
  end
end
