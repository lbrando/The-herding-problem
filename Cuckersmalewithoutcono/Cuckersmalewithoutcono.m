% Inizializzo le variabili
L = 3; % Leader
T = 50; % Targets
%K = 1;
%delta = 0.1;
%gamma = 0.5;
global K delta gamma;
K = 1;
delta = 0.1;
gamma = 0.5;

% Posizione casuale dei targets
pos_targets = rand(T, 2) * 3;

% Posizione del leader
%pos_leader = [1.5, 3.0];
pos_leader = rand(L,2) * 3;

% Numero di iterazioni
num_iterations = 50;

% Parametri aggiuntivi
attraction_strength = 0.3; % Riduco la forza di attrazione tra il leader e i follower
repulsion_strength = 0.1; % Introduco una forza di repulsione tra il leader e i follower per evitare che si avvicinino troppo
leader_attraction_strength = 0.1; % Forza di attrazione del leader

% Simulazione del movimento nel tempo
figure;
hold on;
% Array per memorizzare le traiettorie di leader e follower
leader_trajectory = zeros(num_iterations,L,2);
follower_trajectory = zeros(num_iterations, T, 2); % Cambiato da F a T
for t = 1:num_iterations
    % Memorizza le posizioni attuali di leader e follower
    leader_trajectory(t, :, :) = pos_leader;
    follower_trajectory(t, :, :) = pos_targets; % Cambiato da pos_followers a pos_targets

    % Distanza tra target e leader
    %distances = sqrt(sum((pos_targets - pos_leader).^2, 2));
    
    % Calcolo del campo medio Montecarlo
    for i = 1:T % aggiorno la posizione dei targets
        for l = 1:L % aggiorno la posizione dei leaders

            % Calcolo delle distanze tra il leader e i-esimo target
            distances = sqrt(sum((pos_targets - pos_leader(l, :)).^2, 2));

            % Eseguo il campionamento di M particelle j1...jM uniformemente
            sample_indices = randperm(T,M);

            %Calcolo H¯_alpha(xi)
            H_mean = mean(H(distances,K,delta,gamma));
        
            %Calcolo v_bar_i
            v_bar_i = mean(H(distances, K, delta, gamma));

            %Calcolo il cambiamento di posizione
            pos_targets(i,:) = pos_targets(i,:) + epsilon*H_mean*v_bar_i;

            % Distanza tra target tra loro
            %distances_target_i = sqrt(sum((pos_targets - repmat(pos_targets(i,:), T, 1)).^2, 2)); % Cambiato da pos_followers a pos_targets

            % Forza di interazione del target i
            %forza_interazione_i = sum(H(distances_target_i, K, delta, gamma)) * (pos_targets(i,:) - pos_leader) / (norm(pos_targets(i,:) - pos_leader) + delta); % Cambiato da pos_followers a pos_targets
        
            % Aggiorno la posizione del target i
            %pos_targets(i,:) = pos_targets(i,:) + forza_interazione_i; % Non c'è più la forza di repulsione, poiché non ci sono più follower

            % Limite della posizione del target all'interno dell'area
            %pos_targets(i,:) = max(0, min(pos_targets(i,:), 3));
        end
    end

    % Aggiorno la posizione del leader
    avg_x = mean(pos_targets(:, 1));
    avg_y = mean(pos_targets(:, 2));
    pos_leader = pos_leader + leader_attraction_strength * ([avg_x, avg_y] - pos_leader);

    % Visualizzazione delle posizioni
    scatter(pos_leader(1), pos_leader(2), 'red', 'filled');
    scatter(pos_targets(:,1), pos_targets(:,2), 'blue', 'filled');
    
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
    plot3(follower_trajectory(:, i, 1), follower_trajectory(:, i, 2), 1:numel(follower_trajectory(:, i, 1)), 'b--', 'LineWidth', 1);
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Traiettorie di Leader e Target');
legend('Leader', 'Target');
view(3);
hold off;

% Funzione H
function force = H(distance, K, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = K ./ ((delta^2 + distance.^2).^gamma);
end