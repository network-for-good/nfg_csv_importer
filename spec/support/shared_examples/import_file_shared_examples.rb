shared_examples_for "validate import file" do
  before(:each) do
    csv_data = mock
    csv_data.stubs(:row).with(1).returns(header_data)
    NfgCsvImporter::ImportService.any_instance.stubs(:open_spreadsheet).returns(csv_data)
  end

  it { expect(subject).to be }

  context "validate when there is no file" do
    let(:file) { nil }

    it { expect(subject).not_to be }

    it "should add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to eq(["Import File can't be blank, Please Upload a File"])
    end
  end

  context "with invalid file extensions" do
    let(:file_name) { '/icon.jpg'}

    it { expect(subject).not_to be }

    it "should add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to eq(["The file must be an xls, xlsx, or csv"])
    end
  end

  context "when the file contains an empty header" do
    let(:header_data) { ["first_name", "email", "", "last_name", "banana"] }
    it { should_not be }
    it " should add an error to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to eq(["At least one empty column header was detected. Please ensure that all column headers contain a value." ])
    end
  end

  context 'when the file contains duplicate headers' do
    let(:header_data) { ["first_name", "email", "first_name", "email", "last_name", "banana"] }

    it { expect(subject).not_to be }

    it "should add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to eq(["The column headers contain duplicate values. Either modify the headers or delete a duplicate column. The duplicates are: 'first_name', 'first_name' on columns A & C; 'email', 'email' on columns B & D"])
    end
  end

  context "when there's an error reading the file" do
    before do
      import_file_validateable_host.stubs(:duplicated_headers).raises(StandardError)
    end

    it "should add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to eq(["We weren't able to parse your spreadsheet.  Please ensure the first sheet contains your headers and import data and retry.  Contact us if you continue to have problems and we'll help troubleshoot."])
    end
  end
end
