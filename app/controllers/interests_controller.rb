class InterestsController < ApplicationController
  before_action :set_interest, :set_nav_bar, only: [:show, :edit, :update, :destroy]

  def set_nav_bar
    @nav_bar_details = nav_bar_details
  end

  def interest_params
    params.require(:interest).permit(:user_id,:house_id)
  end
  # GET /interests
  # GET /interests.json
  def index
    @interests = Interest.all
  end

  # GET /interests/1
  # GET /interests/1.json
  def show
    @interest = Interest.find(params[:id])
    creator = User.find(@interest.user_id)
    creatorName = creator.name

    respond_to do |format|
      format.html #show.html.erb
      format.json {render json: @interest}
    end
  end

  # GET /interests/new
  def new
    @nav_bar = nav_bar_details
    @interest = Interest.new
  end

  # GET /interests/1/edit
  def edit
  end

  # POST /interests
  # POST /interests.json
  def create
    @interest = Interest.new(interest_params)
    @interest.user_id=current_user.id
    if(@interest.save)
      render json: {"success":true,"message":"Done!"}
    else
      render json: {"success":false,"message":@interest.errors}
    end
    # respond_to do |format|
    #   if @interest.save
    #     format.html { redirect_to @interest, notice: 'Interest was successfully created.' }
    #     format.json { render :show, status: :created, location: @interest }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @interest.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /interests/1
  # PATCH/PUT /interests/1.json
  def update
    respond_to do |format|
      if @interest.update(interest_params)
        format.html { redirect_to @interest, notice: 'Interest was successfully updated.' }
        format.json { render :show, status: :ok, location: @interest }
      else
        format.html { render :edit }
        format.json { render json: @interest.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interests/1
  # DELETE /interests/1.json
  def destroy
    @interest.destroy
    respond_to do |format|
      format.html { redirect_to interests_url, notice: 'Interest was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def get_interest_users_by_house
    begin
      house = House.find(params[:id])

      viewing_own_house = logged_in? && current_user.id == house.realtor_id
      viewing_own_house = viewing_own_house || isOnlyAdmin?

      interest_users = []

      if viewing_own_house
        interested_users_models = User.find_by_sql("select u.id,u.name,u.email,u.phone,u.preferred_contact_method FROM users u JOIN interests i ON u.id = i.user_id AND house_id = "+house.id.to_s)
        interested_users_models.each do |a_user|
          # if a_user.preferred_contact_method == "email"
          # else if it is "phone"
          # else it is NULL: by default, lets return a string of both
          contact = ""
          email = a_user.email
          phone = a_user.phone
          if a_user.preferred_contact_method == "email"
            if !email.nil?
              contact = email
            else
              contact = mobile
            end
          elsif a_user.preferred_contact_method == "phone"
            if !phone.nil?
              contact = phone
            else
              contact = email
            end
          else
            contacts = []
            if !email.nil?
              contacts.push(email)
            end
            if !phone.nil?
              contacts.push(phone)
            end
            contact = contacts.join(" | ")
            if(contact.length == 0)
              contact = nil
            end
          end
          user_id = a_user.id.to_s
          interest_users.push({"name":a_user.name,"contact":contact,"url":"/users/#{user_id}"})
        end
        response_json = {
            "users":interest_users,
            "success":true
        }
      else
        response_json = {
            "users":[],
            "success":false,
            "message":"Unauthorized"
        }
      end
    rescue
      response_json = {
        "users":[],
      "success":false
      }
    end
    render json: response_json
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interest
      begin
        @interest = Interest.find(params[:id])
      rescue
        redirect_to "/interest"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.

end
