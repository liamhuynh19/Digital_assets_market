class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true

  after_create_commit :broadcast!

  private
  def broadcast!
    rendered_message = ApplicationController.renderer.render(
      partial: "messages/message",
      locals: {
        message: self,
        current_user_id: self.user_id
      }
    )

    ChatChannel.broadcast_to(self.conversation, {
      message: rendered_message,
      message_id: self.id,
      sender_id: self.user_id
    })
  end
end
