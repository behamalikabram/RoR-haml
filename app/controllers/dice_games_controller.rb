class DiceGamesController < ApplicationController
  before_filter :authenticate_user!, except: [:index]
  before_filter :set_variable
  before_action :set_game, only: [:show, :join, :leave, :roll]
  authority_actions :join => 'join', :leave => 'leave', :roll => "roll"

  AUTHORITY_MESSAGES = {"roll" => "You can't roll in current stage"}

  def index
    @current_games = DiceGame.current
    @past_games = DiceGame.completed.limit(10)
    @wallet_amount = if current_user
      current_user.wallet.to_s
    end
  end

  def show
  end

  def new
    @game = DiceGame.new
    render_modal
  end

  def create
    @game = DiceGame.new(game_params)
    if @game.save
      @game.add_user!(current_user)
      @game.trigger_event(:new_game, @game.games_channel)
      # render nothing: true
      js_redirect_to @game, notice: "Game created!"
    else 
      render_modal template: :new
    end
  end

  def join
    unless @game.full?
      @game.add_user!(current_user)

      @game.set_delay_on_roll if @game.full?
    end

    respond_to do |format|
      format.html { redirect_to @game }
      format.js
    end
  end

  def leave
    @game.remove_user!(current_user)

    @game.destroy if @game.empty? 

    redirect_to dice_games_path, notice: "You have left the game (#{@game.id})"
  end

  def roll
    cheat = (current_user.is_admin? and params[:cheat])

    @game.roll!(current_user, cheat)
    respond_to do |format|
      format.html { redirect_to @game }
      format.js {render nothing: true}
    end
  end

  private 
    def set_game
      @game = DiceGame.find(params[:id])
      authorize_action_for @game
    end

    def game_params
      params.require(:dice_game).permit(:type, :capacity, :string_bet).merge({joining_user: current_user})
    end

    def authority_forbidden(error)
      @message = AUTHORITY_MESSAGES[action_name]
      @message ||= "You can't #{action_name} this game"
      respond_to do |format|
        format.html { redirect_to dice_games_path, :alert => @message}
        format.js   { render 'forbidden'}
      end
    end

    def set_variable
      @on_dice_page = true
    end
end
