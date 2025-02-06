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
      pdf.text "PREFACTURA", size: 24, style: :bold, align: :center
      pdf.move_down 10

      # Invoice details with image
      # Invoice header with logo and details in the same line
      pdf.bounding_box([ 0, pdf.cursor ], width: pdf.bounds.width) do
        pdf.image "#{Rails.root}/app/assets/images/logo.jpeg", width: 100, position: :left

        pdf.bounding_box([ 250, pdf.cursor + 100 ], width: 300) do
          pdf.text "Folio: #{@invoice.id}", size: 12, style: :bold
          pdf.text "Receptor: #{@invoice.user.full_name}" if @invoice.user
          pdf.text "Emisión: #{@invoice.issue_date.strftime('%d/%m/%Y')}"
          pdf.text "Vencimiento: #{@invoice.due_date.strftime('%d/%m/%Y')}"
          pdf.text "Estado: #{@invoice.status}"
        end
      end


      pdf.move_down 60

      # Table header
      pdf.text "Detalle de Contenedores y Servicios:", size: 14, style: :bold
      pdf.move_down 5

      container_data = [ [ "Contenedor", "Servicio", "Cargo" ] ]

      # Loop through each container and its services
      @invoice.services.includes(:container).group_by(&:container).each do |container, services|
        services.each_with_index do |service, index|
          container_number = index.zero? ? container.number : "" # Solo en la primera fila
          container_data << [ container_number, service.name, format_currency(service.charge) ]
        end
      end

      # Table without inner borders
      pdf.table(container_data, column_widths: [ 100, 200, 100 ], header: true, row_colors: [ "FFFFFF" ], cell_style: { border_width: 0.1, borders: [ :top, :bottom, :left, :right ] }) do
        row(0).background_color = "BFDBFE"
        row(0).text_color = "000000"
        row(0).font_style = :bold
      end

      pdf.move_down 10

      # Invoice summary
      subtotal = @invoice.services.sum(:charge)
      tax = subtotal * 0.16
      total = subtotal + tax

      # pdf.text "Resumen Prefactura:", size: 14, style: :bold
      summary_data = [
        [ "Subtotal", format_currency(subtotal) ],
        [ "IVA Trasladado 16%", format_currency(tax) ],
        [ "Total", format_currency(total) ]
      ]

      indentation = 100
      pdf.indent(indentation) do
        pdf.table(summary_data, column_widths: [ 200, 100 ], cell_style: { border_width: 0.1, borders: [ :top, :bottom, :left, :right ] }) do
          row(-1).background_color = "BFDBFE" # Apply blue only to the last row
          row(-1).text_color = "000000"       # White text for the last row
          row(-1).font_style = :bold          # Bold text for emphasis
        end
      end

      pdf.move_down 10

      # Payments table
      # if @invoice.payments.any?
      #   pdf.text "Pagos:", size: 14, style: :bold
      #   payment_data = [ [ "Fecha", "Monto", "Forma de Pago" ] ]
      #   payment_data += @invoice.payments.map do |payment|
      #     [ payment.payment_date.strftime("%d/%m/%Y"), format_currency(payment.amount), payment.payment_means ]
      #   end

      #   pdf.table(payment_data, column_widths: [ 100, 100, 150 ], header: true) do
      #     row(0).background_color = "5AB2FF"
      #     row(0).text_color = "FFFFFF"
      #     row(0).font_style = :bold
      #     cells.borders = []
      #     row(0).borders = [ :bottom ]
      #   end
      # end
    end.render
  end

  private

  def format_currency(amount)
    ActionController::Base.helpers.number_to_currency(amount)
  end
end
