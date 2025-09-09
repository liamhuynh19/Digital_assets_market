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
      ChatChannel.broadcast_to(@conversation, message: render_message(@message, current_user))
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.append("messages",
          partial: "messages/message",
          locals: { message: @message, current_user: current_user }
          )
        }
        format.json { head :ok }
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      render json: { error: @message.errors.full_messages }, status: :unprocessable_entity
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
