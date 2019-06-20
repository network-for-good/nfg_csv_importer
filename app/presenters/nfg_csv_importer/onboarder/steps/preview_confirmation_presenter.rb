module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

        # @import is a workaround for now and will be removed.
        attr_reader :import

        def import
          @import ||= NfgCsvImporter::WorkingCode::FakePaypalImport.fake_paypal_import
        end

        def the_fake_import
          import
        end

        # get the preview record's value for the humanized data set
        # by pinging the import preview's user for their name.
        #
        # example preview_object_class_name: 'user' 'donation'
        def humanized_data_card_heading(preview_object_class_name)
          # Get the name of the attribute which is stored
          # in the import definition's humanized_data_set hash.
          heading_attribute_name = import.humanized_data_set[preview_object_class_name]['heading'].first

          # Get the value of the preview object's attribute
          # adds .to_s to ensure that `capture` doesn't flake out (and thus not render component :body) when the body isn't a string
          get_preview_object_attribute(preview_object_class_name, attribute_name: heading_attribute_name).to_s
        end

        def humanized_data_card_body_content(preview_object_class_name)
          import.humanized_data_set[preview_object_class_name].except('heading')
        end

        # This gets the attribute, chained or not, from the preview object as long as that info is connected to import.preview
        def get_preview_object_attribute(preview_object_class_name, attribute_name:)

          # Accounts for summary data like:
          # donation: { summary: %w[campaign.name.goal amount donated_at] }
          preview_object = import_preview.send(preview_object_class_name)

          # Chain the method onto the previous result (or automatically stop when the array has enumerated)
          chain_method(string: attribute_name, object: preview_object)
        end

        # Provide an icon for any specific keyword
        # from the preview data set.
        #
        # This is used when seeking an icon to pair with values (such as the user address summary / 'full_address')
        def humanized_data_preview_icon(keyword)
          case keyword
          when 'name', 'user' then 'user'
          when 'full_address' then 'home'
          when 'id' then 'search'
          when 'note' then 'file-text-o'
          when 'donation' then 'dollar'
          else
            # return a white circle so the icon spacing is present
            'circle inverse'
          end
        end

        # For use when determining if a preview card should be a second user or a donation.
        # On the preview_confirmation step, this is checked on the second card.
        def user_or_donation_card
          import.humanized_data_set.keys.include?('donation') ? 'donation' : 'user'
        end


        def summary_total_title(objects_name)
          import.summary_data_set[objects_name]['total'].keys.first
        end

        # In the import.summary_data_set,
        # dig into the preview object's :charts hash,
        # then, grab the index's key (since this is called in a loop)
        # def summary_title(preview_object_class_name, index:)
        #   import.summary_data_set[preview_object_class_name]['charts'][index].key
        # end

        def summary_rows(preview_object_class_name)
          import.summary_data_set[preview_object_class_name]['charts']
        end

        # ex: summarized_object: import.summary for accessing donatoins, etc.
        # ex: summarized_object: `import` for accessing the import's overall info.
        def summary_total_value(objects_name, summarized_object:)

          # Get the method string stored in the sumary data set's 'total' hash
          method_string = import.summary_data_set[objects_name]['total'].values.first

          # Run the method chain against the summarized object
          chain_method(string: method_string, object: summarized_object)
        end

        # Only difference from #summary_total_value is that this targets the 'charts' hash
        def summary_row_value(objects_name, summarized_object:, index:)

          # Get the method string stored in the sumary data set's 'total' hash
          method_string = import.summary_data_set[objects_name]['charts'].values[index]

          chain_method(string: method_string, object: summarized_object)

        end

        def summary_title_icon(objects_name)
          'user' if objects_name == 'user'
          'dollar' if objects_name = 'donation'
        end

        def pie_chart_values(values)
          # should add up to 100.
          # letter "D" is a styling tool that communicates
          # to the Javascript how visually thick to make the pie chart
          # temporary / work around values
          values ||= [75, 25, 'D']

          content_tag(:span, value[0], class: 'text-primary') +
          content_tag(:span, value[1], class: 'text-muted') +
          content_tag(:span, value[2], class: 'text-white')
        end

        private

        def chain_method(string:, object:)
          string.split('.').inject(object, :try)
        end

        def import_summary_total_method(preview_object_class_name)

          import.summary_data_set[preview_object_class_name]['total'][0]
        end

        # Isolates where preview is found.
        def import_preview
          import.preview
        end
      end
    end
  end
end