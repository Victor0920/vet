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
        format.html { redirect_to @conversation, notice: "Message created" }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @message.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: "Message failed" }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:text, :conversation_id, :sender)
  end
end
