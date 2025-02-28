class Onboarding::Session < NfgOnboarder::Session
  belongs_to :entity, optional: true
end
