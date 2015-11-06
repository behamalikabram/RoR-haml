class FlowerGamesController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :set_variable

  before_action :set_game, except: [:new, :create, :index]
  authority_actions :complete => :update, cancel: "cancel", accept: "accept"
  authorize_actions_for FlowerGame, only: [:create, :new]

  def index
    @host = current_host if current_user and (current_user.is_host? or current_user.is_admin? or current_user.is_moderator?)
    @hosts = FlowerGameHost.online
    @past_games = FlowerGame.completed.limit(10)
    @wallet_amount = if current_user
      current_user.wallet.to_s
    end
  end

  def show
    add_flowers_host(@game.flower_game_host)
  end

  def create
    @game = FlowerGame.new(game_params)
    if @game.save
      js_redirect_to flower_game_path(@game)
    else
      render_modal template: :new
    end
  end

  def new
    @game = FlowerGame.new
    render_modal
  end

  def complete
    @game.assign_attributes(complete_params)
    if @game.complete
      respond_to do |f|
        f.js 
        f.html {redirect_to @game}
      end
    else
      render 'show'
    end
  end

  def accept
    if @game.accept
      respond_to do |f|
        f.js {render 'hide_buttons'}
        f.html {redirect_to @game}
      end
    else
      redirect_to @game, error: "Unable to accept the game"
    end
  end

  def cancel
    if @game.cancel
      respond_to do |f|
        f.js {render 'hide_buttons'}
        f.html {redirect_to @game}
      end
    else
      redirect_to @game, error: "Unable to decline the game."
    end
  end

  private 
    def current_host
      FlowerGameHost.find_by_host_id(current_user.id) || FlowerGameHost.new(host: current_user)
    end

    def game_params
      user_params = FlowerGameHost.host_online?(current_user) ? {host: current_user} : {bettor: current_user}
      user_params.merge!(creator: current_user)
      params.require(:flower_game).permit(:bettor_username, :host_username, :string_bet).merge(user_params)
    end

    def complete_params
      params.require(:flower_game).permit(:color)
    end

    def set_game
      @game = FlowerGame.find(params[:id])
      authorize_action_for @game
    end

    def set_variable
      @on_flowers_page = true
    end
end
