class MessagesController < ApplicationController
  before_action :authenticate_user!

  def index
    @messages = Message.join(:conversation)
    .where(conversation: params[:conversation_id])
    .where("buyer_id = ? OR seller_id = ?", current_user.id, current_user.id)
    .order(created_at: :asc)

    # authorize @messages
  end

  def create
    @conversation = Conversation.find(params[:conversation_id])
    @message = @conversation.messages.build(message_params)
    @message.user = current_user

    # authorize @message
    if @message.save
      # redirect_to conversation_path(@conversation), notice: "message sent"

      # ActionCable.server.broadcast "conversation_#{@conversation.id}", message: render_message(@message)
      # head :ok
      ChatChannel.broadcast_to(@conversation, message: render_message(@message, current_user))
    else
      render json: { error: @message.errors.full_messages }, status: :unprocessable_entity

      # Rails.logger.debug "Message save failed with errors: #{message.errors.full_messages}"
      # redirect_to conversation_path(@conversation), alert: "Failed to send message"
    end
  end

  private
  def message_params
    params.require(:message).permit(:content)
  end

  def render_message(message, user)
    ApplicationController.renderer.render(partial: "messages/message", locals: { message: message, current_user: user })
  end
end
