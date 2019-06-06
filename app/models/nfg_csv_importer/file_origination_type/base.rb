# frozen_string_literal: true

module NfgCsvImporter
  module FileOriginationType
    # The FileOriginationType::Base class is the template on which other
    # FileOriginationType classes are based and should inherit from.
    class Base
      class << self
        def requires_preprocessing_files
          # If this file origination type expects the user to supply
          # pre-processing files to be worked on by the system or handed
          # off for manual manipulation, return true. Returning false will
          # skip the preprocessing upload
          true
        end

        def allowed_import_types
          # returns a list of import types that the user can select from
          # If there is only one item in the list it will skip the step
          # allowing the user to select
          []
        end

        def post_preprocessing_upload_hook
          # This should return a Proc that receives an instance of an import
          # and performs an action on that import. This is where any
          # preprocessing occurs, including file manipulation and messaging.
          -> () {}
        end

        def field_mapping
          # This returns a hash of the fields expected after preprocessing
          # (contained in the postprocess files, i.e. the import.file) mapped
          # to the import type designated in the allowed_import_types (if only
          # one is designated). Return an empty hash if the user is the perform
          # the mapping manually
          # An error will be raised if the allowed import types
          {}
        end

        def expects_preprocessing_to_attach_post_processing_file
          # For files that will be preprocessed, there is an expectation that
          # the output will be a postprocessed file that will be attached
          # to the Import record (import.file)
          # If this value is false, the user will be required to supply the
          # post processed file.
          true
        end

        def logo_path
          # supply the path to the image that you want to display with
          # this file origination type. The image should be stored in the
          # assets/images folder. If it is in a subfolder of the images
          # folder, include the folder, i.e "file_originators/constant_contact_logo.gif"
          ""
        end

        def name
          # the name of the file origination type, i.e ConstantContact, PayPal, etc
          "Your excel files"
        end
      end
    end
  end
end
