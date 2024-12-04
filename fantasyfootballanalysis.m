clear all;
close all;
clc;

username = "public";
password = "dse511project";

conn = mysql(username,password,'Server',"9QQ7GY3", ...
    'DatabaseName',"team_data",'PortNumber',3306)

tablename = "sleeperdata"; 
data = sqlread(conn, tablename);

% Display the data
disp(data);



% Close the connection
close(conn);

% Assume `data` is a table fetched from your SQL database
% Example columns: username, points_week_1, points_week_2, ..., age_week_1, age_week_2

% Extract data for Users 1 and 2
user1_data = data(strcmp(data.username, 'ShepC130'), :);
user2_data = data(strcmp(data.username, 'Drewski98'), :);

% Extract points and ages for all weeks
weeks = 1:(width(data) - 1) / 2; % Assuming half columns are for points and half for ages
user1_points = table2array(user1_data(:, contains(data.Properties.VariableNames, 'points_week')));
user2_points = table2array(user2_data(:, contains(data.Properties.VariableNames, 'points_week')));

user1_ages = table2array(user1_data(:, contains(data.Properties.VariableNames, 'age_week')));
user2_ages = table2array(user2_data(:, contains(data.Properties.VariableNames, 'age_week')));

% Calculate averages
avg_user1_points = mean(user1_points, 'omitnan');
avg_user2_points = mean(user2_points, 'omitnan');

avg_user1_ages = mean(user1_ages, 'omitnan')
avg_user2_ages = mean(user2_ages, 'omitnan')

figure;
plot(weeks, user1_points, '-o', 'LineWidth', 1.5, 'DisplayName', 'Nathaniel Points');
hold on;
plot(weeks, user2_points, '-o', 'LineWidth', 1.5, 'DisplayName', 'Drew Points');

% Plot average lines
yline(avg_user1_points, "b--", 'LineWidth', 1.5, 'DisplayName', 'Nathaniel Avg');
yline(avg_user2_points, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Drew Avg');

% Customize plot
title('Weekly Points Comparison');
xlabel('Week');
ylabel('Points');
legend('Location', 'best');
grid on;
hold off;


%% Predicting Week 14 Scores
% Extract team names and points columns
teams = unique(data.username);  % Extract unique team names
num_teams = numel(teams);

% Initialize storage for results
predicted_scores = table(teams, zeros(num_teams, 1), 'VariableNames', {'Team', 'Predicted_Week_14_Score'});

weeks = (1:13)';  % Weeks 1 to 13 (independent variable)

for i = 1:num_teams
    % Filter data for the current team
    team_name = teams{i};
    team_data = data(strcmp(data.username, team_name), :);
    
    % Extract weekly points for weeks 1 to 13
    team_points = table2array(team_data(:, contains(data.Properties.VariableNames, 'points_week_1':'points_week_13')));
    
    % Train linear regression model
    model = fitlm(weeks, team_points, 'linear');
    
    % Predict Week 14 score
    predicted_week14 = predict(model, 14);
    predicted_scores.Predicted_Week_14_Score(i) = predicted_week14;
    
    % Display results for this team
    fprintf('Predicted Week 14 Score for %s: %.2f\n', team_name, predicted_week14);
end

% Display predicted scores table
disp(predicted_scores);

% Save predictions to a CSV file
writetable(predicted_scores, 'Predicted_Week_14_Scores.csv');

figure;
bar(categorical(predicted_scores.Team), predicted_scores.Predicted_Week_14_Score);
title('Predicted Week 14 Scores for All Teams');
xlabel('Team');
ylabel('Predicted Score');
grid on;


%% Comparing Drewski and ShepC130 (me) to prove that my team is better than his.
% Filter data for User 1 and User 2
user1_data = data(strcmp(data.username, 'ShepC130'), :);
user2_data = data(strcmp(data.username, 'Drewski98'), :);

% Extract weekly points for both users (Weeks 1 to 13)
weeks = 1:(width(data) - 1) / 2; % Assuming half columns are for points and half for ages
user1_points = table2array(user1_data(:, contains(data.Properties.VariableNames, 'points_week')));
user2_points = table2array(user2_data(:, contains(data.Properties.VariableNames, 'points_week')));


% Train regression models for both users
model_user1 = fitlm(weeks, user1_points, 'linear');
model_user2 = fitlm(weeks, user2_points, 'linear');

% Predict Week 14 scores
predicted_week14_user1 = predict(model_user1, 14);
predicted_week14_user2 = predict(model_user2, 14);

% Display predictions
fprintf('Predicted Week 14 Score for User 1: %.2f\n', predicted_week14_user1);
fprintf('Predicted Week 14 Score for User 2: %.2f\n', predicted_week14_user2);

figure;

% Scatter plot for User 1
scatter(weeks, user1_points, 'o', 'DisplayName', 'User 1 Actual');
hold on;

% Line of best fit for User 1
plot(model_user1, 'DisplayName', 'User 1 Best Fit');

% Scatter plot for User 2
scatter(weeks, user2_points, 'x', 'DisplayName', 'User 2 Actual');

% Line of best fit for User 2
plot(model_user2, 'DisplayName', 'User 2 Best Fit');

% Highlight Week 14 predictions
scatter(14, predicted_week14_user1, 'r', 'filled', 'DisplayName', 'User 1 Predicted Week 14');
scatter(14, predicted_week14_user2, 'b', 'filled', 'DisplayName', 'User 2 Predicted Week 14');

% Customize plot
title('Week 14 Predictions for User 1 and User 2');
xlabel('Week');
ylabel('Points');
legend('Location', 'best');
grid on;
hold off;


