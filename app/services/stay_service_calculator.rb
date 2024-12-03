class StayServiceCalculator
  def initialize(container, pricing)
    @stay_container = container
    @stay_pricing = pricing
  end

  def calculate_charge
    entry_move = @stay_container.moves.find_by(move_type: "Entrada")

    # Default values if pricing is nil
    start_delay = @stay_pricing&.start_delay || 1
    grace_period_days = @stay_pricing&.grace_period_days || 15
    daily_rate = @stay_pricing&.price || Service.find_by(name: "Almacenaje")&.charge || 0

    # Calculate the stay duration
    stay_start = entry_move.created_at.to_date + start_delay.days
    stay_end = Date.today
    stay_duration = (stay_end - stay_start).to_i

    # Apply the grace period
    billable_days = [ stay_duration - grace_period_days, 0 ].max

    billable_days * daily_rate
  end
end
