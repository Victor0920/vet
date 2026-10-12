class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)
    @message.sender = :employee
    @message.employee = Current.employee
    @conversation = @message.conversation

    Rails.logger.info(@message.errors)

    if @message.save
      respond_to do |format|
        format.json { render json: { success: true, message: @message } }
        format.html { redirect_to conversation_path(@conversation, return_to: params[:return_to].presence) }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @message.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: t("flash.messages.failed") }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:text, :conversation_id)
  end
end
