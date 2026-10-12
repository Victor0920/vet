module PetsHelper
  # "+0.4 kg" / "-1.2 kg" compared with the previous weighing, nil for the first one
  def weight_change(weight, previous)
    return if previous.nil?

    diff = weight.weight - previous.weight
    sign = "+" if diff.positive?
    "#{sign}#{number_with_precision(diff, precision: 2, strip_insignificant_zeros: true)} kg"
  end
end
