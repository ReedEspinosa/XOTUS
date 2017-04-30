load('beerData_RAW.csv.mat')

for t=1:2220; 
    ingrdCellMat(t, 1:length(beer(t).Ingredients)) = beer(t).Ingredients;  %#ok<SAGROW>
end
allIngStr = sprintf('%s ', ingrdCellMat{:});

allWords = lower(regexp(allIngStr, '[A-Za-z]+', 'match'));


unqWrds = unique(allWords);
unqCnts = cellfun(@(wrd) sum(strcmp(wrd, allWords)), unqWrds);
[cntSort, sortOrd] = sort(unqCnts, 'descend');
unqWrdsSrt = unqWrds(sortOrd);

trashWord = {'oz', 'lbs', 'lb', 'min', 'srm', 'l', 'i', 'misc', 'extract',...
    'tsp', 'g', 'dry','pound','ounce', 'pkgs', 'of', 'us', 'for', 'dark',...
    'minutes', 'brewer', 'pellets', 'american', 'northern', 'to',...
    's', 'cup', 'water', 'syrup', 'or', 'days', 'aa', 'at', 'kg', 'liquid',...
    'minute', 'a', 'mins', 'in', 'aau', 'gal', 'dcl', 'secial', 'first',...
    'cups', 'and', 'the', 'b', 'pkg', 'from', 'tbsp', 'm', 'can', 'f', 'grams'};

tashInd = cellfun(@(str) any(strcmp(str, trashWord)), unqWrdsSrt);

unqSrtCln = unqWrdsSrt(~tashInd);
cntSortCln = cntSort(~tashInd);

tashInd = cellfun(@(str) any(strcmp(str, trashWord)), unqWrdsSrt);

%% need to count words in each row, result should be nBeers X unqWrds matrix
nBeers = size(ingrdCellMat,1);
ingrdCellCol = arrayfun(@(ind) sprintf('%s ',ingrdCellMat{ind,:}), 1:nBeers, 'uniform', 0)';

ingrdColWrds = arrayfun(@(ind) lower(regexp(ingrdCellCol{ind,:}, '[A-Za-z]+', 'match')), 1:nBeers, 'uniform', 0)';




