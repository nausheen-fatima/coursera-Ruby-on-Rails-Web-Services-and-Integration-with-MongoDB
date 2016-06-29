class Address
	include Mongoid::Document
	attr_accessor :city, :state, :location

	def initialize(city=nil, state=nil, loc=nil)
		@city = city
		@state = state
		if loc.nil?
			@location = Point.new(0.0, 0.0)
		else
			@location = Point.new(loc[:coordinates][0], loc[:coordinates][1])
		end
	end

# Class methods ###############################################################

    def self.mongoize object
    	case object
	    when Address then object.mongoize
	    when Hash then
	    	Address.new(object[:city], object[:state], object[:loc]).mongoize
	    else object
	    end
    end

    def self.demongoize object
    	case object
        when Hash then
        	Address.new(object[:city], object[:state], object[:loc])
        when nil then nil
        end
    end

    def self.evolve(object)
		case object
		when Address then object.mongoize
		else object
		end
	end

# Class methods ###############################################################

# Instance methods ############################################################

    def mongoize
    	{
    		city: @city,
    		state: @state,
    		loc: {
        		type: 'Point',
        		coordinates: [
          			@location.longitude, @location.latitude
        		]
      		}
      	}
    end
# Instance methods ############################################################


end