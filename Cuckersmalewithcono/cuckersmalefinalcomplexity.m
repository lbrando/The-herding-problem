% Inizializzo le variabili
L = 10;                 % Leaders
T = 30;                 % Targets
delta = 0.1;
gamma = 0.5;
num_iterations = 10;
epsilon = 0.1;          % Valore di epsilon

% Target positions
all_positions = [rand(L, 2); rand(T, 2)]; % Combino le posizione di Leaders e Targets in un'unica matrice
leader_velocity = repmat([0.1, 0.05], L, 1);  % Velocità costante del leader, regolata per il numero di leader

% Parametri addizionali
attraction_strength = 0.3;
repulsion_strength = 0.1;
p1 = 0.9;
p2 = 0.1;

% Inizializzo le variabili
trajectory = zeros(num_iterations, L+T, 2);

% Inizio simulazione
figure;
hold on;
for n = 1:num_iterations
    % Memorizzo le posizioni attuali
    trajectory(n, :, :) = all_positions;
    
    % Interazione con il cono di percezione (solo per i leader)
    prob_interaction = rand(1, L);
    strong_perception_idx = prob_interaction < p1;
    weak_perception_idx = prob_interaction >= p1 & prob_interaction < (p1 + p2);

    % Aggiorno le posizioni basandosi sulla percezione
    all_positions(strong_perception_idx, :) = all_positions(strong_perception_idx, :) + ...
        attraction_strength * (mean(all_positions(L+1:end, :)) - all_positions(strong_perception_idx, :));
    all_positions(weak_perception_idx, :) = all_positions(weak_perception_idx, :) + ...
        repulsion_strength * (mean(all_positions(L+1:end, :)) - all_positions(weak_perception_idx, :));

    % Aggiorno le posizioni dei leaders
    all_positions(1:L, :) = all_positions(1:L, :) + leader_velocity;

    % Aggiorno le posizioni dei targets
    for t = 1:T
        delta_v = repulsion_strength * sum((all_positions(L+t, :) - all_positions(1:L, :)) ./ vecnorm(all_positions(L+t, :) - all_positions(1:L, :), 2, 2).^gamma);
        all_positions(L+t, :) = all_positions(L+t, :) + delta_v;
    end

    % Disegno le posizioni
    plot(all_positions(1:L, 1), all_positions(1:L, 2), 'r-', 'LineWidth', 2);
    plot(all_positions(L+1:end, 1), all_positions(L+1:end, 2), 'b--', 'LineWidth', 1);
    
    % Pausa
    pause(0.5);
end
hold off;

% Aggiungo la legenda
legend('Leader', 'Follower');

% Disegno le traiettorie
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
