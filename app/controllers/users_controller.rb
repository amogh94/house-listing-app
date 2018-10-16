
class UsersController < ApplicationController
  before_action :set_user, :set_nav_bar, only: [:show, :edit, :update, :destroy]

  def set_nav_bar
    @nav_bar_details = nav_bar_details
    puts @nav_bar_details
  end

  def user_params
   params.require(:user).permit(:name, :email, :password, :role, :company_id, :password_confirmation,:phone,:preferred_contact_method)

  end

  # GET /users
  # GET /users.json
  def index
    redirect_to "/"
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @isLoggedIn = logged_in?

    @roleName = "users" #role["name"];
    @roleMessage = "hi" #role["message"];
    #@nav_bar_details = nav_bar_details
    display_user = @user

    @current_user = current_user
    @isAdmin = isAdmin?(current_user)
    if(isAdmin?(display_user))
      @roleText = roles["4"]
    elsif(isRealtor?(display_user))
      @roleText = roles["2"]
    end
    if(!display_user.company_id.nil?)
      # query for company name
      company = Company.find(display_user.company_id)
      @companyName = company.name
    end
    @display_user = display_user
    @user_active_time = display_user.created_at.strftime("%d / %m / %Y")+", "+display_user.created_at.strftime("%I:%M %p")
  end

  # GET /users/new
  def new
    redirect_to "/"
  end

  # GET /users/1/edit
  def edit
    paramId = params[:id]
    puts current_user.nil?
    isRedirectReqd = !(current_user.id.to_i == paramId.to_i || isAdmin?(current_user))
    if(current_user.nil? || isRedirectReqd)
      redirect_to "/"
    else

    end

  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to "/", notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.update(user_params)
        if @user.company_id != params[:company_id]
          # for all old houses, remove company_id
          House.where(:realtor_id => @user.id).update_all(:company_id => params[:company_id])
        end
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if isOnlyAdmin?
      #interests = Interest.where(user_id:@user.id)

      if @user.destroy
        render json:{"success":true}
      else
        render json:{"success":false}
      end
    else
      render json:{"success":false}
    end
    @user.destroy
    # respond_to do |format|
    #   format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def isAdmin?(user)
      return user.role == 4
    end



    # Never trust parameters from the scary internet, only allow the white list through.
    #def user_params
     # params.fetch(:user, {})
    #end
end
