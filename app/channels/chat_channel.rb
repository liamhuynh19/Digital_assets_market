class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    conversation = Conversation.find(params[:conversation_id])
    stream_for conversation
    @current_user_id = current_user.id
    puts "User #{@current_user_id} subscribed to ChatChannel for Conversation #{conversation.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
