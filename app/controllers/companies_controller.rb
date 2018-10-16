include SearchHelper

class CompaniesController < ApplicationController
  before_action :set_company, :set_nav_bar, only: [:show, :edit, :update, :destroy]

  def set_nav_bar
    @nav_bar_details = nav_bar_details
  end

  def company_params
    params.require(:company).permit(:name,:website,:address,:size,:founded,:revenue,:synopsis)
  end

  # GET /companies
  # GET /companies.json

  def index
    @companies = Company.all
    @nav_bar_details = nav_bar_details
      respond_to do |format|
        format.html
      format.json { render json: @companies }
    end
  end

  # GET /companies/1
  # GET /companies/1.json
  def show
    @company = Company.find(params[:id])

    realtor_count = User.where(:company_id => params[:id]).count

    if realtor_count > 1
      @realtor_line = realtor_count.to_s + " realtors work here"
    elsif realtor_count == 1
      @realtor_line = "1 realtor works here"
    end

    houses = House.where(:company_id => params[:id])
    house_count = houses.count
    if house_count > 1
      @house_line = "This company has listed #{house_count.to_s} houses"
      @house_link = get_browse_href({"company_id":params[:id]})
    elsif house_count == 1
      @house_line = "This company has listed 1 house"
      @house_link = "/houses/#{houses[0].id.to_s}"
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/new
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])

  end

  # POST /companies
  # POST /companies.json
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      if @company.save
        # change the user's company
        User.where(:id=>current_user.id).update_all(:company_id => @company.id)
        format.html { redirect_to @company, notice: 'Company was successfully created.' }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1
  # PATCH/PUT /companies/1.json
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: 'Company was successfully updated.' }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.json
  def destroy
    @company = Company.find(params[:id])

    @company.destroy
    respond_to do |format|
      format.html { redirect_to companies_url, notice: 'Company was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.

end
