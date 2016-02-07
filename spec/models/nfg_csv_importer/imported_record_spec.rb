require 'rails_helper'

describe NfgCsvImporter::ImportedRecord do
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:transaction_id) }
  it { should validate_presence_of(:entity_id)}
  it { should belong_to(:entity) }
  it { should belong_to(:user) }
  it { should belong_to(:importable) }
end
