class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_filter :maintenance
  before_filter :check_ip, :check_for_banned_user, :add_tickets_count, :add_notifications, 
                :add_flowers_host, :add_global_vars

  private 
    def check_for_banned_user
      if current_user and (current_user.banned? or User.ip_banned.where(ip: request.remote_ip).any?)
        sign_out current_user 
        flash[:error] = "Your account was banned"
        redirect_to root_path
      end
    end

    def check_ip
      if current_user and !current_user.ip
        current_user.update_attribute(:ip, request.remote_ip)
      end
    end

    def add_global_vars
      @total_bet = DiceGame.completed.uniq.sum("bet*capacity") + FlowerGame.completed.uniq.sum("bet")
    end

    def add_tickets_count
      @tickets_count = Ticket.not_completed.count if current_user and current_user.can_read?(Ticket)
    end

    def current_user_is_admin?
      current_user and current_user.is_admin?
    end

    def add_notifications
      @any_new_notifications = current_user.any_new_notifications? if current_user
    end

    def add_flowers_host(host=nil)
      host ||= (current_user and current_user.flower_game_host)
      if host and host.online?
        @flower_host = host
        @flower_chat = @flower_host.chat
        @flower_chat_messages = @flower_chat.messages.last(10)
      end
    end
    
    def maintenance
      redirect_to maintenance_path unless request.remote_ip == 'your_ip'
    end

    def authenticate_user!
      unless user_signed_in?
        respond_to do |f|
          alert = "You must log in or sign up before continuing"
          f.html { redirect_to new_user_session_path, alert: alert }
          f.js do
            render 'shared/access_denied', locals: {alert: alert}
          end
        end
      end
    end

    def authority_forbidden(error)
      Authority.logger.warn(error.message)
      respond_to do |f|
        alert = 'You are not authorized to complete that action.'
        f.html { redirect_to request.referrer.presence || root_path, :alert => alert}
        f.js   { render 'shared/access_denied', locals: {alert: alert} }
      end
    end

    def render_modal(template: nil)
      template ||= action_name

      respond_to do |f|
        f.html { render template }
        f.js   { render template, layout: "page_modal" }
      end
    end

    def js_redirect_to(options = {}, response_status = {})
      raise ActionControllerError.new("Cannot redirect to nil!") unless options
      raise ActionControllerError.new("Cannot redirect to a parameter hash!") if options.is_a?(ActionController::Parameters)
      raise AbstractController::DoubleRenderError if response_body

      status = _extract_redirect_to_status(options, response_status)
      loc    = _compute_redirect_to_location(options)
      
      respond_to do |f|
        f.html do 
          self.status        = status
          self.location      = loc
          self.response_body = "<html><body>You are being <a href=\"#{ERB::Util.h(location)}\">redirected</a>.</body></html>"
        end
        f.js   { render 'shared/js_redirect', locals: {path: loc} }
      end
    end

  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected 

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:username, :email, :password, :password_confirmation)}
      devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
      devise_parameter_sanitizer.for(:account_update) {|u| u.permit(:username, :email, :password, :password_confirmation, :current_password)}
    end
end
