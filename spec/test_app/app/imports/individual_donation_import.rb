class IndividualDonationImport
  include ActiveModel::Model

  def self.attr_list
    ["date","time","zone","name","amount","email","transaction_id","address","address_2","city","state","zip_code","country","home_phone","description"]
  end

  attr_accessor *attr_list

  def has_attribute?(attribute)
    respond_to? attribute
  end

  def attributes
    Hash[self.class.attr_list.map { |x| [x, nil] }]
  end

  def attributes=(args)
    args.each do |arg, value|
      self.send("#{arg}=", value)
    end
  end

  def self.table_name
    User.table_name
  end

  def save
    first_name, last_name = name.split
    User.create(first_name: first_name, last_name: last_name, email: email)
  end
end