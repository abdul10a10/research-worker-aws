class ApplicationController < ActionController::API


  def not_found
    render json: { error: 'not_found' }
  end

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      @decoded = JsonWebToken.decode(header)
      @current_user = User.find(@decoded[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def is_admin
    if @current_user.user_type == "Admin" 
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def is_researcher
    if @current_user.user_type == "Researcher" 
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def is_participant
    if @current_user.user_type == "Participant" 
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end

  def is_admin_or_researcher
    if @current_user.user_type == "Admin" || @current_user.user_type == "Researcher" 
    else
      render json: {Data: nil, CanEdit: false, CanDelete: false, Status: :ok, message: "unauthorised-user", Token: nil, Success: true}, status: :ok
    end
  end
  
end
