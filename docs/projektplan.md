# Projektplan — Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab  
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**Kurs:** Virtualiseringsteknik och automation — YH Enköping (ITS24)  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  

---

## Innehållsförteckning

1. [Projektbeskrivning](#1-projektbeskrivning)
2. [Systemarkitektur](#2-systemarkitektur)
3. [VM-översikt](#3-vm-översikt)
4. [Mappstruktur](#4-mappstruktur)
5. [Trafikflöde](#5-trafikflöde)
6. [Säkerhetsdesign](#6-säkerhetsdesign)
7. [Ansible-roller](#7-ansible-roller)
8. [Fasplanering](#8-fasplanering)
9. [Designkrav](#9-designkrav)
10. [Förväntat resultat](#10-förväntat-resultat)

---

## 1. Projektbeskrivning

Secure-Infra-Lab är en automatiserad infrastruktur bestående av
sex virtuella maskiner. Projektet demonstrerar hur moderna
DevOps-principer och säkerhetskrav kombineras i en reproducerbar
labbmiljö.

Infrastrukturen kommer att byggas med följande verktyg:

- **Vagrant** — Infrastructure-as-Code för VM-hantering
- **Ansible** — automatiserad konfigurationshantering
- **Flask + Gunicorn** — Python-webbapplikation med WSGI-server
- **nginx** — reverse proxy och lastbalanserare (round-robin)
- **PostgreSQL** — relationsdatabas med nätverkssegmentering
- **Wazuh** — SIEM/HIDS för säkerhetsövervakning

Hela infrastrukturen kommer att vara reproducerbar från noll med
ett enda kommando:

```bash
vagrant destroy -f && vagrant up && ansible-playbook site.yml
```

---

## 2. Systemarkitektur

Systemet följer en 3-tier-arkitektur med tydlig separation mellan
presentationslager, applikationslager och datalager. Varje lager
kommunicerar endast med angränsande lager.

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
|                       | SSH                            |
|                       v                                |
|  +---------------------------------------------------+ |
|  |  nginx (.11) -- Load balancer, round-robin :80    | |
|  +------------------+--------------------------------+ |
|                     | round-robin                      |
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
|  |  UFW: tillater BARA web1 + web2 pa port 5432      | |
|  +---------------------------------------------------+ |
|                                                        |
|  +---------------------------------------------------+ |
|  |  monitor (.15) -- Wazuh Manager + Dashboard       | |
|  |  SIEM/HIDS -- overvakar alla VMs                  | |
|  +---------------------------------------------------+ |
+--------------------------------------------------------+
```

---

## 3. VM-översikt

| VM       | IP-adress      | Roll                        | RAM     | Port forwarding    |
|----------|----------------|-----------------------------|---------|--------------------|
| control  | 192.168.56.10  | Ansible control node        | 1024 MB | —                  |
| nginx    | 192.168.56.11  | Load balancer               | 512 MB  | :80 → host:8080    |
| web1     | 192.168.56.12  | Flask + Gunicorn (Server 1) | 512 MB  | —                  |
| web2     | 192.168.56.13  | Flask + Gunicorn (Server 2) | 512 MB  | —                  |
| database | 192.168.56.14  | PostgreSQL                  | 512 MB  | —                  |
| monitor  | 192.168.56.15  | Wazuh Manager + Dashboard   | 2048 MB | —                  |
| **Totalt** |              |                             | **5120 MB** |                |

---

## 4. Mappstruktur

```
Secure-Infra-Lab/
|
+-- .gitignore                    # Skyddar secrets.yml + .vagrant/
+-- docs/
|   +-- projektplan.md            # Detta dokument
|   +-- log.md                    # Projektlogg — fas for fas
|
+-- vagrant/
|   +-- Vagrantfile               # Definierar alla 6 VMs
|   +-- secrets.yml               # GITIGNORERAD -- losenord
|
+-- ansible/
    +-- ansible.cfg               # Ansible-konfiguration
    +-- inventory.ini             # Lista pa alla 6 servrar
    +-- site.yml                  # Master-playbook
    |
    +-- vars/
    |   +-- vars.yml              # Delade variabler (IP, portar)
    |
    +-- roles/
        +-- security_hardening/   # SSH-hardning, fail2ban, auditd
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
        +-- nginx/                # Load balancer
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/nginx.conf.j2
        |
        +-- database/             # PostgreSQL + UFW
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/schema.sql.j2
        |
        +-- wazuh_agent/          # Wazuh SIEM-agent
            +-- tasks/main.yml
```

---

## 5. Trafikflöde

Nedanstående sekvens beskriver vad som händer när en användare
besöker `http://localhost:8080/visit`:

```
1. Webbläsare        -->  localhost:8080
2. Port forwarding   -->  nginx:80
3. nginx round-robin -->  web1:5000 ELLER web2:5000
4. Flask             -->  frågar PostgreSQL på database:5432
5. PostgreSQL        -->  svarar med senaste 5 besök
6. Flask             -->  bygger svar med server_name
7. Svar              -->  tillbaka till webbläsaren
```

Växlingen mellan web1 och web2 i steg 3 bevisar att
lastbalansering fungerar korrekt.

---

## 6. Säkerhetsdesign

Systemet kommer att implementera Defense-in-Depth — flera
oberoende säkerhetslager där varje lager kompenserar om ett
annat bryts.

### Lager 1 — Nätverkssegmentering

Endast nginx kommer att vara nåbar utifrån via port forwarding.
web1, web2, database och monitor kommer inte att ha någon
publik ingångspunkt. En angripare måste ta sig förbi nginx
för att ens nå applikationslagret.

### Lager 2 — Brandvägg (UFW)

UFW på database-VM kommer att tillåta inkommande anslutningar
på port 5432 enbart från web1 (192.168.56.12) och
web2 (192.168.56.13). Alla andra anslutningar blockeras.

`listen_addresses` i PostgreSQL kommer att konfigureras med
specifika IP-adresser — inte `'*'`. Detta är ett medvetet
designval för att minimera exponering även om UFW-reglerna
skulle kringgås.

### Lager 3 — SSH-härdning

Följande restriktioner kommer att gälla på alla VMs:

- `PermitRootLogin no` — root-inloggning via SSH förbjuden
- `PasswordAuthentication no` — enbart SSH-nycklar tillåts
- `MaxAuthTries 3` — max tre inloggningsförsök per session
- `AllowUsers vagrant` — enbart vagrant-användaren tillåts

### Lager 4 — fail2ban

fail2ban kommer att övervaka SSH-inloggningsförsök och
automatiskt blockera IP-adresser som uppvisar tecken på
brute-force-attacker.

### Lager 5 — auditd + Wazuh

auditd kommer att logga systemhändelser lokalt på varje VM.
Wazuh-agenter på alla VMs rapporterar till Wazuh Manager
på monitor (.15) för centraliserad säkerhetsövervakning
och intrångsdetektering.

---

## 7. Ansible-roller

### security_hardening — alla VMs

Rollen kommer att installeras på samtliga sex VMs och
säkerställa en konsekvent säkerhetsbaslinje:

- SSH-härdning via `sshd_config.j2`
- fail2ban för brute-force-skydd
- auditd för systemloggning

### database — database-VM

- Installation och konfiguration av PostgreSQL
- Skapar applikationsanvändare med minsta privilegium
- UFW-regler: enbart web1 och web2 på port 5432
- `schema.sql.j2` skapar visits-tabellen

### flask — web1 och web2

En gemensam roll används för båda webservrarna.
Skillnaden hanteras via `server_name`-variabeln:
web1 får "Server 1" och web2 får "Server 2".

- `app.py` med routes: `/` `/secret` `/visit`
- Gunicorn som WSGI-server
- systemd-tjänst för automatisk omstart vid krasch

### nginx — nginx-VM

- `nginx.conf.j2` konfigurerar upstream med web1 + web2
- Round-robin lastbalansering på port 5000
- `proxy_set_header` för Host, X-Real-IP, X-Forwarded-For

### wazuh_agent — alla VMs

- Wazuh-agent installeras på samtliga fem VMs (ej monitor)
- Agenter rapporterar till Wazuh Manager på monitor (.15)
- HIDS-övervakning av filintegritet och systemhändelser

---

## 8. Fasplanering

| Fas   | Namn                                                      |
|-------|-----------------------------------------------------------|
| Fas 1 | Vagrantfile — definiera 6 VMs                             |
| Fas 2 | Ansible-konfiguration (ansible.cfg, inventory, site.yml)  |
| Fas 3 | security_hardening-rollen                                 |
| Fas 4 | database-rollen (PostgreSQL + UFW)                        |
| Fas 5 | flask-rollen (Flask + Gunicorn + systemd)                 |
| Fas 6 | nginx-rollen (load balancer)                              |
| Fas 7 | wazuh_agent-rollen (SIEM)                                 |
| Fas 8 | Verifieringsskript (verify.sh + verify_host.ps1)          |
| Fas 9 | Rapport och presentation                                  |

---

## 9. Designkrav

Följande krav kommer att styra varje arkitektur- och
implementationsbeslut i projektet:

**Reproducerbarhet** — Infrastrukturen ska vara fullständigt
reproducerbar från noll. `vagrant destroy -f && vagrant up &&
ansible-playbook site.yml` ska ge en identisk, fungerande
miljö varje gång utan manuella ingrepp.

**Idempotens** — Ansible-playbooken ska kunna köras flera gånger
utan att orsaka oönskade sidoeffekter. Andra körningen ska
resultera i `changed=0`.

**Minsta privilegium** — Varje komponent ska ha exakt de
rättigheter som krävs för sin funktion — ingenting mer.
Databasanvändaren får bara köra SELECT och INSERT på
visits-tabellen.

**Nätverkssegmentering** — Kommunikation mellan lager ska vara
explicit tillåten, inte implicit. UFW-regler och
`listen_addresses` ska begränsa åtkomst till namngivna
IP-adresser.

**Spårbarhet** — Varje designbeslut ska vara motiverat i
dokumentationen. Läraren eller en ny teammedlem ska kunna
förstå VARFÖR en lösning valdes, inte bara HUR den fungerar.

**Skalbarhet** — Arkitekturen ska möjliggöra horisontell
skalning. Ytterligare webservrar ska kunna läggas till genom
att uppdatera nginx upstream-konfigurationen utan att
förändra övriga komponenter.

---

## 10. Förväntat resultat

### Systembeskrivning

När projektet är färdigt kommer infrastrukturen att bestå av
sex virtuella maskiner som tillsammans bildar ett komplett,
säkerhetshärdat webbsystem. En användare som besöker
`http://localhost:8080/visit` kommer att se ett svar från
antingen "Server 1" eller "Server 2" — beroende på vilken
server nginx skickar förfrågan till. Varje besök loggas i
databasen och de fem senaste besöken visas på sidan.
Systemet kommer att vara fullt automatiserat — från noll
till fungerande infrastruktur med ett enda kommando.

### Teknisk verifieringslista

Följande tester kommer att verifieras automatiskt av
`verify.sh` (Linux) och `verify_host.ps1` (Windows):

| #  | Test                                              | Förväntat resultat          |
|----|---------------------------------------------------|-----------------------------|
| 1  | nginx svarar på port 8080                         | HTTP 200 OK                 |
| 2  | /visit visar "Server 1" eller "Server 2"          | Lastbalansering fungerar    |
| 3  | Upprepad /visit växlar mellan Server 1 och Server 2 | Round-robin bekräftad     |
| 4  | web1 kan nå database på port 5432                 | Anslutning OK               |
| 5  | web2 kan nå database på port 5432                 | Anslutning OK               |
| 6  | Windows kan INTE nå database direkt på port 5432  | Anslutning nekad (UFW)      |
| 7  | flask-tjänst körs på web1                         | active (running)            |
| 8  | flask-tjänst körs på web2                         | active (running)            |
| 9  | fail2ban körs på alla VMs                         | active (running)            |
| 10 | auditd körs på alla VMs                           | active (running)            |
| 11 | PasswordAuthentication är inaktiverad             | no                          |
| 12 | PermitRootLogin är inaktiverad                    | no                          |
| 13 | Wazuh-agent aktiv på alla VMs                     | connected                   |
| 14 | PostgreSQL lyssnar INTE på 0.0.0.0                | Bara web1 + web2 IPs        |

---

*Projektlogg med detaljerade beskrivningar av varje fas
finns i `docs/log.md`.*