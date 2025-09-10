class ConversationsController < ApplicationController
  before_action :authenticate_user!
  def index
    @conversations = Conversation.where("buyer_id = ?  OR seller_id = ?", current_user.id, current_user.id).order(updated_at: :desc)
    # authorize @conversations
  end

  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
    @current_user_id = current_user.id
    # authorize @conversation
  end

  def load_more
    @conversation = Conversation.find(params[:id])

    @messages = @conversation.messages
    .includes(:user)
    .where("id < ?", params[:oldest_message_id])
    .order(created_at: :desc)
    .limit(10)
    .reverse

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "messages/message", collection: @messages }
      format.json { render json: { messages: @messages, oldest_id: @messages.any? ? @messages.first.id : nil } }
    end
  end

  def create
    @conversation = Conversation.find_or_create_by(buyer_id: conversation_params[:buyer_id], seller_id: conversation_params[:seller_id])
    # @conversation = Conversation.new(conversation_params)
    if @conversation.save
      redirect_to conversation_path(@conversation), notice: "Conversation started."
    else
      Rails.logger.debug "Conversation save failed with errors: #{@conversation.errors.full_messages}"
      redirect_to root_path, alert: "Failed to start conversation."
    end
  end

  private
  def conversation_params
    params.require(:conversation).permit(:buyer_id, :seller_id)
  end
end
