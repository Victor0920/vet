class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end

  def create
    @message = Message.new(message_params)
    @conversation = @message.conversation

    Rails.logger.info(@message.errors)

    if @message.save


      respond_to do |format|
        format.json { render json: { success: true, message: @message } }
        format.html { redirect_to @conversation, notice: t("flash.messages.created") }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @message.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: t("flash.messages.failed") }
      end
    end
  end

  def show
    @message = Message.find_by(id: params[:id])
  end

  private

  def message_params
    params.require(:message).permit(:text, :conversation_id, :sender)
  end
end
