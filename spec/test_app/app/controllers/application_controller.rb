class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def entity
    @entity ||= (Entity.find_by(subdomain: request.subdomain) || Entity.first || Entity.create(subdomain: "test"))
  end

  def current_user
    @current_user ||= entity.users.first || User.create(first_name: "Jim", last_name: "Smith", email: "jim@smith.com")
  end
  helper_method :current_user
end
