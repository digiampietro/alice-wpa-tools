                           ALICE-WPA-TOOLS
                      versione 1.1 09/09/2011
                           ===============

    Autore:    Valerio Di Giampietro
    Siti web:  http://va.ler.io
	       http://www.audiocast.it
    Email:     v@ler.io  
	       (l'indirizzo email, da vero geek, e' valido!)
    Twitter:   http://twitter.com/valerio
    Facebook:  http://facebook.com/digiampietro
    LinkedIn:  http://it.linkedin.com/in/digiampietro
    Google+:   https://plus.google.com/114757231905567440664

In questo archivio sono presenti una serie di script perl che
implementano gli algoritmi per la generazione delle chiavi WPA di
default dei router Alice/Pirelli con il firmware AGPF; questi
algoritmi sono basati sulla descrizione che si trova all'url:
http://wifiresearchers.wordpress.com/2010/06/02/alice-agpf-lalgoritmo/

Per comodita' ciascun script perl e' stato anche compilato con il
"Perl Packager" in modo da poterlo eseguire su un PC Windows senza
dover necessariamente installare il perl.

Gli script vengono rilasciati in forma sorgente con licenza di
utilizzo GNU 2.0 (si veda il file license.txt) che, sostanzialmente,
vuol dire che tali programmi si possono liberamente utilizzare,
modificare e ridistribuire a patto che vengano garantite 2 cose:

  1. la riga di copyright presente nei sorgenti venga mantenuta

  2. la distribuzioni dei sorgenti modificati deve avvenire con lo
     stesso tipo di licenza (i sorgenti modificati devono
     essere anch'essi disponibili)

Gli script presenti in questo archivio non richiedono installazione,
vanno decompressi in una directory a scelta e vanno poi lanciati da
tale directory da riga di comando. Gli script sono i seguenti:

listwpa.sh e listwpa.bat
------------------------

  listwpa.sh oppure su windows listwpa.bat sono gli unici due script
  che interessano i lamers:

  esempio su linux: ./listwpa.sh  Alice-18134568
  esempio su PC:      listwpa.bat Alice-18134568

  questi script utilizzano gli altri per cercare la wpa di default,
  l'output e' un elenco di wpa possibili che andranno provate una per
  una. Se tale elenco e' vuoto vuol dire che non e' stato possibile
  trovare nessuna wpa.
  
ssid2mac.pl
-----------
  ssid2mac.pl - dato un SSID Alice trova i possibili mac address della scheda
  ethernet interna

  esempi:   ./ssid2mac.pl  Alice-12345678

ssid2ser.pl
-----------
  ssid2ser.pl - dato un SSID Alice trova i possibili seriali basandosi
  su un file di configurazione che fornisce i valori di K e Q

  esempi: ./ssid2ser.pl -s Alice-54887113  -c config.txt
          ./ssid2ser.pl -s Alice-54887113  -n "548,67903,8,52420689,002553"

  il formato del comando e' il seguente:
     ./ssid2ser.pl -s ssid {-c config.txt|-n config-string} [-d] [-m mac]
                   [-v] [-e] 

     -d       opzionale, print debugging information
     -m       mac address, opzionale, se presente restituisce il seriale
              solo se il mac fornito e' compatibile con quello del config.txt
     -n       utilizza la stringa fornita come fosse l'unica riga presente
              nel file config.txt. L'opzione -n oppure -c deve essere sempre
              presente
     -v       verbose, stampa un po' di informazioni
     -e       extended, usa anche i magic numbers delle serie precedenti 
              e successive

   Da notare che il parametro -m e' fortemente consigliato perche' i
   dati nel config.txt sono riferiti ad una determinata serie di mac
   address.  

   Il parametro -n e' utile per far generare il seriale esattamente
   con i valori di K e Q desiderati senza fornire un file di
   configurazione config.txt. La stringa passata all'opzione -n deve
   essere dello stesso formato delle righe di config.txt

   L'opzione -e estende l'utilizzo del file config.txt in modo da
   utilizzare le serie Q e K relative non solo all'SSID indicato, ma
   anche alle serie precedenti e successive di tale SSID. Questa
   opzione e' automatica qualora nel file config.txt non ci siano i
   dati per l'SSID indicato.

sermac2wpa.pl
-------------
  sermac2wpa.pl - dato il seriale ed il mac address genera la password
  wpa di default

  esempio: ./sermac2wpa.pl -s 67902X0000001  -m 6487d70ae9f1

  il formato del comando e' il seguente:
     sermac2wpa.pl [-q] -s serial -m mac-address 
     -q   quite operation, solo le password

  l'opzione -q stampa solo le password senza nessun'altra informazione.

alice-mn.pl
-----------
  alice-mn.pl - noti SSID, seriale e mac permette di generare la riga
  contenente i magic numbers da inserire nel config.txt. Comando utile
  per aggiungere informazioni al config.txt quando la wpa e' nota

  esempio: ./alice-mn.pl -s Alice-18134568 -n 67901X0098247 -m 00268D007828

  l'opzione -d stampa alcune informazioni di debugging.

alicewpa-dict.pl
----------------
  genera il dizionario delle possibili password per un determinato mac
  address ed un determinato range di numeri seriali. Questo e' utile
  per tentare un attacco con aircrack dopo che si e' catturato una
  sessione di handshake tra un client e l'access point.
  
  esempio: ./alicewpa-dict.pl -s 67902X0000001 -e 67902X0999999 -m 6487d70ae9f1

  l'opzione -v (verbose), che non va bene per aircrack, puo' essere utile per
  individuare rapidamente mac address e seriale una volta che si e'
  scoperta la password wpa.

  da notare che la prima parte del seriale (quella prima della X) deve
  essere la stessa per l'opzione -s (start) e -e (end)

gendict.sh
----------

  Dato un certo SSID Alice genera un dizionario per attacco con
  aircrack molto completo, che include tutti i mac address compatibili
  con l'SSID e tutte le serie di seriali note. Il dizionario puo'
  essere piuttosto grande ma e' abbastanza esaustivo. Da notare,
  comunque, che viene considerata sempre a '0' la prima cifra della
  seconda parte del seriale (permette di diminuire di 10 volte le
  dimensioni del file dizionario ed i conseguenti tempi di crack;
  sperimentalmente non mi e' mai capitato di vedere quel valore
  diverso da '0')

  esempio: ./gendict.sh Alice-18145613

  nell'esempio precedente viene creato il file Alice-18145613.txt
  contenente il dizionario
  
