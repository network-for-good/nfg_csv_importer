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

def drop_in_dropzone(file_path)
  # Generate a fake input selector if one does not already exist
  begin
    # look for the input field
    page.find("input#fakeFileInput", wait: 0.5)
  rescue Capybara::ElementNotFound
    # add the file since it could not be found
    page.execute_script <<-JS
      fakeFileInput = window.$('<input/>').attr(
        {id: 'fakeFileInput', type:'file'}
      ).appendTo('body');
    JS
  end

  # Attach the file to the fake input selector with Capybara
  attach_file("fakeFileInput", file_path)

  # Add the file to a fileList array
  # Trigger the fake drop event
  page.execute_script <<-JS
    var fileList = [fakeFileInput.get(0).files[0]]
    var e = jQuery.Event('drop', { dataTransfer : { files : fileList } });
    $('.dropzone-target')[0].dropzone.listeners[0].events.drop(e);
  JS
end

def click_next_button_for(step)
  click_button next_button_label(step)
end

def next_button_label(step)
  I18n.t("#{step}.button.submit", scope: [:nfg_csv_importer, :onboarding, :import_data])
end

def save_and_open_view_spec_response(html = Capybara.string(rendered).native.inner_html)
  File.open('/tmp/test.html','w'){|file| file.write(html)}; `open '/tmp/test.html'`
end