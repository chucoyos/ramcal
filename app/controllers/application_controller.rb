class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Catch routing errors (404)
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  around_action :set_time_zone

  private
  def user_not_authorized
    flash[:alert] = "No tienes autorización para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end

  def set_time_zone(&block)
    Time.use_zone("America/Mexico_City", &block)
  end
end
