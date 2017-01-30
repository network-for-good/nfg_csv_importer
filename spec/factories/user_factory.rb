FactoryGirl.define do
  factory :user do
    first_name "Will"
    last_name "Smith"
    email "will@smith.com"
    entity { FactoryGirl.create(:entity) }
  end
end
