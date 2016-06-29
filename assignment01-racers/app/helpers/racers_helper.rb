module RacersHelper
	# Instance method toRacer. It must:
	# - Accept a single input argument
	# - If the type of the input argument is a Racer, simply return the instance unmodified. 
	#   Else attempt to instantiate a Racer from the input argument and return the result.
	def toRacer(value)
		# change value to a Racer if not already a Racer
		return value.is_a?(Racer) ? value : Racer.new(value)
	end
end
