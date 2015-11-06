class RegistrationsController < Devise::RegistrationsController

  def new
    if request.xhr?
      build_resource({})
      yield resource if block_given?
      render_modal
    else
      super
    end
  end

  protected
    def after_update_path_for(resource)
      case resource
      when :user, User
        edit_user_registration_path
      else
        super
      end
    end
end