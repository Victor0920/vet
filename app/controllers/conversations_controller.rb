class ConversationsController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @conversations = Current.enterprise.conversations
      .search(@query)
      .includes(:messages, customer: { photo_attachment: :blob })
      .unread_first
  end

  # The "New conversation" modal: pick a customer. Those who already have a chat are marked,
  # and picking one opens it (create finds it instead of making a second one)
  def new
    @query = params[:q].to_s.strip
    @customers = Current.enterprise.customers
      .search(@query)
      .includes(:conversation, photo_attachment: :blob)
      .order(:first_name)
      .limit(50)
  end

  def show
    @conversation = Current.enterprise.conversations.find_by(id: params[:id])
    return redirect_to conversations_url, alert: t("flash.conversations.not_found") if @conversation.nil?

    # Turbo's hover prefetch sends this header: only a real visit reads the chat
    @conversation.mark_read! unless request.headers["X-Sec-Purpose"] == "prefetch"
    @pets = @conversation.customer.pets.includes(:pet_species).with_attached_photo
    @messages = @conversation.messages
    @message = Message.new(conversation_id: @conversation.id)
  end

  def create_message
    @conversation = Current.enterprise.conversations.find(params[:id])
    @message = @conversation.messages.build(message_params.merge(sender: :employee, employee: Current.employee))

    if @message.save
      redirect_to @conversation
    else
      @messages = @conversation.messages
      render :show
    end
  end

  def create
    customer = Current.enterprise.customers.find(conversation_params[:customer_id])
    @conversation = customer.conversation || customer.create_conversation!
    redirect_to conversation_path(@conversation, return_to: params[:return_to].presence)
  end

  def destroy
    @conversation = Current.enterprise.conversations.find(params[:id])

    if @conversation.destroy
      redirect_to conversations_url, notice: t("flash.conversations.deleted")
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @conversation.errors }, status: :unprocessable_entity }
        format.html { redirect_to @conversation, notice: t("flash.conversations.failed") }
      end
    end
  end

  private

  def message_params
    params.require(:message).permit(:text)
  end

  def conversation_params
    params.require(:conversation).permit(:customer_id)
  end
end
