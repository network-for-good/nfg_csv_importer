class NfgCsvImporter::Onboarding::ImportDataController < NfgCsvImporter::Onboarding::BaseController

  layout 'nfg_csv_importer/layouts/onboarding/import_data/layout'

  # steps list
  steps :file_origination_type_selection, :get_started, :overview, :upload_preprocessing, :import_type, :upload_post_processing, :field_mapping, :preview_confirmation, :finish

  expose(:onboarding_group_steps) { [] } # this should be removed if you are using a group step controller as a parent of this controller

  expose(:file_origination_types) { NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).types }

  expose(:file_origination_type) { selected_file_origination_type }

  # The onboarder presenter, when built, automatically
  # generates the step's presenter.
  #
  # Each step has a presenter setup that, at minimum,
  # inherits the OnboarderPresenter.
  expose(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, view_context) }
  # expose(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, view_context) }

  private

  # TODO:
  # Currently a workaround to supply the file origination type string to collect the file origination type object on demand.
  #
  # Not sure if there's a more reliable or succinct way to to collect this info or
  # if it should consistently be pulled out of the onboarding_session data.
  def selected_file_origination_type
    # Helps avoid breaking the view on the initial steps when the step data hasn't yet begun populating
    return unless onboarding_session.step_data['import_data'].present?

    # Reach in and grab the file origination type string
    file_origination_type_name = onboarding_session.step_data['import_data'][:file_origination_type_selection]['file_origination_type']

    # Select the official file origination type object based on the :type_sym
    file_origination_types.select { |t| t.type_sym == file_origination_type_name.try(:to_sym) }.first
  end

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

  def get_started_on_before_save
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
        when :file_origination_type_selection
          OpenStruct.new(name: '') # replace with your object that the step will update
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
    (session[:onboarding_session_id] ? ::Onboarding::Session.find_by(id: session[:onboarding_session_id]) || new_onboarding_session : new_onboarding_session).tap { |os| session[:onboarding_session_id] = os.id }
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
end