class UserService

  def self.deactivate_user(user, reason)
    @user = user
    @reason = reason
    UserMailer.with(user: @user, reason: @reason).rejection_email.deliver_later    
  end

  def self.verify_user(user)
    @user = user
    @user.status = "active"
    @user.verification_status = "1"
    @user.save
    @user.generate_referral_code!

    # WelcomeUser.perform_async(@user.id)
    UserMailer.with(user: @user).user_registration_admin_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Registration"
    @admin = User.where(user_type: "Admin").first
    @notification.user_id = @admin.id
    @user_type = @user.user_type
    @notification.message = "New " + @user_type +" has registered"

    if @user.user_type == "Participant"
      @notification.redirect_url = "/dashboards/overviewuser/#{@user.id}"
    elsif @user.user_type == "Researcher"
      @notification.redirect_url = "/dashboards/overviewresearcheruser/#{@user.id}"
    end
    @notification.save
  end

end