# Video Stabilization

Progetto scritto in **MatLab** per la [stabilizzazione](https://link.springer.com/referenceworkentry/10.1007%2F978-0-387-78414-4_76) di un video tramite una serie operazioni (**cross-correlation**, **rotazione**, **traslazione**... ) applicate su ogni frame del filmato seguendo un' `Ancora` di riferimento (ovvero una porzione selezionata dall'utente sul primo frame).

Considerazioni:

- É stato scelto di stabilizzare l’`Ancora` al centro del frame, in maniera tale da notare meglio la stabilizzazione
- Gli spazi vuoti lasciati dall’imagine traslata vengono riempiti di nero
- Viene assunto che il video sia stato registrato da una persona, e quindi tra un frame e l’altro non ci sono variaizioni di angolo maggiori di 30°

Per maggiori informazioni consultare la relazione all'interno del progetto :smile: