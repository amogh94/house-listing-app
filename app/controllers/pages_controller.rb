require 'sessions_helper'

class PagesController < ApplicationController

  def show

    @nav_bar_details = nav_bar_details

    admin = User.find_by(role: get_admin_role_id)
    @admin_exists = !(admin.nil?)

    puts @admin_exists

    if(!current_user.nil?)
     redirect_to "/users/#{current_user.id}"
    else
      @companies = Company.all
     render template: "pages/home"
    end
    #render json: {"s":1}
  end
end