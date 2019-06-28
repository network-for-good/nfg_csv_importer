# frozen_string_literal: true

def create_test_upload_file(file_name, columns, rows)
  file_path = get_test_upload_file_path(file_name)
  CSV.open(file_path, "wb") do |test_file|
    test_file << columns
    rows.each do |row|
      test_file << row
    end
  end
  file_path
end

def get_test_upload_file_path(file_name = "pt_org_members_valid.txt")
  f = File.expand_path(Rails.root.join('/tmp/', file_name))
end
