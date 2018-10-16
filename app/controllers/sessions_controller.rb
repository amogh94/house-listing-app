class SessionsController < ApplicationController

  include SessionsHelper


  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to "/users/#{user.id}"
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render json: {message:"Sorry!! Invalid email or password combination."}
    end
  end

  def destroy
    log_out
    redirect_to "/"
  end


end