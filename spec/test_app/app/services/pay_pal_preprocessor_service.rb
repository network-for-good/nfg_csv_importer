# frozen_string_literal: true

class PayPalPreprocessorService
  include ActiveStorage::Downloading

  def initialize(import)
    self.import = import
  end

  def process
    files = retrieve_pre_processing_files
    files.each do |file_path|
      file = File.open(file_path)
      document = get_document(file)
      processed_data = convert_row_to_hash_with_ignored_columns_removed(document)
      cleaned_data = clean_data(processed_data)
      temp_file = save_data_to_csv(cleaned_data)
      import.import_file = temp_file
      import.status = :uploaded
      import.fields_mapping = mapped_headers
      import.save!
      temp_file.close
    end
  end

  protected

  attr_accessor :import

  def retrieve_pre_processing_files
    FileUtils.mkdir_p(temp_folder) unless Dir.exist?(temp_folder)
    # download all pre_processing_files
    import.pre_processing_files.map do |file|
      filename = file.filename.to_s
      filepath = File.join temp_folder, filename
      File.open(filepath, 'wb') { |f| f.write(file.download) }
      filepath
    end
  end

  def temp_folder
    @temp_folder ||= File.join(Rails.root.join('tmp').to_s,
                               'imports', import.id.to_s)
  end

  def get_document(file)
    file_path = file.path
    case File.extname(file_path)
    when '.csv'
      Roo::CSV.new(file_path)
    when '.xls'
      Roo::Excel.new(file_path, packed: nil, file_warning: :ignore)
    when '.xlsx'
      Roo::Excelx.new(file_path, packed: nil, file_warning: :ignore)
    end
  end

  def convert_row_to_hash_with_ignored_columns_removed(doc)
    data = []
    doc.each_with_index(mapped_headers) do |row, index|
      next if index < 1
      date_string = "#{row[:date]} #{get_time_string(row[:time])} #{row[:zone]}"
      donated_at = Time.parse(date_string).utc
      data << row.except(:date, :time, :zone).merge(donated_at: donated_at)
    end
    data
  end

  def save_data_to_csv(data)
    temp_file = Tempfile.new(['PayPalDonations', '.csv'])

    CSV.open(temp_file, 'w', {:col_sep => ','}) do |csv|
      csv << data.first.keys
      data.each { |r| csv << r.values }
    end
    temp_file
  end

  def mapped_headers
    {
      date: 'Date',
      time: 'Time',
      zone: 'TimeZone',
      name: 'Name',
      amount: 'Gross',
      email: 'From Email Address',
      transaction_id: 'Transaction ID',
      address: 'Address Line 1',
      address_2: 'Address Line 2/District/Neighborhood',
      city: 'Town/City',
      state: 'State/Province/Region/County/Territory/Prefecture/Republic',
      zip_code: 'Zip/Postal Code',
      country: 'Country',
      home_phone: 'Contact Phone Number',
      description: 'Note'
    }
  end

  def clean_data(data)
    data = remove_negative_amount_records(data)
    clean_donor_name_payment_method(data)
  end

  def remove_negative_amount_records(data)
    data.reject { |item| item[:amount].to_i < 0 }
  end

  def clean_donor_name_payment_method(data)
    data.collect do |item|
      item[:name] = item[:email] if item[:name].blank?
      item[:payment_method] = item[:amount].to_i == 0 ? 'in_kind' : 'Paypal'
      item
    end
  end

  def get_time_string(number)
    Time.at(number).utc.strftime("%H:%M:%S")
  end

end
