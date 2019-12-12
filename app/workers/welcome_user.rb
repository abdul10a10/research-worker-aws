class WelcomeUser
  include Sidekiq::Worker
  
  def perform(user_id)
    @user = User.find(user_id)
    UserMailer.with(user: @user).user_registration_admin_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Registration"
    @admin = User.where(user_type: "Admin").first
    @notification.user_id = @admin.id
    @user_type = @user.user_type
    @notification.message = "New " + @user_type +" has registered"

    if @user.participant?
      @notification.redirect_url = "/dashboards/overviewuser/#{@user.id}"
    elsif @user.researcher?
      @notification.redirect_url = "/dashboards/overviewresearcheruser/#{@user.id}"
    end
    @notification.save
  end
  
end