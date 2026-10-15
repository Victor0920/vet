class FeedbacksController < ApplicationController
  # Stops a stuck button or a script from flooding the developer's inbox
  rate_limit to: 10, within: 1.hour, only: :create,
    with: -> { redirect_to feedbacks_path, alert: t("flash.feedbacks.rate_limited") }

  before_action :set_support

  def index
    # The sidebar link sends ?return_to=<the page you were on>: saved with the feedback
    @feedback = Feedback.new(kind: "problem", page_url: params[:return_to])
    @feedbacks = my_feedbacks
  end

  def create
    @feedback = Current.enterprise.feedbacks.new(feedback_params)
    @feedback.employee = Current.employee
    @feedback.user_agent = request.user_agent

    if @feedback.save
      redirect_to feedbacks_path, notice: t("flash.feedbacks.created")
    else
      @feedbacks = my_feedbacks
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_support
    @support = Rails.configuration.x.support
  end

  # Only your own: colleagues' feedback isn't shown
  def my_feedbacks
    Current.employee.feedbacks.with_attached_images.order(created_at: :desc)
  end

  def feedback_params
    params.expect(feedback: [ :kind, :message, :page_url, images: [] ])
  end
end
