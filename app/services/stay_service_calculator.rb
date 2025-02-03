class StayServiceCalculator
  def initialize(container, pricing)
    @stay_container = container
    @stay_pricing = pricing
  end

  def calculate_charge
    entry_move = @stay_container.moves.find_by(move_type: "Entrada")
    # Default values if pricing is nil
    grace_period_days = @stay_pricing&.grace_period_days || 15
    # daily_rate = @stay_pricing&.price || Service.find_by(name: "Almacenaje", container_id: nil)&.charge || 0

    almacenaje_service = Service.find_by(name: "Almacenaje", container_id: nil)
    daily_rate = @stay_pricing&.price || almacenaje_service&.charge || 0

    if @stay_pricing&.price
      daily_rate = @stay_pricing.price
    elsif almacenaje_service&.charge
      daily_rate = almacenaje_service.charge
    else
      daily_rate = 0
    end


    # Calculate the stay duration
    stay_start = (entry_move.move_date || entry_move.created_at).to_date
    stay_end = Date.today
    stay_duration = (stay_end - stay_start).to_i

    # Apply the grace period
    billable_days = [ stay_duration - grace_period_days, 0 ].max

    billable_days * daily_rate
  end
end
