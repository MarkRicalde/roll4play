class CampaignsController < ApplicationController
  before_action :authenticate_player!
  before_action :set_campaign, only: %i[ show edit update destroy ]
  before_action :check_campaign_access, only: %i[ show edit update destroy ]
  before_action :check_admin_access, only: %i[ edit update destroy ]

  # GET /campaigns or /campaigns.json
  def index
    @campaigns = current_player.campaigns.includes(:players, :sessions).recent
  end

  # GET /campaigns/1 or /campaigns/1.json
  def show
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns or /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)
    
    # Automatically make the creator an admin
    @campaign.memberships.build(player: current_player, role: 'admin')

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to @campaign, notice: "Campaign was successfully created." }
        format.json { render :show, status: :created, location: @campaign }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaigns/1 or /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to @campaign, notice: "Campaign was successfully updated." }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1 or /campaigns/1.json
  def destroy
    @campaign.destroy!

    respond_to do |format|
      format.html { redirect_to campaigns_path, status: :see_other, notice: "Campaign was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def campaign_params
      params.expect(campaign: [ :title, :description, :system ])
    end

    # Check if current player has access to the campaign
    def check_campaign_access
      unless current_player.member_of?(@campaign)
        redirect_to campaigns_path, alert: "You don't have access to this campaign."
      end
    end

    # Check if current player is admin of the campaign
    def check_admin_access
      unless current_player.admin_of?(@campaign)
        redirect_to @campaign, alert: "You must be an admin to perform this action."
      end
    end
end
