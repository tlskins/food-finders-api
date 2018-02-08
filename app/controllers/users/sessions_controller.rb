# frozen_string_literal: true
require 'bcrypt'

class Users::SessionsController < Devise::SessionsController
  include ActionController::MimeResponds
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    # Rails.logger.debug 'POST /resource/sign_in CALLED, auth_options=' + auth_options.inspect
    # self.resource = warden.authenticate!(auth_options)
    # Rails.logger.debug 'self.resource after warden auth =' + self.resource.inspect
    # # set_flash_message!(:notice, :signed_in)
    # sign_in(resource_name, resource)
    # Rails.logger.debug 'after sign in'
    # yield resource if block_given?
    # respond_with resource, location: after_sign_in_path_for(resource)

    self.resource = User.find_by(email: params[:email])

    # check password
    if !resource || resource.encrypted_password.blank?
      render json: { error: "Invalid email or password." }, status: 401
      return
    end

    # check is confirmed
    if resource.confirmed_at.blank?
      render json: { error: "Please confirm your email address.", unconfirmed: true }, status: 401
      return
    end

    bcrypt = BCrypt::Password.new(resource.encrypted_password)
    password = BCrypt::Engine.hash_secret("#{params[:password]}#{resource.class.pepper}", bcrypt.salt)
    valid = Devise.secure_compare(password, resource.encrypted_password)

    # Sign in user even if they are already logged in
    if valid
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      bypass_sign_in(resource, scope: resource_name)

      yield resource if block_given?

      render json: resource, status: 201
    else
      render json: { error: "Invalid email or password." }, status: 401
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
  #   set_flash_message! :notice, :signed_out if signed_out
  #   yield if block_given?
  #   respond_to_on_destroy
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
