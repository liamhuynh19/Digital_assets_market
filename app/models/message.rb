class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  validates :content, presence: true

  after_create_commit :broadcast!

  private
  def broadcast!
    ChatChannel.broadcast_to(self.conversation, {
      content: self.content,
      user_email: self.user.email,
      user_id: self.user_id,
      created_at: self.created_at.to_i,
      conversation_id: self.conversation_id,
      message_id: self.id,
      sender_id: self.user_id
    })
  end
end
