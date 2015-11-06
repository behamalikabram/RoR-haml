class SessionsController < Devise::SessionsController

  def new
    if request.xhr?
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      yield resource if block_given?
      render_modal
    else
      super
    end

  end

  def create
    super
  end

  def destroy
    super
  end

end