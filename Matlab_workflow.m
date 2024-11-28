% Load the CSV file into MATLAB
disp('Loading scraped NBA data...');
nba_data = readtable('nba_data.csv');  % Replace with the correct path

% Display the first few rows of the data
disp('First rows of the raw data:');
disp(nba_data(1:min(5, height(nba_data)), :));

% ---- Data Cleaning ----
disp('Cleaning the data...');
% Remove rows where 'Rk' (Rank) is invalid or non-numeric (e.g., 'Rk' itself)
nba_data(strcmp(nba_data.Rk, 'Rk'), :) = [];  % Remove header-like rows
disp('After removing header-like rows:');
disp(nba_data(1:min(5, height(nba_data)), :));

% Convert the 'Rk' column to numeric (handles conversion issues)
%nba_data.Rk = str2double(nba_data.Rk);  % Convert 'Rk' to numeric

% Handle any NaN values in 'Rk' (e.g., replace with 0 or another strategy)
nba_data.Rk(isnan(nba_data.Rk)) = 0;  % Replace NaN with 0 (or use mean, median, etc.)

% Convert other columns to numeric if necessary
columnsToConvert = varfun(@iscell, nba_data, 'OutputFormat', 'uniform');
for colIdx = find(columnsToConvert)
    colName = nba_data.Properties.VariableNames{colIdx};
    nba_data.(colName) = str2double(nba_data.(colName));
end

% Handle missing values (replace NaN with 0 or column mean)
nba_data = fillmissing(nba_data, 'constant', 0); % Replace NaN with 0

% Display cleaned data (first 5 rows)
disp('First rows of the cleaned data:');
disp(nba_data(1:min(5, height(nba_data)), :));

% ---- Analysis ----

% 1. Group by Age and calculate the sum of Games (G)
disp('Grouping data by Age and summarizing Games played...');
age_vs_games = varfun(@sum, nba_data, 'InputVariables', 'G', 'GroupingVariables', 'Age');

% 2. Group by Age and calculate the total Minutes Played (MP)
disp('Grouping data by Age and summarizing Minutes Played...');
age_vs_minutes = varfun(@sum, nba_data, 'InputVariables', 'MP', 'GroupingVariables', 'Age');

% 3. Histogram of Points Per Game (PTS)
disp('Creating histogram of Points per Game...');
figure;
histogram(nba_data.PTS, 20, 'FaceColor', 'blue', 'EdgeColor', 'black');
title('Distribution of Points per Game');
xlabel('Points per Game');
ylabel('Frequency');
grid on;

% ---- Calculate Correlation Matrix Manually ----

% Select numeric columns for correlation calculation
numericCols = varfun(@isnumeric, nba_data, 'OutputFormat', 'uniform');
numericData = table2array(nba_data(:, numericCols));

% Compute the covariance matrix
covMatrix = cov(numericData);

% Compute the standard deviation for each column
stdDev = std(numericData);

% Calculate the correlation matrix by dividing covariance by the product of standard deviations
correlationMatrixManual = covMatrix ./ (stdDev' * stdDev);

% Display the correlation matrix
disp('Manual Correlation Matrix:');
disp(correlationMatrixManual);

% Plot the correlation matrix as a heatmap
disp('Creating correlation heatmap...');
figure;
imagesc(correlationMatrixManual);
colorbar;
title('Correlation Matrix (Manual)');
xlabel('Numeric Features');
ylabel('Numeric Features');
colormap('jet');  % Replace 'coolwarm' with a valid MATLAB colormap (e.g., 'jet', 'parula')

% 5. Scatter Plot: Rank vs Field Goal (FG)
disp('Creating scatter plot: Rank vs Field Goal...');
figure;
scatter(nba_data.Rk, nba_data.FG, 'r');
title('Rank vs Field Goal');
xlabel('Rank');
ylabel('Field Goal');
grid on;

% 6. Scatter Plot: Assists vs Points
disp('Creating scatter plot: Assists vs Points...');
figure;
scatter(nba_data.AST, nba_data.PTS, 'r');
title('Assists vs Points');
xlabel('Assists per Game');
ylabel('Points per Game');
grid on;

% ---- Visualizations ----

% Plot: Age vs Number of Games
disp('Plotting Age vs Number of Games...');
figure;
plot(age_vs_games.Age, age_vs_games.sum_G, '-o');
title('Age vs Number of Games');
xlabel('Age');
ylabel('Number of Games');
grid on;

% Plot: Age vs Minutes Played
disp('Plotting Age vs Minutes Played...');
figure;
plot(age_vs_minutes.Age, age_vs_minutes.sum_MP, '-o');
title('Age vs Minutes Played');
xlabel('Age');
ylabel('Minutes Played');
grid on;

disp('Analysis complete.');
