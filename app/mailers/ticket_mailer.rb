class TicketMailer < ActionMailer::Base
  default from: "reports@duelallday.com"
  def report_mail(ticket, email)
    @ticket, @chat_messages = ticket, ticket.chat.messages
    mail(to: email, subject: "Ticket #{ticket.id} report")
  end
end
