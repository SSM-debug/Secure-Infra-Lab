# Projektlogg — Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab  
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  

Den här loggen beskriver allt vi gjort i projektet,
fas för fas. För varje fas förklarar vi vad vi gjorde,
vilka kommandon vi körde, vad vi såg på skärmen och
hur vi löste problem som dök upp.

Loggen är skriven så att vem som helst ska kunna följa
med — även den som inte jobbat med projektet tidigare.

---

## Fas 1 - Vagrantfile och VM-uppstart
**Datum:** 2026-05-02
**Git-commits:**
- `Initial structure: Vagrantfile for 6 VMs`
- `Add .gitignore and fix control provisioner: install Ansible via pip instead of apt`

### Vad vi gjorde

Vi skapade projektmappen på E-disken, initierade Git
och designade en Vagrantfile som beskriver alla sex
servrar - IP-adresser, RAM, CPU och provisionerings-
skript för varje server.

När vi startade servrarna installerades Ansible 2.10.8
via apt på control - för gammal version. Vi uppdaterade
Vagrantfilen till att installera Ansible via pip och
startade om control.

Vi skapade också `.gitignore` för att hindra SSH-nycklar
och interna Vagrant-filer från att publiceras på GitHub.

---

### Rollöversikt

```
Fas 1 skapar grunden för hela projektet:
1. Skapar projektmappen och initierar Git
2. Bygger mappstrukturen för hela projektet
3. Designar Vagrantfilen för alla 6 VMs
4. Kopplar projektet till GitHub
5. Startar alla 6 VMs och verifierar att de körs
```

### Filöversikt

```
Secure-Infra-Lab/
├── .gitignore                  ✅
├── docs/                       ✅
├── scripts/                    ✅
├── vagrant/
│   └── Vagrantfile             ✅
└── ansible/
    ├── ansible.cfg             (platshållare)
    ├── inventory.ini           (platshållare)
    ├── site.yml                (platshållare)
    ├── vars/
    │   └── vars.yml            (platshållare)
    ├── host_vars/
    │   └── web2.yml            (platshållare)
    └── roles/
        ├── security_hardening/ (platshållare)
        ├── flask/              (platshållare)
        ├── nginx/              (platshållare)
        ├── database/           (platshållare)
        ├── wazuh_manager/      (platshållare)
        ├── wazuh_agent/        (platshållare)
        └── cockpit/            (platshållare)
```

### Varför detta steg är viktigt

Utan Vagrantfilen måste varje server skapas manuellt.
Det tar tid och resultatet blir aldrig exakt likadant
två gånger.

Med Vagrantfilen beskrivs hela infrastrukturen som kod.
`vagrant up` skapar identiska servrar varje gång - på
vilken dator som helst. Det är principen bakom
Infrastructure-as-Code som används i alla moderna
driftmiljöer.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa projektmappen på E-disken
cd E:\
E:\> mkdir Secure-Infra-Lab
E:\> cd Secure-Infra-Lab
```
Mappen skapades på E-disken ✅

```powershell
# Initiera Git och koppla till GitHub
E:\Secure-Infra-Lab> git init
E:\Secure-Infra-Lab> git remote add origin https://github.com/SSM-debug/Secure-Infra-Lab.git
```
Git initierades och kopplades till GitHub ✅

```powershell
# Skapa hela mappstrukturen
E:\Secure-Infra-Lab> mkdir vagrant, docs, scripts
E:\Secure-Infra-Lab> mkdir ansible\vars, ansible\host_vars
E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening
E:\Secure-Infra-Lab> mkdir ansible\roles\flask
E:\Secure-Infra-Lab> mkdir ansible\roles\nginx
E:\Secure-Infra-Lab> mkdir ansible\roles\database
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_manager
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_agent
E:\Secure-Infra-Lab> mkdir ansible\roles\cockpit
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera Vagrantfilen i VS Code
E:\Secure-Infra-Lab> code vagrant\Vagrantfile
```
Vagrantfilen skapades och konfigurerades i VS Code ✅

```powershell
# Första commit och push till GitHub
E:\Secure-Infra-Lab> git add .
E:\Secure-Infra-Lab> git commit -m "Initial structure: Vagrantfile for 6 VMs"
E:\Secure-Infra-Lab> git push -u origin main
```
Projektet publicerades på GitHub ✅

```powershell
# Starta alla servrar
# Vagrant kräver att man står i mappen med Vagrantfilen
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant up
```
control visade `ansible 2.10.8` - för gammal version ❌
Se Problem 1 nedan.

```powershell
# Starta om control med uppdaterad Vagrantfile
# --provision tvingar provisioner-skriptet att köra igen
E:\Secure-Infra-Lab\vagrant> vagrant reload --provision control
```
`ansible [core 2.17.14]` installerades korrekt ✅

```powershell
# Verifiera att alla servrar är uppe
E:\Secure-Infra-Lab\vagrant> vagrant status
```
```
control     running (virtualbox)
nginx       running (virtualbox)
web1        running (virtualbox)
web2        running (virtualbox)
database    running (virtualbox)
monitor     running (virtualbox)
```
Alla sex servrar körde korrekt ✅

```powershell
# Skapa .gitignore och ta bort spårade Vagrant-filer
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git rm -r --cached vagrant\.vagrant\
E:\Secure-Infra-Lab> git add .
E:\Secure-Infra-Lab> git commit -m "Add .gitignore and fix control provisioner: install Ansible via pip instead of apt"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

---

### Konfigurationsfiler

📄 `vagrant/Vagrantfile`
**Vad den gör:** Beskriver alla sex servrar som kod.
Definierar IP-adresser, RAM, CPU och provisionerings-
skript för varje server.
**Varför den finns:** Hela infrastrukturen återskapas
identiskt med `vagrant up` - på vilken dator som helst.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/vagrant/Vagrantfile
**Officiell dokumentation:** https://developer.hashicorp.com/vagrant/docs/vagrantfile

📄 `.gitignore`
**Vad den gör:** Ignorerar `vagrant/.vagrant/` och
`vagrant/secrets.yml` så att de aldrig publiceras.
**Varför den finns:** SSH-nycklar och lösenord som
hamnar på GitHub är komprometterade för alltid -
även om man tar bort dem efteråt finns de kvar i
Git-historiken.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitignore
**Officiell dokumentation:** https://git-scm.com/docs/gitignore

---

### Problem och lösningar

**Problem 1 - Ansible 2.10.8 för gammal**
**Felmeddelande:** `ansible 2.10.8`
**Orsak:** Ubuntu 22.04 installerar Ansible 2.10.8
via apt - för gammal version som saknar moduler vi behöver.
**Lösning:** Uppdaterade provisioner-skriptet i
Vagrantfilen till `pip3 install ansible`.
**Resultat:** `ansible [core 2.17.14]` ✅

**Problem 2 - Vagrant-filer spårades av Git**
**Vad som hände:** Git spårade `vagrant/.vagrant/`
med SSH-nycklar och intern Vagrant-metadata.
**Orsak:** Ingen `.gitignore` fanns från början.
**Lösning:** Skapade `.gitignore` och körde
`git rm -r --cached vagrant/.vagrant/`.

---

### Teorikoppling

**Koncept: Infrastructure-as-Code (IaC)**

Traditionellt konfigureras servrar manuellt. Det tar
tid och resultatet blir lite annorlunda varje gång.

Infrastructure-as-Code löser det. Infrastrukturen
beskrivs i textfiler som versionshanteras i Git. Kör
man filerna får man exakt samma resultat varje gång.

I det här projektet beskriver Vagrantfilen alla sex
servrar. Förstör man allt och kör `vagrant up` igen
får man identiska servrar på några minuter. Samma
princip används med Terraform och AWS CloudFormation
i riktiga produktionsmiljöer.

**Officiell dokumentation:**
- Vagrant: https://developer.hashicorp.com/vagrant/docs
- VirtualBox: https://www.virtualbox.org/manual/

---

---

## Fas 2 — Ansible-konfiguration
**Datum:** 2026-05-02
**Git-commit:** `Add Ansible config: ansible.cfg, inventory.ini, site.yml`

### Vad vi gjorde

Vi skapade de tre kärnfilerna som Ansible behöver
för att fungera. `ansible.cfg` är den globala
inställningsfilen. `inventory.ini` listar alla
servrar. `site.yml` är huvudplanen som bestämmer
vad som installeras var och i vilken ordning.

Ordningen i `site.yml` är kritisk. Databasen måste
konfigureras innan webbservrarna startar — annars
försöker Flask ansluta till en databas som inte
finns än och tjänsten kraschar.

---

### Rollöversikt

```
Fas 2 konfigurerar Ansible så att det kan kommunicera
med alla servrar:
1. Skapar ansible.cfg med globala inställningar
2. Skapar inventory.ini med alla 6 servrar
3. Skapar site.yml med körordningen för alla roller
4. Skapar vars/vars.yml med delade variabler
```

### Filöversikt

```
ansible/
├── ansible.cfg                 ✅
├── inventory.ini               ✅
├── site.yml                    ✅
└── vars/
    └── vars.yml                ✅
```


### Varför detta steg är viktigt

Utan dessa tre filer kan Ansible inte fungera alls.
`ansible.cfg` talar om för Ansible var den ska leta
efter servrar och hur den ska bete sig. `inventory.ini`
är Ansibles adressbok — utan den vet Ansible inte
att våra servrar existerar. `site.yml` är receptet
som bestämmer vad som lagas och i vilken ordning.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa ansible.cfg i VS Code
# Varför: Utan den måste vi ange alla inställningar
# som flaggor varje gång vi kör Ansible — opraktiskt
# och lätt att glömma
PS E:\Secure-Infra-Lab> code ansible\ansible.cfg
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Skapa inventory.ini i VS Code
# Varför: Ansible måste veta vilka servrar som finns,
# hur man når dem och vilket operativsystem de kör
PS E:\Secure-Infra-Lab> code ansible\inventory.ini
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Skapa site.yml i VS Code
# Varför: Huvudplanen som bestämmer vilken roll som
# körs på vilken server och i vilken ordning
PS E:\Secure-Infra-Lab> code ansible\site.yml
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Skapa vars/vars.yml i VS Code
# Varför: Centraliserade variabler — IP-adresser
# och portnummer definieras på ett ställe och
# används av alla roller
PS E:\Secure-Infra-Lab> code ansible\vars\vars.yml
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Publicera alla filer till GitHub
PS E:\Secure-Infra-Lab> git add ansible/ansible.cfg ansible/inventory.ini ansible/site.yml ansible/vars/vars.yml
PS E:\Secure-Infra-Lab> git commit -m "Add Ansible config: ansible.cfg, inventory.ini, site.yml"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output:
```
[main xxxxxxx] Add Ansible config: ansible.cfg, inventory.ini, site.yml
 4 files changed, X insertions(+)
```
Vad vi fick: Exakt det förväntade ✅

---

### Konfigurationsfiler

📄 `ansible/ansible.cfg`
**Vad den gör:** Global konfigurationsfil för Ansible.
Anger sökväg till inventory-filen, inaktiverar SSH
host key-verifiering och tillåter temporära filer
som Ansible behöver vid privilegieeskalering.
**Varför den finns:** Utan den måste alla inställningar
anges som flaggor vid varje kommandokörning —
`ansible-playbook -i inventory.ini --ssh-extra-args=...`
**Hur vi skrev den:** Vi identifierade de tre
inställningar som alltid behövs i vår miljö och
konsulterade officiell dokumentation för syntax.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/ansible.cfg
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html

📄 `ansible/inventory.ini`
**Vad den gör:** Listar alla sex servrar med
IP-adresser, SSH-användare, nyckelfilssökvägar
och explicit Python-interpreter. Gruppnamnen
har `_g`-suffix för att undvika namnkrockar
mellan grupp och host.
**Varför den finns:** Ansible kan inte kommunicera
med servrarna utan denna fil — den är Ansibles
register över hanterade noder.
**Hur vi skrev den:** Vi listade varje server med
dess IP-adress från Vagrantfilen och lade till
de SSH-parametrar som Ansible behöver.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/inventory.ini
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

📄 `ansible/site.yml`
**Vad den gör:** Huvudplanen — definierar vilken roll
som körs på vilken server och i vilken ordning.
Laddar variabler från `vars/vars.yml` och `secrets.yml`
vid varje körning.
**Varför den finns:** Utan en definierad körordning
kan Flask försöka ansluta till en databas som ännu
inte konfigurerats — vilket orsakar fel.
**Hur vi skrev den:** Vi identifierade rätt körordning
(database → web → nginx → monitor) och skapade
ett play per servergrupp med rätt roll tilldelad.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/site.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html

📄 `ansible/vars/vars.yml`
**Vad den gör:** Centraliserad variabelfil med
IP-adresser och portnummer som delas av alla roller.
**Varför den finns:** Om vi byter IP-adress på en
server behöver vi bara ändra på ett ställe —
inte i varje enskild roll.
**Hur vi skrev den:** Vi samlade alla värden som
används av flera roller på ett ställe.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/vars/vars.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

---

### Problem och lösningar

Inga problem uppstod under den här fasen.

---

### Teorikoppling

**Koncept: Inventory och körordning i Ansible**

Inventory-filen är som en adressbok för Ansible.
Utan den vet Ansible inte att våra servrar existerar.
Varje post i inventory-filen innehåller servernamn,
IP-adress och hur Ansible ska ansluta.

Körordningen i `site.yml` är lika viktig som att
utföra arbetsmoment i rätt följd. Databasen måste
vara konfigurerad och igång innan webbservrarna
startar — annars försöker Flask ansluta till något
som inte finns än och tjänsten misslyckas med start.

I stora produktionsmiljöer används dynamiska
inventories som uppdateras automatiskt när nya
servrar startas i molnet. Nya servrar registreras
direkt utan att någon behöver uppdatera en fil
manuellt.

**Officiell dokumentation:**
- Ansible inventory: https://docs.ansible.com/ansible/latest/inventory_guide/
- Ansible playbooks: https://docs.ansible.com/ansible/latest/playbook_guide/

---

---

## Fas 3 — security_hardening-rollen
**Datum:** 2026-05-04
**Git-commits:**
- `Add security_hardening role: SSH hardening, fail2ban, auditd`
- `Add vars/vars.yml with network and Flask variables`
- `Add .gitattributes: enforce LF line endings for all files`
- `Normalize line endings to LF across all files`
- `Add placeholder roles: database, flask, nginx, wazuh_agent`

### Vad vi gjorde

Vi byggde `security_hardening`-rollen och körde den
mot alla sex servrar. Rollen gör tre saker: den
distribuerar en härdad SSH-konfiguration, installerar
fail2ban som blockerar inloggningsattacker och
installerar auditd som loggar systemhändelser.

Vi stötte på flera problem under fasen. Ansible
kraschade för att rollerna för database, flask, nginx
och wazuh_agent inte existerade än. Control-servern
saknade SSH-nyckel för att nå de andra servrarna.
Windows konverterade radbrytningar på fel sätt.
Alla tre problem löste vi permanent.

Vi lade också till `Defaults !requiretty` i sudoers
via security_hardening-rollen. Det krävs för att
Ansible pipelining ska fungera korrekt — vilket
eliminerar world-readable tmp files-varningen.

Slutresultat: `ansible-playbook site.yml` kördes mot
alla sex servrar med `failed=0` och inga varningar.
Idempotens bekräftad på andra körningen med
`changed=0` på alla servrar.

---

### Rollöversikt

```
security_hardening-rollen gör fyra saker:
1. Uppdaterar paketcachen och installerar fail2ban och auditd
2. Distribuerar en härdad SSH-konfiguration
3. Startar och aktiverar säkerhetstjänsterna
4. Inaktiverar requiretty i sudoers för Ansible pipelining
```

Rollen körs på samtliga 6 servrar — alltid först
innan någon annan roll körs.

### Filöversikt

```
ansible/
├── .gitattributes                              ✅
└── roles/
    └── security_hardening/
        ├── tasks/
        │   └── main.yml                        ✅
        ├── handlers/
        │   └── main.yml                        ✅
        └── templates/
            └── sshd_config.j2                  ✅
```


### Varför detta steg är viktigt

Security hardening är det första som körs på alla
servrar — innan någon applikation installeras.
Det säkerställer att varje server har en konsekvent
säkerhetsbaslinje från dag ett. SSH-härdning,
fail2ban och auditd är grundläggande skydd som
krävs i alla seriösa driftmiljöer.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa mappstruktur för security_hardening-rollen
# Varför: Ansible kräver tasks/, handlers/ och
# templates/ mappar inuti varje roll
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\tasks
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\handlers
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\templates
```
Förväntat output: Inga felmeddelanden.
Vad vi fick: Mapparna skapades korrekt ✅

```powershell
# Öppna rollfilerna i VS Code för redigering
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\tasks\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\handlers\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\templates\sshd_config.j2
```
Förväntat output: VS Code öppnar varje fil.
Vad vi fick: Filerna öppnades korrekt ✅

```powershell
# Skapa tomma platshållarfiler för roller som inte finns än
# Varför: Ansible validerar ALLA roller i site.yml
# vid uppstart — även roller som inte körs just nu.
# Utan platshållare kraschar Ansible direkt
PS E:\Secure-Infra-Lab> foreach ($role in @("database", "flask", "nginx", "wazuh_agent")) {
    $path = "E:\Secure-Infra-Lab\ansible\roles\$role\tasks\main.yml"
    Set-Content -Path $path -Value "---`n# Placeholder — role not yet implemented"
    Write-Host "Created: $path"
}
```
Förväntat output: `Created: E:\...\[rollnamn]\tasks\main.yml` för varje roll.
Vad vi fick: Alla fyra platshållarfiler skapades ✅

```powershell
# Fixa radbrytningsproblem permanent
# Varför: Windows använder CRLF (\r\n), Linux använder LF (\n)
# CRLF i YAML- och Bash-filer kan orsaka tolkningsfel
# på Linux-servrar
PS E:\Secure-Infra-Lab> git config core.autocrlf false
PS E:\Secure-Infra-Lab> git config core.eol lf
PS E:\Secure-Infra-Lab> code .gitattributes
```
Förväntat output: VS Code öppnar .gitattributes för redigering.
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Normalisera alla befintliga filer till LF
PS E:\Secure-Infra-Lab> git rm --cached -r .
PS E:\Secure-Infra-Lab> git reset --hard
PS E:\Secure-Infra-Lab> git add .
PS E:\Secure-Infra-Lab> git commit -m "Normalize line endings to LF across all files"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: Commit bekräftas utan CRLF-varningar.
Vad vi fick: Inga fler CRLF-varningar ✅

```powershell
# Hämta controls publika nyckel och spara i variabel
# Varför: Vi behöver nyckeln för att distribuera den
# till alla andra servrar
PS E:\Secure-Infra-Lab\vagrant> $pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"
```
Förväntat output: Ingen synlig output — nyckeln sparas i variabeln.
Vad vi fick: Nyckeln hämtades korrekt ✅

```powershell
# Distribuera controls publika nyckel till alla servrar
# Varför: Ansible SSH:ar från control till alla servrar.
# Utan nyckeln i authorized_keys nekas åtkomst helt
PS E:\Secure-Infra-Lab\vagrant> foreach ($vm in @("nginx", "web1", "web2", "database", "monitor")) {
    $port = (vagrant ssh-config $vm | Select-String "Port").ToString().Trim().Split(" ")[1]
    $keyfile = (vagrant ssh-config $vm | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
    echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
}
```
Förväntat output: `Warning: Permanently added '[127.0.0.1]:XXXX'` för varje server.
Vad vi fick: nginx, web1, web2, database lyckades ✅
Fel vi fick på monitor: `kex_exchange_identification: read: Connection reset`
Orsak: Monitor hade precis startats om och SSH
var inte redo än. Monitor har 2048 MB RAM och
behöver längre starttid än övriga servrar.
Lösning: Körde `vagrant reload monitor` och
försökte igen — lyckades ✅

```powershell
# Ladda upp säkerhetshärdning-filer till control-VM
# Varför: Ansible på control-VM behöver filerna lokalt
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\security_hardening\tasks\main.yml /home/vagrant/ansible/roles/security_hardening/tasks/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\security_hardening\handlers\main.yml /home/vagrant/ansible/roles/security_hardening/handlers/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\security_hardening\templates\sshd_config.j2 /home/vagrant/ansible/roles/security_hardening/templates/sshd_config.j2 control
```
Förväntat output: `Upload has completed successfully!` för varje fil.
Vad vi fick: Alla tre filer laddades upp korrekt ✅

```powershell
# Committa och pusha alla ändringar
PS E:\Secure-Infra-Lab> git add ansible/roles/security_hardening ansible/site.yml
PS E:\Secure-Infra-Lab> git commit -m "Add security_hardening role: SSH hardening, fail2ban, auditd"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: Commit bekräftas och pushas till GitHub.
Vad vi fick: Exakt det förväntade ✅

---

#### Bash — inuti control-servern

```bash
# Logga in på control-servern
# Kör från: E:\Secure-Infra-Lab\vagrant
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control
```
Förväntat output: `vagrant@control:~$`
Vad vi fick: Inloggning lyckades ✅

```bash
# Skapa mappstruktur för platshållarroller inuti control-servern
# Varför: Ansible på control-servern letar efter roller
# i /home/vagrant/ansible/roles/ — inte på Windows
vagrant@control:~$ for role in database flask nginx wazuh_agent; do
    mkdir -p /home/vagrant/ansible/roles/$role/tasks
    echo -e "---\n# Placeholder — role not yet implemented" \
    > /home/vagrant/ansible/roles/$role/tasks/main.yml
done
```
Förväntat output: Inga felmeddelanden.
Vad vi fick: Alla mappar och filer skapades korrekt ✅

```bash
# Verifiera att alla rollmappar och filer finns
vagrant@control:~$ find /home/vagrant/ansible/roles -name "main.yml"
```
Förväntat output:
```
/home/vagrant/ansible/roles/security_hardening/tasks/main.yml
/home/vagrant/ansible/roles/security_hardening/handlers/main.yml
/home/vagrant/ansible/roles/database/tasks/main.yml
/home/vagrant/ansible/roles/flask/tasks/main.yml
/home/vagrant/ansible/roles/nginx/tasks/main.yml
/home/vagrant/ansible/roles/wazuh_agent/tasks/main.yml
```
Vad vi fick: Exakt det förväntade ✅

```bash
# Generera SSH-nyckelpar på control-servern
# Varför: Control behöver ett eget nyckelpar för att
# autentisera mot nginx, web1, web2, database och monitor
# -t ed25519: modern och säker nyckeltyp
# -N "": inget lösenord — krävs för automatiserad drift
vagrant@control:~$ ssh-keygen -t ed25519 -f /home/vagrant/.ssh/id_rsa -N ""
```
Förväntat output:
```
Your identification has been saved in /home/vagrant/.ssh/id_rsa
Your public key has been saved in /home/vagrant/.ssh/id_rsa.pub
```
Vad vi fick: Exakt det förväntade ✅

```bash
# Verifiera att nycklarna skapades korrekt
vagrant@control:~$ ls -la /home/vagrant/.ssh/
```
Förväntat output:
```
-rw------- id_rsa      (privat nyckel — lämnar aldrig control)
-rw-r--r-- id_rsa.pub  (publik nyckel — distribueras till alla servrar)
```
Vad vi fick: Exakt det förväntade ✅

```bash
# Kör playbooken mot bara control-servern först
# Varför: Säkrare att verifiera mot en server
# innan vi kör mot alla sex
vagrant@control:~$ cd /home/vagrant/ansible
vagrant@control:~/ansible$ ansible-playbook site.yml --limit control
```
Förväntat output:
```
PLAY RECAP
control : ok=7  changed=5  unreachable=0  failed=0
```
Vad vi fick: Exakt det förväntade ✅

```bash
# Kör playbooken mot alla sex servrar
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` för alla sex servrar.
Vad vi fick:
```
control   ok=6  changed=1  failed=0  ✅
database  ok=8  changed=4  failed=0  ✅
nginx     ok=8  changed=5  failed=0  ✅
web1      ok=8  changed=5  failed=0  ✅
web2      ok=8  changed=5  failed=0  ✅
monitor   ok=2  failed=1            ❌
```
Fel vi fick: monitor fick `failed=1` första gången.
Orsak: Monitor hade precis startats om och var
inte helt redo än.
Lösning: Körde playbooken igen mot bara monitor:
```bash
vagrant@control:~/ansible$ ansible-playbook site.yml --limit monitor
```
Resultat: `ok=8  changed=4  failed=0` ✅

```bash
# Verifiera idempotens — kör playbooken en gång till
# Förväntat: changed=0 på alla servrar eftersom
# allt redan är korrekt konfigurerat
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla servrar.
Vad vi fick:
```
control   ok=6  changed=1  failed=0
database  ok=7  changed=0  failed=0
monitor   ok=7  changed=0  failed=0
nginx     ok=7  changed=0  failed=0
web1      ok=7  changed=0  failed=0
web2      ok=7  changed=0  failed=0
```
Control visade `changed=1` — apt cache-uppdateringen
räknas alltid som changed. Alla andra visade
`changed=0` — idempotens bekräftad ✅

---

### Konfigurationsfiler

📄 `ansible/roles/security_hardening/tasks/main.yml`
**Vad den gör:** Uppdaterar paketcachen, installerar
fail2ban och auditd, distribuerar SSH-konfigurationen,
startar säkerhetstjänsterna och inaktiverar requiretty
i sudoers för att möjliggöra pipelining.
**Varför den finns:** Det är ingångspunkten för rollen.
Ansible kör tasks/main.yml automatiskt när rollen
aktiveras i site.yml.
**Hur vi skrev den:** Vi identifierade varje
säkerhetskrav och sökte rätt Ansible-modul för
varje steg i officiell dokumentation.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml
**Officiella källor:**
- apt-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
- service-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html
- template-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html
- lineinfile-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html

📄 `ansible/roles/security_hardening/handlers/main.yml`
**Vad den gör:** Definierar `Restart sshd` — körs
bara om SSH-konfigurationen faktiskt ändrades.
**Varför den finns:** Onödiga omstarter av SSH
i produktion bryter aktiva sessioner för alla
inloggade användare.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/security_hardening/templates/sshd_config.j2`
**Vad den gör:** Jinja2-mall för SSH-serverkonfigurationen.
Inaktiverar root-inloggning och lösenordsinloggning.
Begränsar inloggningsförsök till tre. Tillåter bara
användaren `vagrant`. Stänger av inaktiva sessioner
efter 5 minuter.
**Varför den finns:** Standardkonfigurationen för SSH
tillåter lösenordsinloggning vilket exponerar servern
för automatiserade brute-force-attacker.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2
**Officiell dokumentation:** https://man.openbsd.org/sshd_config

📄 `.gitattributes`
**Vad den gör:** Instruerar Git att alltid använda
LF-radbrytningar för alla filer — oavsett operativsystem.
**Varför den finns:** Windows använder CRLF och Linux
använder LF. Utan den här filen konverterar Git på
Windows alla filer till CRLF vilket kan orsaka
tolkningsfel i Bash-skript och YAML-filer på
Linux-servrar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitattributes
**Officiell dokumentation:** https://git-scm.com/docs/gitattributes

---

### Problem och lösningar

**Problem 1 — Ansible kraschade för att roller saknades**
**Felmeddelande:** `the role 'database' was not found in /home/vagrant/ansible/roles`
**Vad som hände:** Ansible kontrollerar alla roller
som nämns i site.yml vid uppstart — även roller som
inte körs just nu. database, flask, nginx och
wazuh_agent fanns inte än.
**Lösning:** Skapade tomma platshållarfiler för varje
roll. De innehåller bara en kommentar och gör ingenting.
De ersätts med riktig kod när respektive fas börjar.

**Problem 2 — Control saknade SSH-nyckel**
**Felmeddelande:** `/home/vagrant/.ssh/id_rsa: No such file or directory` och `Permission denied (publickey)`
**Vad som hände:** Vagrant skapar SSH-nycklar för
kommunikation mellan Windows och VMs. Men dessa
nycklar delas inte automatiskt mellan VMs. Control
saknade ett eget nyckelpar för intern SSH-kommunikation.
**Lösning:** Genererade ett ED25519-nyckelpar på
control med `ssh-keygen`. Distribuerade den publika
nyckeln till `authorized_keys` på varje server via
Vagrants egna nycklar från Windows.

**Problem 3 — Monitor nekade SSH-anslutning**
**Felmeddelande:** `kex_exchange_identification: read: Connection reset`
**Vad som hände:** Monitor hade precis startats om
och SSH-tjänsten var inte redo än. Monitor allokerar
2048 MB RAM och behöver längre uppstartstid.
**Lösning:** `vagrant reload monitor` följt av
förnyat försök efter fullständig uppstart.

**Problem 4 — Inkonsekventa radbrytningar (CRLF/LF)**
**Felmeddelande:** `warning: LF will be replaced by CRLF`
**Vad som hände:** Git på Windows konverterade
automatiskt alla filer till CRLF. Det kan orsaka
tolkningsfel i YAML- och Bash-filer på Linux-servrar.
**Lösning:** Skapade `.gitattributes` med regeln
`* text=auto eol=lf` och normaliserade alla
befintliga filer:
```powershell
PS E:\Secure-Infra-Lab> git rm --cached -r .
PS E:\Secure-Infra-Lab> git reset --hard
```

---

### Teorikoppling

**Koncept 1: SSH-nyckelautentisering**

SSH-nycklar fungerar som ett digitalt lås och nyckel.
Den publika nyckeln är låset — den läggs på servern
i `authorized_keys`. Den privata nyckeln är nyckeln
— den stannar hos den som ska logga in och lämnar
aldrig den servern.

I det här projektet har control-servern den privata
nyckeln. Den publika nyckeln distribuerades till alla
andra servrar. Ansible loggar nu in automatiskt utan
lösenord — och lösenordsinloggning är helt inaktiverad
via `sshd_config.j2`.

I produktionsmiljöer hanteras SSH-nycklar via
centraliserade system som HashiCorp Vault med
automatisk nyckelrotation och revisionsspårning.

**Officiell dokumentation:** https://www.openssh.com/manual.html

**Koncept 2: Idempotens i konfigurationshantering**

En idempotent operation producerar identiskt resultat
oavsett hur många gånger den körs. I Ansible
kontrollerar varje modul nuvarande tillstånd mot
önskat tillstånd — åtgärder vidtas enbart vid
avvikelse.

I praktiken innebär det att en playbook kan köras
regelbundet i produktion för att säkerställa
konfigurationskonformitet. Om en operatör manuellt
ändrat en inställning återställs den automatiskt vid
nästa körning — utan att påverka komponenter som
redan är korrekt konfigurerade.

**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html

**Koncept 3: Defense-in-Depth via SSH-härdning**

Defense-in-Depth innebär att systemet skyddas på
flera oberoende sätt. Om ett skydd kringgås finns
nästa skydd kvar.

Standardkonfigurationen för SSH tillåter
lösenordsinloggning — vilket exponerar systemet för
automatiserade brute-force-attacker. Vår härdade
konfiguration eliminerar denna attackvektor:
enbart kryptografiska nycklar accepteras.

fail2ban lägger till ett reaktivt skyddslager —
IP-adresser som uppvisar mönster karakteristiska
för automatiserade attacker blockeras automatiskt.
auditd möjliggör forensisk analys — vid en
säkerhetsincident finns en fullständig revisionslogg
över systemhändelser på varje server.

**Officiell dokumentation:**
- fail2ban: https://www.fail2ban.org/wiki/index.php/MANUAL_0_8
- auditd: https://linux.die.net/man/8/auditd
- OpenSSH: https://man.openbsd.org/sshd_config
---

## Övrigt — Git branching-strategi
**Datum:** 2026-05-05  
**Git-commits:**
- `Add .gitattributes: enforce LF line endings for all files`
- `Update docs: professional projektplan.md and enhanced log.md`
- `Add Git branching strategy entry to log.md`

### Vad vi gjorde

Vi satte upp en professionell Git-arbetsstrategi för
projektet. Nuläget sparades som en permanent version
med taggen `v1.0-baseline`. Dokumentationsuppdateringar
genomfördes på en separat branch `docs/update-v2` och
mergades sedan till `main`.

Från och med nu sker alla uppdateringar på separata
branches och merglas till `main` när de är klara.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn

```powershell
# Spara nuläget som en permanent namngiven version
# Varför: En tag är en fast referens till ett specifikt
# ögonblick i historiken — vi kan alltid gå tillbaka hit
PS E:\Secure-Infra-Lab> git tag v1.0-baseline
PS E:\Secure-Infra-Lab> git push origin v1.0-baseline
```
Förväntat output: `* [new tag] v1.0-baseline -> v1.0-baseline`  
Vad vi fick: Exakt det förväntade ✅

```powershell
# Skapa en ny branch för dokumentationsuppdateringen
# Varför: Vi vill inte jobba direkt på main
# En branch håller arbetet isolerat tills det är klart
PS E:\Secure-Infra-Lab> git checkout -b docs/update-v2
```
Förväntat output: `Switched to a new branch 'docs/update-v2'`  
Vad vi fick: Exakt det förväntade ✅

```powershell
# Verifiera att vi är på rätt branch
PS E:\Secure-Infra-Lab> git branch
```
Förväntat output:
```
* docs/update-v2
  main
```
Vad vi fick: Exakt det förväntade ✅

```powershell
# Pusha branchen till GitHub för första gången
# Varför: Nya branches måste kopplas till GitHub explicit
PS E:\Secure-Infra-Lab> git push --set-upstream origin docs/update-v2
```
Förväntat output: `* [new branch] docs/update-v2 -> docs/update-v2`  
Vad vi fick: Exakt det förväntade ✅

```powershell
# Merga den färdiga branchen till main
PS E:\Secure-Infra-Lab> git checkout main
PS E:\Secure-Infra-Lab> git merge docs/update-v2
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: `Fast-forward` med lista över ändrade filer.  
Vad vi fick: Merge lyckades utan konflikter ✅

---

### Teorikoppling

**Koncept: Git branching och versionshantering**

En branch är en isolerad kopia av projektet där man
kan jobba utan att påverka huvudversionen. Tänk på
det som ett utkast — man jobbar i utkastet och
publicerar det till huvuddokumentet när det är klart.

`main`-branchen ska alltid vara stabil och fungera.
Allt nytt arbete sker på separata branches. När
arbetet är klart merglas det till `main`.

En tag är en permanent referens till ett specifikt
ögonblick i historiken. `v1.0-baseline` bevarar
projektets exakta tillstånd vid taggningen för alltid.
Branches rör sig framåt — tags gör det inte.

I professionella projekt används Pull Requests för
att granska kod innan merge. En kollega granskar
ändringarna och godkänner dem innan de når `main`.
GitHub visade oss den möjligheten när vi pushade
`docs/update-v2`.

**Officiell dokumentation:**  
- Git branching: https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell  
- Git tagging: https://git-scm.com/book/en/v2/Git-Basics-Tagging


---

## Fas 4 — database-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add database role: PostgreSQL, UFW, schema`
- `Fix: clean inventory groups, pipelining, SSH UFW rule, no warnings`

### Vad vi gjorde

Vi byggde database-rollen som installerar och konfigurerar
PostgreSQL på database-servern. Rollen skapar databas och
användare med minsta privilegium, skapar visits-tabellen
via en SQL-mall och konfigurerar brandväggsregler så att
bara web1 och web2 får ansluta till databasen.

Vi stötte på flera problem under fasen. Det viktigaste
var att UFW blockerade SSH-porten när brandväggen
aktiverades — vilket låste oss ute från database-servern
helt. Vi löste det genom att alltid tillåta SSH-porten
innan UFW aktiveras.

Vi fixade också tre varningar som uppstod under körningen:
namnkrockar i inventory.ini, world-readable temporära filer
och Python interpreter-varningar. Alla tre åtgärdades
permanent för en ren produktionsmiljö.

Slutresultat: `ansible-playbook site.yml` kördes mot alla
sex servrar med `failed=0` och inga varningar.
Idempotens bekräftad — `changed=0` på alla servrar
utom database som har `changed=1` för PostgreSQL restart.

---

### Rollöversikt

```
database-rollen gör fem saker:
1. Installerar PostgreSQL och python3-psycopg2
2. Skapar databasanvändare och databas med minsta privilegium
3. Kör schema.sql.j2 som skapar visits-tabellen
4. Konfigurerar listen_addresses och pg_hba.conf
5. Konfigurerar UFW — bara web1 och web2 når port 5432
```

### Filöversikt

```
ansible/
└── roles/
    └── database/
        ├── tasks/
        │   └── main.yml                        ✅
        ├── handlers/
        │   └── main.yml                        ✅
        └── templates/
            └── schema.sql.j2                   ✅
```


### Varför detta steg är viktigt

Databasen är hjärtat i systemet. Utan en korrekt
konfigurerad databas kan Flask-applikationen inte spara
eller hämta besöksdata. UFW-reglerna säkerställer att
bara web1 och web2 får prata med databasen — det är
ett kritiskt säkerhetslager i vår Defense-in-Depth-strategi.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa mappstruktur för database-rollen
# Varför: Ansible kräver handlers/ och templates/ mappar
# Obs: tasks/ fanns redan som platshållare sedan Fas 3
PS E:\Secure-Infra-Lab> mkdir ansible\roles\database\handlers
PS E:\Secure-Infra-Lab> mkdir ansible\roles\database\templates
```
Förväntat output: Mapparna skapas utan felmeddelanden.
Vad vi fick: Mapparna skapades korrekt ✅

```powershell
# Öppna rollfilerna i VS Code för redigering
PS E:\Secure-Infra-Lab> code ansible\roles\database\tasks\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\database\handlers\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\database\templates\schema.sql.j2
```
Förväntat output: VS Code öppnar varje fil.
Vad vi fick: Filerna öppnades korrekt ✅

```powershell
# Ladda upp tasks/main.yml till control-VM
# Varför: Ansible på control-VM kör rollerna —
# den behöver filerna lokalt
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control -c "truncate -s 0 /home/vagrant/ansible/roles/database/tasks/main.yml"
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\database\tasks\main.yml /home/vagrant/ansible/roles/database/tasks/main.yml control
```
Förväntat output: `Upload has completed successfully!`
Vad vi fick: Exakt det förväntade ✅

```powershell
# Fixa inventory.ini — byt ut gruppnamn för att
# undvika namnkrockar mellan grupp och host
# Varför: [database] som gruppnamn krockar med
# hosten som också heter database — Ansible varnar
PS E:\Secure-Infra-Lab> code ansible\inventory.ini
```
Gamla gruppnamn → nya gruppnamn:
```
[control]    → [control_g]
[nginx]      → [nginx_g]
[webserver]  → [webserver_g]
[webserver2] → [webserver2_g]
[database]   → [database_g]
[monitor]    → [monitor_g]
```
Förväntat output: Inga namnkrocks-varningar vid nästa körning.
Vad vi fick: Alla varningar om namnkrockar försvann ✅

```powershell
# Uppdatera ansible.cfg med pipelining
# Varför: Pipelining eliminerar world-readable
# tmp files-varningen och är säkrare i produktion
PS E:\Secure-Infra-Lab> code ansible\ansible.cfg
```
Vad vi lade till i [ssh_connection]:
```ini
pipelining = True
```
Förväntat output: World-readable tmp files-varningen försvinner.
Vad vi fick: Varningen försvann efter att requiretty
fixades i security_hardening-rollen ✅

```powershell
# Ladda upp uppdaterade filer till control-VM
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\inventory.ini /home/vagrant/ansible/inventory.ini control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\site.yml /home/vagrant/ansible/site.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\ansible.cfg /home/vagrant/ansible/ansible.cfg control
```
Förväntat output: `Upload has completed successfully!` för varje fil.
Vad vi fick: Alla tre filer laddades upp korrekt ✅

```powershell
# Kopiera SSH-nyckel till nyskapad database-VM
# Varför: Vi förstörde och återskapade database-VM —
# den nya VM:en saknade controls publika nyckel
PS E:\Secure-Infra-Lab\vagrant> $pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"
PS E:\Secure-Infra-Lab\vagrant> $port = (vagrant ssh-config database | Select-String "Port").ToString().Trim().Split(" ")[1]
PS E:\Secure-Infra-Lab\vagrant> $keyfile = (vagrant ssh-config database | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
PS E:\Secure-Infra-Lab\vagrant> echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
```
Förväntat output: `Warning: Permanently added '[127.0.0.1]:2203'`
Vad vi fick: Exakt det förväntade ✅

```powershell
# Rensa gamla SSH-fingeravtryck efter vagrant destroy
# Varför: När vi förstörde och återskapade database-VM
# fick den ett nytt fingeravtryck. Det gamla sparade
# fingeravtrycket i known_hosts orsakar varningar
PS E:\Secure-Infra-Lab\vagrant> ssh-keygen -f "C:\Users\modak\.ssh\known_hosts" -R "[127.0.0.1]:2203"
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control -c "ssh-keygen -f '/home/vagrant/.ssh/known_hosts' -R '192.168.56.14'"
```
Förväntat output: `known_hosts updated` på båda ställena.
Vad vi fick: Exakt det förväntade ✅

```powershell
# Committa och pusha alla ändringar till GitHub
PS E:\Secure-Infra-Lab> git add ansible/roles/database ansible/inventory.ini ansible/ansible.cfg ansible/site.yml ansible/roles/security_hardening
PS E:\Secure-Infra-Lab> git commit -m "Fix: clean inventory groups, pipelining, SSH UFW rule, no warnings"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: `feature/database-role -> feature/database-role`
Vad vi fick: Exakt det förväntade ✅

---

#### Bash — inuti control-servern

```bash
# Gå till ansible-mappen och kör playbooken mot database
vagrant@control:~$ cd /home/vagrant/ansible
vagrant@control:~/ansible$ ansible-playbook site.yml --limit database
```
Förväntat output:
```
PLAY RECAP
database : ok=19+  changed=X  unreachable=0  failed=0
```
Vad vi fick första körningen: `failed=1` — UFW blockerade SSH ❌
Orsak: Vi aktiverade UFW med `policy: deny` utan att
tillåta SSH-porten först. Det låste oss ute från servern.
Lösning: Lade till `Allow SSH`-task före `Enable UFW` i
database-rollens tasks/main.yml.

```bash
# Kör playbooken mot alla servrar
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` för alla sex servrar, inga varningar.
Vad vi fick slutligen:
```
control   ok=7   changed=0  failed=0  ✅
database  ok=21  changed=1  failed=0  ✅
monitor   ok=8   changed=0  failed=0  ✅
nginx     ok=8   changed=0  failed=0  ✅
web1      ok=8   changed=0  failed=0  ✅
web2      ok=8   changed=0  failed=0  ✅
```
Inga varningar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/database/tasks/main.yml`
**Vad den gör:** Installerar PostgreSQL, skapar databas
och användare, kör SQL-schemat, konfigurerar
listen_addresses, pg_hba.conf och UFW-brandväggsregler.
**Varför den finns:** Det är ingångspunkten för
database-rollen. Ansible kör tasks/main.yml automatiskt
när rollen aktiveras i site.yml.
**Hur vi skrev den:** Vi identifierade varje steg som
behövdes och sökte rätt Ansible-modul för varje steg
i officiell dokumentation.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/database-role/ansible/roles/database/tasks/main.yml
**Officiella källor:**
- apt-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html
- postgresql_user: https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_user_module.html
- postgresql_db: https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_db_module.html
- postgresql_pg_hba: https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_pg_hba_module.html
- lineinfile: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html
- ufw: https://docs.ansible.com/ansible/latest/collections/community/general/ufw_module.html
- template: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html

📄 `ansible/roles/database/handlers/main.yml`
**Vad den gör:** Definierar `Restart postgresql` —
körs bara om PostgreSQL-konfigurationen faktiskt ändrades.
**Varför den finns:** Onödiga omstarter av PostgreSQL
i produktion kan orsaka kortvariga driftstopp för
alla anslutna applikationer.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/database-role/ansible/roles/database/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/database/templates/schema.sql.j2`
**Vad den gör:** SQL-mall som skapar visits-tabellen
om den inte redan finns. Tabellen sparar server_name
och tidsstämpel för varje besök.
**Varför den finns:** Flask-applikationen behöver
visits-tabellen för att fungera. `CREATE TABLE IF NOT EXISTS`
gör att tasken är idempotent — den kan köras flera
gånger utan att skapa dubbletter.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/database-role/ansible/roles/database/templates/schema.sql.j2
**Officiell dokumentation:** https://www.postgresql.org/docs/14/sql-createtable.html

📄 `ansible/inventory.ini` (uppdaterad)
**Vad den gör:** Listar alla sex servrar med
IP-adresser, SSH-inställningar och explicit
Python-interpreter. Gruppnamnen är uppdaterade
med `_g`-suffix för att undvika namnkrockar.
**Varför den uppdaterades:** Ansible varnade för
namnkrockar när grupp och host hade samma namn.
Explicit Python-interpreter eliminerar
interpreter-varningen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/database-role/ansible/inventory.ini
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

📄 `ansible/ansible.cfg` (uppdaterad)
**Vad den gör:** Ansible-konfiguration med pipelining
aktiverat för att eliminera world-readable
tmp files-varningen.
**Varför den uppdaterades:** Pipelining är säkrare
än world-readable temporära filer. Det kräver att
`Defaults !requiretty` är konfigurerat i sudoers
— vilket security_hardening-rollen nu hanterar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/database-role/ansible/ansible.cfg
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html

---

### Problem och lösningar

**Problem 1 — Duplicerat innehåll i tasks/main.yml**
**Vad som hände:** När vi försökte klistra in kod i
terminalen via heredoc och PowerShell here-string
kopierades texten fel — antingen visades den i
terminalen istället för att skrivas till filen,
eller så lades den till efter det befintliga
innehållet. Resultatet blev att filen innehöll
dubbla kopior av koden.
**Orsak:** Terminalen (både Bash och PowerShell) kan
inte hantera långa inklistringar med specialtecken
på ett tillförlitligt sätt. Unicode-symboler i
kommentarerna (─, █) förstörde texten ytterligare.
**Lösning:** Öppnade filen direkt i VS Code,
markerade allt med `Ctrl+A`, tog bort med `Delete`
och klistrade in den rena koden. Laddade sedan upp
med `vagrant upload`.
**Lärdomen:** Redigera alltid YAML-filer i VS Code —
aldrig via terminal för längre innehåll.

**Problem 2 — UFW låste ut SSH**
**Felmeddelande:** `Connection timed out` vid SSH till database
**Vad som hände:** Vi aktiverade UFW med `policy: deny`
utan att först tillåta SSH-porten (22). UFW blockerade
all trafik inklusive SSH — vi kunde inte längre
ansluta till database-servern.
**Lösning:** Förstörde och återskapade database-VM med
`vagrant destroy database -f && vagrant up database`.
Lade sedan till `Allow SSH`-tasken **före** `Enable UFW`
i tasks/main.yml.
**Lärdomen:** I en verklig produktionsmiljö hade detta
inneburit ett allvarligt driftstopp. Alltid tillåt
SSH-porten innan UFW aktiveras — annars låser man
ut sig själv permanent.

**Problem 3 — REMOTE HOST IDENTIFICATION HAS CHANGED**
**Felmeddelande:** `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED`
**Vad som hände:** När vi återskapade database-VM fick
den ett nytt SSH-fingeravtryck. Det gamla fingeravtrycket
fanns kvar i `known_hosts` på både Windows och control-VM.
SSH vägrade ansluta av säkerhetsskäl.
**Lösning:** Rensade gamla fingeravtryck med
`ssh-keygen -R` på båda ställena.
**Lärdomen:** Detta händer alltid när en server
återskapas. I produktion dokumenterar man alltid
serverändringar och uppdaterar `known_hosts` på
alla relevanta klienter.

**Problem 4 — Pipelining orsakade SSH-timeout**
**Felmeddelande:** `Data could not be sent to remote host`
**Vad som hände:** Vi aktiverade pipelining i ansible.cfg
men `requiretty` var fortfarande aktiverat i sudoers
på servrarna. Pipelining och requiretty är inkompatibla.
**Lösning:** Lade till `Defaults !requiretty` i sudoers
via security_hardening-rollen. Sedan fungerade
pipelining korrekt.
**Lärdomen:** Pipelining kräver alltid att requiretty
är inaktiverat. Rätt ordning är: konfigurera sudoers
först — aktivera pipelining sedan.

---

### Teorikoppling

**Koncept 1: Minsta privilegium (Principle of Least Privilege)**

Minsta privilegium betyder att varje del av systemet
bara får de rättigheter den faktiskt behöver —
ingenting mer.

I det här projektet skapade vi en dedikerad
databasanvändare `flaskuser` som bara får ansluta
till `flaskdb`-databasen. Användaren kan inte skapa
nya databaser, radera tabeller eller komma åt andra
databaser på servern.

UFW-reglerna tillämpar samma princip på nätverksnivå —
bara web1 och web2 får ansluta till port 5432.
Alla andra anslutningar blockeras.

I produktion används detta mönster överallt.
En webbapplikation får bara läsa och skriva till
sin egen databas. En backup-tjänst får bara läsa.
En admin-användare med fulla rättigheter existerar
bara för underhållsarbete — aldrig för normal drift.

**Officiell dokumentation:**
- PostgreSQL roller: https://www.postgresql.org/docs/14/user-manag.html
- UFW: https://help.ubuntu.com/community/UFW

**Koncept 2: Hur man skriver en Ansible tasks/main.yml**

Varje task i en Ansible-roll följer samma mönster:

```yaml
- name: Vad uppgiften gör (beskrivning på engelska)
  modul_namn:
    parameter1: värde1
    parameter2: värde2
```

Så här tänker man när man skriver en tasks/main.yml
från grunden:

1. Tänk igenom steg för steg vad servern behöver
2. För varje steg — sök rätt Ansible-modul:
   https://docs.ansible.com/ansible/latest/collections/index_module.html
3. Läs modulens dokumentation och kopiera exempelkoden
4. Anpassa parametrarna till ditt projekt

Moduler vi använde i database-rollen:

| Modul | Vad den gör | Dokumentation |
|-------|-------------|---------------|
| apt | Installerar paket | https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html |
| service | Startar/stoppar tjänster | https://docs.ansible.com/ansible/latest/collections/ansible/builtin/service_module.html |
| postgresql_user | Skapar databasanvändare | https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_user_module.html |
| postgresql_db | Skapar databas | https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_db_module.html |
| postgresql_script | Kör SQL-fil | https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_script_module.html |
| postgresql_pg_hba | Konfigurerar pg_hba.conf | https://docs.ansible.com/ansible/latest/collections/community/postgresql/postgresql_pg_hba_module.html |
| lineinfile | Ändrar en rad i en fil | https://docs.ansible.com/ansible/latest/collections/ansible/builtin/lineinfile_module.html |
| ufw | Konfigurerar brandvägg | https://docs.ansible.com/ansible/latest/collections/community/general/ufw_module.html |
| template | Kopierar Jinja2-mall | https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html |

Det är precis så erfarna Ansible-användare jobbar —
ingen kan alla moduler utantill. Man söker i
dokumentationen varje gång.

**Koncept 3: UFW och nätverkssegmentering**

UFW (Uncomplicated Firewall) är ett enkelt sätt att
hantera brandväggsregler i Linux. Det bygger på
iptables men med ett mycket enklare gränssnitt.

Vår UFW-konfiguration på database-servern:
```
Port 22   → Tillåt SSH från alla (måste alltid vara öppen)
Port 5432 → Tillåt bara från 192.168.56.12 (web1)
Port 5432 → Tillåt bara från 192.168.56.13 (web2)
Allt annat → Blockera (policy: deny)
```

Lärdomen från det här projektet: Tillåt alltid
SSH-porten INNAN du aktiverar UFW med `policy: deny`.
Annars låser du ut dig själv från servern.

I produktion lägger man också till övervakning av
UFW-loggar i Wazuh så att man ser om någon försöker
ansluta till blockerade portar — det kan vara ett
tecken på en pågående attack.

**Officiell dokumentation:**
- UFW: https://help.ubuntu.com/community/UFW
- PostgreSQL pg_hba.conf: https://www.postgresql.org/docs/14/auth-pg-hba-conf.html


---

## Fas 5 — flask-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add flask role: app.py, Gunicorn, systemd, env file`
- `Fix flask role: server_name via host_vars, DB permissions, no warnings`

### Vad vi gjorde

Vi byggde flask-rollen som installerar och konfigurerar
Flask-applikationen på web1 och web2. En gemensam roll
används för båda servrarna — skillnaden hanteras via
`server_name`-variabeln. web1 får "Server 1" och web2
får "Server 2".

Rollen installerar Python, Flask och Gunicorn, kopierar
app.py till servern, skapar en `.env`-fil med
databasuppgifter och registrerar en systemd-tjänst som
startar om Flask automatiskt vid krasch.

Vi stötte på flera problem under fasen. BOM-tecken i
filer orsakade tolkningsfel. `server_name`-variabeln
åsidosattes inte korrekt för web2. Flask saknade
rättigheter att skriva till visits-tabellen. Alla
problem löste vi permanent.

Slutresultat: Båda servrarna svarar korrekt.
`/visit` sparar besök i databasen och visar de 5
senaste besöken. Inga varningar.

---

### Rollöversikt

```
flask-rollen gör fem saker:
1. Installerar Python, Flask och Gunicorn
2. Kopierar app.py till servern
3. Skapar en .env-fil med databasuppgifter
4. Registrerar en systemd-tjänst som startar Flask automatiskt
5. Startar och aktiverar tjänsten
```

En gemensam roll används för både web1 och web2.
Skillnaden hanteras via server_name-variabeln:

- web1 → server_name: "Server 1" (default i defaults/main.yml)
- web2 → server_name: "Server 2" (åsidosatt via host_vars/web2.yml)

### Filöversikt

```
flask/
├── files/
│   └── app.py              ✅
├── handlers/
│   └── main.yml            ✅
├── tasks/
│   └── main.yml            ✅
├── templates/
│   ├── flask.service.j2    ✅
│   └── flask.env.j2        ✅
├── vars/
│   └── main.yml            ✅
└── defaults/
    └── main.yml            ✅

ansible/
└── host_vars/
    └── web2.yml            ✅
```

---

### Varför detta steg är viktigt

Flask-applikationen är kärnan i systemet — det är
den som tar emot besök, kommunicerar med databasen
och returnerar svar till användaren. Utan en korrekt
konfigurerad Flask-applikation fungerar inget av
det övriga systemet. systemd-tjänsten säkerställer
att applikationen alltid körs och automatiskt
startar om vid eventuella krascher.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa mappstruktur för flask-rollen
PS E:\Secure-Infra-Lab> mkdir ansible\roles\flask\handlers
PS E:\Secure-Infra-Lab> mkdir ansible\roles\flask\templates
PS E:\Secure-Infra-Lab> mkdir ansible\roles\flask\files
PS E:\Secure-Infra-Lab> mkdir ansible\roles\flask\vars
PS E:\Secure-Infra-Lab> mkdir ansible\roles\flask\defaults
```
Förväntat output: Inga felmeddelanden.
Vad vi fick: Alla mappar skapades korrekt. ✅

```powershell
# Öppna rollfilerna i VS Code
# Viktigt: Spara alltid som UTF-8 (inte UTF-8 with BOM)
# Klicka på "UTF-8 with BOM" längst ner i VS Code
# och välj "Save with Encoding" -> "UTF-8"
PS E:\Secure-Infra-Lab> code ansible\roles\flask\files\app.py
PS E:\Secure-Infra-Lab> code ansible\roles\flask\handlers\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\flask\tasks\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\flask\templates\flask.env.j2
PS E:\Secure-Infra-Lab> code ansible\roles\flask\templates\flask.service.j2
PS E:\Secure-Infra-Lab> code ansible\roles\flask\vars\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\flask\defaults\main.yml
```
Förväntat output: VS Code öppnar varje fil.
Vad vi fick: Filerna öppnades korrekt. ✅

```powershell
# Konvertera filer till LF och ta bort CRLF
PS E:\Secure-Infra-Lab> $files = @(
    "ansible\roles\flask\files\app.py",
    "ansible\roles\flask\handlers\main.yml",
    "ansible\roles\flask\tasks\main.yml",
    "ansible\roles\flask\templates\flask.env.j2",
    "ansible\roles\flask\templates\flask.service.j2",
    "ansible\roles\flask\vars\main.yml",
    "ansible\site.yml"
)
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText("E:\Secure-Infra-Lab\$file")
    $content = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText("E:\Secure-Infra-Lab\$file", $content, [System.Text.Encoding]::UTF8)
    Write-Host "Converted: $file"
}
```
Förväntat output: Converted: [filnamn] för varje fil.
Vad vi fick: Alla filer konverterades korrekt. ✅

```powershell
# Skapa host_vars för web2 — ger server_name: "Server 2"
PS E:\Secure-Infra-Lab> mkdir ansible\host_vars
PS E:\Secure-Infra-Lab> code ansible\host_vars\web2.yml
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt. ✅

```powershell
# Ladda upp alla flask-filer till control-VM
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control -c "mkdir -p /home/vagrant/ansible/roles/flask/files /home/vagrant/ansible/roles/flask/handlers /home/vagrant/ansible/roles/flask/templates /home/vagrant/ansible/roles/flask/vars /home/vagrant/ansible/roles/flask/defaults /home/vagrant/ansible/host_vars"
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\files\app.py /home/vagrant/ansible/roles/flask/files/app.py control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\handlers\main.yml /home/vagrant/ansible/roles/flask/handlers/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\tasks\main.yml /home/vagrant/ansible/roles/flask/tasks/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\templates\flask.env.j2 /home/vagrant/ansible/roles/flask/templates/flask.env.j2 control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\templates\flask.service.j2 /home/vagrant/ansible/roles/flask/templates/flask.service.j2 control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\vars\main.yml /home/vagrant/ansible/roles/flask/vars/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\defaults\main.yml /home/vagrant/ansible/roles/flask/defaults/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\host_vars\web2.yml /home/vagrant/ansible/host_vars/web2.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\site.yml /home/vagrant/ansible/site.yml control
```
Förväntat output: Upload has completed successfully! för varje fil.
Vad vi fick: Alla filer laddades upp korrekt. ✅

```powershell
# Committa och pusha till GitHub
PS E:\Secure-Infra-Lab> git add ansible/roles/flask ansible/roles/database ansible/site.yml ansible/host_vars .gitignore
PS E:\Secure-Infra-Lab> git commit -m "Fix flask role: server_name via host_vars, DB permissions, no warnings"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: feature/flask-role -> feature/flask-role
Vad vi fick: Exakt det förväntade. ✅

---

#### Bash — inuti control-servern

```bash
# Kör playbooken mot web1
vagrant@control:~/ansible$ ansible-playbook site.yml --limit webserver_g
```
Förväntat output: web1 : ok=16  changed=7  failed=0
Vad vi fick: Exakt det förväntade. ✅

```bash
# Verifiera att Flask svarar på web1
vagrant@control:~/ansible$ curl -s http://192.168.56.12:5000/
```
Förväntat output: Hello from Server 1!
Vad vi fick: Hello from Server 1! ✅

```bash
# Kör playbooken mot web2
vagrant@control:~/ansible$ ansible-playbook site.yml --limit webserver2_g
```
Förväntat output: web2 : ok=16  changed=7  failed=0
Vad vi fick: Exakt det förväntade. ✅

```bash
# Verifiera att Flask svarar på web2
vagrant@control:~/ansible$ curl -s http://192.168.56.13:5000/
```
Förväntat output: Hello from Server 2!
Vad vi fick (först): Hello from Server 1! — fel server_name ❌
Fel: server_name från vars/main.yml hade högre prioritet än host_vars.
Lösning: Flyttade server_name till defaults/main.yml och skapade
host_vars/web2.yml med server_name: "Server 2".
Vad vi fick slutligen: Hello from Server 2! ✅

```bash
# Testa /visit-routen
vagrant@control:~/ansible$ curl -s http://192.168.56.12:5000/visit
vagrant@control:~/ansible$ curl -s http://192.168.56.13:5000/visit
```
Förväntat output: Visit registered from Server 1/2 med senaste besök.
Vad vi fick (först): 500 Internal Server Error ❌
Fel: psycopg2.errors.InsufficientPrivilege: permission denied for table visits
Orsak: flaskuser saknade SELECT och INSERT-rättigheter på visits-tabellen.
Lösning: Lade till GRANT-kommandon i schema.sql.j2.
Vad vi fick slutligen:
```
Server 1: <h2>Visit registered from Server 1</h2>
Server 2: <h2>Visit registered from Server 2</h2>
```
✅

---

### Konfigurationsfiler

📄 `ansible/roles/flask/files/app.py`
**Vad den gör:** Flask-applikationen med tre routes:
/ (hello), /secret (visar env-variabler), /visit
(sparar besök i databasen och visar de 5 senaste).
Läser alla credentials från miljövariabler via os.getenv().
**Varför den finns:** Applikationskoden som körs på web1
och web2. Aldrig hårdkodade lösenord i källkod.
**Hur vi skrev den:** Vi följde Flask-dokumentationen
för routes och psycopg2-dokumentationen för
databasanslutning.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/flask-role/ansible/roles/flask/files/app.py
**Officiell dokumentation:**
- Flask: https://flask.palletsprojects.com/en/3.0.x/
- psycopg2: https://www.psycopg.org/docs/

📄 `ansible/roles/flask/templates/flask.service.j2`
**Vad den gör:** systemd-tjänstfil för Flask via Gunicorn.
Startar om tjänsten automatiskt vid krasch. Laddar
miljövariabler från .env-filen. Körs som vagrant-användaren
— aldrig som root.
**Varför den finns:** systemd säkerställer att Flask alltid
körs och startar automatiskt när servern bootar.
**Hur vi skrev den:** Vi följde systemd-dokumentationen
för service-filer och Gunicorn-dokumentationen för
korrekt startkommando.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/flask-role/ansible/roles/flask/templates/flask.service.j2
**Officiell dokumentation:**
- systemd: https://systemd.io/
- Gunicorn: https://docs.gunicorn.org/

📄 `ansible/roles/flask/templates/flask.env.j2`
**Vad den gör:** Miljövariabler för Flask — databasuppgifter
och server_name. Filen är bara läsbar av root (mode 0600).
Flask läser den via systemd EnvironmentFile-direktivet.
**Varför den finns:** Credentials ska aldrig vara i
källkod. .env-filen separerar konfiguration från kod.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/flask-role/ansible/roles/flask/templates/flask.env.j2

📄 `ansible/roles/flask/defaults/main.yml`
**Vad den gör:** Standardvärden för flask-rollen.
server_name är satt till "Server 1" som default.
**Varför den finns:** defaults/main.yml har lägre prioritet
än host_vars — det gör att host_vars/web2.yml kan
åsidosätta server_name för web2.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/flask-role/ansible/roles/flask/defaults/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

📄 `ansible/host_vars/web2.yml`
**Vad den gör:** Åsidosätter server_name för web2 specifikt.
**Varför den finns:** host_vars har högre prioritet än
defaults/main.yml men lägre än vars/main.yml. Det gör
att vi kan ge web2 ett unikt server_name utan att ändra
den gemensamma rollen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/flask-role/ansible/host_vars/web2.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#organizing-host-and-group-variables

---

### Problem och lösningar

**Problem 1 — BOM-tecken i filer**
**Felmeddelande:** Filer började med osynligt tecken (﻿)
**Vad som hände:** VS Code sparade filer med UTF-8 with BOM
istället för UTF-8. BOM-tecknet orsakar tolkningsfel i
YAML och Python på Linux.
**Lösning:** Klicka på "UTF-8 with BOM" i VS Code statusfält
och välj "Save with Encoding" → "UTF-8".
**Lärdomen:** Kontrollera alltid filkodning i VS Code när
nya filer skapas — spara alltid som UTF-8 utan BOM.

**Problem 2 — server_name åsidosattes inte för web2**
**Felmeddelande:** Hello from Server 1! på båda servrarna
**Vad som hände:** server_name i vars/main.yml har högre
prioritet än vars: i site.yml och host_vars. Ansible
använde alltid "Server 1" oavsett vad vi satte.
**Lösning:** Flyttade server_name till defaults/main.yml
(lägre prioritet) och skapade host_vars/web2.yml med
server_name: "Server 2". host_vars åsidosätter defaults.
**Lärdomen:** Ansible variabelprioritet från högst till lägst:
extra vars → host_vars → group_vars → play vars →
role vars → role defaults

**Problem 3 — permission denied for table visits**
**Felmeddelande:** psycopg2.errors.InsufficientPrivilege:
permission denied for table visits
**Vad som hände:** flaskuser skapades men fick inte
explicit GRANT på visits-tabellen och dess sekvens.
**Lösning:** Lade till GRANT SELECT, INSERT ON visits och
GRANT USAGE, SELECT ON SEQUENCE visits_id_seq i
schema.sql.j2.
**Lärdomen:** I PostgreSQL räcker det inte att äga databasen —
varje tabell och sekvens måste ha explicita rättigheter.

**Problem 4 — PostgreSQL lyssnade bara på localhost**
**Felmeddelande:** connection to server at "192.168.56.14",
port 5432 failed: Connection refused
**Vad som hände:** listen_addresses var konfigurerat till
specifika IP-adresser men PostgreSQL startades inte om
efter konfigurationsändringen.
**Lösning:** Ändrade listen_addresses till '*' i database-rollen
och lät UFW-reglerna begränsa åtkomsten till bara
web1 och web2 på port 5432.
**Lärdomen:** listen_addresses = '*' är acceptabelt när
UFW-regler begränsar åtkomsten explicit. Defense-in-Depth
via brandvägg kompenserar för den öppna listen_addresses.

---

### Teorikoppling

**Koncept 1: Ansible variabelprioritet**

Ansible har en strikt prioritetsordning för variabler.
Från högst till lägst prioritet:

1. Extra vars (-e flagga vid körning)
2. host_vars — variabler per specifik host
3. group_vars — variabler per grupp
4. play vars: i site.yml
5. role vars/main.yml — högst inom rollen
6. role defaults/main.yml — lägst inom rollen

I det här projektet använder vi defaults/main.yml
för standardvärden och host_vars/web2.yml för att
åsidosätta server_name på web2. Det ger en ren
och förutsägbar konfiguration.

**Officiell dokumentation:**
https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

**Koncept 2: systemd och tjänstehantering**

systemd är Linuxs tjänstehanterare. Det startar,
stoppar och övervakar tjänster. Med Restart=always
i flask.service.j2 startar systemd om Flask automatiskt
om den kraschar — utan manuell intervention.

I produktionsmiljöer är detta kritiskt. En applikation
som kraschar klockan 3 på natten startar om
automatiskt utan att någon behöver vakna och
logga in manuellt.

**Officiell dokumentation:** https://systemd.io/

**Koncept 3: Separation av konfiguration och kod**

.env-filen separerar konfiguration från kod. app.py
läser aldrig hårdkodade lösenord — den läser dem
alltid från miljövariabler via os.getenv().

Det här gör att samma kod kan köras i olika miljöer
(test, staging, produktion) med olika konfiguration
utan att ändra en enda rad kod. Det är en av de
12 principerna i The Twelve-Factor App — en
standard för moderna webbapplikationer.

**Officiell dokumentation:**
- The Twelve-Factor App: https://12factor.net/config
- Python os.getenv: https://docs.python.org/3/library/os.html#os.getenv


---

## Fas 6 — nginx-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add nginx role: reverse proxy, round-robin load balancer`
- `Fix nginx role: remove BOM from nginx.conf.j2`

### Vad vi gjorde

Vi byggde nginx-rollen som konfigurerar nginx som
reverse proxy med round-robin lastbalansering mot
web1 och web2. nginx tar emot all trafik på port 80
och skickar vidare till web1 och web2 i turordning.

Vi stötte på ett problem — BOM-tecken i nginx.conf.j2
orsakade ett konfigurationsfel. Efter att vi fixat
encodingen fungerade nginx perfekt.

Slutresultat: nginx skickar trafik växelvis till
Server 1 och Server 2. Lastbalanseringen är verifierad
från både control-VM och Windows-webbläsaren via
http://localhost:8080.

---

### Rollöversikt

```
nginx-rollen gör tre saker:
1. Installerar nginx
2. Distribuerar nginx.conf via Jinja2-mall
3. Startar och aktiverar nginx-tjänsten
```

nginx är den enda servern som är nåbar utifrån
via port forwarding (:80 → host:8080). All trafik
passerar genom nginx som distribuerar förfrågningar
till web1 och web2 i round-robin.

### Filöversikt

```
ansible/
└── roles/
    └── nginx/
        ├── tasks/
        │   └── main.yml        ✅
        ├── handlers/
        │   └── main.yml        ✅
        └── templates/
            └── nginx.conf.j2   ✅
```

---

### Varför detta steg är viktigt

nginx är presentationslagret i vår 3-tier-arkitektur.
Det är den enda ingångspunkten till systemet utifrån.
Utan nginx skulle besökare behöva veta exakt vilken
server de ska ansluta till. Med nginx är det helt
transparent — besökaren ansluter alltid till samma
adress och nginx hanterar fördelningen automatiskt.

Lastbalansering ger också redundans — om web1 slutar
fungera kan nginx fortsätta skicka trafik till web2.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa mappstruktur för nginx-rollen
PS E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\handlers
PS E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\templates
```
Förväntat output: Inga felmeddelanden.
Vad vi fick: Mapparna skapades korrekt. ✅

```powershell
# Öppna rollfilerna i VS Code
PS E:\Secure-Infra-Lab> code ansible\roles\nginx\tasks\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\nginx\handlers\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\nginx\templates\nginx.conf.j2
```
Förväntat output: VS Code öppnar varje fil.
Vad vi fick: Filerna öppnades korrekt. ✅

```powershell
# Konvertera filer till LF och ta bort CRLF
PS E:\Secure-Infra-Lab> $files = @(
    "ansible\roles\nginx\handlers\main.yml",
    "ansible\roles\nginx\templates\nginx.conf.j2",
    "ansible\roles\nginx\tasks\main.yml"
)
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText("E:\Secure-Infra-Lab\$file")
    $content = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText("E:\Secure-Infra-Lab\$file", $content, [System.Text.Encoding]::UTF8)
    Write-Host "Converted: $file"
}
```
Förväntat output: Converted: [filnamn] för varje fil.
Vad vi fick: Alla filer konverterades korrekt. ✅

```powershell
# Ladda upp nginx-filer till control-VM
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control -c "mkdir -p /home/vagrant/ansible/roles/nginx/handlers /home/vagrant/ansible/roles/nginx/templates"
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\nginx\tasks\main.yml /home/vagrant/ansible/roles/nginx/tasks/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\nginx\handlers\main.yml /home/vagrant/ansible/roles/nginx/handlers/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\nginx\templates\nginx.conf.j2 /home/vagrant/ansible/roles/nginx/templates/nginx.conf.j2 control
```
Förväntat output: Upload has completed successfully! för varje fil.
Vad vi fick: Alla filer laddades upp korrekt. ✅

```powershell
# Committa och pusha till GitHub
PS E:\Secure-Infra-Lab> git add ansible/roles/nginx
PS E:\Secure-Infra-Lab> git commit -m "Add nginx role: reverse proxy, round-robin load balancer"
PS E:\Secure-Infra-Lab> git push --set-upstream origin feature/nginx-role
```
Förväntat output: feature/nginx-role -> feature/nginx-role
Vad vi fick: Exakt det förväntade. ✅

---

#### Bash — inuti control-servern

```bash
# Kör playbooken mot nginx
vagrant@control:~/ansible$ ansible-playbook site.yml --limit nginx_g
```
Förväntat output: nginx : ok=14  changed=X  failed=0
Vad vi fick (först): failed=1 — nginx startade inte ❌
Fel: nginx: [emerg] unknown directive "﻿#" in flask.conf:5
Orsak: BOM-tecken i nginx.conf.j2 orsakade tolkningsfel.
Lösning: Öppnade filen i VS Code och sparade om som UTF-8.
Vad vi fick slutligen: ok=14  changed=3  failed=0 ✅

```bash
# Verifiera round-robin lastbalansering
vagrant@control:~$ for i in 1 2 3 4 5 6; do curl -s http://192.168.56.11/; echo ''; done
```
Förväntat output:
```
Hello from Server 1!
Hello from Server 2!
Hello from Server 1!
Hello from Server 2!
Hello from Server 1!
Hello from Server 2!
```
Vad vi fick: Exakt det förväntade — perfekt ping-pong! ✅

```bash
# Verifiera /visit via nginx
vagrant@control:~$ for i in 1 2 3 4; do curl -s http://192.168.56.11/visit; echo ''; done
```
Förväntat output: Visit registered from Server 1/2 växelvis.
Vad vi fick: Perfekt växling mellan Server 1 och Server 2. ✅

---

### Konfigurationsfiler

📄 `ansible/roles/nginx/tasks/main.yml`
**Vad den gör:** Installerar nginx, tar bort
standardkonfigurationen, distribuerar vår
konfiguration och aktiverar sajten via en
symbolisk länk.
**Varför den finns:** Ingångspunkten för nginx-rollen.
**Hur vi skrev den:** Vi följde nginx-dokumentationen
för sites-available/sites-enabled-mönstret.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/nginx-role/ansible/roles/nginx/tasks/main.yml
**Officiell dokumentation:**
- nginx: https://nginx.org/en/docs/
- Ansible file-modulen: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html

📄 `ansible/roles/nginx/handlers/main.yml`
**Vad den gör:** Definierar Restart nginx — körs
bara om konfigurationen faktiskt ändrades.
**Varför den finns:** Onödiga omstarter av nginx
i produktion bryter aktiva anslutningar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/nginx-role/ansible/roles/nginx/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/nginx/templates/nginx.conf.j2`
**Vad den gör:** Konfigurerar nginx som reverse proxy
med round-robin lastbalansering. Definierar upstream
med web1 och web2 på port 5000. Vidarebefordrar
original HTTP-headers till Flask.
**Varför den finns:** nginx behöver veta vilka
bakgrundsservrar som finns och hur trafiken ska
fördelas.
**Hur vi skrev den:** Vi följde nginx upstream-
dokumentationen och lärarens kodmönster med
proxy_set_header för Host, X-Real-IP och
X-Forwarded-For.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/nginx-role/ansible/roles/nginx/templates/nginx.conf.j2
**Officiell dokumentation:** https://nginx.org/en/docs/http/ngx_http_upstream_module.html

---

### Problem och lösningar

**Problem 1 — BOM-tecken i nginx.conf.j2**
**Felmeddelande:** nginx: [emerg] unknown directive "﻿#" in flask.conf:5
**Vad som hände:** nginx.conf.j2 sparades med UTF-8
with BOM trots konverteringen. nginx tolkade
BOM-tecknet som ett ogiltigt direktiv och vägrade starta.
**Lösning:** Öppnade filen i VS Code, klickade på
encoding längst ner och valde "Save with Encoding"
→ "UTF-8".
**Lärdomen:** Alltid verifiera encoding för template-filer
(.j2) — nginx är känsligare för BOM-tecken än YAML.

---

### Teorikoppling

**Koncept 1: Reverse proxy och lastbalansering**

En reverse proxy är en server som tar emot förfrågningar
från klienter och vidarebefordrar dem till en eller
flera bakgrundsservrar. Klienten vet inte vilken
bakgrundsserver som svarar — den ser bara proxyn.

Round-robin är den enklaste lastbalanseringsalgoritmen.
Förfrågningar skickas i turordning till varje server.
Förfrågan 1 → web1, förfrågan 2 → web2, förfrågan
3 → web1 igen, och så vidare.

I det här projektet tar nginx emot all trafik på
port 80 och fördelar den till web1 (port 5000) och
web2 (port 5000) i turordning. Det gör att ingen
enskild server överlastas och systemet fortsätter
fungera om en server temporärt är nere.

**Officiell dokumentation:**
- nginx upstream: https://nginx.org/en/docs/http/ngx_http_upstream_module.html
- nginx reverse proxy: https://nginx.org/en/docs/http/ngx_http_proxy_module.html

**Koncept 2: sites-available och sites-enabled**

Ubuntu nginx använder ett mönster med två mappar:
`sites-available` innehåller alla konfigurationsfiler.
`sites-enabled` innehåller symboliska länkar till
de aktiva konfigurationerna.

Det gör det enkelt att aktivera och inaktivera sajter
utan att ta bort konfigurationsfiler. Vi skapar
`flask.conf` i `sites-available` och en symbolisk
länk i `sites-enabled`.

**Officiell dokumentation:** https://nginx.org/en/docs/beginners_guide.html

**Koncept 3: X-Forwarded-For och proxy-headers**

När nginx vidarebefordrar en förfrågan till Flask
ser Flask bara nginx IP-adress — inte klientens
riktiga IP. Med `proxy_set_header X-Forwarded-For`
skickar nginx med klientens riktiga IP-adress i
en HTTP-header. Flask kan då läsa den riktiga
IP-adressen ur headern.

I produktion är detta viktigt för loggning,
säkerhetsanalys och rate limiting — man vill veta
vilka riktiga IP-adresser som ansluter, inte bara
nginx interna IP.

**Officiell dokumentation:** https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_set_header


---

---

## Fas 7 — wazuh_manager, wazuh_agent och Cockpit Dashboard
**Datum:** 2026-05-07 / 2026-05-08
**Git-commits:**
- `Add port forwarding 443->8443 for Wazuh Dashboard on monitor`
- `Add wazuh_manager and wazuh_agent roles, fix flask defaults`
- `Replace Wazuh Dashboard with Cockpit, fix monitor port forwarding`
- `Update comments: Cockpit dashboard on port 9090`

### Vad vi gjorde

Vi installerade Wazuh på hela infrastrukturen och lade
till ett webbbaserat övervakningsdashboard på monitor-servern.

Fas 7 består av tre delar:
- Wazuh Manager installerades på monitor-servern.
  Den tar emot säkerhetshändelser från alla andra servrar.
- Wazuh Agent installerades på de fem andra servrarna.
  Varje agent skickar händelser till Manager kontinuerligt.
- Cockpit installerades på monitor-servern som ett
  lättanvänt webbdashboard för systemövervakning.
  Det nås via https://localhost:9090.

Vi försökte också installera Wazuh Dashboard och
Wazuh Indexer men stötte på problem med SSL-certifikat
och minnesbrist. Vi valde istället Cockpit som är
enklare, kräver mindre minne och ger bra översikt
över systemet.

Slutresultat: Wazuh Manager och Cockpit körs på
monitor. Wazuh Agent körs på alla fem andra servrar.
Hela playbooken ger `failed=0` på alla sex servrar
utan varningar. Cockpit är tillgänglig via
https://localhost:9090.

---

### Vad är Wazuh och hur fungerar det?

Wazuh är ett verktyg som övervakar säkerheten på
dina servrar. Tänk på det som ett larmsystem:

```
Wazuh Agent   = Rörelsedetektor i varje rum
Wazuh Manager = Larmpanelen som samlar alla signaler
Cockpit       = Skärmen där du ser vad som händer
```

Wazuh håller koll på:
- Vem som loggar in och ut på servrarna
- Om viktiga filer ändras (t.ex. /etc/passwd)
- Om någon försöker logga in med fel lösenord många gånger
- Om det finns kända säkerhetsproblem i installerade program

Wazuh arbetar på två sätt:
- I bakgrunden — kontrollerar loggar var femte sekund
- I realtid — skickar varning direkt om något allvarligt händer

---

### Vad är Cockpit?

Cockpit är ett enkelt webbdashboard som är inbyggt
i Ubuntu. Det visar systeminformation i realtid
direkt i webbläsaren utan krånglig konfiguration.

Cockpit visar:
- CPU- och minnesanvändning i realtid
- Systemloggar
- Nätverkstrafik
- Tjänster som körs
- Terminal direkt i webbläsaren

Det nås via: https://localhost:9090
Inloggning med: vagrant / vagrant

---

### Rollöversikt

```
Fas 7 består av tre delar:

Del 1 — wazuh_manager (körs på monitor .15):
1. Lägger till Wazuh i systemets paketlista
2. Installerar wazuh-manager
3. Startar och aktiverar Wazuh Manager-tjänsten
4. Installerar Cockpit för webbbaserad övervakning
5. Startar och aktiverar Cockpit-tjänsten

Del 2 — wazuh_agent (körs på control, nginx, web1, web2, database):
1. Lägger till Wazuh i systemets paketlista
2. Installerar wazuh-agent
3. Talar om för agenten var Manager finns (monitor .15)
4. Startar och aktiverar agent-tjänsten
```

### Filöversikt

```
ansible/
└── roles/
    ├── wazuh_manager/
    │   └── tasks/
    │       └── main.yml        ✅
    │
    └── wazuh_agent/
        └── tasks/
            └── main.yml        ✅

ansible/
└── site.yml                    ✅ (uppdaterad)

vagrant/
└── Vagrantfile                 ✅ (port forwarding 9090→9090)
```

---

### Varför detta steg är viktigt

Utan Wazuh är infrastrukturen blind. Vi vet inte
vad som händer på servrarna. Med Wazuh får vi
full översikt över alla säkerhetshändelser på
ett ställe.

Med Cockpit kan vi dessutom visa systemstatus
live i en webbläsare — CPU, minne, loggar och
tjänster i realtid.

Det här är ett konkret svar på frågan:
"Vad händer om web1 komprometteras?"

```
Angriparen tar sig in på web1
    ↓
Wazuh Agent på web1 märker:
  - Att viktiga filer ändrats
  - Att ovanliga program startats
  - Att misstänkta nätverksanslutningar skapats
    ↓
Varning skickas till Wazuh Manager på monitor
    ↓
Vi ser händelsen i Wazuh Manager-loggarna
Vi ser systemstatus i Cockpit Dashboard
```

Det är Defense-in-Depth i praktiken. fail2ban
stoppar brute-force-attacker. SSH-härdning
blockerar lösenordsinloggning. auditd loggar
systemhändelser. Wazuh samlar allt centralt.
Cockpit ger visuell översikt.

---

### Varför vi använder shell-modulen istället för apt direkt

Wazuh finns inte i Ubuntus standardpaketlista.
Vi måste först lägga till Wazuh's egna paketlista.
Det kräver kommandon som `curl` och `gpg` —
därför använder vi `shell`-modulen.

För att behålla idempotens använder vi
`args: creates:` som säger till Ansible:
"kör bara det här kommandot om den här filen
inte redan finns":

```yaml
- name: Lägg till Wazuh GPG-nyckel
  shell: curl ... | gpg --import
  args:
    creates: /usr/share/keyrings/wazuh.gpg
```

Om filen redan finns hoppar Ansible över steget.
Det betyder att kommandot bara körs en gång.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa mappstruktur för wazuh_manager och wazuh_agent
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_manager/tasks"
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_manager/vars"
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_manager/handlers"
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_manager/templates"
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_agent/vars"
PS E:\Secure-Infra-Lab\ansible\roles> New-Item -ItemType Directory -Path "wazuh_agent/handlers"
```
Förväntat output: Mapparna skapas utan felmeddelanden.
Vad vi fick: Alla mappar skapades korrekt. ✅

```powershell
# Lägg till port forwarding för Cockpit i Vagrantfilen
# Varför: Cockpit körs på port 9090 på monitor-servern
# Med port forwarding når vi den via https://localhost:9090
PS E:\Secure-Infra-Lab> notepad vagrant\Vagrantfile
```
Tillägg i monitor-blocket:
```ruby
monitor.vm.network "forwarded_port", guest: 9090, host: 9090
```
Förväntat output: Ändringen sparas utan fel.
Vad vi fick: Filen sparades korrekt. ✅

```powershell
# Starta om monitor med den uppdaterade Vagrantfilen
PS E:\Secure-Infra-Lab\vagrant> vagrant reload monitor
```
Förväntat output: Machine booted and ready! med port 9090→9090.
Vad vi fick: Exakt det förväntade. ✅

```powershell
# Ladda upp alla Wazuh-filer till control-servern
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh control -c "mkdir -p /home/vagrant/ansible/roles/wazuh_manager/tasks /home/vagrant/ansible/roles/wazuh_agent/tasks"
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\wazuh_manager\tasks\main.yml /home/vagrant/ansible/roles/wazuh_manager/tasks/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\wazuh_agent\tasks\main.yml /home/vagrant/ansible/roles/wazuh_agent/tasks/main.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\site.yml /home/vagrant/ansible/site.yml control
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible\roles\flask\defaults\main.yml /home/vagrant/ansible/roles/flask/defaults/main.yml control
```
Förväntat output: Upload has completed successfully! för varje fil.
Vad vi fick: Alla filer laddades upp korrekt. ✅

```powershell
# Ta bort misslyckad wazuh-indexer tjänst
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh monitor -c "sudo systemctl reset-failed wazuh-indexer"
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh monitor -c "sudo apt-get remove -y wazuh-indexer wazuh-dashboard 2>/dev/null; sudo apt-get autoremove -y"
```
Förväntat output: Paketen avinstalleras utan fel.
Vad vi fick: Varningen försvann från Cockpit. ✅

```powershell
# Committa och pusha till GitHub
PS E:\Secure-Infra-Lab> git add ansible/roles/wazuh_manager ansible/roles/wazuh_agent ansible/roles/flask/defaults ansible/site.yml vagrant/Vagrantfile
PS E:\Secure-Infra-Lab> git commit -m "Add wazuh_manager and wazuh_agent roles, fix flask defaults"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: feature/cockpit-dashboard -> feature/cockpit-dashboard
Vad vi fick: Exakt det förväntade. ✅

---

#### Bash — inuti control-servern

```bash
# Kontrollera att SSH-nyckeln finns på monitor
vagrant@control:~$ ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.15
```
Förväntat output: 1 key(s) installed.
Vad vi fick: All keys were skipped — nyckeln fanns redan. ✅

```bash
# Kör Wazuh Manager och Cockpit på monitor
vagrant@control:~/ansible$ ansible-playbook site.yml --limit monitor_g
```
Förväntat output: monitor : ok=14  changed=2  failed=0
Vad vi fick: ok=14  changed=2  failed=0 ✅

```bash
# Kör Wazuh Agent på alla andra servrar
vagrant@control:~/ansible$ ansible-playbook site.yml --limit control_g:nginx_g:webserver_g:webserver2_g:database_g
```
Förväntat output: failed=0 för alla fem servrar.
Vad vi fick: failed=0 på alla fem. ✅

```bash
# Kör hela playbooken — kontrollera att allt fungerar
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: failed=0 på alla sex servrar.
Vad vi fick:
```
control   ok=12  changed=1  failed=0  ✅
database  ok=26  changed=2  failed=0  ✅
monitor   ok=14  changed=1  failed=0  ✅
nginx     ok=18  changed=1  failed=0  ✅
web1      ok=20  changed=1  failed=0  ✅
web2      ok=20  changed=1  failed=0  ✅
```
Inga varningar. Idempotens bekräftad. ✅

---

### Konfigurationsfiler

📄 `ansible/roles/wazuh_manager/tasks/main.yml`
**Vad den gör:** Lägger till Wazuh i systemets
paketlista, installerar wazuh-manager, startar
tjänsten och installerar Cockpit för webbbaserad
systemövervakning.
**Varför den finns:** Wazuh Manager är den centrala
servern som tar emot data från alla agenter.
Cockpit ger ett enkelt webbgränssnitt för att
se systemstatus i realtid.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/cockpit-dashboard/ansible/roles/wazuh_manager/tasks/main.yml
**Officiell dokumentation:**
- Wazuh: https://documentation.wazuh.com/current/installation-guide/wazuh-manager/step-by-step.html
- Cockpit: https://cockpit-project.org/documentation.html

📄 `ansible/roles/wazuh_agent/tasks/main.yml`
**Vad den gör:** Lägger till Wazuh i systemets
paketlista, installerar wazuh-agent med adressen
till Manager (monitor .15) och startar agenten.
**Varför den finns:** Varje server behöver en agent
för att skicka säkerhetshändelser till Manager.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/cockpit-dashboard/ansible/roles/wazuh_agent/tasks/main.yml
**Officiell dokumentation:** https://documentation.wazuh.com/current/installation-guide/wazuh-agent/index.html

📄 `vagrant/Vagrantfile` (uppdaterad)
**Vad den gör:** Port forwarding 9090→9090 för
monitor-servern. Det gör att Cockpit Dashboard
går att nå från Windows-datorn via
https://localhost:9090.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/feature/cockpit-dashboard/vagrant/Vagrantfile

---

### Problem och lösningar

**Problem 1 — Wazuh installationsskript krävde config-fil**
**Felmeddelande:** Cannot find /tmp/wazuh-install-files.tar
**Vad som hände:** Vi försökte använda Wazuh's
officiella installationsskript. Det är designat
för stora system med många servrar och krävde
en config-fil och extra steg som inte behövs
i vår lilla miljö.
**Lösning:** Vi bytte till apt-installation via
Wazuh's eget paketförråd. Det är enklare och
fungerar bättre för oss.

**Problem 2 — Wazuh Indexer kraschade med OOM**
**Felmeddelande:** wazuh-indexer.service: A process has been killed by the OOM killer
**Vad som hände:** Wazuh Indexer (OpenSearch) är
en stor databas som behöver minst 2 GB RAM för
sig själv. Monitor-servern hade bara 2 GB totalt
— det räckte inte när wazuh-manager redan använde
1.5 GB.
**Lösning:** Vi tog bort wazuh-indexer och
wazuh-dashboard och installerade Cockpit istället.
Cockpit kräver bara ~100 MB RAM och ger ändå
ett bra webbdashboard.

**Problem 3 — Wazuh Indexer kraschade med SSL-fel**
**Felmeddelande:** Unable to read the file /etc/wazuh-indexer/certs/root-ca.pem
**Vad som hände:** Wazuh Indexer kräver SSL-certifikat
som måste genereras med ett speciellt skript.
Det är komplicerat att automatisera med Ansible.
**Lösning:** Bekräftade beslutet att använda
Cockpit istället för Wazuh Dashboard.

**Problem 4 — server_name variabeln hittades inte**
**Felmeddelande:** AnsibleUndefinedVariable: 'server_name' is undefined
**Vad som hände:** Flask-rollen försökte använda
variabeln server_name men filen
flask/defaults/main.yml saknades på control-servern.
**Lösning:** Skapade flask/defaults/main.yml med
server_name: "Server 1" och laddade upp.

---

### Teorikoppling

**Koncept 1: Vad är SIEM och HIDS?**

SIEM betyder Security Information and Event Management.
Det samlar säkerhetsinformation från alla servrar
på ett ställe. Istället för att logga in på varje
server för att kolla loggar ser du allt på ett ställe.

HIDS betyder Host-based Intrusion Detection System.
Det övervakar varje server och letar efter tecken
på att någon försöker ta sig in.

Wazuh kombinerar båda. Det är som att ha en
väktare på varje server som rapporterar till en
central ledningscentral.

**Officiell dokumentation:** https://documentation.wazuh.com/

**Koncept 2: Hotmodellering**

Hotmodellering handlar om att tänka igenom vad
som kan gå fel och hur systemet ska reagera.

En viktig fråga i detta projekt är:
"Vad händer om web1 komprometteras?"

Med Wazuh på plats kan vi svara konkret:

```
Angriparen tar sig in på web1
    ↓
Wazuh Agent på web1 märker:
  - Att viktiga filer ändrats
  - Att ovanliga program startats
  - Att misstänkta nätverksanslutningar skapats
    ↓
Varning skickas till Wazuh Manager på monitor
    ↓
Vi ser händelsen i Wazuh Manager-loggarna
```

Det är Defense-in-Depth i praktiken. Varje
skyddslager kompenserar om ett annat bryts:
- fail2ban stoppar brute-force-attacker
- SSH-härdning blockerar lösenordsinloggning
- auditd loggar systemhändelser
- Wazuh samlar allt centralt
- Cockpit ger visuell systemöversikt

**Officiell dokumentation:** https://documentation.wazuh.com/current/getting-started/use-cases/index.html

**Koncept 3: Idempotens med shell-modulen**

shell-modulen i Ansible kör ett kommando varje
gång playbooken körs. Det bryter mot principen
om idempotens. Vi löser det med `args: creates:`
som anger en fil som bara skapas vid första körningen.

Om filen redan finns hoppar Ansible över steget.
Det ger oss idempotens även med shell-kommandon.

**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html

**Koncept 4: Cockpit — webbbaserad systemövervakning**

Cockpit är ett verktyg som är inbyggt i Ubuntu.
Det låter dig övervaka och hantera en Linux-server
via webbläsaren. Ingen extra konfiguration behövs.

Det visar CPU, minne, disk, nätverkstrafik,
systemloggar och tjänster i realtid. Du kan till
och med öppna en terminal direkt i webbläsaren.

Det är perfekt för att visa systemstatus live
under en presentation — enkelt, tydligt och
professionellt.

**Officiell dokumentation:** https://cockpit-project.org/documentation.html



---

## Fas 8 — Verifieringsskript och rollstruktur
**Datum:** 2026-05-08
**Git-commits:**
- `Add verify.sh and verify_host.ps1`
- `Fix verify scripts: round-robin order, Cockpit TCP check`
- `Add role structure: cockpit role, vars and handlers for all roles`

### Vad vi gjorde

Vi skapade två verifieringsskript som automatiskt
kontrollerar att hela infrastrukturen fungerar korrekt.

`verify.sh` körs på control-servern och testar alla
servrar inifrån nätverket. `verify_host.ps1` körs på
Windows-datorn och testar vad som är nåbart utifrån.

Vi skapade också en separat `cockpit`-roll och
kompletterade mappstrukturen för alla roller med
`vars/main.yml` och `handlers/main.yml`.

Slutresultat:
- verify.sh → PASS=38 FAIL=0 ✅
- verify_host.ps1 → PASS=6 FAIL=0 ✅

---

### Rollöversikt

```
Fas 8 gör tre saker:
1. Skapar verify.sh — testar infrastrukturen inifrån
2. Skapar verify_host.ps1 — testar från Windows
3. Kompletterar rollstrukturen med vars och handlers
```

### Filöversikt

```
scripts/
├── verify.sh               ✅
└── verify_host.ps1         ✅

ansible/roles/
├── cockpit/
│   ├── tasks/main.yml      ✅
│   ├── handlers/main.yml   ✅
│   └── vars/main.yml       ✅
├── database/
│   └── vars/main.yml       ✅
├── nginx/
│   └── vars/main.yml       ✅
├── security_hardening/
│   └── vars/main.yml       ✅
├── wazuh_agent/
│   ├── handlers/main.yml   ✅
│   └── vars/main.yml       ✅
└── wazuh_manager/
    ├── handlers/main.yml   ✅
    └── vars/main.yml       ✅
```

---

### Varför detta steg är viktigt

Verifieringsskript är ett krav i en professionell
driftmiljö. Utan automatiserade tester vet vi inte
om infrastrukturen fungerar korrekt efter en
`vagrant destroy && vagrant up`.

Med verify.sh kan vi köra ett enda kommando och
få bekräftelse på att alla 38 kontrollpunkter
är gröna. Det sparar tid och eliminerar mänskliga
misstag vid verifiering.

---

### Vad testas i verify.sh (38 tester)?

```
Test 1     — nginx svarar HTTP 200
Test 2-3   — Round-robin Server 1 och Server 2
Test 4     — web1 når database:5432
Test 5     — Extern blockeras från database:5432
Test 6-7   — Flask aktiv på web1 och web2
Test 8-13  — fail2ban aktiv på alla 6 servrar
Test 14-19 — auditd aktiv på alla 6 servrar
Test 20-25 — PasswordAuthentication=no på alla servrar
Test 26-31 — PermitRootLogin=no på alla servrar
Test 32-36 — wazuh-agent aktiv på 5 servrar
Test 37    — wazuh-manager aktiv på monitor
Test 38    — Cockpit svarar på port 9090
```

### Vad testas i verify_host.ps1 (6 tester)?

```
Test 1 — nginx svarar via localhost:8080
Test 2 — Round-robin innehåller Server 1
Test 3 — Round-robin innehåller Server 2
Test 4 — /visit registrerar ett besök
Test 5 — Cockpit svarar på port 9090
Test 6 — database:5432 blockerad från Windows
```

---

### Körda kommandon

#### PowerShell — Windows-värddatorn (E:\Secure-Infra-Lab)

```powershell
# Skapa scripts-mappen
PS E:\Secure-Infra-Lab> mkdir scripts
```
Förväntat output: Mappen skapas utan felmeddelanden.
Vad vi fick: Exakt det förväntade. ✅

```powershell
# Öppna verify.sh i VS Code
PS E:\Secure-Infra-Lab> code scripts\verify.sh
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt. ✅

```powershell
# Öppna verify_host.ps1 i VS Code
PS E:\Secure-Infra-Lab> code scripts\verify_host.ps1
```
Förväntat output: VS Code öppnar en tom fil.
Vad vi fick: Filen öppnades korrekt. ✅

```powershell
# Konvertera filer till LF — inga CRLF-varningar
PS E:\Secure-Infra-Lab> $files = @(
    "ansible\roles\cockpit\handlers\main.yml",
    "ansible\roles\cockpit\tasks\main.yml",
    "ansible\roles\cockpit\vars\main.yml",
    "ansible\roles\database\vars\main.yml",
    "ansible\roles\nginx\vars\main.yml",
    "ansible\roles\security_hardening\vars\main.yml",
    "ansible\roles\wazuh_agent\handlers\main.yml",
    "ansible\roles\wazuh_agent\vars\main.yml",
    "ansible\roles\wazuh_manager\handlers\main.yml",
    "ansible\roles\wazuh_manager\vars\main.yml"
)
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText("E:\Secure-Infra-Lab\$file")
    $content = $content -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText("E:\Secure-Infra-Lab\$file", $content, [System.Text.Encoding]::UTF8)
}
Write-Host "Done!"
```
Förväntat output: Done!
Vad vi fick: Done! ✅

```powershell
# Ladda upp verify.sh till control-servern
PS E:\Secure-Infra-Lab\vagrant> vagrant upload ..\scripts\verify.sh /home/vagrant/verify.sh control
```
Förväntat output: Upload has completed successfully!
Vad vi fick: Exakt det förväntade. ✅

```powershell
# Kör verify_host.ps1 från Windows
PS E:\Secure-Infra-Lab> PowerShell -ExecutionPolicy Bypass -File scripts\verify_host.ps1
```
Förväntat output: PASS=6 FAIL=0
Vad vi fick slutligen: PASS=6 FAIL=0 ✅

```powershell
# Committa och pusha till GitHub
PS E:\Secure-Infra-Lab> git add scripts/ ansible/
PS E:\Secure-Infra-Lab> git commit -m "Add verify.sh and verify_host.ps1"
PS E:\Secure-Infra-Lab> git push --set-upstream origin feature/verify-scripts
```
Förväntat output: feature/verify-scripts -> feature/verify-scripts
Vad vi fick: Exakt det förväntade. ✅

---

#### Bash — inuti control-servern

```bash
# Kopiera controls SSH-nyckel till sin egna authorized_keys
# Varför: verify.sh SSH:ar till alla servrar inklusive control
# Utan detta nekas control SSH till sig själv
vagrant@control:~$ cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
```
Förväntat output: Inga felmeddelanden.
Vad vi fick: Exakt det förväntade. ✅

```bash
# Kör verify.sh — första gången
vagrant@control:~$ bash /home/vagrant/verify.sh
```
Förväntat output: PASS=38 FAIL=0
Vad vi fick (först): PASS=30 FAIL=8 ❌

---

**Fel 1 — control SSH nekad sig själv**
Orsak: Controls publika nyckel saknades i
authorized_keys. verify.sh SSH:ar till alla
servrar inklusive control själv.
Lösning:
```bash
vagrant@control:~$ cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
```
Resultat: PASS på alla control-tester ✅

---

**Fel 2 — wazuh-manager hade kraschat**
Orsak: Wazuh Manager kraschade på grund av
minnesbrist efter omstart av monitor-servern.
Lösning:
```powershell
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh monitor -c "sudo systemctl restart wazuh-manager"
PS E:\Secure-Infra-Lab\vagrant> vagrant ssh monitor -c "sudo systemctl is-active wazuh-manager"
```
Förväntat output: active
Vad vi fick: active ✅

---

**Fel 3 — Round-robin i fel ordning**
Orsak: Skriptet förväntade sig Server 1 alltid
först men nginx skickar trafik växelvis — ibland
kommer Server 2 först.
Lösning i verify.sh — ändrade från:
```bash
# Gammalt — kontrollerade exakt ordning
vagrant@control:~$ check "Round-robin Server 1" \
  "$(curl -s http://192.168.56.11/)" "Server 1"
```
Till:
```bash
# Nytt — kontrollerar att båda servrar svarar
# oavsett ordning
vagrant@control:~$ r1=$(curl -s http://192.168.56.11/)
vagrant@control:~$ r2=$(curl -s http://192.168.56.11/)
vagrant@control:~$ check "Round-robin includes Server 1" \
  "$r1 $r2" "Server 1"
vagrant@control:~$ check "Round-robin includes Server 2" \
  "$r1 $r2" "Server 2"
```
Resultat: PASS på round-robin-tester ✅

```bash
# Kör verify.sh — efter alla fixar
vagrant@control:~$ bash /home/vagrant/verify.sh
```
Förväntat output: PASS=38 FAIL=0
Vad vi fick: PASS=38 FAIL=0 ✅

---

### Konfigurationsfiler

📄 `scripts/verify.sh`
**Vad den gör:** Bash-skript som testar 38
kontrollpunkter på alla sex servrar inifrån
nätverket. Körs från control-servern.
**Varför den finns:** Automatiserar verifiering
av hela infrastrukturen efter driftsättning.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh

📄 `scripts/verify_host.ps1`
**Vad den gör:** PowerShell-skript som testar
6 kontrollpunkter från Windows-datorn. Verifierar
att port forwarding och extern åtkomst fungerar.
**Varför den finns:** Testar infrastrukturen
utifrån — precis som en riktig användare.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1

📄 `ansible/roles/cockpit/tasks/main.yml`
**Vad den gör:** Installerar och startar Cockpit
på monitor-servern.
**Varför den finns:** Cockpit är en separat tjänst
och bör ha sin egen roll — inte blandas med
wazuh_manager-rollen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/tasks/main.yml
**Officiell dokumentation:** https://cockpit-project.org/documentation.html

---

### Problem och lösningar

**Problem 1 — PowerShell blockerade skriptet**
**Felmeddelande:** running scripts is disabled on this system
**Orsak:** Windows blockerar PowerShell-skript
som standard av säkerhetsskäl.
**Lösning:**
```powershell
PS E:\Secure-Infra-Lab> PowerShell -ExecutionPolicy Bypass -File scripts\verify_host.ps1
```
**Lärdomen:** I produktionsmiljöer hanteras detta
via Group Policy eller signerade skript.

**Problem 2 — CRLF i nya filer**
**Felmeddelande:** warning: CRLF will be replaced by LF
**Orsak:** VS Code på Windows sparar nya filer
med CRLF-radbrytningar som standard.
**Lösning:** Konvertera med PowerShell-skript
eller klicka på CRLF → LF i VS Code statusfältet.
**Lärdomen:** CRLF orsakade nginx-kraschen tidigare:
```
nginx: [emerg] unknown directive "﻿#"
```
Det är ett konkret exempel på hur ett osynligt
tecken kan stoppa hela systemet.

---

### Teorikoppling

**Koncept 1: Automatiserad verifiering**

I en professionell driftmiljö körs verifieringsskript
automatiskt efter varje driftsättning. Det kallas
"smoke testing" — ett snabbt test som bekräftar
att de viktigaste funktionerna fungerar.

I vårt projekt kör vi verify.sh efter varje
`vagrant up && ansible-playbook site.yml` för
att bekräfta att alla 38 kontrollpunkter är gröna.

**Koncept 2: CRLF och LF — radbrytningar**

Windows använder CRLF (\r\n) och Linux använder
LF (\n) för radbrytningar. Det är ett arv från
skrivmaskinstiden — CR betydde "flytta skrivhuvudet
till vänster" och LF betydde "rulla papperet upp".

I vårt projekt orsakade CRLF att nginx vägrade
starta med felmeddelandet:
```
nginx: [emerg] unknown directive "﻿#"
```
Det är ett konkret exempel på hur ett osynligt
tecken kan stoppa hela systemet. Vi löste det
permanent med `.gitattributes` och VS Code-
inställningen `files.encoding: utf8`.

**Officiell dokumentation:**
- https://git-scm.com/docs/gitattributes

**Koncept 3: Defense-in-Depth verifierad**

verify.sh bekräftar att alla säkerhetslager
fungerar korrekt:
- SSH-härdning (PasswordAuth=no, PermitRoot=no)
- fail2ban aktiv på alla servrar
- auditd aktiv på alla servrar
- UFW blockerar extern åtkomst till databasen
- Wazuh-agenter rapporterar till Manager

Det räcker inte att bara installera säkerhetsverktygen
— vi måste verifiera att de faktiskt är aktiva
och korrekt konfigurerade.

