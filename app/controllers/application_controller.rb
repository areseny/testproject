require 'conversion_errors/execution_errors'

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  include ExecutionErrors

  def default_serializer_options
    # remove if you want the root element to serialise as well
    # {root: false}
    {}
  end

  def render_error(e)
    if e.is_a? ActiveRecord::RecordNotFound
      render_not_found_error(e)
    elsif e.is_a? ExecutionErrors::NotAuthorisedError
      render_unauthorised_error(e)
    else
      render_unprocessable_error(e)
    end
  end

  def render_unauthorised_error(e)
    render json: {errors: [e.message]}, status: 401
  end

  def render_unprocessable_error(e)
    render json: {errors: [e.message]}, status: 422
  end

  def render_not_found_error(e)
    render json: {errors: [e.message]}, status: 404
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  # protected
  #
  # def configure_permitted_parameters
  #   devise_parameter_sanitizer.permit(:sign_up) do |user_params|
  #     user_params.permit({ user: [:email, :password, :password_confirmation] })
  #   end
  # end

end
