% Inizializzazione delle variabili
L = 10;                 % Numero di leader
T = 15;                 % Numero di targets
K = 1;                  % Maggiore di 0
delta = 0.1;
gamma = 0.5;
num_iterations = 10;
epsilon = 0.1;          % Parametro epsilon

% Posizione dei targets
pos_followers = rand(T, 2);    % Posizioni casuali per i targets
pos_leader = rand(L, 2);        % Posizione casuale per i leader
leader_velocity = repmat([0.1, 0.05], L, 1);  % Velocità costante del leader

% Parametri aggiuntivi
attraction_strength = 0.3;     % Riduco la forza di attrazione tra il leader e i targets
repulsion_strength = 0.1;      % Introduco una forza di repulsione tra il leader e i targets per evitare che si avvicinino troppo
leader_attraction_strength = 0.1;   % Forza di attrazione del leader

% Parametri del cono di percezione
p1 = 0.9;       % Peso per forte percezione
p2 = 0.1;       % Peso per debole percezione
theta = pi/2;   % Angolo del cono visivo

% Inizializzazione delle traiettorie
leader_trajectory = zeros(num_iterations, L, 2);
follower_trajectory = zeros(num_iterations, T, 2);

% Simulazione del movimento nel tempo
figure;
hold on;
for n = 0:num_iterations-1
    % Memorizza le posizioni attuali di leader e targets
    for l = 1:L
        leader_trajectory(n+1, l, :) = pos_leader(l, :);
    end
    for t = 1:T
        follower_trajectory(n+1, t, :) = pos_followers(t, :);
    end

    % Visualizza il numero di interazione corrente
    disp(['Interazione ', num2str(n+1)]);

    % Calcola il passo temporale
    delta_tc = 2 * epsilon / size(pos_followers, 1);
    
    % Interazione con il cono di percezione stocastico solo per i leader
    for l = 1:L
        % Calcolo della probabilità di interazione basata sul cono di percezione
        if rand() < p1
            % Interazione con forte percezione
            % Calcolo della variazione di velocità
            delta_v = attraction_strength * (mean(pos_followers) - pos_leader(1,:));
            % Aggiornamento della posizione del leader
            pos_leader(l,:) = pos_leader(1,:) + delta_v;
     
            % Calcolo della direzione della variazione di velocità
            delta_v = attraction_strength * (mean(pos_followers) - pos_leader(l,:));
            % Aggiornamento della posizione del leader
            pos_leader(l,:) = pos_leader(l,:) + delta_v;
        elseif rand() < p2
            % Calcolo variazione velocità
            % Introduzione di una piccola variazione casuale
            delta_v = 0.01 * randn(1, 2); % Variazione casuale con media zero e deviazione standard 0.01
            % Aggiornamento della posizione del leader
            pos_leader(l,:) = pos_leader(l,:) + delta_v;
        
            % Calcolo della direzione della variazione di velocità
            delta_v = repulsion_strength * (pos_leader(l,:) - mean(pos_followers));
            % Aggiornamento della posizione del leader
            pos_leader(l,:) = pos_leader(l,:) + delta_v;
        end
    end

    % Aggiornamento delle posizioni dei leader non accoppiati
    for l = min(L, T)+1:L
        pos_leader(l,:) = pos_leader(l,:) + leader_velocity(l,:);
    end

    % Aggiornamento delle posizioni dei followers
    for t = 1:T
        % Calcolo dell'interazione con i leader per il follower t
        % Calcolo la variazione di velocità del follower in base alla posizione dei leader
        delta_v = repulsion_strength * sum((pos_followers(t,:) - pos_leader) ./ vecnorm(pos_followers(t,:) - pos_leader, 2, 2).^gamma);
        % Aggiornamento della posizione del follower t
        pos_followers(t,:) = pos_followers(t,:) + delta_v;
    end

    % Visualizzazione delle posizioni aggiornate
    for l = 1:L
        plot(pos_leader(l,1), pos_leader(l,2), 'r-', 'LineWidth', 2);
    end
    for t = 1:T
        plot(pos_followers(t,1), pos_followers(t,2), 'b--', 'LineWidth', 1); % Modifica dello stile della linea per i target
    end
    
    % Pausa per visualizzare l'aggiornamento
    pause(0.5);
end
hold off;

% Aggiungi legenda
legend('Leader', 'Follower');

% Visualizzo le traiettorie di leader e targets
figure;
hold on;
%for l = 1:L
    plot3(leader_trajectory(:, l, 1), leader_trajectory(:, l, 2), 1:numel(leader_trajectory(:, l, 1)), 'r-', 'LineWidth', 2);
%end
for t = 1:T
    plot3(follower_trajectory(:, t, 1), follower_trajectory(:, t, 2), 1:numel(follower_trajectory(:, t, 1)), 'b--', 'LineWidth', 1);
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Traiettorie di Leader e Targets');
view(3);
hold off;

% Aggiungi legenda
legend('Traiettorie dei Leader', 'Traiettorie dei Follower');

% Funzione H
function force = H(distance, K, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = K ./ ((delta^2 + distance.^2).^gamma);
end

% complessità di: O(num_iterations * (L + T))