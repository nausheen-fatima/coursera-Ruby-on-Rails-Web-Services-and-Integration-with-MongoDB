class Event
    include Mongoid::Document

    field :o, as: :order, type: Integer
    field :n, as: :name, type: String
    field :d, as: :distance, type: Float
    field :u, as: :units, type: String

    embedded_in :parent, polymorphic: true, touch: true
    validates :order, presence: true
    validates :name, presence: true

    def meters
        case self.units
        when 'yards' then self.distance * 0.9144
        when 'miles' then self.distance * 1609.34
        when 'kilometers' then self.distance * 1000
        when 'meters' then self.distance
        else nil
        end
    end

    def miles
        case self.units
        when 'yards' then self.distance * 0.000568182
        when 'miles' then self.distance
        when 'kilometers' then self.distance * 0.621371
        when 'meters' then self.distance * 0.000621371
        else nil
        end
    end

end
