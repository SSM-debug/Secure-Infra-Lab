# Projektplan — Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab  
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**Organisation:** YH Enköping — IT-säkerhetsingenjör (ITS24)  
**Kurs:** Virtualiseringsteknik och automation  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  

---

## Innehållsförteckning

1. [Syfte och mål](#1-syfte-och-mål)
2. [Verktyg vi använder](#2-verktyg-vi-använder)
3. [Så här ser systemet ut](#3-så-här-ser-systemet-ut)
4. [Våra servrar](#4-våra-servrar)
5. [Hur filerna är organiserade](#5-hur-filerna-är-organiserade)
6. [Vad händer när någon besöker sidan](#6-vad-händer-när-någon-besöker-sidan)
7. [Hur vi skyddar systemet](#7-hur-vi-skyddar-systemet)
8. [Vad varje Ansible-roll gör](#8-vad-varje-ansible-roll-gör)
9. [Arbetsplan](#9-arbetsplan)
10. [Krav vi ställer på systemet](#10-krav-vi-ställer-på-systemet)
11. [Vad vi förväntar oss när allt är klart](#11-vad-vi-förväntar-oss-när-allt-är-klart)

---

## 1. Syfte och mål

Det här projektet handlar om att bygga en komplett webbmiljö
med sex virtuella servrar — helt automatiskt, från grunden,
med ett enda kommando.

Vi visar att det går att beskriva hela infrastrukturen som
kod. Det betyder att miljön alltid ser likadan ut, oavsett
vem som sätter upp den eller när. Det kallas
Infrastructure-as-Code och är standard i moderna
IT-miljöer.

Projektet har tre huvudmål:

**Automatisering** — Allt från tomma servrar till ett
färdigt webbsystem med databas och säkerhetsövervakning
sätts upp automatiskt. Ingen manuell konfiguration behövs.

**Säkerhet** — Varje server är skyddad på flera sätt.
Vi använder nätverkssegmentering, brandväggsregler,
SSH-härdning och intrångsdetektering. Allt är
konfigurerat som kod och gäller på alla servrar.

**Reproducerbarhet** — Om vi förstör hela miljön och
startar om från noll får vi exakt samma resultat varje
gång. Vi bevisar detta med automatiska tester.

---

## 2. Verktyg vi använder

Här är en kort förklaring av varje verktyg och varför
vi använder det.

| Verktyg | Vad det gör |
|---------|-------------|
| Vagrant | Skapar och hanterar virtuella servrar automatiskt |
| VirtualBox | Kör de virtuella servrarna på din dator |
| Ansible | Konfigurerar servrarna automatiskt via SSH |
| Ubuntu 22.04 | Operativsystem på alla servrar |
| Flask | Webbapplikation skriven i Python |
| Gunicorn | Kör Flask-applikationen som en tjänst |
| nginx | Tar emot besökare och skickar dem vidare till rätt server |
| PostgreSQL | Databas där besök sparas |
| Wazuh | Övervakar alla servrar och varnar vid säkerhetsproblem |

---

## 3. Så här ser systemet ut

Systemet är uppbyggt i tre lager. Det kallas
3-tier-arkitektur. Varje lager pratar bara med
lagret precis ovanför eller under sig.

```
Din dator (Windows)
         |
         | Port 8080
         |
+--------v-----------------------------------------------+
|         Privat natverk 192.168.56.0/24                 |
|                                                        |
|  +---------------------------------------------------+ |
|  |  control (.10)                                    | |
|  |  Kör Ansible — konfigurerar alla andra servrar    | |
|  +--------------------+------------------------------+ |
|                       | SSH                            |
|                       v                                |
|  +---------------------------------------------------+ |
|  |  nginx (.11)                                      | |
|  |  Den enda servern som är nåbar utifrån            | |
|  |  Skickar besökare till web1 eller web2            | |
|  +------------------+--------------------------------+ |
|                     | Växlar mellan web1 och web2      |
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
|  |  database (.14)                                   | |
|  |  PostgreSQL — sparar alla besök                   | |
|  |  Bara web1 och web2 får prata med databasen       | |
|  +---------------------------------------------------+ |
|                                                        |
|  +---------------------------------------------------+ |
|  |  monitor (.15)                                    | |
|  |  Wazuh — håller koll på säkerheten på alla servrar| |
|  +---------------------------------------------------+ |
+--------------------------------------------------------+
```

**Lager 1 — nginx** tar emot alla besök utifrån.
Det är den enda servern som syns från omvärlden.

**Lager 2 — web1 och web2** kör webbapplikationen.
Båda servrarna gör samma sak men identifierar sig
olika. Om en server slutar fungera tar den andra över.

**Lager 3 — database** sparar data. Bara web1 och
web2 får ansluta till databasen. Alla andra är
blockerade.

---

## 4. Våra servrar

| Server | IP-adress | Uppgift | RAM | Nåbar utifrån |
|--------|-----------|---------|-----|---------------|
| control | 192.168.56.10 | Kör Ansible | 1024 MB | Nej |
| nginx | 192.168.56.11 | Tar emot besök, skickar vidare | 512 MB | Ja — port 8080 |
| web1 | 192.168.56.12 | Webbapp (Server 1) | 512 MB | Nej |
| web2 | 192.168.56.13 | Webbapp (Server 2) | 512 MB | Nej |
| database | 192.168.56.14 | Sparar besök i PostgreSQL | 512 MB | Nej |
| monitor | 192.168.56.15 | Wazuh säkerhetsövervakning | 2048 MB | Nej |
| **Totalt** | | | **5120 MB** | |

---

## 5. Hur filerna är organiserade

```
Secure-Infra-Lab/
|
+-- .gitattributes         # Ser till att radbrytningar är rätt
+-- .gitignore             # Hindrar lösenord från att hamna på GitHub
+-- docs/
|   +-- projektplan.md     # Det här dokumentet
|   +-- log.md             # Detaljerad logg över allt vi gjort
|
+-- vagrant/
|   +-- Vagrantfile        # Beskriver alla 6 servrar som kod
|   +-- secrets.yml        # GITIGNORERAD — lösenord och hemligheter
|
+-- ansible/
    +-- ansible.cfg        # Inställningar för Ansible
    +-- inventory.ini      # Lista på alla servrar
    +-- site.yml           # Huvudplanen — vad som installeras var
    |
    +-- vars/
    |   +-- vars.yml       # Gemensamma variabler som IP-adresser
    |
    +-- roles/
        +-- security_hardening/   # Skyddar alla servrar
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/sshd_config.j2
        |
        +-- flask/                # Installerar webbapplikationen
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/flask.service.j2
        |   +-- files/app.py
        |   +-- vars/main.yml
        |
        +-- nginx/                # Konfigurerar lastbalanseraren
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/nginx.conf.j2
        |
        +-- database/             # Installerar databasen
        |   +-- tasks/main.yml
        |   +-- handlers/main.yml
        |   +-- templates/schema.sql.j2
        |
        +-- wazuh_agent/          # Installerar säkerhetsövervakning
            +-- tasks/main.yml
```

---

## 6. Vad händer när någon besöker sidan

När du öppnar `http://localhost:8080/visit` i din
webbläsare händer det här i bakgrunden:

```
Steg 1: Din webbläsare skickar en förfrågan till port 8080
Steg 2: Vagrant skickar förfrågan vidare till nginx port 80
Steg 3: nginx väljer web1 eller web2 — de turas om
Steg 4: Den valda servern kör Flask-koden
Steg 5: Flask sparar besöket i databasen
Steg 6: Flask hämtar de 5 senaste besöken från databasen
Steg 7: Svaret skickas tillbaka till din webbläsare
```

Det du ser på sidan visar om det var "Server 1" eller
"Server 2" som svarade. Nästa gång du laddar om sidan
byter nginx till den andra servern. Det är så
lastbalansering fungerar.

---

## 7. Hur vi skyddar systemet

Vi använder en strategi som kallas Defense-in-Depth.
Det betyder att vi har flera skyddslager. Om ett lager
bryts igenom finns nästa lager kvar. Det är som att ha
både lås, larm och grannsamverkan hemma.

### Skydd 1 — Bara nginx syns utifrån

Bara nginx har en publik ingång via port 8080.
Alla andra servrar är osynliga utifrån. En angripare
som hittar systemet ser bara nginx — ingenting annat.

### Skydd 2 — Brandvägg på databasen

Databasen har strikta brandväggsregler. Bara web1
och web2 får ansluta på port 5432. Alla andra
anslutningar blockeras direkt.

Vi sätter också `listen_addresses` i PostgreSQL till
specifika IP-adresser istället för `*` (alla). Det
ger ett extra skydd om brandväggsreglerna skulle
kringgås.

### Skydd 3 — SSH-härdning på alla servrar

Dessa regler gäller på alla servrar:

- Ingen får logga in som root via SSH
- Lösenordsinloggning är helt avstängd — bara SSH-nycklar fungerar
- Max tre inloggningsförsök — sedan stängs anslutningen
- Bara användaren `vagrant` får logga in
- Inaktiva sessioner stängs av efter 5 minuter

### Skydd 4 — Automatisk blockering (fail2ban)

fail2ban håller koll på inloggningsförsök. Om någon
försöker logga in för många gånger på kort tid
blockeras den IP-adressen automatiskt.

### Skydd 5 — Loggning och övervakning (auditd + Wazuh)

auditd loggar allt som händer på varje server —
vem loggade in, vilka filer ändrades, vilka kommandon
kördes. Wazuh samlar in dessa loggar från alla servrar
och visar dem på ett ställe. Om något misstänkt händer
syns det direkt.

---

## 8. Vad varje Ansible-roll gör

### security_hardening — körs på alla servrar

Den här rollen är den första som körs. Den ser till
att alla servrar är grundskyddade innan något annat
installeras. Den installerar fail2ban och auditd,
och distribuerar en härdad SSH-konfiguration.

Dokumentation: https://docs.ansible.com/ansible/latest/

### database — körs på database-servern

Installerar PostgreSQL och skapar databasen och
tabellen som Flask-applikationen använder. Sätter
upp brandväggsregler så att bara web1 och web2 får
ansluta.

Dokumentation: https://www.postgresql.org/docs/

### flask — körs på web1 och web2

Installerar Flask och Gunicorn. Kopierar
applikationskoden till servern. Skapar en systemd-tjänst
som automatiskt startar om applikationen om den kraschar.

Samma roll används för båda servrarna. Den enda
skillnaden är variabeln `server_name` — web1 får
"Server 1" och web2 får "Server 2".

Dokumentation: https://flask.palletsprojects.com/

### nginx — körs på nginx-servern

Konfigurerar nginx som lastbalanserare. Skapar en
konfigurationsfil som skickar förfrågningar till
web1 och web2 i turordning (round-robin).

Dokumentation: https://nginx.org/en/docs/

### wazuh_agent — körs på alla servrar utom monitor

Installerar Wazuh-agenten som skickar säkerhetshändelser
till Wazuh Manager på monitor-servern.

Dokumentation: https://documentation.wazuh.com/

---

## 9. Arbetsplan

| Fas | Vad vi gör |
|-----|------------|
| Fas 1 | Vagrantfile — skapa och starta 6 servrar |
| Fas 2 | Ansible-konfiguration — inventory, playbook, variabler |
| Fas 3 | security_hardening — skydda alla servrar |
| Fas 4 | database — installera och konfigurera PostgreSQL |
| Fas 5 | flask — installera webbapplikationen på web1 och web2 |
| Fas 6 | nginx — konfigurera lastbalanseraren |
| Fas 7 | wazuh_agent — sätta upp säkerhetsövervakning |
| Fas 8 | Verifieringsskript — automatiska tester |
| Fas 9 | Rapport och presentation |

---

## 10. Krav vi ställer på systemet

**Reproducerbarhet** — Kommandot
`vagrant destroy -f && vagrant up && ansible-playbook site.yml`
ska ge exakt samma fungerande miljö varje gång.
Inga manuella ingrepp får behövas.

**Idempotens** — Det ska gå att köra Ansible-playbooken
flera gånger utan att något går sönder. Om vi kör den
en andra gång mot en redan konfigurerad miljö ska
resultatet visa `changed=0` — ingenting ändrades
eftersom allt redan var rätt.

**Minsta privilegium** — Varje del av systemet får
bara de rättigheter den faktiskt behöver. Flask-
applikationen får till exempel bara läsa och skriva
till visits-tabellen — ingenting annat.

**Tydliga nätverksgränser** — Trafik mellan servrarna
är alltid explicit tillåten via brandväggsregler.
Inget är öppet av misstag.

**Spårbarhet** — Varje beslut vi fattar dokumenteras
i `docs/log.md` med förklaring. Vem som helst ska
kunna läsa loggen och förstå varför vi valde som vi
valde.

**Skalbarhet** — Det ska vara enkelt att lägga till
fler webbservrar. Man uppdaterar bara nginx-konfigurationen
— ingenting annat behöver ändras.

---

## 11. Vad vi förväntar oss när allt är klart

### Hur systemet ska fungera

När alla faser är klara ska det här fungera:

En besökare går till `http://localhost:8080/visit`.
Sidan visar antingen "Server 1" eller "Server 2"
beroende på vilken server nginx valde. De fem senaste
besöken visas på sidan. Laddar man om sidan byter
nginx till den andra servern.

Hela miljön byggs upp automatiskt med ett kommando
och testas med automatiska skript.

### Automatiska tester

Dessa tester körs automatiskt av `verify.sh` (Linux)
och `verify_host.ps1` (Windows):

| # | Vad vi testar | Förväntat svar |
|---|---------------|----------------|
| 1 | nginx svarar på port 8080 | HTTP 200 OK |
| 2 | /visit visar "Server 1" eller "Server 2" | Webbappen fungerar |
| 3 | Upprepade besök växlar mellan Server 1 och Server 2 | Lastbalansering fungerar |
| 4 | web1 når databasen på port 5432 | Anslutning OK |
| 5 | web2 når databasen på port 5432 | Anslutning OK |
| 6 | En extern dator når inte databasen direkt | Blockerad av UFW |
| 7 | Flask-tjänsten körs på web1 | active (running) |
| 8 | Flask-tjänsten körs på web2 | active (running) |
| 9 | fail2ban körs på alla servrar | active (running) |
| 10 | auditd körs på alla servrar | active (running) |
| 11 | Lösenordsinloggning är avstängd | no |
| 12 | Root-inloggning via SSH är avstängd | no |
| 13 | Wazuh-agenten är aktiv på alla servrar | connected |
| 14 | PostgreSQL lyssnar inte på alla IP-adresser | Bara web1 + web2 |

---

*Den detaljerade loggen över hur vi byggde allt
finns i `docs/log.md`.*