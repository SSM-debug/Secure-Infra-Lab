# Secure-Infra-Lab

En automatiserad infrastruktur med sex virtuella servrar som sätts upp helt automatiskt med ett enda kommando. Systemet implementerar Infrastructure-as-Code, Defense-in-Depth och fullständig reproducerbarhet - från tom hårdvara till ett fungerande system med lastbalansering, databas och SIEM-övervakning.

**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab

---

## Innehållsförteckning

- [Arkitektur](#arkitektur)
- [Miljöer och IP-adresser](#miljöer-och-ip-adresser)
- [Mappstruktur](#mappstruktur)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Secrets](#secrets)
- [Ansible-roller](#ansible-roller)
- [Säkerhetsåtgärder](#säkerhetsåtgärder)
- [STRIDE-analys och hotmodellering](#stride-analys-och-hotmodellering)
- [Verifiering och testresultat](#verifiering-och-testresultat)
- [Produktion och skalbarhet](#produktion-och-skalbarhet)
- [Designval och motivering](#designval-och-motivering)
- [Tekniska begränsningar och framtida förbättringar](#tekniska-begränsningar-och-framtida-förbättringar)

---

## Arkitektur

```
Windows 11 (host)
        |
        | :8080 (nginx)   :9090 (Cockpit)
        |
+-------v-------------------------------------------------+
|           Private network 192.168.56.0/24                |
|                                                          |
|  +----------------------------------------------------+  |
|  |  control (.10) - 1024 MB                          |  |
|  |  Ansible control node                             |  |
|  |  Runs playbooks against all servers via SSH       |  |
|  +-------------------+--------------------------------+  |
|                      | SSH (Ansible)                    |
|          +-----------+-----------+                      |
|          v           v           v                      |
|  +------------+ +----------+ +----------+              |
|  | nginx (.11)|  |web1 (.12)| |web2 (.13)|              |
|  | 512 MB     |  | 512 MB   | | 512 MB   |              |
|  | Port 8080  |  | Flask +  | | Flask +  |              |
|  | Load       |  | Gunicorn | | Gunicorn |              |
|  | Balancer   |  | Server 1 | | Server 2 |              |
|  +-----+------+ +----+-----+ +----+-----+              |
|        |              |            |                     |
|        | round-robin  |            |                     |
|        +--------------+------------+                     |
|                       | port 5432                        |
|                       | UFW: web1 and web2 only          |
|                       v                                  |
|  +----------------------------------------------------+  |
|  |  database (.14) - 512 MB                          |  |
|  |  PostgreSQL                                       |  |
|  |  UFW blocks all except web1 and web2              |  |
|  +----------------------------------------------------+  |
|                                                          |
|  +----------------------------------------------------+  |
|  |  monitor (.15) - 2048 MB                          |  |
|  |  Wazuh Manager + Cockpit (port 9090)              |  |
|  |  Receives security events from all agents         |  |
|  +----------------------------------------------------+  |
|        ^           ^           ^          ^          ^   |
|        | Wazuh agent (all servers except monitor)       |
+----------------------------------------------------------+
```

### 3-tier-arkitektur

**Lager 1 - nginx (.11)** tar emot all inkommande
trafik via port 8080. Det är den enda servern som
är nåbar utifrån. Alla förfrågningar distribueras
automatiskt mellan web1 och web2 via round-robin.

**Lager 2 - web1 (.12) och web2 (.13)** kör
Flask-applikationen via Gunicorn. Båda servrarna
kör identisk kod men identifierar sig som
"Server 1" respektive "Server 2". Om en server
slutar svara tar den andra över automatiskt.

**Lager 3 - database (.14)** kör PostgreSQL och
är helt isolerad från omvärlden. Bara web1 och
web2 kan ansluta på port 5432 - begränsat av
både UFW och pg_hba.conf.

**monitor (.15)** deltar inte i trafikflödet.
Den övervakar säkerhetshändelser från alla fem
övriga servrar via Wazuh-agenter och ger
systemöverblick via Cockpit på port 9090.

> Fullständig arkitekturbeskrivning finns i
> [docs/projektplan.md - Avsnitt 3](docs/projektplan.md).

### draw.io-diagram

Öppna [docs/architecture.drawio](docs/architecture.drawio)
på https://diagrams.net för ett visuellt
arkitekturdiagram. File > Export as > PNG för
att spara som bild.

<details>
<summary>Visa draw.io XML</summary>

```xml
<mxfile host="diagrams.net">
  <diagram name="Secure-Infra-Lab">
    <mxGraphModel dx="1422" dy="762" grid="1" gridSize="10"
      guides="1" tooltips="1" connect="1" arrows="1"
      fold="1" page="1" pageScale="1" pageWidth="1169"
      pageHeight="827" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>

        <!-- Windows Host -->
        <mxCell id="2" value="Windows 11 (host)"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#dae8fc;strokeColor=#6c8ebf;
          fontStyle=1;fontSize=12;"
          vertex="1" parent="1">
          <mxGeometry x="400" y="40" width="200"
            height="50" as="geometry"/>
        </mxCell>

        <!-- Private Network Box -->
        <mxCell id="3" value="Private network 192.168.56.0/24"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#f5f5f5;strokeColor=#666666;
          fontStyle=1;fontSize=11;verticalAlign=top;"
          vertex="1" parent="1">
          <mxGeometry x="100" y="140" width="800"
            height="600" as="geometry"/>
        </mxCell>

        <!-- control -->
        <mxCell id="4" value="control (.10)&#xa;Ansible control node&#xa;1024 MB"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="380" y="180" width="240"
            height="70" as="geometry"/>
        </mxCell>

        <!-- nginx -->
        <mxCell id="5" value="nginx (.11)&#xa;Load Balancer&#xa;Port 8080 | 512 MB"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="380" y="310" width="240"
            height="70" as="geometry"/>
        </mxCell>

        <!-- web1 -->
        <mxCell id="6" value="web1 (.12)&#xa;Flask + Gunicorn&#xa;Server 1 | 512 MB"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="200" y="440" width="200"
            height="70" as="geometry"/>
        </mxCell>

        <!-- web2 -->
        <mxCell id="7" value="web2 (.13)&#xa;Flask + Gunicorn&#xa;Server 2 | 512 MB"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="600" y="440" width="200"
            height="70" as="geometry"/>
        </mxCell>

        <!-- database -->
        <mxCell id="8" value="database (.14)&#xa;PostgreSQL | 512 MB&#xa;UFW: port 5432"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="380" y="570" width="240"
            height="70" as="geometry"/>
        </mxCell>

        <!-- monitor -->
        <mxCell id="9" value="monitor (.15)&#xa;Wazuh Manager + Cockpit&#xa;Port 9090 | 2048 MB"
          style="rounded=1;whiteSpace=wrap;html=1;
          fillColor=#00BCD4;strokeColor=#006EAF;
          fontColor=#ffffff;fontStyle=1;"
          vertex="1" parent="1">
          <mxGeometry x="700" y="570" width="160"
            height="70" as="geometry"/>
        </mxCell>

        <!-- Port forwarding nginx -->
        <mxCell id="10" value=":8080"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;orthogonalLoop=1;"
          edge="1" source="2" target="5" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Port forwarding Cockpit -->
        <mxCell id="11" value=":9090"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;orthogonalLoop=1;dashed=1;"
          edge="1" source="2" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Ansible SSH -->
        <mxCell id="12" value="SSH (Ansible)"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;"
          edge="1" source="4" target="5" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Round-robin web1 -->
        <mxCell id="13" value="round-robin"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;"
          edge="1" source="5" target="6" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Round-robin web2 -->
        <mxCell id="14" value="round-robin"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;"
          edge="1" source="5" target="7" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- web1 to database -->
        <mxCell id="15" value="port 5432"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;"
          edge="1" source="6" target="8" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- web2 to database -->
        <mxCell id="16" value="port 5432"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;"
          edge="1" source="7" target="8" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

        <!-- Wazuh agents -->
        <mxCell id="17" value="Wazuh events"
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;strokeColor=#FF6B6B;"
          edge="1" source="4" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="18" value=""
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;strokeColor=#FF6B6B;"
          edge="1" source="5" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="19" value=""
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;strokeColor=#FF6B6B;"
          edge="1" source="6" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="20" value=""
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;strokeColor=#FF6B6B;"
          edge="1" source="7" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>
        <mxCell id="21" value=""
          style="edgeStyle=orthogonalEdgeStyle;
          rounded=0;dashed=1;strokeColor=#FF6B6B;"
          edge="1" source="8" target="9" parent="1">
          <mxGeometry relative="1" as="geometry"/>
        </mxCell>

      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

</details>

---

## Miljöer och IP-adresser

| Server | IP-adress | Roll | Port forwarding | RAM |
|--------|-----------|------|----------------|-----|
| control | 192.168.56.10 | Ansible control node | - | 1024 MB |
| nginx | 192.168.56.11 | Load balancer | 80 -> host:8080 | 512 MB |
| web1 | 192.168.56.12 | Flask + Gunicorn (Server 1) | - | 512 MB |
| web2 | 192.168.56.13 | Flask + Gunicorn (Server 2) | - | 512 MB |
| database | 192.168.56.14 | PostgreSQL + UFW | - | 512 MB |
| monitor | 192.168.56.15 | Wazuh Manager + Cockpit | 9090 -> host:9090 | 2048 MB |
| **Totalt** | | | | **5120 MB** |

---

## Mappstruktur

```
Secure-Infra-Lab/
|
+-- .gitattributes          # Enforces LF line endings for all files
+-- .gitignore              # Ignores secrets.yml and .vagrant/
+-- README.md               # This document
|
+-- docs/
|   +-- projektplan.md      # System design and architecture
|   +-- log.md              # Technical documentation phase by phase
|   +-- architecture.drawio # Visual architecture diagram
|
+-- scripts/
|   +-- verify.sh           # 38 automated tests from control
|   +-- verify_host.ps1     # 6 automated tests from Windows host
|
+-- vagrant/
|   +-- Vagrantfile         # Defines all 6 VMs
|   +-- secrets.yml         # GITIGNORED - create manually
|
+-- ansible/
    +-- ansible.cfg         # Ansible configuration
    +-- inventory.ini       # Servers and groups
    +-- site.yml            # Master playbook
    +-- vars/vars.yml       # Shared variables
    +-- host_vars/web2.yml  # server_name override for web2
    |
    +-- roles/
        +-- security_hardening/
        +-- flask/
        +-- nginx/
        +-- database/
        +-- wazuh_manager/
        +-- wazuh_agent/
        +-- cockpit/
```

Viktiga filer på GitHub:
- [Vagrantfile](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/vagrant/Vagrantfile)
- [site.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/site.yml)
- [inventory.ini](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/inventory.ini)
- [vars.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/vars/vars.yml)
- [app.py](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/files/app.py)
- [nginx.conf.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/templates/nginx.conf.j2)
- [verify.sh](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh)
- [verify_host.ps1](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1)

> Detaljerad beskrivning av varje fil finns i
> [docs/log.md](docs/log.md) under respektive fas.

---

## Krav och förutsättningar

**Programvara på Windows-hosten:**

- [VirtualBox](https://www.virtualbox.org/) - testat med 7.x
- [Vagrant](https://www.vagrantup.com/) - testat med 2.x
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) (rekommenderas för YAML-redigering)

**Hårdvarukrav:**

- Minst 8 GB RAM (projektet använder totalt 5120 MB)
- Minst 20 GB ledigt diskutrymme

---

## Kom igång

```powershell
# Clone the repository
cd E:\
E:\> git clone https://github.com/SSM-debug/Secure-Infra-Lab.git
E:\> cd Secure-Infra-Lab
```

```powershell
# Create the secrets file (see Secrets section below)
E:\Secure-Infra-Lab> code vagrant\secrets.yml
```

```powershell
# Start all 6 VMs
# NOTE: First startup takes 10-15 minutes
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant up
```

Förväntat output per server: `=== [servername]: ready ===`

```powershell
# Upload Ansible files to control
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\scripts\verify.sh /home/vagrant/verify.sh control
```

```powershell
# Log in to control and run the playbook
E:\Secure-Infra-Lab\vagrant> vagrant ssh control
```

```bash
# Run the playbook - configures the entire infrastructure automatically
# NOTE: Wazuh Manager installation takes 10-15 minutes
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```

Förväntat slutresultat: `failed=0` på alla servrar.

```bash
# Verify that everything works (38 tests)
vagrant@control:~$ bash verify.sh
```

```powershell
# Verify from Windows (6 tests)
E:\Secure-Infra-Lab> .\scripts\verify_host.ps1
```

**Tillgängliga tjänster efter uppstart:**

| URL | Beskrivning |
|-----|-------------|
| http://localhost:8080/ | Flask via nginx - visar Server 1 eller Server 2 |
| http://localhost:8080/visit | Registrerar besök i databasen och visar de 5 senaste |
| http://localhost:8080/secret | Visar laddade miljövariabler |
| https://localhost:9090 | Cockpit dashboard (vagrant/vagrant) |

> Detaljerade kommandon för varje fas finns i
> [docs/log.md](docs/log.md).

---

## Secrets

Filen `vagrant/secrets.yml` innehåller databasuppgifter
och måste skapas manuellt. Den gitignoreras och finns
aldrig i repot.

Skapa filen med exakt detta innehåll:

```yaml
---
db_name: flaskdb
db_user: flaskuser
db_password: your-password-here
```

Filen laddas upp till control och refereras i playbooken:

```yaml
vars_files:
  - vars/vars.yml
  - secrets.yml
```

Verifiera att filen aldrig committats:

```powershell
E:\Secure-Infra-Lab> git log --all -- vagrant/secrets.yml
```

Förväntat svar: tom output. Inga commits - filen
har aldrig publicerats på GitHub.

---

## Ansible-roller

### security_hardening

Körs FÖRST på alla sex servrar innan några tjänster
installeras. Sätter en konsekvent säkerhetsbaslinje
på hela infrastrukturen.

**Härdningsåtgärder:**
- SSH root-inloggning inaktiverad (`PermitRootLogin no`)
- Lösenordsinloggning inaktiverad - bara SSH-nycklar fungerar
- Max 3 inloggningsförsök (`MaxAuthTries 3`)
- Inaktiva sessioner stängs efter 5 minuter (`ClientAliveInterval 300`)
- fail2ban: blockerar IP efter 5 misslyckade försök inom 10 minuter
- auditd: loggar alla kommandon, filändringar och inloggningar

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml)
- [templates/sshd_config.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2)

**Officiell dokumentation:** [docs.ansible.com](https://docs.ansible.com/ansible/latest/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 3](docs/log.md).

---

### database

Installerar PostgreSQL på database-servern, skapar
databasen och användaren med minsta privilegium och
konfigurerar brandväggsregler.

**Säkerhetsåtgärder:**
- flaskuser får bara SELECT och INSERT på visits-tabellen
- pg_hba.conf tillåter bara web1 och web2
- UFW blockerar port 5432 från alla utom web1 och web2

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/tasks/main.yml)
- [templates/schema.sql.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/templates/schema.sql.j2)

**Officiell dokumentation:** [postgresql.org/docs](https://www.postgresql.org/docs/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 4](docs/log.md).

---

### flask

Installerar Flask och Gunicorn på web1 och web2.
Samma roll används för båda servrarna - server_name
hanteras via `defaults/main.yml` (Server 1) och
`host_vars/web2.yml` (Server 2).

Flask-applikationen har tre routes:
- `/` - hälsningsmeddelande med servernamnet
- `/secret` - visar laddade miljövariabler
- `/visit` - registrerar besöket och visar 5 senaste

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/tasks/main.yml)
- [files/app.py](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/files/app.py)
- [templates/flask.service.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.service.j2)
- [templates/flask.env.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.env.j2)

**Officiell dokumentation:** [flask.palletsprojects.com](https://flask.palletsprojects.com/) och [docs.gunicorn.org](https://docs.gunicorn.org/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 5](docs/log.md).

---

### nginx

Konfigurerar nginx som reverse proxy och
lastbalanserare. Distribuerar trafik mellan
web1 och web2 via round-robin.

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/tasks/main.yml)
- [templates/nginx.conf.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/templates/nginx.conf.j2)

**Officiell dokumentation:** [nginx.org/en/docs](https://nginx.org/en/docs/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 6](docs/log.md).

---

### wazuh_manager

Installerar Wazuh Manager på monitor-servern.
Tar emot säkerhetshändelser från alla agenter och
analyserar dem mot regeluppsättningar i realtid.

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/tasks/main.yml)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 7](docs/log.md).

---

### wazuh_agent

Installerar Wazuh-agenten på control, nginx, web1,
web2 och database. Agenten skickar säkerhetshändelser
till Wazuh Manager på monitor (192.168.56.15).

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/tasks/main.yml)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

---

### cockpit

Installerar Cockpit på monitor-servern. Ger en
webbaserad vy av systemstatus utan att behöva
logga in via SSH.

Nåbar via: `https://localhost:9090` (vagrant/vagrant)

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/tasks/main.yml)

**Officiell dokumentation:** [cockpit-project.org](https://cockpit-project.org/)

> Detaljer om alla roller finns i
> [docs/projektplan.md - Avsnitt 8](docs/projektplan.md).

---

## Säkerhetsåtgärder

Vi implementerar Defense-in-Depth. Det innebär
flera oberoende skyddslager - om ett lager bryts
igenom finns nästa lager kvar.

| Åtgärd | Var | Hur det verifieras |
|--------|-----|--------------------|
| SSH root-inloggning inaktiverad | Alla servrar | `sudo sshd -T \| grep permitrootlogin` |
| Lösenordsinloggning inaktiverad | Alla servrar | `sudo sshd -T \| grep passwordauthentication` |
| UFW aktiv | database | `sudo ufw status verbose` |
| Port 5432 blockerad utifrån | database | verify_host.ps1 test 6 |
| Port 5432 tillgänglig från web1/web2 | database | verify.sh test 4 |
| fail2ban aktiv | Alla servrar | `systemctl is-active fail2ban` |
| auditd aktiv | Alla servrar | `systemctl is-active auditd` |
| Wazuh-agent aktiv | 5 servrar | `systemctl is-active wazuh-agent` |
| Flask kör som icke-root | web1, web2 | `ps aux \| grep gunicorn` |
| Secrets utanför Git | Alla | `git log --all -- vagrant/secrets.yml` |

**Designnotering om listen_addresses:**

PostgreSQL är konfigurerad med `listen_addresses = '*'`
i nuvarande miljö. Det innebär att databasen lyssnar
på alla nätverk, men pg_hba.conf och UFW blockerar
alla anslutningar utom från web1 och web2.

Det är ett medvetet beslut baserat på laboratoriets
begränsningar. I en produktionsmiljö ska
`listen_addresses` sättas till specifika IP-adresser
(`192.168.56.12,192.168.56.13,127.0.0.1`) för ett
extra skyddslager. Det är dokumenterat som känd
avvägning i projektet.

> Fullständig säkerhetsanalys finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

---

## STRIDE-analys och hotmodellering

STRIDE är en metod för att identifiera säkerhetshot
systematiskt. Varje bokstav representerar en
hotkategori:

- **S**poofing - Utge sig för att vara något man inte är
- **T**ampering - Manipulera data eller kod
- **R**epudiation - Neka att man utfört en handling
- **I**nformation Disclosure - Exponera känslig information
- **D**enial of Service - Göra systemet otillgängligt
- **E**levation of Privilege - Skaffa högre rättigheter

### Hotmodelleringsscenario: vad händer om web1 komprometteras?

En angripare som får kontroll över web1 kan:
- Läsa databasuppgifter i `/home/vagrant/.env`
- Ansluta till databasen på port 5432 (web1 är tillåten av UFW)
- Skriva falska besök till visits-tabellen
- Försöka nå andra servrar på det interna nätverket

En angripare på web1 kan INTE:
- Nå andra servrar direkt - UFW tillåter bara nödvändig trafik
- Logga in på database-servern via SSH (bara control har access)
- Nå monitor-servern direkt från web1
- Eskalera till root utan att trigga auditd och Wazuh

Wazuh detekterar:
- Ovanliga processer som startar på web1
- SSH-inloggningsförsök till andra servrar
- Filändringar i känsliga kataloger
- Ovanlig databastrafik

> Detaljerad beskrivning av skyddslagren finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

### STRIDE-tabell

| Hot | Kategori | Komponent | Skydd vi har |
|-----|----------|-----------|--------------|
| Angripare utger sig för att vara web1 eller web2 | Spoofing | database | pg_hba.conf med IP-whitelist |
| Manipulation av Flask-applikationens kod | Tampering | web1, web2 | auditd loggar filändringar |
| Ingen loggning av databastransaktioner | Repudiation | database | auditd + Wazuh-agent |
| Databasuppgifter exponeras på GitHub | Information Disclosure | web1, web2 | secrets.yml gitignoreras |
| Flask-miljövariabler läcker i loggar | Information Disclosure | web1, web2 | EnvironmentFile med mode 0600 |
| nginx överbelastas | Denial of Service | nginx | round-robin fördelar last |
| SSH-brute-force mot alla servrar | Denial of Service | Alla | fail2ban blockerar efter 5 försök |
| Angripare eskalerar från web1 till database | Elevation of Privilege | database | UFW + pg_hba.conf |
| Obehörig SSH-åtkomst via root | Elevation of Privilege | Alla | PermitRootLogin no |

### Kvarvarande brister

**Brist 1 - Okrypterad HTTP mellan nginx och Flask**

Trafiken på det interna nätverket är okrypterad.
En angripare med tillgång till det interna nätverket
kan läsa trafiken.

Accepterat i laboratoriet eftersom nätverket är
isolerat och bara tillgängligt från värddatorn.
I produktion: TLS med internt CA-certifikat eller
WireGuard overlay-nätverk.

**Brist 2 - listen_addresses satt till '*'**

PostgreSQL tar emot anslutningsförsök från alla
IP-adresser. pg_hba.conf och UFW blockerar obehöriga
men det är inte Defense-in-Depth.

Accepterat i laboratoriet - dokumenterat som känd
avvägning. I produktion: specifika IP-adresser.

**Brist 3 - Wazuh utan active response**

Wazuh detekterar hot men blockerar dem inte
automatiskt. Active response konfigureras separat.

Accepterat i laboratoriet. I produktion: aktivera
active response för automatisk IP-blockering vid
brute-force-attacker.

---

## Verifiering och testresultat

Verifieringen bevisar att infrastrukturen är
korrekt konfigurerad och fullständigt reproducerbar.

### verify.sh - 38 tester från control

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh)

```bash
vagrant@control:~$ bash verify.sh
```

Skriptet testar:

| Testkategori | Antal tester |
|-------------|-------------|
| nginx svarar på port 80 | 1 |
| Round-robin Server 1 | 1 |
| Round-robin Server 2 | 1 |
| web1 når databasen på port 5432 | 1 |
| Extern blockeras från databasen | 1 |
| Flask aktiv på web1 | 1 |
| Flask aktiv på web2 | 1 |
| fail2ban aktiv på alla 6 servrar | 6 |
| auditd aktiv på alla 6 servrar | 6 |
| Lösenordsinloggning inaktiverad | 6 |
| Root-inloggning inaktiverad | 6 |
| Wazuh-agent aktiv på 5 servrar | 5 |
| Wazuh Manager aktiv på monitor | 1 |
| Cockpit svarar på port 9090 | 1 |

Förväntat output:

```
==============================
 Secure-Infra-Lab Verify
==============================
PASS: nginx HTTP 200
PASS: Round-robin Server 1
PASS: Round-robin Server 2
...
==============================
 Results: PASS=38 FAIL=0
==============================
```

### verify_host.ps1 - 6 tester från Windows

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1)

```powershell
E:\Secure-Infra-Lab> .\scripts\verify_host.ps1
```

Skriptet testar från värddatorns perspektiv:
- nginx svarar via port forwarding 8080
- Round-robin inkluderar Server 1
- Round-robin inkluderar Server 2
- /visit registrerar ett besök
- Cockpit svarar på port 9090
- Databasen är INTE nåbar från Windows (UFW fungerar)

Förväntat output:

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

### Reproducerbarhet

Dessa resultat ska uppnås varje gång efter:

```bash
vagrant destroy -f && vagrant up
vagrant upload ../ansible /home/vagrant/ansible control
ansible-playbook site.yml
bash verify.sh
```

38/38 och 6/6 varje gång - utan manuella ingrepp.
Det bevisar att infrastrukturen är fullständigt
reproducerbar.

---

## Produktion och skalbarhet

### Skillnader mot en produktionsmiljö

| Laboratoriet | Produktionsmiljön |
|-------------|------------------|
| Vagrant + VirtualBox | AWS, Azure eller dedikerad hårdvara |
| Statiska privata IP:er | DNS + cloud load balancers |
| secrets.yml | HashiCorp Vault eller AWS Secrets Manager |
| Cockpit för övervakning | Wazuh Dashboard (OpenSearch) + SOC-team |
| HTTP internt | TLS på all kommunikation |
| Manuell vagrant upload | CI/CD-pipeline med GitHub Actions |

### Skalbarhet i nuvarande design

Att lägga till en tredje webbserver kräver tre steg:

1. Lägg till servern i `ansible/inventory.ini`
2. Lägg till IP-adressen i `ansible/vars/vars.yml`
3. Kör `ansible-playbook site.yml`

nginx.conf.j2 uppdateras automatiskt via
Jinja2-variabler. Inga manuella ändringar i
nginx-konfigurationen behövs.

### Loggning och övervakning

Wazuh Manager på monitor samlar loggar från alla
fem servrar i realtid. Wazuh-regler genererar
alerts vid misstänkt aktivitet.

Cockpit ger en webbaserad realtidsvy av systemhälsa:
CPU, minne, disk och aktiva tjänster per server.

I produktion kompletteras Wazuh med automatisk
backup av PostgreSQL och integrering med ett
SOC-team för incidenthantering.

> Fullständig diskussion om skalbarhet finns i
> [docs/projektplan.md - Avsnitt 10](docs/projektplan.md).

---

## Designval och motivering

### Varför separata VMs för varje lager?

Att köra Flask och PostgreSQL på samma server
hade förenklat upplägget men eliminerat
nätverkssegmenteringen. Med separata VMs krävs
en nätverksanslutning mot databasen som UFW
begränsar till bara web1 och web2. Om
webbservern komprometteras kan angriparen inte
automatiskt nå databasen direkt.

### Varför Gunicorn istället för Flasks inbyggda server?

Flasks inbyggda server är entrådig och hanterar
en förfrågan i taget. Gunicorn kör flera
worker-processer parallellt och är den etablerade
standarden för Flask i produktion. systemd med
`Restart=always` ger automatisk återhämtning
vid krascher.

### Varför Jinja2-template för nginx.conf?

IP-adresserna till web1 och web2 hämtas från
`vars.yml` via Jinja2-variabler. Om en tredje
webbserver läggs till uppdateras nginx-konfigurationen
automatiskt nästa gång playbooken körs. Inga
manuella ändringar i nginx.conf behövs.

### Varför en gemensam flask-roll för web1 och web2?

DRY-principen (Don't Repeat Yourself). Samma
rollkod används för båda servrarna. Skillnaden
hanteras via Ansibles variabelprioritering:
`defaults/main.yml` sätter "Server 1" som
standardvärde och `host_vars/web2.yml` överskriver
det för web2. Inga duplicerade roller behövs.

### Varför security_hardening körs först?

Säkerheten måste vara på plats innan några
tjänster installeras. Om vi installerade Flask
först och härdade SSH efteråt skulle det finnas
ett tidsfönster då servern är oskyddad. Security
hardening som första steg garanterar att alla
servrar har en konsekvent säkerhetsbaslinje
från dag ett.

### Varför Wazuh istället för bara fail2ban?

fail2ban blockerar lokalt på varje server.
Det ger ingen överblick över vad som händer
på hela infrastrukturen. Wazuh är ett SIEM-system
som samlar händelser från alla servrar centralt
och korrelerar dem. En angripare som försöker
brute-force-attacker mot flera servrar syns
omedelbart i Wazuh - inte bara på den enskilda
servern.

> Fullständig diskussion om designval finns i
> [docs/projektplan.md](docs/projektplan.md).

---

## Tekniska begränsningar och framtida förbättringar

### Varför Cockpit istället för Wazuh Dashboard

Wazuh Manager är installerad och körs korrekt på
monitor-servern. Wazuh-agenter körs på alla fem
övriga servrar och skickar säkerhetshändelser
till Manager i realtid. Det är den
säkerhetskritiska delen och den fungerar fullt ut.

Wazuh Dashboard (som körs via OpenSearch Dashboards,
tidigare kallad Kibana) installerades inte.
Anledningen är teknisk: OpenSearch Dashboards
kräver minst 4 GB RAM enbart för sig själv.
Värddatorn har 6.4 GB tillgängligt RAM totalt.
Med sex VMs igång samtidigt (totalt 5120 MB
tilldelat) fanns inget utrymme kvar för dashboarden
utan att riskera att hela miljön kraschade.

Cockpit valdes som alternativt övervakningsgränssnitt.
Cockpit är resurseffektivt (under 100 MB RAM),
installeras via ett enda apt-kommando och ger
tillräcklig systemöverblick för denna miljö:
CPU, minne, diskutrymme, aktiva tjänster och
loggar per server.

I en produktionsmiljö med dedikerad hårdvara
eller molninfrastruktur installeras OpenSearch
Dashboards för fullständig SIEM-visualisering.

### Framtida förbättringsmöjligheter

**1. Wazuh Dashboard (OpenSearch)**
Aktivera fullständig SIEM-visualisering när
hårdvaran tillåter. Kräver minst 8 GB RAM på hosten.

**2. Wazuh Active Response**
Konfigurera automatisk IP-blockering vid
brute-force-attacker. Wazuh-infrastrukturen
finns redan på plats - det är en
konfigurationsändring i ossec.conf.

**3. TLS mellan nginx och Flask**
Kryptera intern trafik med ett internt
CA-certifikat eller WireGuard overlay-nätverk.

**4. Automatisk failover**
Health checks i nginx med automatisk
bortkoppling av en server som inte svarar.
Konfigureras med `max_fails` och `fail_timeout`
i upstream-blocket i nginx.conf.

**5. listen_addresses på databasen**
Byt från `'*'` till specifika IP-adresser för
ett extra skyddslager. Redan dokumenterat som
känd avvägning i projektet.

**6. Secrets management**
Ersätt secrets.yml med HashiCorp Vault för
hantering av databasuppgifter och SSH-nycklar
i produktionsmiljö.

**7. CI/CD-pipeline**
Automatisera `vagrant destroy && vagrant up &&
ansible-playbook` med GitHub Actions för att
verifiera reproducerbarhet vid varje commit.

---

```
Projekt: Secure-Infra-Lab
Författare: Sushanta Shekhar Modak & Farhad Norman
GitHub: https://github.com/SSM-debug/Secure-Infra-Lab
Detaljerad logg: docs/log.md
Projektplan: docs/projektplan.md
Datum: 2026-05-11
```