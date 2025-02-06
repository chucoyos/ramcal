require "prawn"
require "prawn/table"

class InvoicePdf
  def initialize(invoice)
    @invoice = invoice
  end

  def render
    Prawn::Document.new do |pdf|
      pdf.font "Helvetica"

      # Title
      pdf.text "Estado de Cuenta", size: 24, style: :bold, align: :center
      pdf.move_down 10

      # Invoice details
      pdf.text "Folio: #{@invoice.id}", size: 12, style: :bold
      pdf.text "Cliente: #{@invoice.user.full_name}" if @invoice.user
      pdf.text "Fecha de Emisión: #{@invoice.issue_date.strftime('%d/%m/%Y')}"
      pdf.text "Fecha de Vencimiento: #{@invoice.due_date.strftime('%d/%m/%Y')}"
      pdf.text "Estado: #{@invoice.status}"
      pdf.move_down 10

      # Container list
      if @invoice.services.any?
        pdf.text "Contenedores:", size: 14, style: :bold
        container_data = @invoice.services.includes(:container).map(&:container).uniq.map { |c| [ c.number ] }
        pdf.table container_data, column_widths: [ 200 ], header: [ "Número de Contenedor" ]
        pdf.move_down 10
      end

      # Invoice summary
      pdf.text "Resumen de Factura:", size: 14, style: :bold
      summary_data = [
        [ "Total", format_currency(@invoice.total) ],
        [ "Saldo Pendiente", format_currency(@invoice.total - @invoice.payments.sum(:amount)) ]
      ]
      pdf.table summary_data, column_widths: [ 200, 150 ], row_colors: [ "DDDDDD", "FFFFFF" ]
      pdf.move_down 10

      # Payments table
      if @invoice.payments.any?
        pdf.text "Pagos:", size: 14, style: :bold
        payment_data = [ [ "Fecha", "Monto", "Forma de Pago" ] ]
        payment_data += @invoice.payments.map do |payment|
          [ payment.payment_date.strftime("%d/%m/%Y"), format_currency(payment.amount), payment.payment_means ]
        end
        pdf.table payment_data, column_widths: [ 100, 100, 150 ], header: true
      end
    end.render
  end

  private

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount)
  end
end
