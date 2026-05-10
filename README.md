# Secure-Infra-Lab

En automatiserad infrastruktur med sex virtuella servrar - lastbalanserad Flask-webbapplikation via nginx, isolerad PostgreSQL-databasserver, säkerhetshärdning på alla servrar och centraliserad säkerhetsövervakning med Wazuh.

---

## Innehållsförteckning

- [Arkitektur](#arkitektur)
- [Miljöer och IP-adresser](#miljöer-och-ip-adresser)
- [Mappstruktur](#mappstruktur)
- [Komponenter](#komponenter)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Secrets](#secrets)
- [Säkerhetsåtgärder](#säkerhetsåtgärder)
- [Säkerhetsanalys](#säkerhetsanalys)
- [Verifiering](#verifiering)
- [Designval och motivering](#designval-och-motivering)

---

## Arkitektur

```
Windows-laptop (host)
        |
        | :8080 (nginx) / :9090 (Cockpit)
        |
+-------v------------------------------------------------+
|          Privat natverk 192.168.56.0/24                |
|                                                        |
|  +---------------------------------------------------+ |
|  |  control (.10) - Ansible control node             | |
|  +--------------------+------------------------------+ |
|                       | SSH                            |
|                       v                                |
|  +---------------------------------------------------+ |
|  |  nginx (.11) - Load balancer                      | |
|  |  Enda servern nabar utifran via port 8080          | |
|  +------------------+--------------------------------+ |
|                     | Round-robin                      |
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
|  |  database (.14) - PostgreSQL                      | |
|  |  UFW: port 5432 endast fran web1 och web2         | |
|  +---------------------------------------------------+ |
|                                                        |
|  +---------------------------------------------------+ |
|  |  monitor (.15) - Wazuh Manager + Cockpit          | |
|  |  Sakerhetsovervakning och systemdashboard         | |
|  +---------------------------------------------------+ |
+--------------------------------------------------------+
```

---

## Miljöer och IP-adresser

| VM | Roll | IP-adress | Port forwarding | Beskrivning |
|---|---|---|---|---|
| control | Ansible control node | 192.168.56.10 | - | Kor Ansible mot alla andra servrar |
| nginx | Lastbalanserare | 192.168.56.11 | 80 -> host:8080 | Tar emot all inkommande trafik och fordelar den |
| web1 | Applikationsserver | 192.168.56.12 | - | Flask + Gunicorn, hanteras av systemd |
| web2 | Applikationsserver | 192.168.56.13 | - | Flask + Gunicorn, hanteras av systemd |
| database | Databasserver | 192.168.56.14 | - | PostgreSQL, nabar bara fran web1 och web2 |
| monitor | Sakerhetsserver | 192.168.56.15 | 9090 -> host:9090 | Wazuh Manager + Cockpit dashboard |

---

## Mappstruktur

```
Secure-Infra-Lab/
|
+-- .gitattributes              # Tvingarr LF-radbrytningar for alla filer
+-- .gitignore                  # Ignorerar secrets.yml och .vagrant/
+-- docs/
|   +-- projektplan.md          # Projektbeskrivning och arkitektur
|   +-- log.md                  # Teknisk dokumentation fas for fas
|
+-- scripts/
|   +-- verify.sh               # 38 automatiska tester fran control
|   +-- verify_host.ps1         # 6 automatiska tester fran Windows
|
+-- vagrant/
|   +-- Vagrantfile             # Definierar alla 6 VMs och natverksinst.
|   +-- secrets.yml             # GITIGNORERAD - losenord och hemligheter
|
+-- ansible/
    +-- ansible.cfg             # Ansible-konfiguration
    +-- inventory.ini           # Servrar och grupper
    +-- site.yml                # Master playbook - roller i ratt ordning
    |
    +-- vars/
    |   +-- vars.yml            # Delade variabler (IP-adresser, portar)
    |
    +-- host_vars/
    |   +-- web2.yml            # server_name for web2 (Server 2)
    |
    +-- roles/
        +-- security_hardening/ # SSH-hardning, fail2ban, auditd
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/sshd_config.j2
        |   +-- vars/main.yml
        |
        +-- flask/              # Flask + Gunicorn pa web1 och web2
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/flask.service.j2
        |   +-- templates/flask.env.j2
        |   +-- files/app.py
        |   +-- vars/main.yml
        |   +-- defaults/main.yml
        |
        +-- nginx/              # Reverse proxy och lastbalansering
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/nginx.conf.j2
        |   +-- vars/main.yml
        |
        +-- database/           # PostgreSQL, schema och UFW
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/schema.sql.j2
        |   +-- vars/main.yml
        |
        +-- wazuh_manager/      # Wazuh Manager pa monitor
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- vars/main.yml
        |
        +-- wazuh_agent/        # Wazuh-agent pa alla servrar utom monitor
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- vars/main.yml
        |
        +-- cockpit/            # Cockpit dashboard pa monitor
            +-- tasks/main.yml
            +-- handlers/main.yml
            +-- vars/main.yml
```

---

## Komponenter

### Vagrantfile

Definierar sex virtuella maskiner i VirtualBox med ett
gemensamt host-only-natverk (192.168.56.0/24). Port
forwarding pa nginx (80 -> 8080) och monitor (9090 -> 9090)
gor att webbapplikationen och Cockpit ar nabara fran
Windows-hosten. Alla andra servrar ar inte nabara utifran.

### ansible.cfg

Pekar pa inventory.ini pa control-servern
(/home/vagrant/ansible/inventory.ini), inaktiverar host
key checking och aktiverar pipelining for att eliminera
varningar om world-readable tmp-filer.

### inventory.ini

Grupperar servrarna i control_g, nginx_g, webserver_g,
webserver2_g, database_g och monitor_g. Gruppnamnen har
_g-suffix for att undvika namnkrockar mellan grupp och host.

### site.yml

Master playbook med sju plays som kors i ordning:
1. security_hardening - hardnar alla sex servrar
2. database - konfigureras innan webbservrar startar
3. webserver_g (web1) - Flask + Gunicorn
4. webserver2_g (web2) - Flask + Gunicorn
5. nginx_g - konfigureras sist, efter webbservrar
6. monitor_g - Wazuh Manager + Cockpit
7. Wazuh-agenter pa alla servrar utom monitor

### Rollen security_hardening

Kors forst pa alla sex servrar. Installerar fail2ban och
auditd, distribuerar hardad SSH-konfiguration och
inaktiverar requiretty i sudoers for Ansible pipelining.

### Rollen flask

Installerar Python, Flask och Gunicorn. Kopierar app.py
och skapar en systemd-tjanst med Restart=always. Samma
roll anvands for bade web1 och web2 - server_name hanteras
via defaults/main.yml och host_vars/web2.yml.

### Rollen nginx

Installerar nginx och distribuerar nginx.conf.j2 som
definierar ett upstream-block med web1 och web2 pa port
5000. Round-robin lastbalansering ar standard i nginx.

### Rollen database

Installerar PostgreSQL, skapar flaskdb och flaskuser med
minsta privilegium (SELECT och INSERT pa visits-tabellen).
Konfigurerar pg_hba.conf for web1 och web2 och aktiverar
UFW som blockerar port 5432 fran alla utom web1 och web2.

### Rollen wazuh_manager

Installerar Wazuh Manager pa monitor-servern. Tar emot
sakerhetshandelser fran alla agenter och analyserar dem
mot regeluppsattningar i realtid.

### Rollen wazuh_agent

Installerar Wazuh-agenten pa control, nginx, web1, web2
och database. Agenten skickar sakerhetshindelser till
Wazuh Manager pa monitor (192.168.56.15).

### Rollen cockpit

Installerar Cockpit pa monitor-servern. Ger en webbaserad
vy av systemstatus - CPU, minne, disk och aktiva tjanster.
Nabar via https://localhost:9090.

### Flask-applikationen (app.py)

En Flask-applikation med tre routes:

| Endpoint | Beskrivning |
|---|---|
| `/` | Returnerar halsningsmeddelande med servernamnet |
| `/secret` | Visar laddade miljovariabler (for verifiering) |
| `/visit` | Sparar besoket i databasen och visar 5 senaste besok |

All konfiguration (databasuppgifter, servernamn) las
fran miljovariabler via os.getenv().

---

## Krav och förutsättningar

**Programvara som maste vara installerad pa Windows-hosten:**

- VirtualBox: https://www.virtualbox.org/ (testat med 7.x)
- Vagrant: https://www.vagrantup.com/ (testat med 2.x)
- Git: https://git-scm.com/

**Hardvarukrav:**

- Minst 8 GB RAM (projektet anvander totalt 5120 MB)
- Minst 30 GB ledigt diskutrymme

---

## Kom igång

```powershell
# 1. Klona repot
git clone https://github.com/SSM-debug/Secure-Infra-Lab.git
cd Secure-Infra-Lab

# 2. Skapa secrets-filen
# Skapa vagrant/secrets.yml med foljande innehall:
# db_name: flaskdb
# db_user: flaskuser
# db_password: ValjEttStarktLosenord

# 3. Starta alla VMs
cd vagrant
vagrant up

# 4. Logga in pa control och ladda upp Ansible-filer
vagrant upload ../ansible /home/vagrant/ansible control

# 5. Logga in pa control och kor playbooken
vagrant ssh control
```

```bash
# 6. Kor playbooken fran control
cd ansible
ansible-playbook site.yml

# 7. Verifiera att allt fungerar
bash /home/vagrant/verify.sh
```

```powershell
# 8. Verifiera fran Windows
cd E:\Secure-Infra-Lab
.\scripts\verify_host.ps1
```

**Forvant slutresultat:**

Oppna http://localhost:8080/visit i webblasaren. Sidan
visar "Server 1" eller "Server 2" beroende pa vilken
server nginx valde. Laddar man om sidan byter nginx
till den andra servern.

---

## Secrets

Filen `vagrant/secrets.yml` maste skapas lokalt och
ska aldrig committjas till Git (den finns i .gitignore).

Skapa filen med foljande innehall:

```yaml
---
db_name: flaskdb
db_user: flaskuser
db_password: ValjEttStarktLosenord
```

Filen laddas upp till control-servern med vagrant upload
och refereras i playbooken med:

```yaml
vars_files:
  - vars/vars.yml
  - secrets.yml
```

---

## Säkerhetsåtgärder

| Atgard | Var | Hur verifieras det |
|---|---|---|
| SSH root-inloggning inaktiverad | Alla VMs | `sudo sshd -T \| grep permitrootlogin` |
| Losen ordsautentisering via SSH inaktiverad | Alla VMs | `sudo sshd -T \| grep passwordauthentication` |
| UFW brandvagg aktiv | database | `sudo ufw status verbose` |
| Port 5432 blockerad utifran | database | verify_host.ps1 test 6 |
| Port 5432 tillganglig fran web1 | database | verify.sh test 4 |
| fail2ban aktiv | Alla VMs | `systemctl is-active fail2ban` |
| auditd aktiv | Alla VMs | `systemctl is-active auditd` |
| Wazuh-agent aktiv | Alla utom monitor | `systemctl is-active wazuh-agent` |
| Flask kor som icke-root | web1, web2 | `ps aux \| grep gunicorn` |
| Secrets utanfor Git | Alla | `git log --all -- vagrant/secrets.yml` (tom output) |

---

## Säkerhetsanalys

### Kvarvarande brister

**Brist 1 - listen_addresses satt till '*'**

PostgreSQL lyssnar pa alla IP-adresser istallet for
bara web1 och web2. Det innebar att PostgreSQL tar
emot anslutningsforsokt fran alla IP-adresser, aven om
pg_hba.conf och UFW blockerar obehorniga.

*Atgard i produktionsmiljo:* Satt listen_addresses till
specifika IP-adresser (192.168.56.12, 192.168.56.13,
127.0.0.1). Det ger tre oberoende sakerhetsslager istallet
for tva.

*Accepterat i denna miljo eftersom:* pg_hba.conf och UFW
blockerar alla anslutningar utom fran web1 och web2.
Risken bedoms som lag i isolerad labbmiljo.

**Brist 2 - Okrypterad kommunikation mellan nginx och Flask**

Trafiken mellan nginx och Flask-servrarna ar okrypterad
HTTP pa det interna natverket.

*Atgard i produktionsmiljo:* Konfigurera TLS med ett
internt CA-certifikat for kommunikationen pa det privata
natverket.

*Accepterat i denna miljo eftersom:* Det privata natverket
(192.168.56.0/24) ar isolerat och enbart tillgangligt
fran varddatorn.

**Brist 3 - Cockpit anvander sjalvsignerat certifikat**

Cockpit-dashboarden anvander ett sjalvsignerat certifikat
som inte ar betrodd av webblasaren.

*Atgard i produktionsmiljo:* Installera ett CA-signerat
certifikat eller anvanda en intern PKI.

*Accepterat i denna miljo eftersom:* Cockpit ar bara
tillganglig via localhost:9090 fran varddatorn.

### Vad som skyddar miljön

- Natverkssegmentering: databasen ar inte nabar utifran
- UFW pa databasservern med explicita allow-regler
- pg_hba.conf begransar databastillgang till web1 och web2
- Minsta privilegium pa databasnivaerna (SELECT och INSERT)
- SSH-hardning pa alla servrar
- fail2ban blockerar brute-force-attacker automatiskt
- auditd loggar alla systemhandelser
- Wazuh overvakar sakerhetshandelser i realtid
- Inga losenord i versionshanteringen

---

## Verifiering

**Fran control-servern (38 tester):**

```bash
vagrant@control:~$ bash verify.sh
```

```
==============================
 Secure-Infra-Lab Verify
==============================
PASS: nginx HTTP 200
PASS: Round-robin Server 1
PASS: Round-robin Server 2
PASS: web1 reaches database:5432
PASS: External blocked from database:5432
PASS: Flask active on web1
PASS: Flask active on web2
PASS: fail2ban active on 192.168.56.10
... (alla 38 tester)
==============================
 Results: PASS=38 FAIL=0
==============================
```

**Fran Windows-varddatorn (6 tester):**

```powershell
E:\Secure-Infra-Lab> .\scripts\verify_host.ps1
```

```
==============================
 Secure-Infra-Lab Verify Host
==============================
PASS: nginx responds on localhost:8080
PASS: Round-robin includes Server 1
PASS: Round-robin includes Server 2
PASS: /visit registers a visit
PASS: Cockpit responding on port 9090
PASS: database:5432 blocked from host
==============================
 Results: PASS=6 FAIL=0
==============================
```

---

## Designval och motivering

### Varför separata VMs for webbserver och databas?

Att kora Flask och PostgreSQL pa samma VM hade foregyklat
upplaget men eliminerat natverkssegmenteringen. Med separata
VMs kravs en natverksanslutning mot databasservern som
UFW-reglerna begransar till bara web1 och web2.

### Varför Gunicorn istallet for Flasks inbyggda server?

Flasks inbyggda server ar entradad och hanterar en
forfragan i taget. Gunicorn kor flera worker-processer
och ar den etablerade standarden for Flask i produktion.
Det gor ocksa att tjansten hanteras av systemd med
automatisk omstart vid krascher.

### Varför Jinja2-mall for nginx.conf?

IP-adresserna till web1 och web2 hämtas fran vars.yml via
Jinja2-variabler. Om en tredje webbserver laggs till
behover man bara uppdatera vars.yml och nginx-konfigurationen
genereras automatiskt nasta gang playbooken kors.

### Varför defaults/main.yml for server_name?

defaults/main.yml har lagsta prioritet i Ansibles
variabelhierarki. Det gor att host_vars/web2.yml kan
overskriva server_name for web2 utan att beh ova
duplicera rollkoden. web1 anvander standardvardet
"Server 1" och web2 far "Server 2" via host_vars.

### Varför cockpit istallet for Wazuh Dashboard?

Wazuh Dashboard kräver minst 4 GB RAM och ar for
resurskravande for var labbmiljo med 2048 MB pa monitor.
Cockpit ar lattvagtigt, installeras fran Ubuntus
standardrepository och ger tillracklig systemoverblick
for vart syfte.

---

*Skapad av: Sushanta Shekhar Modak & Farhad Norman*
*Datum: 2026-05-10*