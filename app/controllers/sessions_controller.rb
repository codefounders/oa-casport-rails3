class SessionsController < ApplicationController
  
  def setup
    # In an SSL enabled Apache server w/ Passenger you'd do something like this to assign the DN:
    #request.env['omniauth.strategy'].options[:uid] = request.env['SSL_CLIENT_S_DN']
    request.env['omniauth.strategy'].options[:uid] = 1
    render :text => 'Setup compelte', :status => 404
  end
  
  def create
    auth_hash = request.env['omniauth.auth']
    unless auth_hash.blank?
      user = User.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid']) || User.create_with_omniauth(auth_hash)
      session[:user_id] = user.id
      session[:expires_at] = 24.hours.from_now
      add_message('Thanks for logging in via CASPORT')
    else
      add_error('Your credentials could not be validated via CASPORT')
      Rails.logger.error("Error authentication DN: #{request.env['SSL_CLIENT_S_DN']}")
    end
    redirect_to root_url
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => 'You have signed out successfully.'
  end
  
  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
end
