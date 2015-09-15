class HomeController < ApplicationController

  def index
  end

  def show
    @user = User.where(:uid => params[:uid]).first
  end

end
