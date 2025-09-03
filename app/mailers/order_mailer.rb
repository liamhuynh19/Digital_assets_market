class OrderMailer < ApplicationMailer
  def invoice_email(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(:product)

    attachments["invoice_#{order.id}.pdf"] = generate_invoice_pdf if defined?(WickedPdf)

    mail(to: @user.email, subject: "Your invoice for new order - From Digital assets market")
  end

  private
  def generate_invoice_pdf
    WickedPdf.new.pdf_from_string(
      render_to_string(
        template: "order_mailer/invoice_pdf",
        layout: false,
        formats: [ :html ]
      )
    )
  rescue NameError
    nil
  end
end
