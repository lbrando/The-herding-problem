% Initialize variables
L = 10;                 % Number of leaders
T = 30;                 % Number of targets
delta = 0.1;
gamma = 0.5;
num_iterations = 10;
epsilon = 0.1;          % Epsilon parameter

% Target positions
all_positions = [rand(L, 2); rand(T, 2)]; % Combine leader and follower positions into a single matrix
leader_velocity = repmat([0.1, 0.05], L, 1);  % Constant leader velocity, adjusted for the number of leaders

% Additional parameters
attraction_strength = 0.3;
repulsion_strength = 0.1;
p1 = 0.9;
p2 = 0.1;

% Initialize trajectories
trajectory = zeros(num_iterations, L+T, 2);

% Simulation loop
figure;
hold on;
for n = 1:num_iterations
    % Store current positions
    trajectory(n, :, :) = all_positions;
    
    % Interaction with perception cone (only for leaders)
    prob_interaction = rand(1, L);
    strong_perception_idx = prob_interaction < p1;
    weak_perception_idx = prob_interaction >= p1 & prob_interaction < (p1 + p2);

    % Update positions based on perception
    all_positions(strong_perception_idx, :) = all_positions(strong_perception_idx, :) + ...
        attraction_strength * (mean(all_positions(L+1:end, :)) - all_positions(strong_perception_idx, :));
    all_positions(weak_perception_idx, :) = all_positions(weak_perception_idx, :) + ...
        repulsion_strength * (mean(all_positions(L+1:end, :)) - all_positions(weak_perception_idx, :));

    % Update positions of leaders
    all_positions(1:L, :) = all_positions(1:L, :) + leader_velocity;

    % Update positions of followers
    for t = 1:T
        delta_v = repulsion_strength * sum((all_positions(L+t, :) - all_positions(1:L, :)) ./ vecnorm(all_positions(L+t, :) - all_positions(1:L, :), 2, 2).^gamma);
        all_positions(L+t, :) = all_positions(L+t, :) + delta_v;
    end

    % Plot positions
    plot(all_positions(1:L, 1), all_positions(1:L, 2), 'r-', 'LineWidth', 2);
    plot(all_positions(L+1:end, 1), all_positions(L+1:end, 2), 'b--', 'LineWidth', 1);
    
    % Pause for visualization
    pause(0.5);
end
hold off;

% Add legend
legend('Leader', 'Follower');

% Plot trajectories
figure;
hold on;
%for i = 1:L
    plot3(trajectory(:, i, 1), trajectory(:, i, 2), 1:num_iterations, 'r-', 'LineWidth', 2);
%end
for i = L+1:L+T
    plot3(trajectory(:, i, 1), trajectory(:, i, 2), 1:num_iterations, 'b--', 'LineWidth', 1);
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Leader and Follower Trajectories');
view(3);
hold off;

% Aggiungi legenda
legend('Traiettorie dei Leader', 'Traiettorie dei Follower');
