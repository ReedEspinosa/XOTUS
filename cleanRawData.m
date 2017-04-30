fileNm = 'beerData_RAW.csv';

C = fileread(fileNm);
Csplit = regexp(C, '","', 'split');
CperEntry = diff(find(cellfun(@(txt) ~isempty(regexp(txt, 'http', 'once')), Csplit)));
if any(CperEntry ~= CperEntry(1))
    error('The beers could not be properly seperated')
else
    CperEntry = CperEntry(1);
    fprintf('%d Columns found per beer\n', CperEntry)
end

% remove header row
Csplit(1) = [];

Nbeers = length(Csplit)/CperEntry;
fprintf('%d beers were found\n', Nbeers)
for t = 1:Nbeers
    strtInd = (t-1)*CperEntry + 1;
    
    % URL
    beer(t).url = Csplit{strtInd}; %#ok<*SAGROW>
    
    % Beer Code
    bcd = regexp(Csplit{strtInd+1}, '[(][0-9]+[A-F][)]', 'match');
    beer(t).code = bcd{1}(2:(end-1));
    
    % Technical Specs
    if length(Csplit{strtInd+2}) > 16 &&...
            (strcmpi(Csplit{strtInd+2}(1:16), 'Original Gravity') ||... % data exists
            strcmpi(Csplit{strtInd+2}(1:16), 'Final Gravity'))
        
        techDataCell = strsplit(Csplit{strtInd+2}, '\n');
        for i = 1:length(techDataCell);
            if techDataCell{i}(1) == ' ' % remove leading space
                techDataCell{i} = techDataCell{i}(2:end);
            end
            val = sscanf(techDataCell{i}, 'Original Gravity: %f');
            if ~isempty(val)
                beer(t).OrgGrav = val;
            end
            val = sscanf(techDataCell{i}, 'Final Gravity: %f');
            if ~isempty(val)
                beer(t).FinalGrav = val;
            end
            val = sscanf(techDataCell{i}, 'Alcohol by Vol: %f');
            if ~isempty(val)
                beer(t).ABV = val/100;
            end
            val = sscanf(techDataCell{i}, 'Yield: %f');
            if ~isempty(val) && ~isempty(regexpi(techDataCell{i}, 'Gallons'))             
                beer(t).yield = val;
            end
        end
    end
    
    % Rating
    rateDat = sscanf(Csplit{strtInd+3}, '%f stars based on %d votes');
    if isempty(rateDat)
        rateDat(1) = nan;
    end
    if length(rateDat) < 2
        rateDat(2) = nan;
    end
    beer(t).Rating = rateDat(1);
    beer(t).Votes = rateDat(2);
    
    % Ingredients
    ingred = Csplit((strtInd+4):(strtInd+15));
    emptyInd = cellfun(@(str) strcmp(str, 'null'), ingred);
    ingred(emptyInd) = [];
    beer(t).Ingredients = ingred';
    
    % Procedure
    beer(t).Procedure = Csplit{strtInd+16};
end

save([fileNm '.mat'])


% for t=1:2220; temp = beer(t).Ingredients; kirby{t} = temp