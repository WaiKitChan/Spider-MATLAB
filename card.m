classdef card
    properties
        suit int8
        rank int8
    end
    methods
        function c=card(s,r)
            c.suit=s;
            c.rank=r;
        end
    end
end