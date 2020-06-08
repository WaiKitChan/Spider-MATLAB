function spider(suit)
    % SPIDER(SUIT) starts a spider patience game with SUIT suits, possible 
    % values are 1, 2 and 4 (default).
    %
    % Spider is a type of patience game played using 2 decks of cards (104
    % cards). The player's goal is to remove all cards from the table.
    % Cards are to be moved between 10 stackss, and each move is legal if
    % (1) cards moved are of the same suit and arranged in consecutive 
    %     numerical order, with the smallest on top, and
    % (2) the rank of the top card of the destination exceed that of the
    %     bottom card of the moved cards by 1.
    % Once a sequence of card from King to Ace of the same suit is formed,
    % all 13 cards are removed from the game area.
    %
    % Player can redeal 5 times. Each redeal add 1 card to all 10 stacks in
    % the game area. No stack should be empty in order to redeal. All 5
    % redealing must be done in order to win the game.
    %
    % This function closes all existing figures and the game area is shown 
    % in a new figure. It is recommended that you use at least half a
    % screen to display the figure. To play the game, you are required to
    % input commands via the console. Possible commands are shown below:
    % 
    % N M: N and M are integers from 0 to 9, with 0 corresponding to the
    %      leftmost stack and 9 corresponding to the rightmost stack. Cards
    %      will be moved from stack N to stack M if the desired move is
    %      legal. Such move, if legal, is always unique.
    % r:   Redeal.
    % x:   Exit the game.
    %
    % Commands are case-insensitive.
    
    if nargin<1; suit=4; end
    if suit~=4&&suit~=2&&suit~=1; error('Cannot start spider patience with %g suits. Possible values are 1, 2 and 4.',suit); end

    % initialize background
    close all;
    [X,Y]=meshgrid(0:63,0:42);
    surf(X,Y,zeros(43,64),mod(X,2)+mod(Y,2));
    colormap([0,9/16,0;0,10/16,0;0,11/16,0]);
    shading flat;
    hold on;
    axis equal;
    view(0,-90);
    axes=gca;
    set(axes,'XLim',[0,63],'YLim',[0,42]);
    axes.XAxis.Visible='off';
    axes.YAxis.Visible='off';

    % initialize graphics
    res=imread('resource/card.png');
    face=mat2cell(res,70*ones(4,1),50*ones(13,1),3);
    back=imread('resource/back.png');
    clear res;
    
    % initialize cards
    % pool=uint8(2:105); % for testing
    pool=uint8(randperm(104)-1);
    suits=mod(floor(pool/13),suit);
    ranks=mod(pool,13);
    cards=repmat(card(0,0),104);
    for ii=1:104; cards(ii)=card(suits(ii),ranks(ii)); end
    clear pool suits ranks
    status='Redealing left: %d, Suits completed: %d';
    redeal=5;
    suitok=0;
    title(sprintf(status,redeal,suitok));
    stacks=[cardstack(),cardstack(),cardstack(),cardstack(),cardstack(),cardstack(),cardstack(),cardstack(),cardstack(),cardstack()];
    for ii=0:9; text(6*ii+4,1,char(ii+48),'Color','y','FontSize',12,'FontName','Consolas'); end
    for ii=0:43
        jj=mod(ii,10)+1;
        stacks(jj).size=stacks(jj).size+1;
        stacks(jj).card(stacks(jj).size)=cards(ii+1);
        stacks(jj).cardid(stacks(jj).size)=54-ii;
        image(back,'XData',6*jj-4+(0:5),'YData',2+floor(ii/10)+(0:7));
    end
    for ii=1:10
        stacks(ii).hidden=stacks(ii).size;
        stacks(ii).chain=1;
    end
    for ii=44:53
        jj=mod(ii,10)+1;
        stacks(jj).size=stacks(jj).size+1;
        stacks(jj).card(stacks(jj).size)=cards(ii+1);
        stacks(jj).cardid(stacks(jj).size)=54-ii;
        image(face{cards(ii+1).suit+1,cards(ii+1).rank+1},'XData',6*jj-4+(0:5),'YData',2+floor(ii/10)+(0:7));
    end
    cardindex=55;
    
    % start game
    while suitok<8
        cmd=input('Input command: ','s');
        c=unicode2native(lower(cmd(find(~isspace(cmd)))));
        if c; switch c(1)
            case 114 % redeal
                if ~redeal; fprintf('No redealing left.\n\n'); else
                    valid=true;
                    for ii=1:10
                        if stacks(ii).size==0
                            fprintf('Stack %d is empty.\n',ii-1);
                            valid=false;
                        elseif stacks(ii).size>=32
                            fprintf('Stack %d reached height limit.\n',ii-1);
                            valid=false;
                        end
                    end
                    if ~valid; fprintf('Cannot redeal.\n\n'); else
                        fprintf('Cards have been redealt.\n');
                        for ii=1:10
                            smem=stacks(ii);
                            smem.size=smem.size+1;
                            mem=cards(cardindex);
                            smem.card(smem.size)=mem;
                            smem.cardid(smem.size)=1-ii;
                            image(face{mem.suit+int8(1),mem.rank+int8(1)},'XData',6*ii-4+(0:5),'YData',1+double(smem.size)+(0:7));
                            cardindex=cardindex+1;
                            smem.countchain();
                        end
                        % reindex, because it is how matlab graphics works
                        p=1;
                        perm=zeros(1,cardindex-suitok*13-1);
                        for ii=1:10
                            smem=stacks(ii);
                            for jj=smem.size:-1:1
                                perm(p)=smem.cardid(jj)+10;
                                smem.cardid(jj)=p;
                                p=p+1;
                            end
                        end
                        axes.Children=axes.Children([perm,cardindex+(-suitok*13:10)]);
                        % reindex end
                        for ii=1:10
                            smem=stacks(ii);
                            if smem.chain==13 % suit completed, should have been a function but there are too many different variables used
                                              % due to the involvement of graphics (which matlab is not very good at) and it needs a bigger container class
                                smem.size=smem.size-13;
                                if smem.size==smem.hidden
                                    smem.hidden=smem.hidden-1;
                                    if smem.size>0
                                        smem.chain=1;
                                        mem=smem.card(smem.size);
                                        axes.Children(smem.cardid(smem.size)).CData=face{mem.suit+1,mem.rank+1};
                                    else; smem.chain=0;
                                    end
                                else; smem.countchain();
                                end
                                for jj=1:13; axes.Children(smem.cardid(smem.size+jj)).Visible='off'; end
                                fprintf('One suit completed on stack %d.\n',ii-1);
                                % reindex
                                p=0;
                                for jj=1:ii-1; p=p+stacks(jj).size; end
                                for jj=ii:10
                                    smem=stacks(jj);
                                    for kk=1:smem.size; smem.cardid(kk)=smem.cardid(kk)-13; end
                                end
                                axes.Children=axes.Children([1:p,p+14:cardindex-1-suitok*13,p+1:p+13,cardindex+(-suitok*13:10)]);
                                % reindex end
                                suitok=suitok+1;
                            end
                        end
                        redeal=redeal-1;
                        fprintf('%d redealings left.\n\n',redeal);
                        title(sprintf(status,redeal,suitok));
                    end
                end
            case 120 % exit
                suitok=9;
            otherwise % move from stack n to stack m
                if c(1)>=48&&c(1)<=57&&length(c)>=2
                    if c(2)>=48&&c(2)<=57
                        [moved,mstatus]=stacks(c(1)-47).move(stacks(c(2)-47));
                        if mstatus==-1; fprintf('Move is legal but stack %d reached height limit.\n\n',c(2)-48);
                        elseif mstatus==0; fprintf('Move is illegal.\n\n');
                        else
                            fprintf('%d cards moved from stack %d to stack %d.\n',moved,c(1)-48,c(2)-48);
                            smem=stacks(c(2)-47);
                            for ii=0:moved-1
                                set(axes.Children(smem.cardid(smem.size-ii)),'XData',6*double(c(2)-47)-4+(0:5),'YData',1+double(smem.size-ii)+(0:7));
                            end
                            % reindex
                            p=1;
                            perm=zeros(1,cardindex-suitok*13-1);
                            for ii=1:10
                                smem=stacks(ii);
                                for jj=smem.size:-1:1
                                    perm(p)=smem.cardid(jj);
                                    smem.cardid(jj)=p;
                                    p=p+1;
                                end
                            end
                            axes.Children=axes.Children([perm,cardindex+(-suitok*13:10)]);
                            % reindex end
                            if bitand(mstatus,2) % reveal hidden card
                                smem=stacks(c(1)-47);
                                mem=smem.card(smem.size);
                                axes.Children(smem.cardid(smem.size)).CData=face{mem.suit+1,mem.rank+1};
                            end
                            if bitand(mstatus,4) % suit completed
                                smem=stacks(c(2)-47);
                                smem.size=smem.size-13;
                                if smem.size==smem.hidden
                                    smem.hidden=smem.hidden-1;
                                    if smem.size>0
                                        smem.chain=1;
                                        mem=smem.card(smem.size);
                                        axes.Children(smem.cardid(smem.size)).CData=face{mem.suit+1,mem.rank+1};
                                    else; smem.chain=0;
                                    end
                                else; smem.countchain();
                                end
                                for ii=1:13; axes.Children(smem.cardid(smem.size+ii)).Visible='off'; end
                                fprintf('One suit completed on stack %d.\n',c(2)-48);
                                % reindex
                                p=0;
                                for ii=1:c(2)-48; p=p+stacks(ii).size; end
                                for ii=c(2)-47:10
                                    smem=stacks(ii);
                                    for jj=1:smem.size; smem.cardid(jj)=smem.cardid(jj)-13; end
                                end
                                axes.Children=axes.Children([1:p,p+14:cardindex-1-suitok*13,p+1:p+13,cardindex+(-suitok*13:10)]);
                                % reindex end
                                suitok=suitok+1;
                                title(sprintf(status,redeal,suitok));
                            end
                            fprintf('\n');
                        end
                    else; fprintf('Invalid command.\n\n');
                    end
                else; fprintf('Invalid command.\n\n');
                end
            end
        end
    end
    if suitok==8; fprintf('All 8 suits have been completed.\nCongratulations!\n'); title('Congratulations!');
    else; close all;
    end
end