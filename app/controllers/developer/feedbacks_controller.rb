# Every company's feedback, newest first, filterable by status; the status is what the employee sees
module Developer
  class FeedbacksController < BaseController
    def index
      @status = params[:status].presence_in(Feedback.statuses.keys)
      @counts = Feedback.group(:status).count
      @feedbacks = Feedback.includes(:enterprise, :employee).with_attached_images.order(created_at: :desc)
      @feedbacks = @feedbacks.where(status: @status) if @status
    end

    def show
      @feedback = Feedback.find(params[:id])
    end

    def update
      @feedback = Feedback.find(params[:id])

      if @feedback.update(params.expect(feedback: [ :status ]))
        redirect_to developer_feedback_path(@feedback), notice: t("flash.feedbacks.status_updated")
      else
        redirect_to developer_feedback_path(@feedback), alert: @feedback.errors.full_messages.to_sentence
      end
    end
  end
end
