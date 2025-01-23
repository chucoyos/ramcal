class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    @months = (0..5).map { |n| Date.today.beginning_of_month - n.months }

    @report_data = @months.map do |month|
      payments = Payment.where(created_at: month..month.end_of_month)
      pending_invoices = Invoice.where(status: "Pendiente", created_at: month..month.end_of_month)
      partial_invoices = Invoice.where(status: "Parcial", created_at: month..month.end_of_month)

      # Calculate the total pending amount (considering partial payments)
      total_pending_partial = partial_invoices.sum(:total) - partial_invoices.joins(:payments).sum("payments.amount")
      total_due = pending_invoices.sum(:total) + total_pending_partial

      {
        month: month,
        grouped: payments.group(:payment_means).sum(:amount),
        total: payments.sum(:amount),
        due: total_due
      }
    end
  end
end
