class LegResult
    include Mongoid::Document

    field :secs, type: Float

    embedded_in :entrant
    embeds_one :event, as: parent

    validates_presence_of :event

    after_initialize do |doc|
        doc.calc_ave
    end

    # empty calback method
    def calc_ave
    end

    def secs= val
        self[:secs] = val
        calc_ave
    end
end
