class FlowerGameHostsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_host, only: [:update, :go_offline, :test_stream]
  authority_actions :go_offline => :update, :test_stream => :update
  authorize_actions_for FlowerGameHost, only: [:create]

  def create
    @host = FlowerGameHost.new(host_params)
    if @host.save
      @host.go_online
      redirect_to flower_games_path, notice: "You are online!"
    else
      render 'new'
    end
  end

  def update
    if @host.update_attributes(host_params)
      @host.go_online
      path = params[:redirect_to] || flower_games_path
      redirect_to path, notice: "Information updated"
    else 
      render 'new'
    end
  end

  def go_offline
    @host.go_offline
    redirect_to flower_games_path
  end

  def open_chat
    @host = FlowerGameHost.find(params[:id])
    @chat = @host.chat
    @messages = @chat.messages.last(10)
    respond_to do |f|
      f.js
      f.html
    end
  end

  def test_stream
    @on_test_stream_page = true
  end

  private

    def host_params
      params.require(:flower_game_host).permit(:string_min_bet, :string_max_bet, :stream_link).merge(host: current_user)
    end

    def set_host
      @host = FlowerGameHost.find(params[:id])
      authorize_action_for @host
    end
end
