# LodView (lodview-ng)

LodView is a Java web application based on Spring Boot and Apache Jena that provides W3C-compliant IRI dereferencing for publishing RDF data as Linked Open Data.

This fork ([teamdigitale/dati-semantic-lodview](https://github.com/teamdigitale/dati-semantic-lodview)) modernizes the upstream project [LodLive/LodView](https://github.com/LodLive/LodView) by porting it to:

- **Java 21** (Eclipse Temurin)
- **Spring Boot 3.x** with embedded Tomcat
- **Gradle** as the build system
- An executable artifact runnable with `java -jar` (no external Tomcat required)

> **Note for users of the upstream version with Tomcat:** previous LodView releases required deploying a WAR file onto Apache Tomcat 9. This fork uses Spring Boot with embedded Tomcat: running `java -jar lodview.war` is enough. Deployment to an external application server (Tomcat, Jetty, etc.) is **not supported nor recommended**.

---

## Prerequisites

- A reachable SPARQL endpoint (e.g. Virtuoso, Fuseki, GraphDB)
- Ubuntu 22.04+ (for native installation) or Docker

---

## Option 1: Docker (recommended)

Official images are published on GitHub Container Registry. This is the recommended installation mode.

### 1.1 Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

### 1.2 Create the environment file

Create a `lodview.env` file and **customize the values** for your environment:

```env
# === SPARQL ENDPOINT (REQUIRED) ===
# Set the URL of your SPARQL endpoint (e.g. Virtuoso, Fuseki, GraphDB)
LodViewendpoint=<PUBLIC_SPARQL_ENDPOINT_URL>
LodViewendpointInternal=<INTERNAL_SPARQL_ENDPOINT_URL>
LodViewendpointType=virtuoso

# === NAMESPACE ===
LodViewIRInamespace=<BASE_IRI_NAMESPACE>

# === HOME PAGE ===
LodViewhomeUrl=<HOME_PAGE_URL>
LodViewhomeTitle=<HOME_PAGE_TITLE>
LodViewhomeDescription=<HOME_PAGE_DESCRIPTION>
LodViewhomeContent=<HOME_PAGE_CONTENT>

# === OPTIONAL ===
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

> **Note on Docker networking:** if the SPARQL endpoint runs on the same host as the container, you cannot use `localhost` from inside the container. Use `host.docker.internal` (Docker Desktop) or the actual host machine IP. Alternatively, start the container with `--network host` (in that case the `-p` flag is not needed).

### 1.3 Start the container

```bash
docker run -d \
  --name lodview \
  --restart unless-stopped \
  -p 8080:8080 \
  --env-file lodview.env \
  ghcr.io/teamdigitale/dati-semantic-lodview:latest
```

Verify:

```bash
docker logs lodview
# The application is available on http://localhost:8080
```

---

## Option 2: Native installation with systemd

This mode builds from source and runs the service as a system service.

### 2.1 Install Java 21

```bash
sudo apt update
sudo apt install -y eclipse-temurin-21-jdk
```

If the package is not available, add the Adoptium repository:

```bash
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y temurin-21-jdk
```

Verify:

```bash
java -version
# openjdk version "21.x.x" ...
```

### 2.2 Fetch the sources and build

```bash
sudo useradd -r -s /usr/sbin/nologin lodview

cd /opt
sudo git clone https://github.com/teamdigitale/dati-semantic-lodview.git
cd dati-semantic-lodview

# Build without tests
sudo ./gradlew clean build -x test

# Copy the artifact to the installation directory
sudo mkdir -p /opt/lodview
sudo cp build/libs/lodview.war /opt/lodview/lodview.war
sudo chown -R lodview:lodview /opt/lodview
```

**(Optional)** Remove the sources after the build to save space:

```bash
sudo rm -rf /opt/dati-semantic-lodview
```

### 2.3 Create the environment file

Create `/opt/lodview/lodview.env` and **customize the values** (same format as for Docker):

```env
# === SPARQL ENDPOINT (REQUIRED) ===
# Set the URL of your SPARQL endpoint (e.g. Virtuoso, Fuseki, GraphDB)
LodViewendpoint=<PUBLIC_SPARQL_ENDPOINT_URL>
LodViewendpointInternal=<INTERNAL_SPARQL_ENDPOINT_URL>
LodViewendpointType=virtuoso

# === NAMESPACE ===
LodViewIRInamespace=<BASE_IRI_NAMESPACE>

# === HOME PAGE ===
LodViewhomeUrl=<HOME_PAGE_URL>
LodViewhomeTitle=<HOME_PAGE_TITLE>
LodViewhomeDescription=<HOME_PAGE_DESCRIPTION>
LodViewhomeContent=<HOME_PAGE_CONTENT>

# === OPTIONAL ===
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

> **Note:** an external environment file is used instead of inline `Environment=` directives in the `.service` unit because several values (titles, descriptions) contain spaces and special characters that would require complex quoting under systemd.

### 2.4 Create the systemd unit file

Create `/etc/systemd/system/lodview.service`:

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

### 2.5 Start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable lodview
sudo systemctl start lodview

# Check status
sudo systemctl status lodview

# The service is available on http://localhost:8080
```

---

## Environment variables

The environment variables override the values defined in the bundled `conf.ttl` file. The prefix is `LodView` followed by the name of the configuration property.

| Variable | Description | Default |
|---|---|---|
| `LodViewendpoint` | Public SPARQL endpoint URL | `http://localhost:8890/sparql` |
| `LodViewendpointInternal` | Internal SPARQL endpoint URL (if different from the public one) | `http://localhost:8890/sparql` (from `conf.ttl`) |
| `LodViewendpointType` | Endpoint type (`virtuoso` or empty) | empty |
| `LodViewIRInamespace` | Base IRI namespace | `https://w3id.org/italia` |
| `LodViewhttpRedirectSuffix` | HTTP 303 redirect suffix (e.g. `.html`) | `.html` |
| `LodViewhomeUrl` | Home page URL | - |
| `LodViewhomeTitle` | Home page title | - |
| `LodViewhomeDescription` | Home page description | - |
| `LodViewhomeContent` | Home page textual content | - |
| `LodViewpreferredLanguage` | Preferred language (e.g. `it`, `en`) | `it` |
| `LodViewpublicUrlPrefix` | Public URL prefix (`auto` for automatic detection) | `auto` |
| `LodViewstaticResourceURL` | Static resources URL (`auto` for automatic detection) | `auto` |
| `LodViewforceIriEncoding` | IRI encoding handling (`auto`, `decode`, `encode`) | `auto` |
| `LodViewredirectionStrategy` | Redirect strategy (`pubby` or empty) | empty |
| `LodViewdefaultInverseBehaviour` | Inverse relations: `open` or `close` | `close` |
| `LodViewauthUsername` | Username for SPARQL endpoint authentication | empty |
| `LodViewauthPassword` | Password for SPARQL endpoint authentication | empty |
| `LodViewlicense` | License HTML text (shown at the bottom of the page) | empty |

---

## Note for users of Apache HTTPD as a reverse proxy

If you already have an Apache HTTPD reverse proxy configured for the previous version (external Tomcat), keep in mind that the architectural model has changed:

- **Before:** Apache talked to a single Tomcat process on a single port, routing requests by path (e.g. `/lodview`, `/lode`, `/webvowl`).
- **Now:** each visualizer is an autonomous Spring Boot process listening on its own local port.

All applications start on port **8080** by default. If you run multiple visualizers on the same machine you need to assign different ports via the standard Spring Boot `SERVER_PORT` environment variable:

| Application | Suggested `SERVER_PORT` |
|---|---|
| LodView | `8080` (default) |
| LODE | `8081` |
| WebVOWL | `8082` |

Add the following to each application's `.env` file (both for Docker and systemd):

```env
SERVER_PORT=8080
```

For Docker, map the ports accordingly: `-p 8080:8080`, `-p 8081:8081`, `-p 8082:8082`.

Apache can keep acting as a reverse proxy, but the backend is no longer a single shared Tomcat.

### Dedicated virtual hosts

If you use a dedicated domain (or subdomain) for each visualizer, the configuration is minimal:

```apache
<VirtualHost *:443>
    ServerName lodview.example.com

    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"

    # ... SSL configuration ...
</VirtualHost>
```

### Path-based proxy (multiple visualizers on the same domain)

If you want to expose multiple visualizers under different paths of the same domain (e.g. `example.com/lodview`, `example.com/lode`, `example.com/webvowl`), you need to configure for each application:

1. **`SERVER_PORT`** — a different local port for each visualizer (see table above)
2. **`SERVER_SERVLET_CONTEXT_PATH`** — the sub-path on which the application must serve

Both are standard Spring Boot properties supported by all three applications without code changes.

Example `.env` file for LodView in path-based mode:

```env
SERVER_PORT=8080
SERVER_SERVLET_CONTEXT_PATH=/lodview
```

Full Apache configuration for all three visualizers:

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

    # ... SSL configuration ...
</VirtualHost>
```

> **Note:** without `SERVER_SERVLET_CONTEXT_PATH`, Spring Boot applications serve on `/` (root) and the path-based proxy would not work correctly. Without `SERVER_PORT`, all applications would try to use port 8080.

---

## Ports

| Port | Protocol | Description |
|---|---|---|
| 8080 | HTTP | LodView web interface (default, configurable via `SERVER_PORT`) |
