class WalletsController < ApplicationController
  before_filter :authenticate_user!
  
  def show
    @wallet = current_user.wallet
    @tickets = current_user.tickets.limit(50)
    render_modal
  end
end
