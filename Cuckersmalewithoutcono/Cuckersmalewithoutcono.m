% Parametri della simulazione
L_values = 20:30;                % Intervallo del numero di leader
T_values = 60:110;               % Intervallo del numero di targets
alpha_values = 3:0.1:3.5;        % Intervallo dei valori di alpha
num_iterations = 50;             % Numero di iterazioni per la simulazione

% Inizializzazione delle variabili di memorizzazione dei risultati
results = zeros(length(alpha_values), length(T_values));

% Loop attraverso tutti i valori di alpha e T
for a_idx = 1:length(alpha_values)
    for t_idx = 1:length(T_values)
        alpha = alpha_values(a_idx);
        T = T_values(t_idx);
        
        % Numero di leader casuale nell'intervallo specificato
        L = randi([10, 15]);

        % Inizializzo le posizioni casuali dei leader e dei targets
        pos_targets = rand(T, 2) * 3;
        pos_leader = rand(L, 2) * 3;

        % Simulazione del movimento nel tempo
        for t = 1:num_iterations
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
        end
        
        % Calcolo di un parametro di interesse da memorizzare nei risultati
        % (ad esempio, la dispersione dei targets)
        results(a_idx, t_idx) = mean(vecnorm(pos_targets - center_of_mass, 2, 2));
    end
end

% Creazione del grafico di superficie
[X, Y] = meshgrid(T_values, alpha_values);
figure;
contourf(X, Y, results, 'LineColor', 'none');
colorbar;
xlabel('Number of targets (N_T)');
ylabel('Repulsion intensity (\alpha)');
title('Global Interaction');

% Funzione H
function force = H(distance, alpha, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = alpha ./ ((delta^2 + distance.^2).^gamma);
end
