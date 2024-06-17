% Inizializzo le variabili
L = 5;                   % Numero di leader
T = 10;                  % Numero di targets
M = 5;                   % Numero di particelle nel campionamento
epsilon = 0.1;           % Costante di scalatura del tempo
alpha = 2;               % Esponente per la distanza nella funzione di interazione
delta = 0.1;             % Parametro delta
gamma = 0.5;             % Parametro gamma

% Le posizioni iniziali dei leader e dei targets vengono generate
% casualmente in un un'area 3x3

% Posizione casuale dei targets
pos_targets = rand(T, 2) * 3;

% Posizione dei leader
pos_leader = rand(L, 2) * 3;

% Numero di iterazioni
num_iterations = 10;

% Parametri aggiuntivi
attraction_strength = 0.3;        % Riduzione della forza di attrazione tra il leader e i follower
repulsion_strength = 0.1;         % Introduzione di una forza di repulsione tra il leader e i follower per evitare che si avvicinino troppo
leader_attraction_strength = 0.1; % Forza di attrazione del leader
repulsion_from_leader_strength = 0.2; % Forza di repulsione esercitata dal leader
buffer_size = 0.5;                % Dimensione del buffer attorno ai leader
min_distance_from_com = 1.0;      % Distanza minima dal centro di massa
repulsion_from_com_strength = 0.2; % Forza di repulsione dal centro di massa

% Simulazione del movimento nel tempo
figure;
hold on;

% Inizializzazione degli array per memorizzare le traiettorie di leader e target
leader_trajectory = zeros(num_iterations, L, 2);
target_trajectory = zeros(num_iterations, T, 2);

% Calcolo delle forze di interazione tra i target e si aggiornano le
% posizioni
for t = 1:num_iterations
    % Memorizza le posizioni attuali di leader e target
    leader_trajectory(t, :, :) = pos_leader;
    target_trajectory(t, :, :) = pos_targets;

    % Calcolo del centro di massa del gruppo
    center_of_mass = mean(pos_targets);

    % Identifico i target più lontani dal centro di massa
    distances_to_com = vecnorm(pos_targets - center_of_mass, 2, 2);
    [~, sorted_indices] = sort(distances_to_com, 'descend');
    
    % Distribuisco i target più lontani tra i leader
    furthest_targets = sorted_indices(1:L);
    
    % Calcolo delle forze di interazione tra i target
    interaction_forces = zeros(T, 2);
    for i = 1:T
        for j = 1:T
            if i ~= j
                d = norm(pos_targets(i,:) - pos_targets(j,:));
                force = H(d, alpha, delta, gamma);
                interaction_forces(i,:) = interaction_forces(i,:) + force * (pos_targets(j,:) - pos_targets(i,:)) / d;
            end
        end
    end

    % Aggiornamento delle posizioni dei target
    pos_targets = pos_targets + epsilon * interaction_forces;

    % Aggiorno la posizione di ciascun leader verso il target assegnato e
    % applico la forza di repulsione necessarie
    for l = 1:L
        target_position = pos_targets(furthest_targets(l), :);
        
        % Calcolo della distanza dal leader al target assegnato
        dist_to_target = norm(pos_leader(l, :) - target_position);
        
        % Se il target assegnato è all'interno del buffer, non muovere il leader
        if dist_to_target > buffer_size
            pos_leader(l, :) = pos_leader(l, :) + leader_attraction_strength * (target_position - pos_leader(l, :));
        end
        
        % Applicare la forza di repulsione dal leader al target assegnato
        repulsion_force = repulsion_from_leader_strength * (target_position - pos_leader(l, :)) / norm(target_position - pos_leader(l, :));
        pos_targets(furthest_targets(l), :) = pos_targets(furthest_targets(l), :) - repulsion_force;

        % Calcolare la distanza dal leader al centro di massa
        dist_to_com = norm(pos_leader(l, :) - center_of_mass);
        
        % Se il leader è troppo vicino al centro di massa, applicare una forza di repulsione
        if dist_to_com < min_distance_from_com
            repulsion_from_com_force = repulsion_from_com_strength * (pos_leader(l, :) - center_of_mass) / dist_to_com;
            pos_leader(l, :) = pos_leader(l, :) + repulsion_from_com_force;
        end
    end

    % Visualizzazione delle posizioni
    scatter(pos_leader(:,1), pos_leader(:,2), 'red', 'filled');  % Posizioni dei leader in rosso
    scatter(pos_targets(:, 1), pos_targets(:, 2), 'blue', 'filled');  % Posizioni dei target in blu
    scatter(center_of_mass(1), center_of_mass(2), 100, 'magenta', 'filled', 'd'); % Centro di massa in magenta

    % Disegna il buffer attorno ai leader
    for l = 1:L
        rectangle('Position', [pos_leader(l,1)-buffer_size, pos_leader(l,2)-buffer_size, 2*buffer_size, 2*buffer_size], ...
                  'Curvature', [1, 1], ...
                  'EdgeColor', 'r', ...
                  'LineStyle', '--');  % Buffer attorno ai leader in rosso tratteggiato
    end

    % Impostazione degli assi cartesiani
    xlim([0, 3]);
    ylim([0, 3]);

    xlabel('X');
    ylabel('Y');
    title(['Interazione ', num2str(t)]);
    legend('Leader', 'Target', 'Centro di Massa');
    pause(0.5);
end
hold off;

% Visualizza le traiettorie di leader e target
figure;
hold on;
% Indico i leader con linee rosse
for l = 1:L
    plot3(leader_trajectory(:, l, 1), leader_trajectory(:, l, 2), 1:numel(leader_trajectory(:, l, 1)), 'r-', 'LineWidth', 2);
end
% Indico i target con linee blu
for i = 1:T
    plot3(target_trajectory(:, i, 1), target_trajectory(:, i, 2), 1:numel(target_trajectory(:, i, 1)), 'b--', 'LineWidth', 1);
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Traiettorie di Leader e Target');
legend('Leader', 'Target');
view(3);
hold off;

% Funzione H
function force = H(distance, ~, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = 1 ./ ((delta^2 + distance.^2).^gamma);
end