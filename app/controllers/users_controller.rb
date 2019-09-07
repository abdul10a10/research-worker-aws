class UsersController < ApplicationController
  def index
    @users = User.all
    render json: @users, status: :ok
  end

  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created
    else
      head(:unprocessable_entity)
    end


  end
  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      @message = "user has been deleted"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end

  def show
    # user = User.find(params[:id])

    if  User.where(:id => params[:id]).present?
      user = User.find(params[:id])
      render json: user, status: :found
    else
      @message = "user not found"
      render json: {message: @message}, status: :not_found
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @message = "user info has been updated"
      render json: {message: @message}, status: :ok
    else
      head(:unprocessable_entity)
    end
  end
  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name, :country, :user_type, :university, :university_email, :department, :specialisation, :job_type, :referral_code)
  end
end
