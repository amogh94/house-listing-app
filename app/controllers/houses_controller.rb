include HousesHelper

include SearchHelper

class HousesController < ApplicationController
  before_action :set_house, :set_nav_bar, only: [:show, :edit, :update, :destroy]

  def set_nav_bar
    @nav_bar_details = nav_bar_details
  end

  # GET /houses
  # GET /houses.json

  def house_params
    params.require(:house).permit(:company_id, :location, :sq_footage, :year_build, :style, :list_price, :floors, :basement, :current_owner)
  end

  def index
    @nav_bar_details = nav_bar_details
    @houses = House.all

    @filters = get_all_filters
    #run
    #@houses = get_result
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @houses }
    end
  end

  def search
    @nav_bar_details = nav_bar_details
    @houses = House.all
    @filters = get_all_filters
    run
    @houses = get_result
    if is_search_request?
      @nav_bar_details["searchKeyword"] = get_search_keywords.gsub!("-"," ")
    end
    @loginStatus = logged_in?
    respond_to do |format|
      format.html { render "houses/index"}
      format.json { render json: @houses }
    end

  end



  # GET /houses/1
  # GET /houses/1.json
  def show
    @house = House.find(params[:id])
    begin
      company = Company.find(@house.company_id)
      companyName = company.name
    rescue
    end
    realtor=  User.find(@house.realtor_id)

    realtorName = realtor.name

    @list_price = get_formatted_price(@house.list_price)

    if(!@house.floors.nil? && @house.floors > 0)
      @floors = @house.floors.to_s+" floor"
      if @house.floors > 1
        @floors += "s"
      end
    end

    @ago = get_time_ago
    @basements = (@house.basement)?"Contains basement!":"(Does not contain a basement)"

    @contactExists = (!companyName.nil? || !realtorName.nil?)

    if(@contactExists)
      if(!companyName.nil?)
        @companyName = companyName
        @companyHref = "/companies/#{company.id}"
      end
      if(!realtorName.nil?)
        @realtorName= realtorName
        @realtorHref = "/users/#{@house.realtor_id}"
        @realtorContact = realtor.email
      end
    end

    ctas = []
    if(current_user.nil?)

    elsif(isOnlyHouseHunter? || isHouseHunter?(current_user))
      ctas.push({"text":"I'm Interested!","action":"javascript:void(0)","successErrorMessaging":true,
                 "success":"Thank you for your interest!","failure":"Something went wrong.","id":"interestCta"})
    end

    if !logged_in?
      @is_my_old_house = false
    else
      @is_my_old_house = isRealtor?(current_user) && @house.realtor_id == current_user.id && @house.company_id != current_user.company_id
    end

    if( (isRealtor?(current_user) && @house.realtor_id == current_user.id && @house.company_id == current_user.company_id) || isOnlyAdmin?)
     # ctas.push({"text":"Interests & Inquiries","action":"/"})
      ctas.push({"text":"Remove","id":"removeHouse"})
      ctas.push({"text":"Edit","action":edit_house_path(@house)})
    end
    @ctas = ctas

    if(logged_in?)
    @show_inq_form = is_user_interested(@house.id,current_user.id) || isOnlyAdmin?
    else
      @show_inq_form = false
    end
    @hide_class_inq_form = (@show_inq_form)?"":" hide"


    get_interests_inquiries_text(@house.id,logged_in?,@current_user)

    @viewing_own_house = (logged_in? && current_user.id == @house.realtor_id) || isOnlyAdmin?

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @house }
    end
  end

  def searchbar
    url = get_search_href(params[:keyword],nil)
    render json: {"url":url}
  end

  def search_filter
    filters = params
    filters.delete("action")
    filters.delete("controller")

    url = get_browse_href(filters)
    puts url
    puts "URLL"
    render json: {"url":url}
  end

  # GET /houses/new
  def new
    @nav_bar_details = nav_bar_details
    @house = House.new
    @companies = Company.where(id: current_user.company_id)
    if(@isHouseHunter)
      redirect_to "/users/#{current_user.id}"
    else
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @house }
      end
    end
  end

  # GET /houses/1/edit
  def edit
    @house = House.find(params[:id])
    isAllowed = !current_user.nil? && (isOnlyAdmin? || @house.realtor_id == current_user.id)
    if( !isAllowed )
      redirect_to "/houses"
    end
    @companies = Company.all
  end

  # POST /houses
  # POST /houses.json
  def create
    @house = House.new(house_params)
    @companies = Company.all
    @house.realtor_id = current_user.id
    respond_to do |format|
      if @house.save
        format.html { redirect_to @house, notice: 'House was successfully created.' }
        format.json { render :show, status: :created, location: @house }
      else
        puts @house.errors.full_messages
        format.html { render :new }
        format.json { render json: @house.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /houses/1
  # PATCH/PUT /houses/1.json
  def update
    @companies = Company.all
    respond_to do |format|
      if @house.update(house_params)
        format.html { redirect_to @house, notice: 'House was successfully updated.' }
        format.json { render :show, status: :ok, location: @house }
      else
        format.html { render :edit }
        format.json { render json: @house.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /houses/1
  # DELETE /houses/1.json
  def destroy
    @house = House.find(params[:id])
    @house.destroy
    respond_to do |format|
      format.html { redirect_to houses_url, notice: 'House was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_house
     begin
      @house = House.find(params[:id])
     rescue
      redirect_to "/houses"
     end
    end

    # Never trust parameters from the scary internet, only allow the white list through.

    def set_vhp_ctas
      #ctas =

    end

  def get_time_ago
    current_time = Time.now
    t2 = @house.updated_at
    t1 = current_time
    diff= t1-t2
    minutes = (diff/60).floor
    hours = (minutes/60).floor
    days = (hours/24).floor
    if days < 1
      if hours < 1
        if minutes < 1
         return (diff.to_i % 60).to_s + " seconds ago"
        elsif minutes == 1
          return "1 minute ago"
        else
          return minutes.to_s + " minutes ago"
        end
      elsif hours == 1
        return "1 hour ago"
      else
        return hours.to_s + " hours ago"
      end
    elsif days == 1
      return "1 day ago"
    else
      return days.to_s + "days ago"
    end
  end

end
