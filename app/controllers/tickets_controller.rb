class TicketsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_new_ticket, only: [:new_transfer, :new_withdraw, :new_deposit, :create]
  before_action :set_ticket, only: [:accept, :cancel, :report]
  before_action :set_ticket_type, only: [:new_transfer, :new_withdraw, :new_deposit]

  authority_actions :new_transfer => :create, :new_withdraw => :create, 
                    :new_deposit => :create, :cancel => "cancel", accept: "accept", report: "report"

  authorize_actions_for Ticket, only: [:index]

  def new_transfer
  end

  def new_withdraw
  end

  def new_deposit
  end

  def create
    @ticket.assign_attributes(ticket_create_params)
    if @ticket.save
      flash[:success] = "Your #{@ticket.type} request was created!"
      js_redirect_to wallet_path
    else 
      render_modal template: :new
    end
  end

  def index
    @tickets = Ticket.not_completed.includes(:user, :chat)
  end

  def accept
    @ticket.accepted_by = current_user
    if params[:rate] and @ticket.deposit_type? and @ticket.currency == "07"
      @ticket.amount = @ticket.amount * params[:rate].to_i
    end
    @ticket.complete 
    redirect_to tickets_path, notice: "Ticket ##{@ticket.id} was accepted"
  end

  def cancel
    @ticket.cancel
    flash[:notice] = "Ticket ##{@ticket.id} was cancelled"
    redirect_to(current_user.is_user? ? wallet_path : tickets_path)
  end

  def report
    @ticket.report
    respond_to do |f|
      f.html {redirect_to @ticket, notice: "Ticket reported"}
      f.js
    end
  end

  private 
    def set_new_ticket
      @ticket = current_user.tickets.new
      authorize_action_for(@ticket)
    end

    def set_ticket
      @ticket = Ticket.find(params[:id])
      authorize_action_for(@ticket)
    end

    def set_ticket_type
      @ticket.type = action_name.split("_")[1]
      render_modal(template: :new)
    end

    def ticket_create_params
      params.require(:ticket).permit(:string_amount, :currency, :recipient_user_username, :type, :message)
    end
end
