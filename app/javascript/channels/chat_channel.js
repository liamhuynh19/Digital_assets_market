import consumer from "channels/consumer"

// Setup the chat channel connection when the DOM is fully loaded
document.addEventListener("turbo:load", setupChatChannel)
document.addEventListener("DOMContentLoaded", setupChatChannel)

function setupChatChannel() {
  const messagesContainer = document.getElementById('messages')
  
  // Only set up the subscription if we're on a conversation page
  if (messagesContainer && messagesContainer.dataset.conversationId) {
    const conversationId = messagesContainer.dataset.conversationId
    
    // Clear any existing subscriptions for this conversation
    consumer.subscriptions.subscriptions.forEach(sub => {
      const data = JSON.parse(sub.identifier)
      if (data.channel === "ChatChannel" && data.conversation_id == conversationId) {
        consumer.subscriptions.remove(sub)
      }
    })
    
    // Create a new subscription
    consumer.subscriptions.create(
      { channel: "ChatChannel", conversation_id: conversationId },
      {
        connected() {
          console.log("Connected to ChatChannel for conversation:", conversationId);
        },
        
        disconnected() {
          console.log("Disconnected from ChatChannel");
        },
        
        received(data) {
          console.log("Received message:", data);
        
          
          // Find the message element if it already exists (prevent duplicates)
          const existingMessage = document.getElementById(`message-${data.message_id}`);
          if (!existingMessage) {
            messagesContainer.insertAdjacentHTML("beforeend", data.message);
            
            // Auto-scroll to the bottom of the messages container if user was near bottom
            if (isUserNearBottom(messagesContainer)) {
              scrollToBottom(messagesContainer);
            }
          }
        }
      }
    )
  }
}
