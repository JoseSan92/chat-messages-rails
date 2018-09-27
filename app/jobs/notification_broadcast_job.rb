class NotificationBroadcastJob < ApplicationJob
    queue_as :default

  def perform(personal_message)
    sender = personal_message.user
    recipient = personal_message.receiver
    conversation = personal_message.conversation
    message = render_message(personal_message, conversation, recipient)

    ActionCable.server.broadcast "notifications_#{personal_message.user.id}_channel", message: message, conversation_id: personal_message.conversation.id

    if personal_message.receiver.online?
      ActionCable.server.broadcast "notifications_#{personal_message.receiver.id}_channel", notification: render_notification(personal_message), message: message,
                                   conversation_id: personal_message.conversation.id
    end
  end

  private

  def render_notification(message)
    NotificationsController.render partial: 'notifications/notification', locals: {message: message}
  end

  def render_message(message, conversation, user)
    PersonalMessagesController.render partial: 'conversations/recivied', locals: {personal_messages: message, user: user, conversation: conversation}
  end
end
