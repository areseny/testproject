require 'execution_errors'

class ApplicationController < ActionController::API

  include ActionController::HttpAuthentication::Token::ControllerMethods
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  include ExecutionErrors

  helper_method :service_authenticated?, :current_service

  attr_reader :current_account

  def authenticate_account!
    unless account_id_in_token?
      render json: { errors: ['Authorized users only'] }, status: :unauthorized
      return
    end
    @current_account = Account.find(auth_token[:account_id])
  rescue JWT::VerificationError, JWT::DecodeError
    render json: { errors: ['Authorized users only'] }, status: :unauthorized
  end

  def authenticate!
    authenticate_service
    unless service_authenticated?
      authenticate_account!
    end
  end

  def default_serializer_options
    # remove if you want the root element to serialise as well
    # {root: false}
    # {}
  end

  def authenticate_service
    token = request.headers["service_key"]
    Service.find_by(auth_key: token)
  end

  def service_authenticated?
    current_service.present?
  end

  def current_entity
    current_service || current_account
  end

  def current_service
    @_current_service ||= authenticate_service
  end

  def authorise_admin!
    unless current_entity && current_entity.admin?
      render_unauthorised_error("Authorized users only")
    end
  end

  def render_error(e)
    if e.is_a? StepNotInstalledError
      render_step_not_installed_error(e)
    elsif e.is_a? ActiveRecord::RecordNotFound
      render_not_found_error(e.message)
    elsif e.is_a? ExecutionErrors::NotAuthorisedError
      render_unauthorised_error(e.message)
    elsif e.is_a? EmptyChainError
      render_empty_chain_error(e.message)
    else
      render_unprocessable_error(e.message)
    end
  end

  def render_empty_chain_error(e)
    render json: {errors: "The chain you supplied has no steps"}, status: 422
  end

  def render_step_not_installed_error(e)
    render json: {errors: "The following steps are not installed: #{e.missing_step_classes.join(", ")}. Check the spelling of the step class name, contact the system administrator to ask to install the step, or try with a different recipe."}, status: 422
  end

  def render_unauthorised_error(message)
    render json: {errors: [message].flatten}, status: 401
  end

  def render_unprocessable_error(message)
    render json: {errors: [message].flatten}, status: 422
  end

  def render_not_found_error(message)
    render json: {errors: [message].flatten}, status: 404
  end

  private # more jwt

  def http_token
    @http_token ||= if request.headers['access-token'].present?
                      request.headers['access-token'].split(' ').last
                    end
  end

  def auth_token
    @auth_token ||= JsonWebToken.decode(http_token)
  end

  def account_id_in_token?
    http_token && auth_token && auth_token[:account_id].to_i
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  # protected
  #
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up) do |account_params|
  #     account_params.permit({ account: [:email, :password, :password_confirmation] })
  #   end
  # end

end
