# The Herding Problem

Questo progetto è una simulazione del "problema di raduno" in Matlab, sviluppata per una tesi triennale in Informatica presso l'Università degli Studi di Napoli Federico II. La simulazione è basata su modelli di interazione sociale in cui leader e target si muovono in base a forze di attrazione e repulsione. 

## Autore

**Lucia Brando**

## Relatore

- **Daniele Castorina**

## Co-relatori

- **Giacomo Ascione**
- **Davide Fiore**

## Descrizione del Codice

Il codice implementa una simulazione in cui:

1. **Leader** e **target** si muovono in uno spazio bidimensionale, soggetti a forze che modellano il comportamento di raduno.
2. I target sono attratti verso il centro di massa del gruppo, mentre i leader cercano di radunare i target più lontani.
3. Diverse forze di attrazione e repulsione governano le dinamiche della simulazione:
   - Attrazione dei leader verso i target
   - Repulsione dei target e dei leader dal centro di massa
   - Repulsione dei target dai leader

Il codice varia i parametri della simulazione, inclusi:
- Numero di leader e target
- Intensità delle forze di attrazione e repulsione (parametro \(\alpha\))
- Iterazioni del processo di raduno.

### Parametri Principali
- **L_values**: intervallo del numero di leader
- **T_values**: intervallo del numero di target
- **alpha_values**: intensità della repulsione
- **num_iterations**: numero di iterazioni per ciascuna configurazione.

### Risultati
Al termine della simulazione, la dispersione dei target viene calcolata come media delle distanze rispetto al centro di massa. I risultati sono rappresentati graficamente con un grafico di contorno, mostrando come la dispersione dei target cambia in funzione dell'intensità di repulsione (\(\alpha\)) e del numero di target.

### Visualizzazione

Nella cartella `IMMAGINI` troverai diverse figure che illustrano i risultati della simulazione e i grafici di interazione globale generati dal codice. 

---

## Funzioni Principali

- **H**: funzione per il calcolo della forza di interazione tra i target in base alla distanza.

## Installazione e Uso

1. Clona la repository:
    ```bash
    git clone https://github.com/lbrando/The-herding-problem.git
    ```

2. Esegui il codice in un ambiente Matlab compatibile.

---

Questo progetto rappresenta un primo studio sul problema del raduno per esplorare le dinamiche di interazione sociale in scenari simulati, in cui leader e target cooperano attraverso forze di attrazione e repulsione.
