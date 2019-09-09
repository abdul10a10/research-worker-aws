# Preview all emails at http://localhost:3000/rails/mailers/forget_password_mailer
class ForgetPasswordMailerPreview < ActionMailer::Preview
  def forget_password_mail_preview
    ForgetPasswordMailer.with(user: User.last).forget_password_email
  end
end
