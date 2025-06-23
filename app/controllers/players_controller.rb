class PlayersController < ApplicationController
  before_action :set_player, only: %i[show edit update]

  # GET /players
  # Optional: list all players (admin or public)
  def index
    @players = Player.all
  end

  # GET /players/:id
  def show
  end

  # GET /players/:id/edit
  def edit
    # You may want to restrict editing to current_player only
    redirect_to root_path, alert: "Not authorized" unless @player == current_player
  end

  # PATCH/PUT /players/:id
  def update
    if @player == current_player
      if @player.update(player_params)
        redirect_to @player, notice: "Profile successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to root_path, alert: "Not authorized"
    end
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :email) # add any fields you have
  end
end
