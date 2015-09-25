function data = getYahooDailyData(tickers, startDate, endDate, dateFormat)
% GETYAHOODAILYDATA scrapes the Yahoo! Finance website for one or more
% ticker symbols and returns OHLC, volume, and adjusted close information
% for the date range specified.
%
% Inputs: 
% tickers: Either a character string or cell array of strings listing one
%   or more (Yahoo!-formatted) ticker symbols
% startDate, endDate: Either MATLAB datenums or character strings listing
%   the date range desired (inclusive)
% dateFormat (optional): If startDate and endDate are strings, then this
%   indicates their format.  (See the 'formatIn' argument of DAMENUM.)
%
% Outputs:
% data: A structure containing fields for each ticker requested.  The
%   fields are named by genvarname(ticker).  Each field is an N-by-7 table
%   listing the dates, open, high, low, close, volume, and adjusted close
%   for all N of the trading days between startDate and endDate and in
%   increasing order of date.  NOTE: If the version of MATLAB is less than
%   8.2 (R2013b), then data returns a structure of dataset arrays
%   (Statistics Toolbox required).
%
% EXAMPLE:
% data = getYahooDailyData({'MSFT', 'ML.PA'}, ...
%   '01/01/2010', '01/01/2013', 'dd/mm/yyyy');

%% 1. Input parsing
% Check to see if a single ticker was provided as a string; if so, make it
% a cell array to better fit the later logic.
if ischar(tickers)
    tickers = {tickers};
end

% If dateFormat is provided, use it.  Otherwise, assume datenums were
% given.
if nargin == 4
    startDate = datenum(startDate, dateFormat);
    endDate   = datenum(  endDate, dateFormat);
end

url1 = 'http://ichart.finance.yahoo.com/table.csv?s=';

[sY, sM, sD] = datevec(startDate);
[eY, eM, eD] = datevec(endDate);

url2 = ['&a=' num2str(sM-1, '%02u') ...
    '&b=' num2str(sD) ...
    '&c=' num2str(sY) ...
    '&d=' num2str(eM-1, '%02u') ...
    '&e=' num2str(eD) ...
    '&f=' num2str(eY) '&g=d&ignore=.csv'];

% Determine if we're using tables or datasets:
isBeforeR2013b = verLessThan('matlab', '8.2');

%% 2. Load Data in a loop
h = waitbar(0, 'Getting daily data from Yahoo!');
for iTicker = 1:length(tickers)
    try
        str = urlread([url1 tickers{iTicker} url2]);
    catch
        % Special behaviour if str cannot be found: this means that no
        % price info was returned.  Error and say which asset is invalid:
        close(h)
        error('getYahooDailyData:invalidTicker', ...
            ['No data returned for ticker ''' tickers{iTicker} ...
            '''. Is this a valid symbol? Do you have an internet connection?'])
    end
    c = textscan(str, '%s%f%f%f%f%f%f', 'HeaderLines', 1, 'Delimiter', ',');
    if isBeforeR2013b
        ds = dataset(c{1}, c{2}, c{3}, c{4}, c{5}, c{6}, c{7}, 'VarNames', ...
            {'Date', 'Open', 'High', 'Low', 'Close', 'Volume', 'AdjClose'});
    else
        ds = table(c{1}, c{2}, c{3}, c{4}, c{5}, c{6}, c{7}, 'VariableNames', ...
            {'Date', 'Open', 'High', 'Low', 'Close', 'Volume', 'AdjClose'});
    end
    ds.Date = datenum(ds.Date, 'yyyy-mm-dd');
    ds = flipud(ds);
%     data.(genvarname(tickers{iTicker})) = ds;    
    data(iTicker) = struct('ticker',tickers{iTicker}, 'ohlc', ds);
    waitbar(iTicker/length(tickers), h);
end

close(h)