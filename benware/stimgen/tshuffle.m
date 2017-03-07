function internalindex = tshuffle(internalindex,nopairs)
% internalindex = a vector including all the desired types of trial,
%   whether randomised or not.
%   e.g, internalindex=[0 0 1 1 2 2 2 2];
%     or internalindex=[ones(1,50) 2*ones(1,50) 3*ones(1,100)];
% 
% nopairs = a single value or vector representing the types of trials for
% which there should be no pairs.
% 
% Examples
% > trialtypes=tshuffle([0*ones(1,5) 1*ones(1,5) 2*ones(1,10)],0), %will never have repeated zeros
% > trialtypes=tshuffle([0*ones(1,5) 1*ones(1,5) 2*ones(1,5) 3*ones(1,5)],[0 1 2 3]), %will never have repetitions of 0, 1, 2 OR 3.

%known bug: this algorithm only works when the different trial types
%(stored in internalindex) have equal numbers or are simple ratios of each
%other.
%
% This is fine for the typical (e.g.) 100 N, 50 RN, and and 50 RefRN but
% it wouldn't handle unusual numbers of trials
%e.g., tshuffle([1 0 1 0 1],1); %should get stuck in an infinite loop, but crashes
%    also: tshuffle([1 0 1 0 1 0 0 0 0 1],0) should be soluble, but crashes
%
% (A version exists that can handle any combination, but it can be very
% slow.)

%programming assumes that internalindex is a horizontal vector; make it so
swapflag=size(internalindex,1)>1;
if swapflag; internalindex=internalindex'; end;

if nargin>2
    error('need to update the calling program: shuffle now only takes two parameters')
end;

if nargin<2
    internalindex=internalindex(randperm(length(internalindex)));
    return
end

%work out the proportions of the internal index
trialtypes=unique(internalindex);
for typ=length(trialtypes):-1:1
    typecount(typ)=length(find(trialtypes(typ)==internalindex));
end;
typebase=typecount/tgcd(typecount); %the number of trials
% typebase=typecount/gcd(typecount);
%start with a general shuffle
internalindex=internalindex(randperm(length(internalindex)));

%now shuffle out any unwanted repeats
finishedflag=false;
while finishedflag==false
    pairs=findpairs(internalindex,nopairs);
    if isempty(pairs)
        finishedflag=true;
    else %need to do some swapping
        %choose a randomly selected pair
        totalpairs=length(pairs);
        pairselection=floor(totalpairs*rand)+1;
        if pairselection>pairs(totalpairs) %only occurs if rand==1, but better safe...
            pairselection=pairs(totalpairs);
        end;
        thispair=pairs(pairselection); %chooses just one random pair to focus on
        
        %choose other trials to shuffle with this pair
        pairtype=internalindex(thispair); %this is the type that the pair is
        if thispair==length(internalindex)
            selection=[length(internalindex) 1]; %round the houses
        else
            selection=[thispair thispair+1]; %to start with...
        end;
        try
            targetbalance=typebase*(lcm(typebase(trialtypes==pairtype),2)/2);
        catch
            typebase %#ok<NOPRT>
            trialtypes %#ok<NOPRT>
            pairtype %#ok<NOPRT>
            trialtypes==pairtype %#ok<NOPRT,EQEFF>
%             rethrow(lasterr)
        end;
        for ii=1:length(trialtypes)
            if trialtypes(ii)==pairtype
                if targetbalance(ii)>2
                    possibilities=find(internalselection==trialtypes(ii));
                    possibilities=possibilities(randperm(length(possibilities)));
                    selection=[selection possibilities(targetbalance(ii)-2)];
                end;
            else
                possibilities=find(internalindex==trialtypes(ii));
                possibilities=possibilities(randperm(length(possibilities)));
                try
                    selection=[selection possibilities(1:targetbalance(ii))];
                catch
                    internalindex %#ok<NOPRT>
                    possibilities %#ok<NOPRT>
                    targetbalance %#ok<NOPRT>
                    ii %#ok<NOPRT>
                    targetbalance(ii) %#ok<NOPRT>
                    possibilities(targetbalance(ii)) %#ok<NOPRT>
%                     rethrow(lasterr)
                end;
            end;
        end; %now, 'selection' is an index to a representative sample of trials to be shuffled
        
        reorderedselection=selection(randperm(length(selection)));
        internalindex(selection)=internalindex(reorderedselection);
        
        %disp(internalindex)
        %pause(1)
    end;
end;

%%spin the roulette wheel, to randomise where the "ends" are (no longer needed)
%firsttrial=trand(length(internalindex));
%internalindex=[internalindex(firsttrial:length(internalindex)) internalindex(1:(firsttrial-1))];

if swapflag; internalindex=internalindex'; end;

function allpairs=findpairs(internalindex,nopairs)
%nopairs is an array of numbers that shouldn't appear consecutively in
%internalindex. Find pairs returns the first position of each such pair.

allpairs=[];
for ii=1:length(nopairs)
    highlights=find(internalindex==nopairs(ii));
    totalhighlights=length(highlights);
    distances=highlights(2:totalhighlights)-highlights(1:(totalhighlights-1));
    allpairs=[allpairs highlights(distances==1)];
    if internalindex(1)==nopairs(ii)&&internalindex(length(internalindex))==nopairs(ii) %first and last
        allpairs=[allpairs length(internalindex)]; %flag the last one
    end;
end;