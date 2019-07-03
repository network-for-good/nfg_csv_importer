module NfgCsvImporter
  module Onboarding
    class ImportDataController < NfgCsvImporter::Onboarding::BaseController
      include NfgCsvImporter::Concerns::ImportAttributeLoaders
      include NfgCsvImporter::ImportsHelper
      prepend_before_action :set_steps
      before_action :load_imported_for
      before_action :load_imported_by

      layout 'nfg_csv_importer/layouts/onboarding/import_data/layout'

      # we do this so we can access the list of steps from outside the onboarder
      def self.step_list
        %i[file_origination_type_selection upload_preprocessing import_type overview upload_post_processing field_mapping preview_confirmation finish]
      end

      # steps list
      steps *step_list

      expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

      expose(:file_type_manager) { NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration) }
      expose(:file_origination_types) { file_type_manager.types }
      expose(:file_origination_type_name) { get_file_origination_type_name }
      expose(:file_origination_type) { file_type_manager.type_for(file_origination_type_name) }
      expose(:import_definitions) { user_import_definitions(imported_for: @imported_for, user: @imported_by, definition_class: ::ImportDefinition, imported_by: @imported_by)}
      expose(:import_type ) { get_import_type }
      expose(:import) { get_import }

      expose(:imported_for ) { @imported_for }
      expose(:imported_by ) { @imported_by }
      expose(:previous_imports) { imported_for.imports.complete.order_by_recent.where(import_type: import_type) }

      # used on the finish step
      expose(:imported_records_count) { import.imported_records.count }

      # The onboarder presenter, when built, automatically
      # generates the step's presenter.
      #
      # Each step has a presenter setup that, at minimum,
      # inherits the OnboarderPresenter.
      expose(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, view_context) }
      # expose(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, view_context) }

      private

      # on before save steps
      def file_origination_type_selection_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def finish_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def preview_confirmation_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def field_mapping_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def upload_post_processing_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def import_type_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def upload_preprocessing_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end

      def overview_on_before_save
        # you can add logic here to perform, such as appending data to the params, before the form is to be saved
      end


      # on valid steps
      def file_origination_type_selection_on_valid_step
        # you can add logic here to perform actions once a step has completed successfully
      end

      def finish_on_valid_step
        # you can add logic here to perform actions once a step has completed successfully
      end

      def preview_confirmation_on_valid_step
        return unless import.uploaded? # only when the import is still in an 'uploaded' state should we attempt to enqueue it
        import.queued!
        NfgCsvImporter::ProcessImportJob.perform_later(import.id)
      end

      def field_mapping_on_valid_step
        # you can add logic here to perform actions once a step has completed successfully
      end

      def upload_post_processing_on_valid_step
        # you can add logic here to perform actions once a step has completed successfully
        import.uploaded!
        import.update(fields_mapping: NfgCsvImporter::FieldsMapper.new(import).call)
      end

      def import_type_on_valid_step
        # Set a session variable so we can lookup the import in the future
        session[:onboarding_import_data_import_id] = form.model.id
      end

      def upload_preprocessing_on_valid_step
        session[:onboarding_import_data_import_id] = form.model.id
        # each file origination type may have different processes
        # they want run after the preprocessed files are uploaded.
        # They should be defined in the file_origination type and
        # must respond to #call (as any Proc/lambda would)
        file_origination_type.post_preprocessing_upload_hook.call(import)
      end

      def overview_on_valid_step
        # you can add logic here to perform actions once a step has completed successfully
      end

      def get_onboarding_admin
        defined?(current_admin) ? current_admin : OpenStruct.new(id: 999, first_name: 'Any', last_name: 'User', email: 'any@user.com', primary_key: 'id')
      end

      def can_view_step_without_onboarding_session
        return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
        # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
        # return true if step == :my_step
        false
      end

      def get_form_target
        case step
            when :file_origination_type_selection
              OpenStruct.new(file_origination_type: file_origination_type_name) # replace with your object that the step will update
            when :overview
              OpenStruct.new(name: '') # replace with your object that the step will update
            when :upload_preprocessing
              new_import
            when :import_type
              import || new_import
            when :upload_post_processing
              import
            when :field_mapping
              OpenStruct.new(name: '') # replace with your object that the step will update
            when :preview_confirmation
              OpenStruct.new(name: '') # replace with your object that the step will update
            when :finish
              OpenStruct.new(name: '') # replace with your object that the step will update
        else
          OpenStruct.new(name: '')
        end
      end

      def finish_wizard_path
        imports_path
         # where to take the user when the have finished this step
         # TODO add a path to where the user should go once they complete the onboarder
      end

      def onboarder_name
        "import_data"
      end

      def get_file_origination_type_name
        # on the first step, we need to get at the type name before it gets saved to the onboarding
        # session. This is so we can set the steps based on the file origination type directly after
        # the type is selected by the user. That selection may change which type the user wants to
        # to submit, so it may be different from what was previously stored in the session
        params[:nfg_csv_importer_onboarding_import_data_file_origination_type_selection].try(:[],:file_origination_type) ||
        onboarding_session.step_data['import_data'].try(:[], :file_origination_type_selection).try(:[], 'file_origination_type')
      end

      def get_onboarding_session
        # Use the following as an example of how an onboarding session would be either retrieved or instantiated
        # We call new rather than create because we don't want the onboarding session
        # to be saved if the user does not continue past the first step.
        # onboarding_admin.onboarding_session_for(onboarder_name) || Onboarding::Session.new(onboarding_session_parameters)

        # the following is a hack for the test app. So we can progress through the pages. It will need to be revised
        # when used in DM. Not sure of the best way to do that.
        (session[:onboarding_session_id] ? ::Onboarding::Session.find_by(id: session[:onboarding_session_id]) || new_onboarding_session : new_onboarding_session).tap { |os| session[:onboarding_session_id] = os.id }
      end

      def get_import
        session[:onboarding_import_data_import_id] = params[:import_id] if params[:mport_id].present?
        begin
          @imported_for.imports.find(session[:onboarding_import_data_import_id])
        rescue
          session.delete(:onboarding_import_data_import_id)
          return nil
        end
      end

      def get_import_type
        params[:nfg_csv_importer_onboarding_import_data_import_type].try(:[],:import_type) ||
        onboarding_session.step_data['import_data'].try(:[], :import_type).try(:[], 'import_type')
      end

      def new_onboarding_session
        ::Onboarding::Session.create(onboarding_session_parameters)
      end

      def onboarding_session_parameters
        {
          entity: nil,# supply the parent object to the onboarding session
          owner: nil,
          current_step: "file_origination_type_selection",  #typically the first step
          related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
          name: onboarder_name
        }
      end

      def new_import
        Import.new(imported_for: @imported_for, imported_by: @imported_by, file_origination_type: file_origination_type_name, status: "pending")
      end

      def fields_to_be_cleansed_from_form_params
        # these are fields that we don't want to store in onboarder session
        %w{ import_file pre_processing_files }
      end

      def set_steps
        self.steps = if file_origination_type.nil?
                      [:file_origination_type_selection]
                    else
                      self.class.step_list.reject {|step| file_origination_type.skip_steps.include? step}
                    end
      end
    end
  end
end