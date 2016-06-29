class Placing
    include Mongoid::Document
    attr_accessor :name, :place

    def initialize(name=nil, place=nil)
        @name = name
        @place = place
    end

# Class methods ###############################################################
    def self.mongoize object
        case object
        when Placing then object.mongoize
        when Hash then
            Placing.new(object[:name], object[:place]).mongoize
        else object
        end
    end

    def self.demongoize object
        case object
        when Hash then
            Placing.new(object[:name], object[:place])
        when nil then nil
        end
    end

    def self.evolve object
        case object
        when Placing then object.mongoize
        else object
        end
    end
# Class methods ###############################################################

# Instance methods ############################################################
    def mongoize
        { name: @name, place: @place }
    end
# Instance methods ############################################################
end