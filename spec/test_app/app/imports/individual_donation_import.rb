class IndividualDonationImport
  include ActiveModel::Model

  attr_accessor :date,:time,:zone,:name,:amount,:email,:transaction_id,:address,:address_2,:city,:state,:zip_code,:country,:home_phone,:description

  def save
    first_name, last_name = name.split
    User.create(first_name: first_name, last_name: last_name, email: email)
  end
end