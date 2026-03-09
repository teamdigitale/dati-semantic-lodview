# LodView (lodview-ng)

LodView è un'applicazione web Java basata su Spring Boot e Apache Jena che fornisce IRI dereferencing conforme W3C per la pubblicazione di dati RDF come Linked Open Data.

Questo fork ([teamdigitale/dati-semantic-lodview](https://github.com/teamdigitale/dati-semantic-lodview)) modernizza il progetto originale [LodLive/LodView](https://github.com/LodLive/LodView) portandolo a:

- **Java 21** (Eclipse Temurin)
- **Spring Boot 3.x** con Tomcat embedded
- **Gradle** come build system
- Artifact eseguibile con `java -jar` (niente Tomcat esterno)

> **Nota per chi usa la versione originale con Tomcat:** le versioni precedenti di LodView richiedevano il deploy di un file WAR su Apache Tomcat 9. Questo fork utilizza Spring Boot con Tomcat embedded: è sufficiente eseguire `java -jar lodview.war`. Il deploy su un application server esterno (Tomcat, Jetty, etc.) **non è supportato né consigliato**.

---

## Prerequisiti

- Un endpoint SPARQL raggiungibile (es. Virtuoso, Fuseki, GraphDB)
- Server Ubuntu 22.04+ (per installazione nativa) oppure Docker

---

## Opzione 1: Docker (consigliata)

Le immagini ufficiali sono pubblicate su GitHub Container Registry. Questa è la modalità di installazione consigliata.

### 1.1 Installare Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

### 1.2 Creare il file di environment

Creare il file `lodview.env` e **personalizzare i valori** in base al proprio ambiente:

```env
# === SPARQL ENDPOINT (OBBLIGATORIO) ===
# Inserire l'URL del proprio endpoint SPARQL (es. Virtuoso, Fuseki, GraphDB)
LodViewendpoint=<URL_ENDPOINT_SPARQL_PUBBLICO>
LodViewendpointInternal=<URL_ENDPOINT_SPARQL_INTERNO>
LodViewendpointType=virtuoso

# === NAMESPACE ===
LodViewIRInamespace=<NAMESPACE_IRI_BASE>

# === HOME PAGE ===
LodViewhomeUrl=<URL_HOME_PAGE>
LodViewhomeTitle=<TITOLO_HOME_PAGE>
LodViewhomeDescription=<DESCRIZIONE_HOME_PAGE>
LodViewhomeContent=<CONTENUTO_HOME_PAGE>

# === OPZIONALI ===
LodViewhttpRedirectSuffix=
LodViewpreferredLanguage=it
LodViewpublicUrlPrefix=auto
LodViewstaticResourceURL=auto
LodViewforceIriEncoding=auto
LodViewredirectionStrategy=
LodViewdefaultInverseBehaviour=close
LodViewauthUsername=
LodViewauthPassword=
LodViewlicense=
```

> **Nota sulla rete Docker:** se l'endpoint SPARQL gira sullo stesso host del container, non è possibile usare `localhost` dall'interno del container. Usare `host.docker.internal` (Docker Desktop) oppure l'IP effettivo della macchina host. In alternativa, avviare il container con `--network host` (in tal caso il flag `-p` non è necessario).

### 1.3 Avviare il container

```bash
docker run -d \
  --name lodview \
  --restart unless-stopped \
  -p 8080:8080 \
  --env-file lodview.env \
  ghcr.io/teamdigitale/dati-semantic-lodview:latest
```

Verificare:

```bash
docker logs lodview
# L'applicazione è disponibile su http://localhost:8080
```

---

## Opzione 2: Installazione nativa con systemd

Questa modalità prevede il build dai sorgenti e l'avvio come servizio di sistema.

### 2.1 Installare Java 21

```bash
sudo apt update
sudo apt install -y eclipse-temurin-21-jdk
```

Se il pacchetto non è disponibile, aggiungere il repository Adoptium:

```bash
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y temurin-21-jdk
```

Verificare:

```bash
java -version
# openjdk version "21.x.x" ...
```

### 2.2 Scaricare i sorgenti e buildare

```bash
sudo useradd -r -s /usr/sbin/nologin lodview

cd /opt
sudo git clone https://github.com/teamdigitale/dati-semantic-lodview.git
cd dati-semantic-lodview

# Build senza test
sudo ./gradlew clean build -x test

# Copiare l'artifact nella directory di installazione
sudo mkdir -p /opt/lodview
sudo cp build/libs/lodview.war /opt/lodview/lodview.war
sudo chown -R lodview:lodview /opt/lodview
```

**(Opzionale)** Rimuovere i sorgenti dopo il build per liberare spazio:

```bash
sudo rm -rf /opt/dati-semantic-lodview
```

### 2.3 Creare il file di environment

Creare il file `/opt/lodview/lodview.env` e **personalizzare i valori** (il formato è lo stesso usato per Docker):

```env
# === SPARQL ENDPOINT (OBBLIGATORIO) ===
# Inserire l'URL del proprio endpoint SPARQL (es. Virtuoso, Fuseki, GraphDB)
LodViewendpoint=<URL_ENDPOINT_SPARQL_PUBBLICO>
LodViewendpointInternal=<URL_ENDPOINT_SPARQL_INTERNO>
LodViewendpointType=virtuoso

# === NAMESPACE ===
LodViewIRInamespace=<NAMESPACE_IRI_BASE>

# === HOME PAGE ===
LodViewhomeUrl=<URL_HOME_PAGE>
LodViewhomeTitle=<TITOLO_HOME_PAGE>
LodViewhomeDescription=<DESCRIZIONE_HOME_PAGE>
LodViewhomeContent=<CONTENUTO_HOME_PAGE>

# === OPZIONALI ===
LodViewhttpRedirectSuffix=
LodViewpreferredLanguage=it
LodViewpublicUrlPrefix=auto
LodViewstaticResourceURL=auto
LodViewforceIriEncoding=auto
LodViewredirectionStrategy=
LodViewdefaultInverseBehaviour=close
LodViewauthUsername=
LodViewauthPassword=
LodViewlicense=
```

> **Nota:** si usa un file di environment esterno anziché direttive `Environment=` inline nel file `.service`, perché diversi valori (titoli, descrizioni) contengono spazi e caratteri speciali che richiederebbero quoting complesso in systemd.

### 2.4 Creare il file di servizio systemd

Creare il file `/etc/systemd/system/lodview.service`:

```ini
[Unit]
Description=LodView - Linked Data Browser
After=network.target

[Service]
Type=simple
User=lodview
Group=lodview
WorkingDirectory=/opt/lodview

EnvironmentFile=/opt/lodview/lodview.env
ExecStart=/usr/bin/java -jar /opt/lodview/lodview.war

Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### 2.5 Avviare il servizio

```bash
sudo systemctl daemon-reload
sudo systemctl enable lodview
sudo systemctl start lodview

# Verificare lo stato
sudo systemctl status lodview

# Il servizio è disponibile su http://localhost:8080
```

---

## Variabili d'ambiente

Le variabili d'ambiente sovrascrivono i valori definiti nel file `conf.ttl` interno all'applicazione. Il prefisso è `LodView` seguito dal nome della proprietà nel file di configurazione.

| Variabile | Descrizione | Default |
|---|---|---|
| `LodViewendpoint` | URL dell'endpoint SPARQL pubblico | `http://localhost:8890/sparql` |
| `LodViewendpointInternal` | URL dell'endpoint SPARQL interno (se diverso dal pubblico) | `http://localhost:8890/sparql` (da `conf.ttl`) |
| `LodViewendpointType` | Tipo di endpoint (`virtuoso` o vuoto) | vuoto |
| `LodViewIRInamespace` | Namespace IRI base | `https://w3id.org/italia` |
| `LodViewhttpRedirectSuffix` | Suffisso per redirect HTTP 303 (es. `.html`) | `.html` |
| `LodViewhomeUrl` | URL della home page | - |
| `LodViewhomeTitle` | Titolo della home page | - |
| `LodViewhomeDescription` | Descrizione della home page | - |
| `LodViewhomeContent` | Contenuto testuale della home page | - |
| `LodViewpreferredLanguage` | Lingua preferita (es. `it`, `en`) | `it` |
| `LodViewpublicUrlPrefix` | Prefisso URL pubblico (`auto` per rilevamento automatico) | `auto` |
| `LodViewstaticResourceURL` | URL risorse statiche (`auto` per rilevamento automatico) | `auto` |
| `LodViewforceIriEncoding` | Gestione encoding IRI (`auto`, `decode`, `encode`) | `auto` |
| `LodViewredirectionStrategy` | Strategia redirect (`pubby` o vuoto) | vuoto |
| `LodViewdefaultInverseBehaviour` | Relazioni inverse: `open` o `close` | `close` |
| `LodViewauthUsername` | Username per autenticazione endpoint SPARQL | vuoto |
| `LodViewauthPassword` | Password per autenticazione endpoint SPARQL | vuoto |
| `LodViewlicense` | Testo HTML della licenza (in fondo alla pagina) | vuoto |

---

## Nota per chi usa Apache HTTPD come reverse proxy

Se si dispone già di un reverse proxy Apache HTTPD configurato per la versione precedente (Tomcat esterno), tenere presente che il modello architetturale è cambiato:

- **Prima:** Apache parlava con un unico processo Tomcat su una singola porta, smistando le richieste per path (es. `/lodview`, `/lode`, `/webvowl`).
- **Ora:** ogni visualizzatore è un processo Spring Boot autonomo in ascolto sulla propria porta locale.

Tutte le applicazioni partono di default sulla porta **8080**. Se si eseguono più visualizzatori sulla stessa macchina, è necessario assegnare porte diverse tramite la variabile d'ambiente standard Spring Boot `SERVER_PORT`:

| Applicazione | `SERVER_PORT` suggerita |
|---|---|
| LodView | `8080` (default) |
| LODE | `8081` |
| WebVOWL | `8082` |

Aggiungere nel file `.env` di ciascuna applicazione (sia per Docker che per systemd):

```env
SERVER_PORT=8080
```

Per Docker, mappare di conseguenza: `-p 8080:8080`, `-p 8081:8081`, `-p 8082:8082`.

Apache può continuare a fare reverse proxy, ma il backend non è più un unico Tomcat condiviso.

### Virtual host dedicati

Se si usa un dominio (o sottodominio) dedicato per ogni visualizzatore, la configurazione è minimale:

```apache
<VirtualHost *:443>
    ServerName lodview.example.com

    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    # ... configurazione SSL ...
</VirtualHost>
```

### Path-based proxy (più visualizzatori sullo stesso dominio)

Se si vogliono esporre più visualizzatori sotto path diversi dello stesso dominio (es. `example.com/lodview`, `example.com/lode`, `example.com/webvowl`), è necessario configurare per ciascuna applicazione:

1. **`SERVER_PORT`** — una porta locale diversa per ogni visualizzatore (vedi tabella sopra)
2. **`SERVER_SERVLET_CONTEXT_PATH`** — il sotto-path su cui l'applicazione deve servire

Entrambe sono proprietà standard di Spring Boot, supportate da tutte e tre le applicazioni senza modifiche al codice.

Esempio di file `.env` per LodView in modalità path-based:

```env
SERVER_PORT=8080
SERVER_SERVLET_CONTEXT_PATH=/lodview
```

Configurazione Apache completa per tutti e tre i visualizzatori:

```apache
<VirtualHost *:443>
    ServerName example.com

    ProxyPass /lodview http://localhost:8080/lodview
    ProxyPassReverse /lodview http://localhost:8080/lodview

    ProxyPass /lode http://localhost:8081/lode
    ProxyPassReverse /lode http://localhost:8081/lode

    ProxyPass /webvowl http://localhost:8082/webvowl
    ProxyPassReverse /webvowl http://localhost:8082/webvowl

    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    # ... configurazione SSL ...
</VirtualHost>
```

> **Nota:** senza `SERVER_SERVLET_CONTEXT_PATH`, le applicazioni Spring Boot servono su `/` (root) e il path-based proxy non funzionerebbe correttamente. Senza `SERVER_PORT`, tutte le applicazioni tenterebbero di usare la porta 8080.

---

## Porte

| Porta | Protocollo | Descrizione |
|---|---|---|
| 8080 | HTTP | Interfaccia web LodView (default, configurabile con `SERVER_PORT`) |
