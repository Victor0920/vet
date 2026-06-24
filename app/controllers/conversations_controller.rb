class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.all
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages
    @message = Message.new(conversation_id: @conversation.id)
  end

  def create_message
    @conversation = Conversation.find(params[:id])
    @message = @conversation.messages.build(message_params)

    if @message.save
      redirect_to @convesation, notice: "Message created"
    else
      @messages = @convesation.messages
      render :show
    end
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end
end
