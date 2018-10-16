class InquiriesController < ApplicationController
  before_action :set_inquiry, :set_nav_bar, only: [:show, :edit, :update, :destroy]

  def set_nav_bar
    @nav_bar_details = nav_bar_details
  end

  # GET /inquiries
  # GET /inquiries.json

  def inquiry_params
    params.require(:inquiry).permit(:interest_id, :subject, :message)
  end

  def index
    @nav_bar_details = nav_bar_details
    @inquiries = Inquiry.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @inquiries }
    end
  end

  # GET /inquiries/1
  # GET /inquiries/1.json
  def show
    @inquiry = Inquiry.find(params[:id])
    #creator =  User.find(@inquiry.user_id)
    #creatorName = creator.name

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @house }
    end
  end

  # GET /inquiries/new
  def new
    @inquiry = Inquiry.new

    if(@isHouseHunter)
      redirect_to "/users/#{current_user.id}"
    else
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @house }
      end
    end
  end

  # GET /inquiries/1/edit
  def edit
    @inquiry = Inquiry.find(params[:id])
    if !logged_in? || isRealtor?(current_user)
      redirect_to "/inquiries"
    end

    # HH and admin
    inquiry_id = params[:id]
    @inquiry = Inquiry.find(inquiry_id)
    interest = Interest.find_by(id:@inquiry.interest_id)
    if current_user.id == interest.user_id
      @inquiry.destroy
      redirect_to "/inquiries"
    else
      redirect_to "/inquiries"
    end
  end

  # POST /inquiries
  # POST /inquiries.json
  def create
    @inquiry = Inquiry.new
    if(!current_user.nil?)
      interest = Interest.where(user_id:current_user.id, house_id: params[:house_id])

    end
    if interest.length == 0
      render json:{"success":false}
      return
    else
      interest = interest[0]
      existing_inquiry = Inquiry.find_by(interest_id:interest.id)
      if !existing_inquiry.nil?
        existing_inquiry.destroy
      end
      @inquiry.interest_id = interest.id
      @inquiry.subject = params[:subject]
      @inquiry.message = params[:message]
      if @inquiry.save
        render json:{"success":true}
      else
        render json:{"success":false}
      end
    end
  end


  def get_inquiries_by_house
    begin
      inq_res = Inquiry.find_by_sql("SELECT u.id,iq.id AS iqid, iq.interest_id, u.name, u.email, iq.subject, iq.message, iq.reply, u.phone, u.preferred_contact_method
FROM users u
  JOIN interests AS i ON i.user_id=u.id
  JOIN inquiries AS iq ON iq.interest_id=i.id
WHERE i.house_id="+params[:id])
      user_res = User.find_by_sql("SELECT u.id,iq.id AS iqid, iq.interest_id, u.name, u.email, iq.subject, iq.message, iq.reply, u.phone, u.preferred_contact_method
FROM users u
  JOIN interests AS i ON i.user_id=u.id
  JOIN inquiries AS iq ON iq.interest_id=i.id
WHERE i.house_id="+params[:id])

      result = []
      inq_res.each_with_index do |inquiry,index|
        user = user_res[index]
        contact = ""
        email = user.email
        phone = user.phone
        if user.preferred_contact_method == "email"
          if !email.nil?
            contact = email
          else
            contact = mobile
          end
        elsif user.preferred_contact_method == "phone"
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
        result_obj = {
            "name":user.name,
            "contact":contact,
            "subject":inquiry.subject,
            "message":inquiry.message,
            "id":inquiry.id
        }
        if inquiry["reply"]
          result_obj["reply"] = inquiry.reply
        end
        result.push(result_obj)
      end

      render json:{"success":true,"inquiries":result}

    rescue
      render json:{"success":false,"inquiries":[]}
    end
  end


  # PATCH/PUT /inquiries/1
  # PATCH/PUT /inquiries/1.json
  def update
    if Inquiry.where(:id => params[:id]).update(:reply => params[:reply])
      render json:{"success":true}
    else
      render json:{"success":false}
    end
  end

  # DELETE /inquiries/1
  # DELETE /inquiries/1.json
  def destroy
    if !logged_in? || isRealtor?(current_user)
      redirect_to "/inquiries"
    end

    # HH and admin
    inquiry_id = params[:id]
    @inquiry = Inquiry.find(inquiry_id)
    interest = Interest.find_by(id:@inquiry.interest_id)
    if current_user.id == interest.user_id
      @inquiry.destroy
      redirect_to "/inquiries"
    else
      redirect_to "/inquiries"
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inquiry
      begin
        @inquiry = Inquiry.find(params[:id])
      rescue
        redirect_to "/inquiries"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.

end
