import consumer from "channels/consumer"

// Setup the chat channel connection when the DOM is fully loaded
document.addEventListener("turbo:load", setupChatChannel)
document.addEventListener("DOMContentLoaded", setupChatChannel)

function setupChatChannel() {
  const messagesContainer = document.getElementById('messages')
  
  // Only set up the subscription if we're on a conversation page
  if (messagesContainer && messagesContainer.dataset.conversationId) {
    const conversationId = messagesContainer.dataset.conversationId
    let channelCurrentUserId; // Store user ID here
    
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
          if (data.type === 'init') {
            channelCurrentUserId = data.current_user_id;
            return;
          }
                    
          // Check if message already exists to prevent duplicates
          if (document.getElementById(`message-${data.message_id}`)) {
            return;
          }
          
          // Use channel's current user ID instead of data attribute
          const isFromCurrentUser = data.user_id === channelCurrentUserId;
          
          // Generate message HTML client-side
          const messageHTML = `
            <div id="message-${data.message_id}" class="message mb-3 ${isFromCurrentUser ? 'text-end' : ''}">
              <div class="d-inline-block p-3 rounded ${isFromCurrentUser ? 'bg-primary text-white' : 'bg-light'}" 
                   style="max-width: 80%;">
                <div class="small mb-1 ${isFromCurrentUser ? 'text-white-50' : 'text-muted'}">
                  ${data.user_email} • ${formatTimeAgo(data.created_at)}
                </div>
                <div>${data.content}</div>
              </div>
            </div>
          `;
          
          messagesContainer.insertAdjacentHTML("beforeend", messageHTML);
          
          // Auto-scroll if user is near bottom
          if (isUserNearBottom(messagesContainer)) {
            scrollToBottom(messagesContainer);
          }
        }
      }
    )
  }
}

// Helper function to format time ago
function formatTimeAgo(timestamp) {
  const now = new Date();
  const messageDate = new Date(timestamp * 1000);
  const diffSeconds = Math.floor((now - messageDate) / 1000);
  
  if (diffSeconds < 60) return 'less than a minute ago';
  if (diffSeconds < 3600) return `${Math.floor(diffSeconds / 60)} minutes ago`;
  if (diffSeconds < 86400) return `${Math.floor(diffSeconds / 3600)} hours ago`;
  return `${Math.floor(diffSeconds / 86400)} days ago`;
}
