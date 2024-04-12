% Inizializzo le variabili
L = 3;                   % Numero di leader
T = 50;                  % Numero di targets
M = 5;                   % Numero di particelle nel campionamento
epsilon = 0.1;           % Costante di scalatura del tempo
alpha = 2;               % Esponente per la distanza nella funzione di interazione
delta = 0.1;             % Parametro delta
gamma = 0.5;             % Parametro gamma

% Posizione casuale dei targets
pos_targets = rand(T, 2) * 3;

% Posizione dei leader
pos_leader = rand(L, 2) * 3;

% Numero di iterazioni
num_iterations = 50;

% Parametri aggiuntivi
attraction_strength = 0.3;        % Riduzione della forza di attrazione tra il leader e i follower
repulsion_strength = 0.1;         % Introduzione di una forza di repulsione tra il leader e i follower per evitare che si avvicinino troppo
leader_attraction_strength = 0.1; % Forza di attrazione del leader

% Simulazione del movimento nel tempo
figure;
hold on;

% Array per memorizzare le traiettorie di leader e target
leader_trajectory = zeros(num_iterations, L, 2);
target_trajectory = zeros(num_iterations, T, 2);

% Calcolo del contatore di tempo
Ntot = T * (T - 1) / 2;            % Numero totale di coppie di target
Delta_t_c = 2 * epsilon / Ntot;

for t = 1:num_iterations
    % Memorizza le posizioni attuali di leader e target
    leader_trajectory(t, :, :) = pos_leader;
    target_trajectory(t, :, :) = pos_targets;

    % Iterazione sui target
    for i = 1:T % implementazione dell'algoritmo asintotico di Bird I
        % Aggiorna le posizioni dei targets ad ogni interazione del tempo
        % Calcolo delle distanze tra il target i e tutti gli altri target
        distances = sqrt(sum((pos_targets - pos_targets(i, :)).^2, 2));

        % Eseguo il campionamento di M particelle j1...jM uniformemente
        sample_indices = randperm(T, M);

        % Calcolo H¯_alpha(xi)
        H_mean = mean(H(distances(sample_indices), alpha, delta, gamma));

        % Calcolo v_bar_i
        v_bar_i = mean(H(distances(sample_indices), alpha, delta, gamma));

        % Calcolo il cambiamento di posizione
        pos_targets(i,:) = pos_targets(i,:) + epsilon * H_mean * v_bar_i;
    end

    % Aggiorno la posizione del leader
    avg_x = mean(pos_targets(:, 1));
    avg_y = mean(pos_targets(:, 2));
    pos_leader = pos_leader + leader_attraction_strength * ([avg_x, avg_y] - pos_leader);

    % Visualizzazione delle posizioni
    scatter(pos_leader(1), pos_leader(2), 'red', 'filled');
    scatter(pos_targets(:, 1), pos_targets(:, 2), 'blue', 'filled');

    % Impostazione degli assi cartesiani
    xlim([0, 3]);
    ylim([0, 3]);

    xlabel('X');
    ylabel('Y');
    title(['Interazione ', num2str(t)]);
    legend('Leader', 'Target');
    pause(0.5);
end
hold off;

% Visualizza le traiettorie di leader e target
figure;
hold on;
% Indico il leader con una linea rossa
plot3(leader_trajectory(:, 1), leader_trajectory(:, 2), 1:numel(leader_trajectory(:, 1)), 'r-', 'LineWidth', 2);
% Indico il target con una linea blu
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
function force = H(distance, alpha, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = 1 ./ ((delta^2 + distance.^2).^gamma);
end

% complessità di: O(num_iterations * T)