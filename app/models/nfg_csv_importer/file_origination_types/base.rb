# frozen_string_literal: true

module NfgCsvImporter
  module FileOriginationTypes
    # The FileOriginationType::Base class is the template on which other
    # FileOriginationType classes are based and should inherit from.
    class Base

      class << self
        def valid_file_extensions
          %w[csv xls xlsx].freeze
        end

        def get_valid_file_extensions(type_name)
          class_name = type_name&.to_s&.camelcase
          # self_import resides in NfgCsvImporter gem and is prefixed with NfgCsvImproter
          # All other imports are in the host application and are not prefixed

          file_origination = NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls if class_name == 'SelfImportCsvXls'
          file_origination ||= "::FileOriginationTypes::#{class_name}".constantize

          file_origination.valid_file_extensions
        end

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

          # TODO: This needs to be thought through better because the host
          # application controls the list of import types that are available
          # and may do so basd on the user
          []
        end

        def post_preprocessing_upload_hook
          # This should return a Proc that receives an instance of an import
          # and performs an action on that import. This is where any
          # preprocessing occurs, including file manipulation and messaging.
          -> (import, options = {}) {}
        end

        def field_mapping
          # This returns a hash of the fields expected after preprocessing
          # (contained in the postprocess files, i.e. the import_file) mapped
          # to the import type designated in the allowed_import_types (if only
          # one is designated). Return an empty hash if the user is the perform
          # the mapping manually
          # An error will be raised if the allowed import types
          {}
        end

        def requires_post_processing_file
          # Most file origination types will require that a post processed file
          # be attached to the import (on the import_file attachment)
          # Some types will automatically create this file, others will ask the
          # user to attach it. A few may skip this step, implying that no
          # import will actually run (this is the case when we are)
          true
        end

        def collect_note_with_pre_processing_files
          # In most cases, when a user attaches preprocessing files to an
          # import we won't need them to also provide some information about those
          # files. But in some cases we do, and it is up to the file origination
          # type to decide that
          false
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

        def description
          # displays in the file origination type panel
          ""
        end

        def skip_steps
          # returns the list of steps that should be skipped
          # depending on the file_origination_type
          # This should be overridden by the child class
          %i[]
        end

        def display_mappings
          true
        end
      end
    end
  end
end
