# Secure-Infra-Lab

Du startar en server. En timme senare försöker
någon bruta-força SSH. Ser du det? Stoppar systemet
det automatiskt? Kan du bevisa att hela infrastrukturen
är identisk varje gång du bygger om den från grunden?

Secure-Infra-Lab svarar på dessa frågor med ett
hands-on laboratorium som automatiskt sätter upp
sex virtuella servrar med öppen källkod. Systemet
implementerar IaC (Infrastructure-as-Code), Defense-in-Depth
och fullständig reproducerbarhet - bevisad av 38
automatiserade tester varje gång.

**Prova det själv - fyra kommandon:**

```powershell
# 1. Starta alla 6 VMs automatiskt (15-20 min)
E:\Secure-Infra-Lab\vagrant> vagrant up
# Förväntat: === [servername]: ready === för varje VM
#            === SSH keys copied ===
```

```bash
# 2. Konfigurera hela infrastrukturen med Ansible (15-20 min)
vagrant@control:~$ ansible-playbook ~/ansible/site.yml
# Förväntat: failed=0 på alla 6 servrar
```

```bash
# 3. Verifiera från control-VM
vagrant@control:~$ bash ~/scripts/verify.sh
# Förväntat: PASS=38 FAIL=0
```

```powershell
# 4. Verifiera från Windows
E:\Secure-Infra-Lab> powershell -ExecutionPolicy Bypass -File .\scripts\verify_host.ps1
# Förväntat: PASS=6 FAIL=0
```

**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab

---

## Innehållsförteckning

- [Vad är Secure-Infra-Lab?](#vad-är-secure-infra-lab)
- [Arkitektur](#arkitektur)
- [Mappstruktur](#mappstruktur)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Verifiering och testresultat](#verifiering-och-testresultat)
- [Se det i aktion](#se-det-i-aktion)
- [Secrets](#secrets)
- [Ansible-roller](#ansible-roller)
- [Säkerhet i praktiken](#säkerhet-i-praktiken)
- [STRIDE-analys och hotmodellering](#stride-analys-och-hotmodellering)
- [CAP-teorem och SPoF-analys](#cap-teorem-och-spof-analys)
- [Designval och motivering](#designval-och-motivering)
- [Produktion och skalbarhet](#produktion-och-skalbarhet)
- [Kvarvarande brister](#kvarvarande-brister)
- [Felsökning - problem vi löste](#felsökning---problem-vi-löste)
- [Framtida förbättringsmöjligheter](#framtida-förbättringsmöjligheter)
- [Ordlista](#ordlista)

---

## Vad är Secure-Infra-Lab?

Secure-Infra-Lab är ett automatiserat laboratorium
för IT-säkerhet och infrastruktur byggt med öppen källkod.
Projektet demonstrerar hur en modern webbapplikation
kan driftsättas säkert med IaC (Infrastructure-as-Code) -
principen att hela infrastrukturen beskrivs som
versionshanterad kod, precis som applikationskoden.

**Teknisk stack:**

- **[Vagrant](https://www.vagrantup.com/)** - hanterar livscykeln för virtuella maskiner
- **[VirtualBox](https://www.virtualbox.org/)** - typ 2 hypervisor som kör VM:arna på Windows-hosten
- **[Ansible](https://docs.ansible.com/)** - konfigurationshanteringsverktyg som automatiserar hela infrastrukturen
- **[Flask](https://flask.palletsprojects.com/)** + **[Gunicorn](https://docs.gunicorn.org/)** - Python-webbapplikation med produktionsserver
- **[nginx](https://nginx.org/en/docs/)** - load balancer med round-robin och passive health checks
- **[PostgreSQL](https://www.postgresql.org/docs/)** - relationsdatabas isolerad med Defense-in-Depth
- **[Wazuh](https://documentation.wazuh.com/)** - SIEM (Security Information and Event Management) med Active Response
- **[Cockpit](https://cockpit-project.org/)** - webbaserat systemadministrationsgränssnitt för realtidsövervakning

**Varför hypervisor och inte containers?**

Projektet använder VirtualBox (typ 2 hypervisor) istället
för Docker/Podman (containers). Skillnaden är fundamental:

| | Hypervisor (VM) | Container |
|-|-----------------|-----------|
| Kärnisolering | Egen kärna per VM | Delar värdets kärna |
| RAM-användning | 512 MB - 2 GB per enhet | 10-100 MB per enhet |
| Starttid | 30-60 sekunder | Under 1 sekund |
| Säkerhetsisolering | Stark (hypervisor-gräns) | Svagare (container-escape möjlig) |
| Nätverksisolering | Komplett (egna gränssnitt) | Delat nätverksnamespace |
| Passar för | Komplett OS-simulering, nätverkslab | Mikroservices, applikationsdrift |

VMs valdes för detta projekt eftersom vi simulerar
en realistisk nätverksmiljö med separata servrar,
UFW-regler och SSH-härdning per server - något som
kräver fullständig OS-isolering. I produktion med
containerorkestrering (Kubernetes) skulle workloads
köras i containers, men infrastrukturlagret (nätverk,
säkerhet, monitoring) hanteras fortfarande på VM-nivå.

**IaC: Cattle vs Pets**

Traditionell serverhantering behandlar servrar som
"pets" (husdjur) - unika, manuellt konfigurerade
maskiner med namn och historia. IaC behandlar servrar
som "cattle" (boskap) - identiska, utbytbara enheter
beskrivna som kod. Om en server fallerar förstörs
den och ersätts automatiskt med en identisk kopia.
`vagrant destroy -f && vagrant up` bevisar detta
i praktiken.

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
|  |  Kör playbooks mot alla servrar via SSH           |  |
|  +-------------------+--------------------------------+  |
|                      | SSH (Ansible)                    |
|          +-----------+-----------+                      |
|          v           v           v                      |
|  +------------+ +----------+ +----------+              |
|  | nginx (.11)|  |web1 (.12)| |web2 (.13)|              |
|  | 768 MB     |  | 768 MB   | | 768 MB   |              |
|  | Port 8080  |  | Flask +  | | Flask +  |              |
|  | Load       |  | Gunicorn | | Gunicorn |              |
|  | Balancer   |  | Server 1 | | Server 2 |              |
|  +-----+------+ +----+-----+ +----+-----+              |
|        |    round-robin | HTTPS   |                     |
|        +--------------+------------+                    |
|                       | port 5432                        |
|                       | UFW: web1 och web2 only          |
|                       v                                  |
|  +----------------------------------------------------+  |
|  |  database (.14) - 1024 MB                         |  |
|  |  PostgreSQL                                       |  |
|  |  UFW blockerar allt utom web1 och web2            |  |
|  +----------------------------------------------------+  |
|                                                          |
|  +----------------------------------------------------+  |
|  |  monitor (.15) - 2048 MB                          |  |
|  |  Wazuh Manager + Cockpit (port 9090)              |  |
|  |  Tar emot säkerhetshändelser från alla agenter    |  |
|  +----------------------------------------------------+  |
|        ^           ^           ^          ^          ^   |
|        | Wazuh-agent (alla servrar utom monitor)        |
+----------------------------------------------------------+
```

### 3-tier-arkitektur

En 3-tier-arkitektur delar applikationen i tre logiska
lager med olika ansvar och säkerhetsnivåer. Varje lager
kommunicerar bara med angränsande lager.

**Lager 1 - Presentation (nginx .11)**
Tar emot all trafik utifrån via port 8080. Det är den enda
servern som nåbar utifrån dvs. från Windows-hosten. Fördelar förfrågningar
mellan web1 och web2 med round-robin. All intern
kommunikation mot Flask är krypterad med TLS
(Transport Layer Security) via självsignerade certifikat
genererade av Ansible.

**Lager 2 - Applikation (web1 .12, web2 .13)**
Flask körs via Gunicorn med 2 worker-processer.
Passive health checks med `max_fails=2 fail_timeout=30s`
gör att nginx automatiskt slutar skicka trafik till
en server som inte svarar - ingen manuell intervention.

**Lager 3 - Data (database .14)**
PostgreSQL isolerad med Defense-in-Depth på tre lager:
`listen_addresses`, UFW och pg_hba.conf. Ingen server
utom web1 och web2 kan ansluta - inte ens control-VM.

**Övervakning (monitor .15)**
Wazuh Manager samlar säkerhetshändelser från alla
fem servrar i realtid via krypterad TCP-kanal och
korrelerar dem centralt. Cockpit ger systemöverblick
via webbläsare på port 9090.

### draw.io-diagram

Öppna [docs/architecture.drawio](docs/architecture.drawio)
på https://diagrams.net. Välj File > Export as > PNG
för att exportera som bild.

<details>
<summary>Visa draw.io XML</summary>

```xml
<mxfile host="app.diagrams.net">
  <diagram name="Secure-Infra-Lab" id="0">
    <mxGraphModel dx="1885" dy="1084" grid="0" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="0" pageScale="1" pageWidth="1700" pageHeight="1200" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="host" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;strokeWidth=2;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;Windows 11 (host)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;:8080 nginx  |  :9090 Cockpit" vertex="1">
          <mxGeometry height="70" width="249" x="615" y="40" as="geometry" />
        </mxCell>
        <mxCell id="net" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=none;strokeColor=#aaaaaa;strokeWidth=2;dashed=1;fontSize=13;verticalAlign=top;spacingTop=12;fontColor=#666666;" value="&lt;font style=&quot;font-size: 13px;&quot;&gt;&lt;b&gt;Private network — 192.168.56.0/24&lt;/b&gt;&lt;/font&gt;" vertex="1">
          <mxGeometry height="760" width="1460" x="100" y="160" as="geometry" />
        </mxCell>
        <mxCell id="control" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#006EAF;strokeColor=#004d80;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;control (.10)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Ansible control node&lt;br&gt;192.168.56.10 | 1024 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="230" as="geometry" />
        </mxCell>
        <mxCell id="nginx" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#00897B;strokeColor=#004D40;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;nginx (.11)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Load balancer&lt;br&gt;192.168.56.11 | Port 8080 | 768 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="420" as="geometry" />
        </mxCell>
        <mxCell id="web1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;web1 (.12)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Flask + Gunicorn | Server 1&lt;br&gt;192.168.56.12 | 768 MB" vertex="1">
          <mxGeometry height="80" width="220" x="200" y="610" as="geometry" />
        </mxCell>
        <mxCell id="web2" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;web2 (.13)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Flask + Gunicorn | Server 2&lt;br&gt;192.168.56.13 | 768 MB" vertex="1">
          <mxGeometry height="80" width="220" x="1060" y="610" as="geometry" />
        </mxCell>
        <mxCell id="database" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;database (.14)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;PostgreSQL + UFW&lt;br&gt;192.168.56.14 | 1024 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="800" as="geometry" />
        </mxCell>
        <mxCell id="monitor" parent="1" style="rounded=1;whiteSpace=wrap;html=1;fillColor=#4527A0;strokeColor=#1A0073;strokeWidth=2;fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;monitor (.15)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Wazuh Manager + Cockpit&lt;br&gt;192.168.56.15 | Port 9090 | 2048 MB" vertex="1">
          <mxGeometry height="80" width="220" x="1060" y="800" as="geometry" />
        </mxCell>
        <mxCell id="rr_web1" edge="1" parent="1" source="nginx" target="web1" style="edgeStyle=orthogonalEdgeStyle;strokeColor=#3019FF;strokeWidth=2.5;fontStyle=1;fontSize=12;" value="round-robin | HTTPS">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="500" y="560" />
              <mxPoint x="310" y="560" />
              <mxPoint x="310" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="rr_web2" edge="1" parent="1" source="nginx" target="web2" style="edgeStyle=orthogonalEdgeStyle;strokeColor=#2D1EFF;strokeWidth=2.5;fontStyle=1;fontSize=12;" value="round-robin | HTTPS">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="980" y="560" />
              <mxPoint x="1170" y="560" />
              <mxPoint x="1170" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="db_web1" edge="1" parent="1" source="web1" target="database" style="edgeStyle=orthogonalEdgeStyle;strokeColor=#38F8FF;strokeWidth=2;fontSize=11;" value="port 5432">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="310" y="760" />
              <mxPoint x="630" y="760" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="w_all" edge="1" parent="1" source="database" target="monitor" style="edgeStyle=orthogonalEdgeStyle;strokeColor=#FF9696;strokeWidth=1.5;dashed=1;" value="Wazuh events">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ufw_label" parent="1" style="text;html=1;align=center;fontSize=10;fontStyle=2;fontColor=#1565C0;" value="UFW: port 5432 tillåts bara från web1 och web2" vertex="1">
          <mxGeometry height="18" width="340" x="530" y="888" as="geometry" />
        </mxCell>
        <mxCell id="leg" parent="1" style="rounded=1;fillColor=#ffffff;strokeColor=#cccccc;strokeWidth=1;" value="" vertex="1">
          <mxGeometry height="100" width="396" x="275" y="971" as="geometry" />
        </mxCell>
        <mxCell id="legtitle" parent="1" style="text;html=1;fontSize=13;" value="&lt;b&gt;Legend&lt;/b&gt;" vertex="1">
          <mxGeometry height="20" width="100" x="285" y="972" as="geometry" />
        </mxCell>
        <mxCell id="ll3" edge="1" parent="1" style="endArrow=block;endFill=1;strokeColor=#3019FF;strokeWidth=2.5;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1010" as="sourcePoint" />
            <mxPoint x="345" y="1010" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt3" parent="1" style="text;html=1;fontSize=11;" value="Round-robin lastbalansering (HTTPS/TLS)" vertex="1">
          <mxGeometry height="18" width="240" x="353" y="1002" as="geometry" />
        </mxCell>
        <mxCell id="ll4" edge="1" parent="1" style="endArrow=block;endFill=1;strokeColor=#38F8FF;strokeWidth=2;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1035" as="sourcePoint" />
            <mxPoint x="345" y="1035" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt4" parent="1" style="text;html=1;fontSize=11;" value="PostgreSQL port 5432 (UFW-begränsad)" vertex="1">
          <mxGeometry height="18" width="260" x="353" y="1027" as="geometry" />
        </mxCell>
        <mxCell id="ll5" edge="1" parent="1" style="endArrow=block;endFill=1;strokeColor=#FF9696;strokeWidth=1.5;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1058" as="sourcePoint" />
            <mxPoint x="345" y="1058" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt5" parent="1" style="text;html=1;fontSize=11;" value="Wazuh security events (krypterad TCP)" vertex="1">
          <mxGeometry height="18" width="230" x="353" y="1050" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

</details>

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
|   +-- verify.sh           # 38 automated tests from control-VM
|   +-- verify_host.ps1     # 6 automated tests from Windows host
|   +-- copy_keys.sh        # Copies Vagrant SSH keys automatically after vagrant up
|
+-- vagrant/
|   +-- Vagrantfile         # Defines all 6 VMs, RAM, network and triggers
|   +-- secrets.yml         # GITIGNORED - database credentials, create manually
|
+-- ansible/
    +-- ansible.cfg         # Ansible configuration (inventory path, SSH settings)
    +-- inventory.ini       # All servers, groups and SSH key paths
    +-- site.yml            # Master playbook - orchestrates all roles in order
    +-- vars/vars.yml       # Shared variables (IP addresses, ports, users)
    +-- host_vars/web2.yml  # server_name override for web2 (DRY principle)
    |
    +-- roles/
        +-- security_hardening/ # SSH hardening, fail2ban, auditd on all servers
        +-- flask/              # Flask + Gunicorn + TLS on web1 and web2
        +-- nginx/              # Load balancer with round-robin and health checks
        +-- database/           # PostgreSQL + UFW + pg_hba.conf isolation
        +-- wazuh_manager/      # Wazuh Manager + Active Response on monitor
        +-- wazuh_agent/        # Wazuh agents on control, nginx, web1, web2, database
        +-- cockpit/            # Web-based dashboard on monitor (port 9090)
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

> Detaljerad fas-för-fas-dokumentation finns i
> [docs/log.md](docs/log.md).

---

## Krav och förutsättningar

**Programvara (Windows-hosten):**

- [VirtualBox 7.x](https://www.virtualbox.org/) - typ 2 hypervisor för VM-hantering
- [Vagrant 2.x](https://www.vagrantup.com/) - VM-livscykelhantering via kod
- [Git](https://git-scm.com/) - versionshantering
- [VS Code](https://code.visualstudio.com/) - rekommenderas för YAML-redigering

**Hårdvarukrav:**

Minst **10 GB RAM** och **20 GB** ledigt diskutrymme krävs.

**Miljöer och IP-adresser:**

| Server | IP-adress | Roll | Port forwarding | RAM |
|--------|-----------|------|-----------------|-----|
| control | 192.168.56.10 | Ansible control node | - | 1024 MB |
| nginx | 192.168.56.11 | Load balancer | 80 → host:8080 | 768 MB |
| web1 | 192.168.56.12 | Flask + Gunicorn (Server 1) | - | 768 MB |
| web2 | 192.168.56.13 | Flask + Gunicorn (Server 2) | - | 768 MB |
| database | 192.168.56.14 | PostgreSQL + UFW | - | 1024 MB |
| monitor | 192.168.56.15 | Wazuh Manager + Cockpit | 9090 → host:9090 | 2048 MB |
| **Totalt** | | | | **6400 MB** |

Alla servrar kör Ubuntu 22.04 LTS (ubuntu/jammy64)
i ett isolerat host-only nätverk (192.168.56.0/24).
Bara nginx (port 8080) och monitor (port 9090) är
nåbara från Windows-hosten via port forwarding.

---

## Kom igång

### Steg 1 - Klona repot

```powershell
E:\> git clone https://github.com/SSM-debug/Secure-Infra-Lab.git
E:\> cd Secure-Infra-Lab
```

### Steg 2 - Skapa secrets-filen

Filen innehåller databasuppgifter och gitignoreras -
den publiceras aldrig på GitHub. Secrets separeras
från kod för att förhindra att lösenord hamnar i
versionshistoriken - ett av de vanligaste säkerhetsmissarna
i moderna system.

```powershell
E:\Secure-Infra-Lab> code vagrant\secrets.yml
```

Klistra in exakt detta innehåll:

```yaml
---
db_name: flaskdb
db_user: flaskuser
db_password: ditt-lösenord-här
```

### Steg 3 - Starta alla 6 VMs

```powershell
# Vagrant skapar VMs, installerar Ansible,
# genererar SSH-nycklar och kopierar dem automatiskt
E:\Secure-Infra-Lab\vagrant> vagrant up
```

Tar 15-20 minuter. Förväntat output per server:

```
=== control: ready ===
=== nginx: ready ===
=== web1: ready ===
=== web2: ready ===
=== database: ready ===
=== monitor: ready ===
=== SSH keys copied ===   ← SSH-nycklar kopierade automatiskt via trigger
```

### Steg 4 - Konfigurera infrastrukturen med Ansible

```powershell
# Logga in på control-VM
E:\Secure-Infra-Lab\vagrant> vagrant ssh control
```

```bash
# Ansible konfigurerar alla 6 servrar automatiskt
# OBS: Wazuh Manager-installation tar 10-15 minuter
vagrant@control:~$ ansible-playbook ~/ansible/site.yml
```

Förväntat slutresultat - `failed=0` på alla servrar:

```
PLAY RECAP
control  : ok=13 changed=9  failed=0
database : ok=31 changed=23 failed=0
monitor  : ok=17 changed=13 failed=0
nginx    : ok=20 changed=14 failed=0
web1     : ok=26 changed=20 failed=0
web2     : ok=26 changed=20 failed=0
```

### Tillgängliga tjänster

| URL | Vad du ser |
|-----|-----------|
| `http://localhost:8080/` | "Hello from Server 1!" eller "Server 2!" |
| `http://localhost:8080/visit` | Registrerar besök, visar de 5 senaste |
| `http://localhost:8080/secret` | Laddade miljövariabler |
| `https://localhost:9090` | Cockpit dashboard - öppna i inkognito-fönster (vagrant/vagrant) |

> **OBS:** Cockpit använder ett självsignerat TLS-certifikat.
> Öppna i inkognito-fönster (Ctrl+Shift+N) för att
> undvika cachade certifikatfel. Acceptera certifikatvarningen
> för att fortsätta.

> Detaljerade kommandon för varje fas finns i
> [docs/log.md](docs/log.md).

---

## Verifiering och testresultat

Verifieringen bevisar att infrastrukturen är korrekt
konfigurerad och fullständigt reproducerbar - körs
direkt efter `ansible-playbook` för att bekräfta
att allt fungerar som förväntat.

### verify.sh - 38 tester från control

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh)

```bash
vagrant@control:~$ bash ~/scripts/verify.sh
```

| Testkategori | Antal tester |
|-------------|-------------|
| nginx HTTP 200 | 1 |
| Round-robin Server 1 och Server 2 | 2 |
| web1 når databasen (port 5432) | 1 |
| Extern blockeras från databasen | 1 |
| Flask aktiv på web1 och web2 | 2 |
| fail2ban aktiv på alla 6 servrar | 6 |
| auditd aktiv på alla 6 servrar | 6 |
| Lösenordsinloggning inaktiverad (alla 6) | 6 |
| Root-inloggning inaktiverad (alla 6) | 6 |
| Wazuh-agent aktiv på 5 servrar | 5 |
| Wazuh Manager aktiv på monitor | 1 |
| Cockpit svarar på port 9090 | 1 |
| **Totalt** | **38** |

Förväntat output:

```
==============================
 Secure-Infra-Lab Verify
==============================
PASS: nginx HTTP 200
PASS: Round-robin Server 1
PASS: Round-robin Server 2
PASS: web1 reaches database:5432
PASS: External blocked from database:5432
...
==============================
 Results: PASS=38 FAIL=0
==============================
```

### verify_host.ps1 - 6 tester från Windows

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1)

```powershell
E:\Secure-Infra-Lab> powershell -ExecutionPolicy Bypass -File .\scripts\verify_host.ps1
```

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

### Reproducerbarhet bevisad

```powershell
# Förstör ALLT och bygg om från grunden
E:\Secure-Infra-Lab\vagrant> vagrant destroy -f ; vagrant up
```

```bash
vagrant@control:~$ ansible-playbook ~/ansible/site.yml
vagrant@control:~$ bash ~/scripts/verify.sh
# Results: PASS=38 FAIL=0 - varje gång, utan manuella ingrepp
```

38/38 och 6/6 varje gång bevisar att infrastrukturen
är fullständigt reproducerbar - IaC i praktiken.

---

## Se det i aktion

### Round-robin lastbalansering

nginx växlar automatiskt mellan web1 och web2:

```bash
vagrant@control:~$ curl http://192.168.56.11/
Hello from Server 1!

vagrant@control:~$ curl http://192.168.56.11/
Hello from Server 2!   # ← automatisk växling

vagrant@control:~$ curl http://192.168.56.11/
Hello from Server 1!
```

### Automatisk failover

Stäng av web1 - web2 tar över utan intervention:

```bash
# Simulera ett serverfel
E:\Secure-Infra-Lab\vagrant> vagrant halt web1

# Alla requests går automatiskt till web2
vagrant@control:~$ for i in {1..5}; do curl http://192.168.56.11/; done
Hello from Server 2!
Hello from Server 2!
Hello from Server 2!
Hello from Server 2!
Hello from Server 2!   # ← ingen timeout, inga fel

# Starta web1 - round-robin återupptas automatiskt
E:\Secure-Infra-Lab\vagrant> vagrant up web1
```

### Wazuh + Active Response: en attack i realtid

En angripare försöker bruta-força SSH:

```
Sekund 1:  Första SSH-försöket misslyckas
           → auditd loggar händelsen i /var/log/audit/audit.log

Sekund 10: Femte försöket misslyckas
           → fail2ban blockerar angriparens IP lokalt

Sekund 11: Wazuh-agenten skickar händelsedata till Manager
           → krypterad TCP-kanal till 192.168.56.15:1514

Sekund 12: Wazuh Manager analyserar mot regeluppsättningen
           → Regel 5763 triggas (level 10)

Sekund 13: Active Response aktiveras automatiskt
           → firewall-drop: iptables -I INPUT -s <IP> -j DROP

Sekund 14: Angriparen blockerad i 300 sekunder
```

```bash
vagrant@monitor:~$ sudo tail -f /var/ossec/logs/alerts/alerts.log
** Alert: Rule 5763 - sshd: Multiple failed logins
Active Response: firewall-drop - IP blocked for 300 seconds
```

### Verifiera Defense-in-Depth

```bash
# Lager 1: PostgreSQL lyssnar bara på sin egen IP
vagrant@database:~$ sudo -u postgres psql -c "SHOW listen_addresses;"
 listen_addresses
------------------
 192.168.56.14
(1 row)   # ← Inte '*' - Defense-in-Depth aktivt

# Lager 2: UFW-regler
vagrant@database:~$ sudo ufw status verbose
5432/tcp  ALLOW IN  192.168.56.12   ← web1
5432/tcp  ALLOW IN  192.168.56.13   ← web2
Default:  deny (incoming)

# Lager 3: pg_hba.conf
vagrant@database:~$ sudo grep flaskuser /etc/postgresql/14/main/pg_hba.conf
host flaskdb flaskuser 192.168.56.12/32 md5
host flaskdb flaskuser 192.168.56.13/32 md5
```

---

## Secrets

Filen `vagrant/secrets.yml` gitignoreras alltid
och publiceras aldrig på GitHub.

Varför separera secrets från kod? Botar skannar
GitHub kontinuerligt och hittar hårdkodade lösenord
inom minuter efter publicering. Secrets i gitignorerad
fil är minimikravet - i produktion används dedikerade
secrets managers som HashiCorp Vault.

Secrets laddas automatiskt av Vagrant och kopieras
till control-VM. Varje play i playbooken refererar:

```yaml
vars_files:
  - vars/vars.yml
  - secrets.yml
```

Verifiera att secrets aldrig committats:

```powershell
E:\Secure-Infra-Lab> git log --all -- vagrant/secrets.yml
# Förväntat: tom output
```

---

## Ansible-roller

Ansible organiserar konfigurationsuppgifter i
**roller** - återanvändbara enheter med eget ansvar.
`site.yml` orchestrerar rollerna i kritisk ordning:

```
1. security_hardening → alla 6 servrar (säkerhetsbaslinje)
2. database           → PostgreSQL + UFW + pg_hba.conf
3. flask              → web1 och web2 (Flask + Gunicorn + TLS)
4. nginx              → load balancer med round-robin
5. wazuh_manager      → Wazuh Manager + Active Response
6. cockpit            → webbaserad dashboard
7. wazuh_agent        → agenter på 5 servrar (sist)
```

---

### security_hardening

**Vad är SSH-härdning?**
SSH-härdning (hardening) innebär att man stänger
alla onödiga inloggningsvägar och begränsar de
som finns kvar. Ubuntu:s standardkonfiguration
är tillåtande - lösenordsinloggning aktiv, root
kan logga in. Härdning stänger dessa risker.

**Härdningsåtgärder:**
- `PermitRootLogin no` - ingen root-åtkomst via SSH (Least Privilege)
- `PasswordAuthentication no` - bara SSH-nyckelautentisering
- `MaxAuthTries 3` - max 3 försök per anslutning
- `ClientAliveInterval 300` - inaktiva sessioner stängs efter 5 min
- **fail2ban** - blockerar IP efter 5 misslyckade försök inom 10 min
- **auditd** - loggar alla kommandon, filändringar och inloggningar

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml)
- [templates/sshd_config.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2)

**Officiell dokumentation:** [docs.ansible.com](https://docs.ansible.com/ansible/latest/)

> Detaljer om implementation finns i [docs/log.md - Fas 2](docs/log.md).

---

### database

**Vad är Defense-in-Depth för en databas?**
Defense-in-Depth innebär att samma resurs skyddas
av flera oberoende lager. För PostgreSQL används tre:

```
Lager 1 - listen_addresses = 192.168.56.14
          PostgreSQL lyssnar BARA på sin egen IP

Lager 2 - UFW blockerar port 5432 på nätverksnivå
          Bara web1 och web2 har tillstånd

Lager 3 - pg_hba.conf med md5-regler per IP (/32-mask)
          Autentisering kontrolleras per exakt IP-adress
```

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/tasks/main.yml)
- [templates/schema.sql.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/templates/schema.sql.j2)

**Officiell dokumentation:** [postgresql.org/docs](https://www.postgresql.org/docs/)

> Detaljer om implementation finns i [docs/log.md - Fas 4](docs/log.md).

---

### flask

**Vad är Principle of Least Privilege?**
Least Privilege innebär att varje process bara har
de rättigheter den absolut behöver. Flask körs som
`vagrant`, inte root. Om Flask komprometteras får
angriparen bara vagrant-rättigheter.

Säkerhetshärdning i systemd-tjänsten:
- `User=vagrant` - körs som icke-privilegierad användare
- `NoNewPrivileges=true` - kan inte skaffa fler rättigheter
- `PrivateTmp=true` - isolerad /tmp-mapp per tjänst
- `EnvironmentFile=/etc/flask.env` - secrets med mode 0600

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/tasks/main.yml)
- [files/app.py](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/files/app.py)
- [templates/flask.service.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.service.j2)
- [templates/flask.env.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.env.j2)

**Officiell dokumentation:** [flask.palletsprojects.com](https://flask.palletsprojects.com/) | [docs.gunicorn.org](https://docs.gunicorn.org/)

> Detaljer om implementation finns i [docs/log.md - Fas 5](docs/log.md).

---

### nginx

**Vad är passive health checks?**
Passive health checks innebär att nginx övervakar
riktiga förfrågningar för att avgöra om en server
fungerar - inga separata test-förfrågningar behövs.

```nginx
upstream flask_servers {
    server {{ webserver_ip }}:5000 max_fails=2 fail_timeout=30s;
    server {{ webserver2_ip }}:5000 max_fails=2 fail_timeout=30s;
}
```

`max_fails=2` → markera server som nere efter 2 fel
`fail_timeout=30s` → prova igen efter 30 sekunder

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/tasks/main.yml)
- [templates/nginx.conf.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/templates/nginx.conf.j2)

**Officiell dokumentation:** [nginx.org/en/docs](https://nginx.org/en/docs/)

> Detaljer om implementation finns i [docs/log.md - Fas 6](docs/log.md).

---

### wazuh_manager

**Vad är ett SIEM-system?**
SIEM (Security Information and Event Management) är
ett centralt system som samlar, normaliserar och
analyserar säkerhetshändelser från hela infrastrukturen.
Till skillnad från lokala verktyg som fail2ban ger
SIEM en helhetsbild och kan korrelera händelser
från flera servrar - till exempel att en angripare
testar flera servrar i sekvens (lateral movement,
MITRE ATT&CK T1021).

**MITRE ATT&CK** är ett globalt ramverk som
dokumenterar kända angreppstekniker och taktiker.
Wazuh har inbyggda detektionsregler mappade mot
MITRE ATT&CK-kategorier.

Wazuh Manager kör på monitor (192.168.56.15).
Konfigurationsfilen `ossec.conf.j2` definierar
Active Response:

```xml
<!-- /var/ossec/etc/ossec.conf på monitor -->
<command>
  <name>firewall-drop</name>
  <executable>firewall-drop</executable>
  <timeout_allowed>yes</timeout_allowed>
</command>

<active-response>
  <command>firewall-drop</command>
  <location>local</location>   <!-- körs på angripen agent -->
  <rules_id>5763</rules_id>    <!-- SSH Authentication Failure -->
  <timeout>300</timeout>       <!-- blockeras 5 minuter -->
</active-response>
```

**Verifiera Wazuh Manager:**

```bash
vagrant@monitor:~$ sudo systemctl status wazuh-manager
vagrant@monitor:~$ sudo /var/ossec/bin/wazuh-control status
# wazuh-analysisd, wazuh-remoted, wazuh-logcollector: running
```

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/tasks/main.yml)
- [templates/ossec.conf.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/templates/ossec.conf.j2)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

> Detaljer om implementation finns i [docs/log.md - Fas 7](docs/log.md).

---

### wazuh_agent

**Vad gör Wazuh-agenten konkret?**
Wazuh-agenten körs som bakgrundstjänst och utför tre
huvuduppgifter på varje övervakad server:

1. **Log collection** - läser `/var/log/auth.log`,
   `/var/log/syslog` och systemloggar i realtid
2. **FIM (File Integrity Monitoring)** - övervakar
   kritiska kataloger (`/etc`, `/usr/bin`) och larmar
   vid oväntade ändringar
3. **Rootkit detection** - kontrollerar regelbundet
   efter tecken på komprometterade system

Alla händelser skickas via krypterad TCP till Wazuh
Manager på 192.168.56.15:1514.

**Verifiera agent-kommunikation:**

```bash
vagrant@web1:~$ sudo systemctl status wazuh-agent
# Active: active (running)
```

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/tasks/main.yml)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

---

### cockpit

**Vad är Cockpit och varför valdes det?**
Cockpit är ett webbaserat systemadministrationsgränssnitt
för Linux. Det kräver inga extra agenter och använder
under 100 MB RAM - jämfört med Wazuh Dashboard
(OpenSearch) som kräver 4+ GB.

**Vad ser du i Cockpit?**
- **Overview** - CPU, RAM, diskutrymme, uptime i realtid
- **Services** - status för wazuh-manager, fail2ban, auditd, nginx
- **Networking** - gränssnitt (enp0s3: NAT, enp0s8: 192.168.56.15)
- **Terminal** - webbläsarbaserad terminal
- **Logs** - systemd journal filtrerad per tjänst

**Live-demonstration:**
```bash
# I Cockpit Terminal - visa Wazuh-larm live
sudo tail -20 /var/ossec/logs/alerts/alerts.log

# Visa fail2ban-status
sudo fail2ban-client status sshd
```

Nåbar via: `https://localhost:9090`
Öppna i inkognito-fönster. Logga in med vagrant/vagrant.

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/tasks/main.yml)

**Officiell dokumentation:** [cockpit-project.org](https://cockpit-project.org/)

> Detaljer om alla roller finns i [docs/projektplan.md - Avsnitt 8](docs/projektplan.md).

---

## Säkerhet i praktiken

Defense-in-Depth - varje komponent skyddas av
flera oberoende lager:

| Åtgärd | Var | Verifieras med |
|--------|-----|----------------|
| SSH root-inloggning inaktiverad | Alla | `sudo sshd -T \| grep permitrootlogin` |
| Lösenordsinloggning inaktiverad | Alla | `sudo sshd -T \| grep passwordauthentication` |
| UFW aktiv | database | `sudo ufw status verbose` |
| Port 5432 blockerad utifrån | database | verify_host.ps1 test 6 |
| Port 5432 tillgänglig från web1/web2 | database | verify.sh test 4 |
| fail2ban aktiv | Alla | `systemctl is-active fail2ban` |
| auditd aktiv | Alla | `systemctl is-active auditd` |
| Wazuh-agent aktiv (SIEM) | 5 servrar | `systemctl is-active wazuh-agent` |
| Flask kör som vagrant, ej root | web1, web2 | `ps aux \| grep gunicorn` |
| TLS krypterad kommunikation | nginx → Flask | `curl -k https://192.168.56.12:5000/` |
| Secrets aldrig i Git | Alla | `git log --all -- vagrant/secrets.yml` |

> Fullständig säkerhetsanalys finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

---

## STRIDE-analys och hotmodellering

STRIDE är ett hotmodelleringsramverk för att
systematiskt identifiera säkerhetshot:

| Bokstav | Hotkategori | Enkelt förklarat |
|---------|-------------|-----------------|
| **S**poofing | Identitetsförfalskning | "Jag låtsas vara web1 mot databasen" |
| **T**ampering | Datamanipulering | "Jag ändrar Flask-koden på disk" |
| **R**epudiation | Förnekelse | "Ingen kan bevisa att jag gjorde det" |
| **I**nformation Disclosure | Informationsläckage | "Jag hittar lösenordet i koden" |
| **D**enial of Service | Tillgänglighetsattack | "Jag gör servern otillgänglig" |
| **E**levation of Privilege | Privilegieeskalering | "Jag skaffar root-rättigheter" |

### Hotmodelleringsscenario: vad händer om web1 komprometteras?

En angripare med kontroll över web1 **KAN:**
- Läsa databasuppgifter i `/etc/flask.env`
- Ansluta till PostgreSQL på port 5432 (web1 tillåts av UFW)
- Skriva falska poster till visits-tabellen
- Skanna det interna nätverket (192.168.56.0/24)

En angripare på web1 **KAN INTE:**
- Logga in på andra servrar via SSH
- Nå monitor direkt (inget undantag i UFW)
- Eskalera till root (`NoNewPrivileges` i systemd)
- Göra filändringar utan att auditd loggar dem
- Undvika Wazuh-detektering

**Wazuh detekterar automatiskt:**
- Ovanliga processer (MITRE ATT&CK T1059)
- SSH-anslutningsförsök mot andra servrar (T1021)
- Filändringar i `/etc`, `/usr/bin` (FIM-larm)

> Detaljerad beskrivning finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

### STRIDE-tabell

| Hot | Kategori | Komponent | Skydd |
|-----|----------|-----------|-------|
| Fejka web1/web2 mot databasen | Spoofing | database | pg_hba.conf med `/32`-mask |
| Ändra Flask-applikationens kod | Tampering | web1, web2 | auditd loggar filändringar |
| Ingen loggning av DB-transaktioner | Repudiation | database | auditd + Wazuh FIM |
| Databasuppgifter på GitHub | Info Disclosure | web1, web2 | secrets.yml gitignoreras |
| Miljövariabler läcker | Info Disclosure | web1, web2 | EnvironmentFile mode 0600 |
| nginx överbelastas | Denial of Service | nginx | round-robin fördelar last |
| SSH brute-force | Denial of Service | Alla | fail2ban + Wazuh Active Response |
| Eskalera från web1 till database | Elevation of Privilege | database | UFW + pg_hba.conf |
| Root-åtkomst via SSH | Elevation of Privilege | Alla | `PermitRootLogin no` |

---

## CAP-teorem och SPoF-analys

### CAP-teoremet

CAP-teoremet (Brewer, 2000) säger att ett distribuerat
system aldrig kan garantera alla tre egenskaper samtidigt:

| Egenskap | Förklaring | Praktiskt exempel |
|----------|------------|------------------|
| **C**onsistency | Alla noder ser samma data | Alla kassor visar samma saldo direkt |
| **A**vailability | Systemet svarar alltid | Kassan svarar alltid, även om svaret kan vara gammalt |
| **P**artition tolerance | Fungerar trots nätverksavbrott | Kassan fungerar även om serverrummet tappar nät |

**Vårt val: AP-system** (Availability + Partition tolerance)

- Om web1 faller tar web2 över direkt → **tillgänglighet** uppnås
- Sessionsdata kan gå förlorad vid failover → **konsistensoffret**
- PostgreSQL är ett SPoF - om databasen faller slutar /visit fungera

I produktion löses detta med PostgreSQL streaming
replication (primary → replica), som ger både
HA (High Availability) och partitionstolerans.

### SPoF-analys (Single Point of Failure)

SPoF är en komponent vars haveri stoppar hela
eller delar av systemet. Att identifiera och
dokumentera SPoF:ar är ett tecken på mogen systemdesign.

| Komponent | SPoF? | Konsekvens | Lösning i produktion |
|-----------|-------|------------|---------------------|
| nginx | **Ja** | Hela systemet otillgängligt | Keepalived/VRRP med Virtual IP |
| web1 | Nej | web2 tar över automatiskt | Passive health checks (implementerat) |
| web2 | Nej | web1 tar över automatiskt | Passive health checks (implementerat) |
| database | **Ja** | /visit slutar fungera | PostgreSQL primary/replica |
| monitor | Nej | Övervakning faller bort | Redundant SIEM-nod |
| control | Nej | Ansible körs inte | Ny control-VM |

---

## Designval och motivering

### Varför separata VMs för varje lager?

Nätverkssegmentering kräver fullständig OS-isolering.
Med separata VMs tillämpas UFW-regler på nätverksnivå -
om webbservern komprometteras blockerar UFW åtkomst
till databasen. En monolitisk server saknar detta
skydd. Detta är Zero Trust Architecture i praktiken:
"never trust, always verify" gäller även intern trafik.

### Varför Gunicorn?

Flasks inbyggda server är entrådig och märkt
"NOT FOR PRODUCTION USE" i dokumentationen.
Gunicorn kör parallella worker-processer och är
industristandard. `Restart=always` i systemd ger
automatisk återhämtning vid krascher - ett krav
för HA (High Availability).

### Varför Jinja2-templates?

IP-adresser hämtas från `vars.yml` via Jinja2.
Lägga till web3 kräver bara en rad i `inventory.ini`
och en playbook-körning - ingen manuell nginx-konfiguration.
Det är DRY-principen (Don't Repeat Yourself) i IaC.

### Varför en gemensam flask-roll?

DRY-principen. `host_vars/web2.yml` överskriver
`server_name` för web2 via Ansibles variabelprioritering.
Duplicering skapar underhållsskuld - en ändring måste
annars göras på två ställen.

### Varför security_hardening körs först?

Secure-by-Default-principen. Säkerhetsbaslinje
måste finnas innan tjänster exponeras. Annars
finns ett tidsfönster där servern är oskyddad.

### Varför Wazuh och inte bara fail2ban?

fail2ban blockerar lokalt per server utan helhetsbild.
Wazuh är ett SIEM-system som samlar händelser centralt
och korrelerar dem. Lateral movement (angripare som
rör sig mellan servrar) syns i Wazuh - inte lokalt.

### Cattle vs Pets: Varför IaC?

Traditionell hantering behandlar servrar som "pets"
(husdjur) - unika, manuellt konfigurerade. IaC behandlar
dem som "cattle" (boskap) - identiska, utbytbara.
`vagrant destroy -f && vagrant up` är beviset:
hela infrastrukturen återskapas identiskt från kod.

> Fullständig diskussion finns i [docs/projektplan.md](docs/projektplan.md).

---

## Produktion och skalbarhet

### Lägga till en tredje webbserver

```ini
# 1. ansible/inventory.ini
[webserver3_g]
web3 ansible_host=192.168.56.16 ansible_user=vagrant ...
```

```yaml
# 2. ansible/vars/vars.yml
webserver3_ip: "192.168.56.16"
```

```bash
# 3. nginx uppdateras automatiskt via Jinja2
vagrant@control:~$ ansible-playbook ~/ansible/site.yml
```

### Labb vs produktion

| Laboratoriet | Produktionsmiljön |
|-------------|------------------|
| Vagrant + VirtualBox (typ 2) | AWS/Azure eller bare metal |
| Statiska privata IP:er | DNS + cloud load balancers |
| secrets.yml | HashiCorp Vault eller AWS Secrets Manager |
| Cockpit | Wazuh Dashboard (OpenSearch) + SOC-team |
| Självsignerat TLS | CA-signerat certifikat (Let's Encrypt) |
| Manuell playbook | CI/CD-pipeline (GitHub Actions) |
| Inga backups | Automatiserade PostgreSQL-dumps till S3 |

> Fullständig diskussion finns i
> [docs/projektplan.md - Avsnitt 10](docs/projektplan.md).

---

## Kvarvarande brister

**Brist 1 - nginx är SPoF (Single Point of Failure)**

nginx är enda ingångspunkten. Om nginx-VM kraschar
är hela systemet otillgängligt utifrån.

Accepterat i laboratoriet. I produktion:
Keepalived + VRRP med Virtual IP för automatisk failover.

**Brist 2 - database är SPoF**

Ingen PostgreSQL-replikering. Om database-VM kraschar
slutar /visit fungera.

Accepterat i laboratoriet. I produktion:
PostgreSQL streaming replication eller AWS RDS Multi-AZ.

**Brist 3 - secrets.yml i klartext på disk**

Databasuppgifter okrypterade i secrets.yml på
control-VM. Gitignoreras men läsbar på disk.

Accepterat i laboratoriet. I produktion:
HashiCorp Vault med dynamiska, automatiskt roterade uppgifter.

**Brist 4 - Ingen CI/CD-pipeline**

Reproducerbarhet verifieras manuellt. Ingen automatisk
verifiering vid commit.

Accepterat i laboratoriet. I produktion:
GitHub Actions på självhostad runner.

**Brist 5 - Självsignerat TLS-certifikat**

`proxy_ssl_verify off` i nginx - kryptering fungerar
men identiteten verifieras inte. MITM-angrepp möjligt
på internt nätverk.

Accepterat i isolerad labbmiljö. I produktion:
internt CA, `proxy_ssl_verify on`, certifikatpinning.

**Brist 6 - secrets.yml i Vagrantfile**

Databasuppgifter skapas automatiskt för att eliminera
manuella steg. Acceptabelt i isolerad labbmiljö.
I produktion: CI/CD-miljövariabler injicerade vid deploy.

---

## Felsökning - problem vi löste

Verkliga tekniska utmaningar dokumenterade med
rotorsak, lösning och lärdomar. Systematisk felsökning
demonstrerar djupare förståelse än ett projekt
som fungerar perfekt från start.

### Problem 1: Ansible ignorerade ansible.cfg

**Symptom:**
```
[WARNING]: Ansible is being run in a world writable directory,
ignoring it as an ansible.cfg source.
```

**Rotorsak:** Vagrant monterar synced_folder med 0777
på Windows/NTFS. Ansible vägrar läsa ansible.cfg
från world-writable kataloger av säkerhetsskäl.

**Lösning:** Kopiera ansible.cfg till `/etc/ansible/`
i Vagrantfile provisioning:
```ruby
cp /home/vagrant/ansible/ansible.cfg /etc/ansible/ansible.cfg
```

**Lärdom:** Förstå varför verktyg har säkerhetskontroller
innan du kringgår dem. Kontrollen är korrekt i produktion.

---

### Problem 2: SSH-nycklar kopierades för tidigt

**Symptom:**
```
cp: cannot stat '.../private_key': No such file or directory
```

**Rotorsak:** Race condition - control provisionerades
innan de andra VM:arna genererat sina SSH-nycklar.

**Lösning:** Vagrant trigger `after :up` körs EFTER
att alla VM:ar är uppe:
```ruby
config.trigger.after :up do |trigger|
  trigger.run = {
    inline: "vagrant ssh control -c 'bash /home/vagrant/scripts/copy_keys.sh'"
  }
end
```

**Lärdom:** Race conditions är vanliga i distribuerade
miljöer. Triggers löser timing-problem elegant.

---

### Problem 3: PostgreSQL startade inte

**Symptom:**
```
FATAL: could not create any TCP/IP sockets
WARNING: could not bind IPv4 address "192.168.56.12"
```

**Rotorsak:** Felaktig förståelse av `listen_addresses`.
Vi satte det till web1/web2:s IP:er i tron att det
begränsade anslutningar - PostgreSQL försökte istället
binda (lyssna på) dessa adresser som inte tillhörde
database-VM.

**Lösning:**
```yaml
line: "listen_addresses = '{{ database_ip }}'"
# database_ip = 192.168.56.14 (database-VM:s egen IP)
```

**Lärdom:** `listen_addresses` styr VILKET gränssnitt
PostgreSQL lyssnar PÅ. `pg_hba.conf` och UFW styr
VARIFRÅN anslutningar tillåts. Fundamentalt olika.

---

### Problem 4: Wazuh Manager startade inte

**Symptom:**
```
chgrp failed: failed to look up group ossec
```

**Rotorsak:** Wazuh 4.x döpte om systemgruppen
från `ossec` till `wazuh`.

**Lösning:**
```yaml
group: wazuh   # Inte 'ossec'
```

**Lärdom:** Kontrollera alltid release notes vid
versionsuppgraderingar. Namnbyten är breaking changes.

---

### Problem 5: Active Response fungerade inte

**Symptom:**
```
ERROR: (1303): Invalid command 'firewall-drop'
```

**Rotorsak:** Wazuh 4.x kräver explicit `<command>`-
definition. Äldre versioner hade inbyggda defaults.

**Lösning:**
```xml
<command>
  <name>firewall-drop</name>
  <executable>firewall-drop</executable>
  <timeout_allowed>yes</timeout_allowed>
</command>
```

**Lärdom:** Var explicit - skriv konfigurationen
istället för att lita på defaults som kan försvinna.

---

### Problem 6: RAM-brist (OOM)

**Symptom:**
```
fatal: [web1]: FAILED! => {"rc": 137}
```

**Rotorsak:** rc=137 betyder att kernel OOM killer
(Out of Memory) dödade processen. VMs med 512 MB RAM
fick slut på minne under Wazuh-installation.

**Lösning:**
```ruby
vb.memory = 768   # Upp från 512 MB
```

**Lärdom:** rc=137 = OOM kill. Kontrollera `free -m`
vid mystiska process-crashes.

---

## Framtida förbättringsmöjligheter

**1. Wazuh Dashboard (OpenSearch)**
Fullständig SIEM-visualisering. Kräver 4+ GB RAM
enbart för OpenSearch - inte möjligt med nuvarande hårdvara.

**2. Secrets management (HashiCorp Vault)**
Dynamiska databasuppgifter som roteras automatiskt.
Integreras med Ansible via `hashi_vault` lookup-plugin.

**3. CI/CD-pipeline (GitHub Actions)**
Automatisera destroy/up/playbook på självhostad runner
vid varje commit till main.

**4. PostgreSQL-replikering**
Streaming replication eliminerar database som SPoF
och möjliggör zero-downtime vid underhåll.

**5. Keepalived/VRRP**
Redundant nginx med Virtual IP eliminerar nginx som SPoF.

**6. Container-migrering**
Migrera Flask och nginx till Docker/Podman för snabbare
deployment. Jämföra hypervisor-baserad (nuvarande) vs
container-baserad är ett naturligt nästa steg i
labbmiljöns utveckling.

---

## Ordlista

### Active Response (Wazuh)
Automatisk motåtgärd triggas av Wazuh-regler.
`firewall-drop` kör `iptables -I INPUT ... -j DROP`
på agenten och blockerar angriparens IP automatiskt.

### Ansible
Konfigurationshanteringsverktyg som automatiserar
serverinstallation och konfiguration via SSH.
Beskriver önskat tillstånd deklarativt - Ansible
räknar ut hur det ska uppnås.

### auditd
Linux audit-daemon. Loggar systemhändelser som
filåtkomst, processstart och inloggningar för
spårbarhet och forensisk analys.

### CAP-teoremet
Brewer, 2000: Ett distribuerat system kan maximalt
garantera två av tre egenskaper: Consistency (C),
Availability (A), Partition tolerance (P).

### CI/CD (Continuous Integration/Continuous Deployment)
Automatisering av bygg, test och driftsättning
vid varje kodändring. Möjliggör snabb och tillförlitlig
mjukvaruleverans. *Verktyg: GitHub Actions, GitLab CI.*

### Cockpit
Webbaserat systemadministrationsgränssnitt för Linux.
Nås via webbläsare, kräver inga extra agenter.

### Container
Lättviktig virtualiseringsform som delar värdets
Linux-kärna. Snabbare och mer resurseffektiv än VMs
men med svagare isolering. *Verktyg: Docker, Podman.*

### Defense-in-Depth
Säkerhetsstrategi med flera oberoende skyddslager.
Om ett lager kringgås finns nästa kvar.

### DRY-principen (Don't Repeat Yourself)
Programmeringsprincip: samma logik ska bara finnas
på ett ställe. Minskar underhållsskuld och risken
för inkonsistenser.

### fail2ban
Intrångsförebyggande verktyg som analyserar loggar
och blockerar IP-adresser efter upprepade misslyckade
inloggningsförsök.

### FIM (File Integrity Monitoring)
Wazuh-funktion som övervakar kritiska filer för
oväntade ändringar. Larmar vid modifiering av
`/etc`, `/usr/bin` etc.

### Gunicorn
Produktionsserver för Python/Flask. Kör parallella
worker-processer för att hantera flera förfrågningar
samtidigt. Ersätter Flasks inbyggda dev-server.

### HA (High Availability)
Systemdesign som minimerar driftstopp genom redundans,
automatisk failover och eliminering av SPoF:ar.

### Hypervisor
Programvara som skapar och hanterar virtuella maskiner.
**Typ 1** (bare metal): körs direkt på hårdvara (VMware ESXi, Hyper-V).
**Typ 2** (hosted): körs ovanpå ett OS (VirtualBox, VMware Workstation).

### IaC (Infrastructure-as-Code)
Principen att infrastruktur beskrivs som versionshanterad
kod. Möjliggör reproducerbar, automatiserad och
granskningsbar infrastruktur. *Verktyg: Vagrant, Ansible, Terraform.*

### Idempotens
En operation är idempotent om den kan köras hur
många gånger som helst och alltid ger samma resultat.
Ansible-tasks är designade för idempotens.

### Jinja2
Mallspråk för Python. Används av Ansible för
att generera konfigurationsfiler med dynamiska
värden från variabeldefintioner.

### Least Privilege (Minsta privilegium)
Säkerhetsprincip: varje process ska ha minimalt
nödvändiga rättigheter. Flask körs som vagrant,
inte root.

### Lateral movement
Angreppsmetod (MITRE ATT&CK T1021) där en angripare
rör sig från en komprometterad server till andra
system i nätverket. Wazuh detekterar detta centralt.

### MITRE ATT&CK
Globalt ramverk som dokumenterar kända angreppstekniker
och taktiker. Wazuh har inbyggda detektionsregler
mappade mot MITRE ATT&CK-kategorier.

### OOM (Out of Memory)
Tillstånd när systemet tar slut på RAM. Linux-kernel
OOM killer terminerar processer för att frigöra minne.
Indikeras av exit code 137.

### Passive Health Check
nginx-funktion som övervakar riktiga förfrågningar
för att avgöra om en backend-server fungerar.
Kräver ingen aktiv testrafik mot backend-servrarna.

### pg_hba.conf
PostgreSQL Host-Based Authentication. Konfigurationsfil
som styr vilka användare från vilka IP-adresser
som får autentisera mot databasen.

### Race condition
Defekt som uppstår när resultatet beror på timing
eller ordning av händelser som är utom kontroll.
Uppstod i projektet när SSH-nycklar kopierades
innan VM:arna var klara.

### Reproducerbarhet
Förmågan att återskapa identisk miljö från grunden.
Bevisas i detta projekt av 38/38 och 6/6 efter
`vagrant destroy -f && vagrant up`.

### Roll (Ansible role)
Återanvändbar enhet som organiserar tasks, handlers,
templates och variabler för ett specifikt syfte.

### Round-robin
Lastbalanseringsalgoritm som distribuerar förfrågningar
i turordning mellan tillgängliga servrar.

### SIEM (Security Information and Event Management)
Centralt system som samlar, normaliserar och
analyserar säkerhetshändelser. Möjliggör korrelation
av händelser från flera servrar. *Exempel: Wazuh, Splunk.*

### SPoF (Single Point of Failure)
Komponent vars haveri stoppar hela eller delar
av systemet. nginx och database är SPoF:ar i
detta projekt.

### SSH (Secure Shell)
Kryptografiskt protokoll för säker fjärrinloggning.
Ansible använder SSH för all kommunikation med
managed nodes.

### Systemd
Linux init-system och service manager. Hanterar
tjänsters livscykel, `Restart=always` ger automatisk
återstart vid krascher.

### TLS (Transport Layer Security)
Kryptografiskt protokoll för säker kommunikation.
Används för att kryptera trafik mellan nginx och Flask.

### UFW (Uncomplicated Firewall)
Användarvänlig frontend till iptables för
Ubuntu/Debian. Hanterar nätverkstrafik på
IP- och portnivå.

### Vagrant trigger
Vagrant-funktion som kör kod vid specifika
livscykelhändelser, t.ex. `after :up` - körs
efter att alla VM:ar startat klart.

### Zero Trust Architecture
Säkerhetsmodell: "Never trust, always verify."
All kommunikation verifieras, även intern.
Nätverkssegmentering med UFW är ett steg mot ZTA.

---

```
Projekt:          Secure-Infra-Lab
Författare:       Sushanta Shekhar Modak & Farhad Norman
GitHub:           https://github.com/SSM-debug/Secure-Infra-Lab
Detaljerad logg:  docs/log.md
Projektplan:      docs/projektplan.md
Datum:            2026-05-14
```
