class HomeController < ApplicationController
  def index
    @on_home_page = true
  end

  def terms
  end

  def info
    render_modal
  end

  def help
    render_modal
  end

  def leaderboard
    @week_depositers = User.normal_users.week_deposit_tickets.deposit_leaders
    @week_leaders = User.normal_users.week_winners
    render_modal
  end
end
