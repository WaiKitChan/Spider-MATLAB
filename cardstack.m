classdef cardstack<handle
    properties
        card card
        cardid double 
        size int8
        hidden int8
        chain int8
    end
    methods
        function s=cardstack()
            s.card=repmat(card(0,0),1,32); % define height limit 32
            s.cardid=zeros(1,32); % for graphics handling
            s.size=int8(0);
            s.hidden=int8(-1);
            s.chain=int8(0);
        end
        function fullsuit=countchain(s)
            if ~s.size; s.chain=0; fullsuit=false; return; end
            ii=s.size;
            mem=s.card(ii);
            suit=mem.suit; rank=mem.rank;
            s.chain=0;
            while ii>0&&ii>s.hidden&&mem.suit==suit&&mem.rank==rank
                ii=ii-1;
                rank=rank+1;
                s.chain=s.chain+1;
                if ii>0; mem=s.card(ii); end
            end
            if s.chain==13; fullsuit=true; end
        end
        function [moved,status]=move(s1,s2)
            status=int8(1);
            moved=int8(0);
            if ~s1.size; status=int8(0); return;
            elseif ~s2.size
                moved=s1.chain;
                s1.size=s1.size-s1.chain;
                for ii=1:moved
                    s2.card(ii)=s1.card(s1.size+ii);
                    s2.cardid(ii)=s1.cardid(s1.size+ii);
                end
                s2.size=moved;
                s2.chain=moved;
                s1.countchain();
                if s1.hidden==s1.size
                    s1.hidden=s1.hidden-1; 
                    if s1.size>0; s1.chain=1; status=status+2; end
                end
                return;
            end
            source=s1.card(s1.size);
            target=s2.card(s2.size);
            moved=target.rank-source.rank;
            if moved>0&&moved<=s1.chain
                if s2.size+moved>32; status=int8(-1);
                else
                    s1.size=s1.size-moved;
                    for ii=1:moved
                        s2.card(s2.size+ii)=s1.card(s1.size+ii);
                        s2.cardid(s2.size+ii)=s1.cardid(s1.size+ii);
                    end
                    s2.size=s2.size+moved;
                end
                s1.countchain();
                if source.suit==target.suit; s2.chain=s2.chain+moved;
                else s2.chain=moved;
                end
                if s1.hidden==s1.size
                    s1.hidden=s1.hidden-1; 
                    if s1.size>0; s1.chain=1; status=status+2; end
                end
                if s2.chain==13; status=status+4; end
            else status=int8(0);
            end
        end
    end
end