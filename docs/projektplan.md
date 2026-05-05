# Projektplan — Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab  
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**Organisation:** YH Enköping — IT-säkerhetsingenjör (ITS24)  
**Kurs:** Virtualiseringsteknik och automation  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  

---

## Innehållsförteckning

1. [Syfte och mål](#1-syfte-och-mål)
2. [Teknisk översikt](#2-teknisk-översikt)
3. [Systemarkitektur](#3-systemarkitektur)
4. [VM-specifikation](#4-vm-specifikation)
5. [Mappstruktur](#5-mappstruktur)
6. [Trafikflöde](#6-trafikflöde)
7. [Säkerhetsstrategi](#7-säkerhetsstrategi)
8. [Ansible-roller](#8-ansible-roller)
9. [Fasplanering](#9-fasplanering)
10. [Designkrav](#10-designkrav)
11. [Förväntat resultat](#11-förväntat-resultat)

---

## 1. Syfte och mål

Secure-Infra-Lab är ett infrastrukturprojekt som demonstrerar
hur en komplett, säkerhetshärdad webbmiljö kan automatiseras
och driftsättas reproducerbart med moderna DevOps-verktyg.

Projektet visar att infrastruktur kan beskrivas som kod —
vilket eliminerar manuella konfigurationsfel, säkerställer
identiska miljöer vid varje driftsättning och möjliggör
snabb återställning vid driftstörning.

**Projektets tre huvudmål:**

**Automatisering** — Hela infrastrukturen, från tomma
virtuella maskiner till ett fungerande webbsystem med
databas och säkerhetsövervakning, driftsätts med ett
enda kommando utan manuella ingrepp.

**Säkerhet** — Varje komponent är härdad enligt
principen Defense-in-Depth. Nätverkssegmentering,
brandväggsregler, SSH-härdning och intrångsdetektering
implementeras som kod och tillämpas konsekvent på
samtliga noder.

**Reproducerbarhet** — Miljön är fullständigt
reproducerbar. Förstörs infrastrukturen återbyggs den
identiskt. Detta verifieras automatiskt av
testskript som körs mot den färdiga miljön.

---

## 2. Teknisk översikt

Infrastrukturen består av sex virtuella maskiner som
tillsammans bildar ett komplett webbsystem med
lastbalansering, redundans och centraliserad
säkerhetsövervakning.

| Verktyg | Version | Syfte |
|---------|---------|-------|
| Vagrant | 2.x | Infrastructure-as-Code, VM-hantering |
| VirtualBox | 7.x | Hypervisor |
| Ansible | 2.17.x | Konfigurationshantering |
| Ubuntu | 22.04 LTS | Operativsystem (alla VMs) |
| Flask | 3.x | Python-webbapplikation |
| Gunicorn | 21.x | WSGI-server |
| nginx | 1.18.x | Reverse proxy, lastbalanserare |
| PostgreSQL | 14.x | Relationsdatabas |
| Wazuh | 4.x | SIEM/HIDS, säkerhetsövervakning |

---

## 3. Systemarkitektur

Systemet följer en 3-tier-arkitektur med tydlig separation
mellan presentationslager, applikationslager och datalager.
Kommunikation mellan lager är explicit tillåten — aldrig
implicit. Detta begränsar en angripares rörelseförmåga
avsevärt vid en eventuell kompromiss.

```
Windows-laptop (host)
         |
         | :8080 (port forwarding)
         |
+--------v-----------------------------------------------+
|         Privat natverk 192.168.56.0/24                 |
|                                                        |
|  +---------------------------------------------------+ |
|  |  control (.10)                                    | |
|  |  Ansible control node -- ansible_connection=local | |
|  +--------------------+------------------------------+ |
|                       | SSH (krypterad kanal)          |
|                       v                                |
|  +---------------------------------------------------+ |
|  |  nginx (.11) -- Reverse proxy, round-robin :80    | |
|  +------------------+--------------------------------+ |
|                     | round-robin lastbalansering      |
|             +-------+-------+                          |
|             v               v                          |
|  +---------------+  +---------------+                  |
|  |  web1 (.12)   |  |  web2 (.13)   |                  |
|  |  Flask +      |  |  Flask +      |                  |
|  |  Gunicorn     |  |  Gunicorn     |                  |
|  |  "Server 1"   |  |  "Server 2"   |                  |
|  +-------+-------+  +-------+-------+                  |
|          +---------------+                             |
|                          v                             |
|  +---------------------------------------------------+ |
|  |  database (.14) -- PostgreSQL                     | |
|  |  UFW: tillater enbart web1 + web2 pa port 5432    | |
|  +---------------------------------------------------+ |
|                                                        |
|  +---------------------------------------------------+ |
|  |  monitor (.15) -- Wazuh Manager + Dashboard       | |
|  |  SIEM/HIDS -- centraliserad sakerhetsovervakning  | |
|  +---------------------------------------------------+ |
+--------------------------------------------------------+
```

**Presentationslager** — nginx på .11 är den enda
komponenten med publik ingångspunkt. All inkommande
trafik passerar genom nginx som distribuerar
förfrågningar till applikationslagret via round-robin.

**Applikationslager** — web1 (.12) och web2 (.13) kör
Flask-applikationen bakom Gunicorn. Båda noderna är
identiskt konfigurerade men identifieras individuellt
via variabeln `server_name`. Redundansen säkerställer
att systemet fortsätter fungera även om en nod fallerar.

**Datalager** — PostgreSQL på .14 är strikt isolerad.
UFW-regler tillåter enbart anslutningar från web1 och
web2 på port 5432. Inga andra noder eller externa
system kan nå databasen direkt.

**Övervakningsnod** — Wazuh Manager på .15 samlar in
säkerhetshändelser från samtliga noder i realtid.

---

## 4. VM-specifikation

| VM | IP-adress | Roll | RAM | Port forwarding |
|---|---|---|---|---|
| control | 192.168.56.10 | Ansible control node | 1024 MB | — |
| nginx | 192.168.56.11 | Reverse proxy, lastbalanserare | 512 MB | :80 → host:8080 |
| web1 | 192.168.56.12 | Flask + Gunicorn (Server 1) | 512 MB | — |
| web2 | 192.168.56.13 | Flask + Gunicorn (Server 2) | 512 MB | — |
| database | 192.168.56.14 | PostgreSQL | 512 MB | — |
| monitor | 192.168.56.15 | Wazuh Manager + Dashboard | 2048 MB | — |
| **Totalt** | | | **5120 MB** | |

---

## 5. Mappstruktur

```
Secure-Infra-Lab/
|
+-- .gitattributes                # Enforces LF line endings
+-- .gitignore                    # Excludes secrets + .vagrant/
+-- docs/
|   +-- projektplan.md            # Detta dokument
|   +-- log.md                    # Detaljerad projektlogg
|
+-- vagrant/
|   +-- Vagrantfile               # Definierar alla 6 VMs
|   +-- secrets.yml               # GITIGNORERAD -- credentials
|
+-- ansible/
    +-- ansible.cfg               # Ansible configuration
    +-- inventory.ini             # Server inventory
    +-- site.yml                  # Master playbook
    |
    +-- vars/
    |   +-- vars.yml              # Shared variables (IPs, ports)
    |
    +-- roles/
        +-- security_hardening/   # SSH hardening, fail2ban, auditd
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/sshd_config.j2
        |
        +-- flask/                # Flask + Gunicorn + systemd
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/flask.service.j2
        |   +-- files/app.py
        |   +-- vars/main.yml
        |
        +-- nginx/                # Reverse proxy, load balancer
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/nginx.conf.j2
        |
        +-- database/             # PostgreSQL + UFW
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/schema.sql.j2
        |
        +-- wazuh_agent/          # Wazuh SIEM agent
            +-- tasks/main.yml
```

---

## 6. Trafikflöde

Sekvensen nedan beskriver en komplett förfrågningscykel
från klientens webbläsare till databasen och tillbaka:

```
1. Klient            -->  http://localhost:8080/visit
2. Port forwarding   -->  nginx:80
3. nginx round-robin -->  web1:5000 ELLER web2:5000
4. Flask             -->  INSERT + SELECT mot database:5432
5. PostgreSQL        -->  Returnerar senaste 5 besök
6. Flask             -->  Bygger HTTP-svar med server_name
7. Svar              -->  Tillbaka till klientens webbläsare
```

Växlingen mellan web1 och web2 i steg 3 är synlig för
slutanvändaren — svaret visar antingen "Server 1" eller
"Server 2". Detta är ett konkret bevis på att
lastbalanseringen fungerar korrekt.

---

## 7. Säkerhetsstrategi

Systemet implementerar Defense-in-Depth — en
säkerhetsstrategi där flera oberoende skyddslager
samverkar. Om ett lager kringgås begränsar nästa lager
skadan. Varje lager är implementerat som kod och
tillämpas automatiskt vid varje driftsättning.

### Lager 1 — Nätverkssegmentering

Endast nginx exponeras mot omvärlden via port forwarding.
web1, web2, database och monitor saknar helt publika
ingångspunkter. En angripare som identifierar
systemet utifrån ser enbart nginx.

### Lager 2 — Brandvägg (UFW)

UFW på database-noden tillåter inkommande TCP-trafik
på port 5432 enbart från 192.168.56.12 (web1) och
192.168.56.13 (web2). Samtliga övriga anslutningar
blockeras.

`listen_addresses` i PostgreSQL konfigureras med
explicita IP-adresser — aldrig med wildcard `'*'`.
Detta är ett medvetet designval som ger ett extra
skyddslager även om brandväggsreglerna kringgås.

### Lager 3 — SSH-härdning

Följande restriktioner tillämpas på samtliga noder
via Ansible-rollen `security_hardening`:

- `PermitRootLogin no` — direkt root-åtkomst via SSH förbjuden
- `PasswordAuthentication no` — enbart SSH-nyckelautentisering
- `MaxAuthTries 3` — maximalt tre autentiseringsförsök
- `AllowUsers vagrant` — enbart definierade användare tillåts
- `ClientAliveInterval 300` — inaktiva sessioner termineras

### Lager 4 — Intrångsprevention (fail2ban)

fail2ban övervakar autentiseringsloggar i realtid och
blockerar automatiskt IP-adresser som uppvisar mönster
karakteristiska för brute-force-attacker mot SSH.

### Lager 5 — Revision och övervakning (auditd + Wazuh)

auditd loggar systemhändelser lokalt på varje nod —
inloggningar, filmodifieringar, privilegieeskaleringar
och processexekveringar. Wazuh-agenter på samtliga
noder vidarebefordrar dessa händelser till Wazuh Manager
på monitor (.15) för centraliserad analys och
realtidsvarning.

---

## 8. Ansible-roller

### security_hardening — samtliga noder

Etablerar en konsekvent säkerhetsbaslinje på alla sex
noder. Körs alltid först i site.yml för att säkerställa
att grundläggande härdning är på plats innan
applikationstjänster installeras.

Dokumentation: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/

### database — database-noden

Installerar och konfigurerar PostgreSQL. Skapar
applikationsanvändare med minsta möjliga privilegium.
Tillämpar UFW-regler och konfigurerar `listen_addresses`
med explicita IP-adresser. Skapar visits-tabellen via
`schema.sql.j2`.

Dokumentation: https://www.postgresql.org/docs/

### flask — web1 och web2

En gemensam roll hanterar båda webservrarna.
Konfigurationsskillnaden — `server_name` — injiceras
som en Ansible-variabel. Installerar Flask och
Gunicorn, distribuerar `app.py` och registrerar
en systemd-tjänst som startar om applikationen
automatiskt vid krasch.

Dokumentation: https://flask.palletsprojects.com/

### nginx — nginx-noden

Konfigurerar nginx som reverse proxy med round-robin
lastbalansering mot web1 och web2. Distribuerar
`nginx.conf.j2` med upstream-block och proxy-headers.

Dokumentation: https://nginx.org/en/docs/

### wazuh_agent — samtliga noder (ej monitor)

Installerar och registrerar Wazuh-agenten på alla
fem applikationsnoder. Agenten rapporterar
säkerhetshändelser till Wazuh Manager på monitor (.15).

Dokumentation: https://documentation.wazuh.com/

---

## 9. Fasplanering

| Fas | Leverabel |
|-----|-----------|
| Fas 1 | Vagrantfile — sex reproducerbara VMs |
| Fas 2 | Ansible-konfiguration (ansible.cfg, inventory.ini, site.yml) |
| Fas 3 | security_hardening-rollen — SSH, fail2ban, auditd |
| Fas 4 | database-rollen — PostgreSQL, UFW, schema |
| Fas 5 | flask-rollen — Flask, Gunicorn, systemd |
| Fas 6 | nginx-rollen — reverse proxy, lastbalansering |
| Fas 7 | wazuh_agent-rollen — SIEM-integration |
| Fas 8 | Automatiserade verifieringsskript (verify.sh + verify_host.ps1) |
| Fas 9 | Rapport och presentation |

---

## 10. Designkrav

Följande krav styr samtliga arkitektur- och
implementationsbeslut i projektet:

**Reproducerbarhet** — Kommandot
`vagrant destroy -f && vagrant up && ansible-playbook site.yml`
skall producera en identisk, fullt fungerande miljö
vid varje körning — utan manuella ingrepp.

**Idempotens** — Ansible-playbooken skall kunna köras
upprepade gånger utan oönskade sidoeffekter. En andra
körning mot en redan konfigurerad miljö skall resultera
i `changed=0` på samtliga noder.

**Minsta privilegium** — Varje komponent tilldelas
exakt de rättigheter som krävs för sin funktion.
Databasanvändaren är begränsad till SELECT och INSERT
på visits-tabellen. Inga komponenter körs som root.

**Explicit nätverksåtkomst** — Kommunikation mellan
lager tillåts explicit via UFW-regler och PostgreSQL
`listen_addresses`. Inga implicita nätverkstillstånd
accepteras.

**Spårbarhet** — Samtliga designbeslut dokumenteras
med motivering i `docs/log.md`. En ny teammedlem
eller teknisk granskare skall kunna förstå varför
varje beslut fattades — inte enbart hur det
implementerades.

**Skalbarhet** — Arkitekturen möjliggör horisontell
skalning av applikationslagret. Ytterligare webservrar
kan läggas till genom att uppdatera nginx
upstream-konfigurationen utan ändringar i övriga
komponenter.

---

## 11. Förväntat resultat

### Systembeskrivning

När samtliga faser är genomförda kommer infrastrukturen
att utgöra ett komplett, automatiserat och
säkerhetshärdat webbsystem. En klient som ansluter till
`http://localhost:8080/visit` tar emot ett svar från
antingen "Server 1" eller "Server 2" — beroende på
vilken nod nginx dirigerar förfrågan till. Varje besök
registreras i databasen och de fem senaste besöken
presenteras i svaret. Systemet är fullständigt
automatiserat och reproducerbart från noll med ett
enda kommando.

### Teknisk verifieringslista

Samtliga tester verifieras automatiskt av
`verify.sh` (Linux) och `verify_host.ps1` (Windows):

| # | Test | Förväntat resultat |
|---|------|--------------------|
| 1 | nginx svarar på port 8080 | HTTP 200 OK |
| 2 | /visit returnerar "Server 1" eller "Server 2" | Applikationslagret nås |
| 3 | Upprepade anrop till /visit växlar mellan Server 1 och Server 2 | Round-robin bekräftad |
| 4 | web1 når database på port 5432 | Anslutning etablerad |
| 5 | web2 når database på port 5432 | Anslutning etablerad |
| 6 | Extern klient når ej database på port 5432 | Anslutning nekad (UFW) |
| 7 | flask-tjänsten körs på web1 | active (running) |
| 8 | flask-tjänsten körs på web2 | active (running) |
| 9 | fail2ban körs på samtliga noder | active (running) |
| 10 | auditd körs på samtliga noder | active (running) |
| 11 | PasswordAuthentication inaktiverad | no |
| 12 | PermitRootLogin inaktiverad | no |
| 13 | Wazuh-agent aktiv på samtliga noder | connected |
| 14 | PostgreSQL lyssnar ej på 0.0.0.0 | Enbart web1 + web2 IPs |

---

*Detaljerad dokumentation av implementationsarbetet
finns i `docs/log.md`.*