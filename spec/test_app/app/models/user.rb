class User < ActiveRecord::Base
  has_many :imports, class_name: "NfgCsvImporter::Import"
  belongs_to :entity

  validates :email, :presence => true, format: /\A.+@.+\Z/
  validates :first_name, presence: true

  include NfgOnboarder::OnboardableOwner

  def name
    "#{first_name} #{last_name}"
  end
end