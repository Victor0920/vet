class ConversationsController < ApplicationController
  def index
    @conversations = Conversation.all
    @users = User.all
    @conversation = Conversation.new
  end

  def show
    @conversation = Conversation.find_by(id: params[:id])
    @user = User.find_by(id: @conversation.user_id)
    return redirect_to conversations_url, alert: "Conversation not found" if @conversation.nil?

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

  def create
    @conversation = Conversation.new(conversation_params)

    if @conversation.save
      redirect_to @conversation, notice: "Conversation created"
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @conversation.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: "Conversation failed" }
      end
    end
  end

  def destroy
    @conversation = Conversation.find(params[:id])

    if @conversation.destroy
      redirect_to conversations_url, notice: "Conversation deleted"
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @conversation.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: "Conversation failed" }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end

  def conversation_params
    params.require(:conversation).permit(:user_id)
  end
end
