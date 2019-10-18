module NfgCsvImporter
  module Onboarding
    class ImportDataController < NfgCsvImporter::Onboarding::BaseController
      include NfgCsvImporter::Concerns::ImportAttributeLoaders
      include NfgCsvImporter::ImportsHelper
      prepend_before_action :set_steps

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
      expose(:file_origination_type) { get_file_origination_type }
      expose(:import_definitions) { user_import_definitions(imported_for: imported_for, user: imported_by, definition_class: ::ImportDefinition, imported_by: imported_by)}
      expose(:import_type) { get_import_type }
      expose(:import) { (get_import || new_import) }
      expose(:imported_for) { load_imported_for }
      expose(:imported_by) { load_imported_by }
      expose(:previous_imports) { imported_for.imports.complete.order_by_recent.where(import_type: import_type, file_origination_type: [nil, file_origination_type_name]) }

      # The onboarder presenter, when built, automatically
      # generates the step's presenter.
      #
      # Each step has a presenter setup that, at minimum,
      # inherits the OnboarderPresenter.
      expose(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, view_context) }

      private

      def points_of_no_return
        [:finish]
      end


      # on valid steps

      def finish_on_valid_step
        reset_onboarding_session # wipe out the session so we can work an another import
      end

      def preview_confirmation_on_valid_step
        return unless import.uploaded_or_calculating_statistics? # only when the import is still in an 'uploaded' state should we attempt to enqueue it
        import.queued!
        NfgCsvImporter::ImportMailer.send_import_result(import).deliver_now
        NfgCsvImporter::ProcessImportJob.perform_later(import.id)
      end

      def upload_post_processing_on_valid_step
        # This line is duplicated in import_type_on_valid_step below b/c
        # the import_type step is skipped if the admin only have access
        # to a single import definition.
        session[:onboarding_import_data_import_id] = form.model.id

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
        # begin
        #   # we use form.model here because `import` was memoized
        #   # as a new import and won't be updated on this cycle
        result = file_origination_type.post_preprocessing_upload_hook.call(form.model, { note: get_note })
        if result.status == :success
          flash[:error] = nil
        else

          # on header errors for a file, we need to show error and keep the user from continuing
          flash[:error] = result.errors.join("; ")

        # flash[:error] = "#{I18n.t('nfg_csv_importer.onboarding.import_data.invalid_headers')}: #{e.message}"
          # true signifies there is an error, this block comes from nfg_onboarder where on_valid_step is called from
          reset_on_failure(step)
          # yield(true, step.to_sym) if block_given?
        end
      end

      # end on valid steps

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
              import
            when :import_type
              import
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
        # since this should only be called when the user is leaving the last step
        # in case they left the finish step without actually finishing
        reset_onboarding_session # wipe out the session so we can work an another import
        params[ALT_FINISH_PATH_PREPEND_KEY] || imports_path
         # where to take the user when the have finished this step
      end

      def onboarder_name
        "import_data_onboarder"
      end

      def get_file_origination_type_name
        # on the first step, we need to get at the type name before it gets saved to the onboarding
        # session. This is so we can set the steps based on the file origination type directly after
        # the type is selected by the user. That selection may change which type the user wants to
        # to submit, so it may be different from what was previously stored in the session
        params[:nfg_csv_importer_onboarding_import_data_file_origination_type_selection].try(:[],:file_origination_type) ||
        onboarding_session.step_data['import_data'].try(:[], :file_origination_type_selection).try(:[], 'file_origination_type')
      end

      def get_file_origination_type
        update_file_origination_type_if_it_has_changed(import)
        import.file_origination_type
      end

      def get_onboarding_session
        # we have to find the onboarding session first from the user session, if we can't find it then we need to look at the params
        # if still can't find it then we create a new onboarding session
        onboarding_sess = nil
        onboarding_sess = ::Onboarding::Session.find_by(id: session[:onboarding_session_id]) if session[:onboarding_session_id]
        onboarding_sess ||= get_import&.onboarding_session if params[:import_id]
        onboarding_sess ||= new_onboarding_session
        onboarding_sess.tap { |os| session[:onboarding_session_id] = os.id }
      end

      def get_import
        session[:onboarding_import_data_import_id] = params[:import_id] if params[:import_id].present?
        begin
          imported_for.imports.find(session[:onboarding_import_data_import_id])
        rescue
          session.delete(:onboarding_import_data_import_id)
          return nil
        end
      end

      def get_import_type
        params[:nfg_csv_importer_onboarding_import_data_import_type].try(:[],:import_type) ||
        onboarding_session.step_data['import_data'].try(:[], :import_type).try(:[], 'import_type') ||
        import_definitions.keys.first
      end

      def get_note
        params[:nfg_csv_importer_onboarding_import_data_upload_preprocessing].try(:[],:note) ||
        onboarding_session.step_data['import_data'].try(:[], :upload_preprocessing).try(:[], 'note')
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
        Import.new(imported_for: imported_for, imported_by: imported_by, file_origination_type: file_origination_type_name, status: "pending", import_type: get_import_type)
      end

      def fields_to_be_cleansed_from_form_params
        # these are fields that we don't want to store in onboarder session
        %w{ import_file pre_processing_files }
      end

      def reset_on_failure(step)
        onboarding_session.update(current_step: step)
        @override_next_step = step
      end

      def set_steps
        self.steps = if file_origination_type.nil?
                      [:file_origination_type_selection]
                    else
                      self.class.step_list.reject {|step| file_origination_type.skip_steps&.include? step}
                    end

        # We can skip the import_type step if the admin only have access
        # to a single import definition.
        self.steps -= [:import_type] if import_definitions.size == 1
      end

      def reset_onboarding_session
        session[:onboarding_session_id] = nil
        session[:onboarding_import_data_import_id] = nil
      end

      def update_file_origination_type_if_it_has_changed(import)
        return unless import&.file_origination_type
        if file_origination_type_name != import.file_origination_type.name
          import.file_origination_type = file_origination_type_name
          # import.pre_processing_files.map(&:purge)
        end
      end

      def upload_preprocessing_on_before_save
        form.pre_processing_files = [] if form_params.empty?
      end
    end
  end
end
