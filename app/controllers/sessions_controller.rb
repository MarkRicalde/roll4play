class SessionsController < ApplicationController
    def index
      @sessions = Session.all
    end
  
    def show
      @session = Session.find(params[:id])
      @players = @session.players
    end
  
    def create
      @session = Session.new(session_params)
      if @session.save
        redirect_to @session
      else
        render :new
      end
    end
  
    private
  
    def session_params
      params.require(:session).permit(:name, :description)
    end
  end
  