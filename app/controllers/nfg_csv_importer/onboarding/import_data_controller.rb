class NfgCsvImporter::Onboarding::ImportDataController < NfgCsvImporter::Onboarding::BaseController

  layout 'nfg_csv_importer/layouts/onboarding/import_data/layout'

  # steps list
  steps :get_started, :overview, :upload_preprocessing, :import_type, :upload_post_processing, :field_mapping, :preview_confirmation, :finish

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  # WORKAROUNDS
  expose(:import_presenter) { NfgCsvImporter::ImportPresenter.new(NfgCsvImporter::Import.new, view_context) }
  expose(:pre_processing_type) { params[:pre_processing_type] || params[:import][:pre_processing_type] }

  private

  # on before save steps
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

  def get_started_on_before_save
    # you can add logic here to perform, such as appending data to the params, before the form is to be saved
  end


  # on valid steps
  def finish_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def preview_confirmation_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def field_mapping_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def upload_post_processing_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def import_type_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def upload_preprocessing_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def overview_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def get_started_on_valid_step
    # you can add logic here to perform actions once a step has completed successfully
  end

  def get_onboarding_admin
    defined?(current_admin) ? current_admin : OpenStruct.new(id: 999, first_name: 'Any', last_name: 'User', email: 'any@user.com', primary_key: 'id')
  end

  def can_view_step_without_onboarding_session
    return true if params[:id] == 'wicked_finish' # the onboarding session is typically completed prior to this step
    # if there are steps that can be accessed without a onboarding session (typically the first step of the onboarder), list them here
    # return true if step == :get_started
    false
  end

  def get_form_target
    case step
        when :get_started
          OpenStruct.new(name: '') # replace with your object that the step will update
        when :overview
          OpenStruct.new(name: '') # replace with your object that the step will update
        when :upload_preprocessing
          OpenStruct.new(name: '') # replace with your object that the step will update
        when :import_type
          OpenStruct.new(name: '') # replace with your object that the step will update
        when :upload_post_processing
          OpenStruct.new(name: '') # replace with your object that the step will update
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
     # where to take the user when the have finished this step
     # TODO add a path to where the user should go once they complete the onboarder
  end

  def onboarder_name
    "import_data"
  end

  def get_onboarding_session
    # Use the following as an example of how an onboarding session would be either retrieved or instantiated
    # We call new rather than create because we don't want the onboarding session
    # to be saved if the user does not continue past the first step.
    # onboarding_admin.onboarding_session_for(onboarder_name) || Onboarding::Session.new(onboarding_session_parameters)

    # the following is a hack for the test app. So we can progress through the pages. It will need to be revised
    # when used in DM. Not sure of the best way to do that.
    session[:onboarding_session_id] ? ::Onboarding::Session.find(session[:onboarding_session_id]) : ::Onboarding::Session.create(onboarding_session_parameters).tap { |os| session[:onboarding_session_id] = os.id }
  end

  def onboarding_session_parameters
    {
      entity: nil,# supply the parent object to the onboarding session
      owner: nil,
      current_step: "get_started",  #typically the first step
      related_objects: {} ,# a hash containing the whatever object will be saved first, i.e. { project: get_project },
      name: onboarder_name
    }
  end
end