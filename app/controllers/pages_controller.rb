class PagesController < ApplicationController
  def all_user
    user = User.all
    render json: user
  end


end