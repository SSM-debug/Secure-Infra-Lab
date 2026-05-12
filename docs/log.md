
## Teknisk dokumentation - Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab 
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  


Den här loggen beskriver allt vi gjort i projektet,fas för fas. För varje fas förklarar vi vad vi gjorde, vilka kommandon vi körde, vad vi såg på skärmen och hur vi löste problem som dök upp.

Loggen är skriven så att vem som helst ska kunna följamed — även den som inte jobbat med projektet tidigare.

---
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
**Hur vi skapade den:** Vi identifierade kraven för
varje server - vilken IP, hur mycket RAM och vilken
roll den har i systemet. Sedan använde vi Vagrants
officiella dokumentation för syntax och
provisioneringsblock. Varje server fick ett eget
`config.vm.define`-block med namn, nätverk och
VirtualBox-inställningar. Control fick ett extra
provisionerings-skript som installerar Ansible.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/vagrant/Vagrantfile
**Officiell dokumentation:** https://developer.hashicorp.com/vagrant/docs/vagrantfile

📄 `.gitignore`
**Vad den gör:** Ignorerar `vagrant/.vagrant/` och
`vagrant/secrets.yml` så att de aldrig publiceras
på GitHub.
**Varför den finns:** SSH-nycklar och lösenord som
hamnar på GitHub är komprometterade för alltid -
även om man tar bort dem efteråt finns de kvar i
Git-historiken.
**Hur vi skapade den:** Vi gick igenom projektmappen
och identifierade alla filer som innehåller känslig
information eller intern metadata. `vagrant/.vagrant/`
innehåller SSH-nycklar och Vagrant-intern state.
`vagrant/secrets.yml` innehåller databaslösenord.
Båda lades till i `.gitignore` innan första push.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitignore
**Officiell dokumentation:** https://git-scm.com/docs/gitignore

---

### Problem och lösningar

**Problem 1 - Ansible 2.10.8 för gammal**
**Felmeddelande:** `ansible 2.10.8`
**Vad som hände:** Ubuntu 22.04 installerar Ansible
2.10.8 via apt automatiskt. Den versionen saknar
stöd för moduler vi behöver i projektet.
**Varför det hände:** apt-paketet för Ansible på
Ubuntu 22.04 är fryst på version 2.10.8 från 2021.
**Lösning:** Uppdaterade provisioner-skriptet i
Vagrantfilen från `apt-get install -y ansible` till
`pip3 install ansible`. pip installerar alltid
senaste versionen direkt från PyPI.
**Resultat:** `ansible [core 2.17.14]` ✅

**Problem 2 - Vagrant-filer spårades av Git**
**Vad som hände:** Git staging visade filer från
`vagrant/.vagrant/` med SSH-nycklar på väg till
GitHub.
**Varför det hände:** Ingen `.gitignore` fanns -
Git spårade alla filer inklusive Vagrants interna
SSH-nycklar.
**Lösning:** Skapade `.gitignore` och körde
`git rm -r --cached vagrant/.vagrant/` för att
avregistrera redan spårade filer från Git.
**Resultat:** Inga känsliga filer publicerades ✅

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

## Fas 2 - Ansible-konfiguration
**Datum:** 2026-05-03
**Git-commits:**
- `Add Ansible config: ansible.cfg, inventory.ini, site.yml`
- `Fix inventory.ini: add all:children group to resolve host/group name warnings`
- `Fix: clean inventory groups, pipelining, SSH UFW rule, no warnings`

### Vad vi gjorde

Vi skapade de fyra kärnfilerna som Ansible behöver
för att fungera. `ansible.cfg` är den globala
inställningsfilen. `inventory.ini` listar alla
servrar med IP-adresser och SSH-parametrar.
`site.yml` definierar körordningen för alla roller.
`vars/vars.yml` samlar delade variabler på ett ställe.

Inventory-grupperna döptes om från `control` till
`control_g` osv för att undvika namnkrockar mellan
grupp och host i Ansible. Pipelining aktiverades i
`ansible.cfg` för att eliminera varningar om
world-readable tmp-filer.

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
├── ansible.cfg             ✅
├── inventory.ini           ✅
├── site.yml                ✅
└── vars/
    └── vars.yml            ✅
```

### Varför detta steg är viktigt

Utan dessa filer kan Ansible inte fungera. `ansible.cfg`
talar om för Ansible var den hittar servrarna och hur
den ska bete sig. `inventory.ini` är Ansibles register
över alla hanterade noder. `site.yml` styr körordningen
- databasen måste konfigureras innan webbservrarna
startar, annars kraschar Flask vid uppstart.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa och konfigurera alla fyra kärnfiler i VS Code
E:\Secure-Infra-Lab> code ansible\ansible.cfg
E:\Secure-Infra-Lab> code ansible\inventory.ini
E:\Secure-Infra-Lab> code ansible\site.yml
E:\Secure-Infra-Lab> code ansible\vars\vars.yml
```
Alla fyra filer skapades och konfigurerades i VS Code ✅

```powershell
# Ladda upp filerna till control-servern
# Ansible körs från /home/vagrant/ansible/ på control
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ../ansible /home/vagrant/ansible control
```
Filerna laddades upp till control ✅

```powershell
# Logga in på control för att testa Ansible
E:\Secure-Infra-Lab\vagrant> vagrant ssh control
```

#### Bash - control (192.168.56.10)

```bash
# Verifiera att Ansible når alla servrar
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible all -m ping
```
Förväntat output: `pong` från alla sex servrar ✅

```powershell
# Committa till GitHub
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add ansible/ansible.cfg ansible/inventory.ini ansible/site.yml ansible/vars/vars.yml
E:\Secure-Infra-Lab> git commit -m "Add Ansible config: ansible.cfg, inventory.ini, site.yml"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

---

### Konfigurationsfiler

📄 `ansible/ansible.cfg`
**Vad den gör:** Global konfigurationsfil för Ansible.
Anger sökväg till inventory-filen, inaktiverar SSH
host key-verifiering och aktiverar pipelining.
**Varför den finns:** Utan den måste alla inställningar
anges som flaggor vid varje kommandokörning.
**Hur vi skapade den:** Vi läste Ansibles officiella
dokumentation för `ansible.cfg` och identifierade
de tre inställningar som alltid behövs i vår miljö.
`host_key_checking = False` behövs för att Ansible
inte ska fastna på SSH-verifiering i ett lokalt labb.
`pipelining = True` under `[ssh_connection]` lades
till efter att vi fick varningar om world-readable
tmp-filer. Inventory-sökvägen pekar på
`/home/vagrant/ansible/inventory.ini` eftersom
Ansible körs från control-servern, inte från Windows.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/ansible.cfg
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html

📄 `ansible/inventory.ini`
**Vad den gör:** Listar alla sex servrar med
IP-adresser, SSH-parametrar och Python-interpreter.
Gruppnamnen har `_g`-suffix för att undvika
namnkrockar mellan grupp och host.
**Varför den finns:** Ansible kan inte kommunicera
med servrarna utan denna fil.
**Hur vi skapade den:** Vi hämtade IP-adresserna
direkt från Vagrantfilen och skapade en grupp per
server. control fick `ansible_connection=local`
eftersom den kör Ansible lokalt - ingen SSH behövs.
Övriga servrar fick `ansible_private_key_file`
pekat på controls SSH-nyckel. Vi lade till
`ansible_python_interpreter=/usr/bin/python3`
explicit för att undvika varningar om Python-version.
Gruppnamnen fick `_g`-suffix efter att Ansible
varnade för namnkrockar mellan grupp och host.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/inventory.ini
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

📄 `ansible/site.yml`
**Vad den gör:** Huvudplanen - definierar vilken roll
som körs på vilken server och i vilken ordning.
Laddar variabler från `vars/vars.yml` och `secrets.yml`.
**Varför den finns:** Körordningen är kritisk -
databasen måste vara klar innan webbservrarna startar.
**Hur vi skapade den:** Vi ritade upp flödet för
systemet och bestämde körordningen: security_hardening
körs först på alla servrar, sedan database, sedan
web1 och web2, sedan nginx, sedan wazuh_manager och
slutligen wazuh_agent. Varje servergrupp fick ett
eget `play`-block med `hosts`, `vars_files` och
`roles`. `secrets.yml` laddas separat från
`vars/vars.yml` eftersom den är gitignorerad och
innehåller lösenord.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/site.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html

📄 `ansible/vars/vars.yml`
**Vad den gör:** Centraliserad variabelfil med
IP-adresser och portnummer som delas av alla roller.
**Varför den finns:** Om en IP-adress ändras behöver
vi bara uppdatera på ett ställe - inte i varje
enskild roll.
**Hur vi skapade den:** Vi gick igenom alla roller
och identifierade vilka värden som används på flera
ställen. IP-adresserna för alla sex servrar hämtades
från Vagrantfilen och samlades här. Flask-port 5000
och flask_user lades till eftersom de används av
både flask-rollen och nginx-rollen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/vars/vars.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

---

### Problem och lösningar

**Problem 1 - Namnkrockar i inventory**
**Felmeddelande:**
```
[WARNING]: Could not match supplied host pattern,
ignoring: nginx
```
**Vad som hände:** Ansible varnade för namnkrockar
när grupp och host hade samma namn - t.ex. hette
både gruppen och hosten `nginx`.
**Varför det hände:** Ansible tillåter inte samma
namn på grupp och host i samma inventory-fil.
**Lösning:** Döpte om alla grupper till `control_g`,
`nginx_g`, `webserver_g`, `webserver2_g`,
`database_g` och `monitor_g`.
**Resultat:** Inga fler namnkrocksvarningar ✅

**Problem 2 - World-readable tmp files-varning**
**Felmeddelande:**
```
[WARNING]: Skipping plugin, cannot use a
world-readable tmpfiles
```
**Vad som hände:** Ansible visade varning om
world-readable temporära filer vid varje körning.
**Varför det hände:** `allow_world_readable_tmpfiles`
räcker inte ensamt - pipelining måste också aktiveras.
**Lösning:** Aktiverade `pipelining = True` under
`[ssh_connection]` i `ansible.cfg`. Kräver också
`Defaults !requiretty` i sudoers - detta konfigureras
av security_hardening-rollen i Fas 3.
**Resultat:** Inga fler varningar ✅

---

### Teorikoppling

**Koncept: Inventory och körordning i Ansible**

Inventory-filen är Ansibles adressbok. Utan den vet
Ansible inte att servrarna existerar. Varje post
innehåller servernamn, IP-adress och hur Ansible
ska ansluta.

Körordningen i `site.yml` är lika viktig som att
utföra arbetsmoment i rätt följd. Databasen måste
vara igång innan webbservrarna startar - annars
försöker Flask ansluta till något som inte finns.

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

## Fas 3 - security_hardening-rollen
**Datum:** 2026-05-03
**Git-commits:**
- `Add security_hardening role: SSH hardening, fail2ban, auditd`
- `Add .gitattributes: enforce LF line endings for all files`
- `Normalize line endings to LF across all files`
- `Fix: clean inventory groups, pipelining, SSH UFW rule, no warnings`
- `Add role structure: cockpit role, vars and handlers for all roles`

### Vad vi gjorde

Vi designade och körde `security_hardening`-rollen
mot alla sex servrar. Rollen installerar fail2ban och
auditd, distribuerar en härdad SSH-konfiguration och
inaktiverar `requiretty` i sudoers för att Ansible
pipelining ska fungera korrekt.

Vi löste fyra problem under fasen. Ansible kraschade
för att roller saknades på disk. SSH-nyckeldistrubueringen
till monitor misslyckades. Windows skapade CRLF-
radbrytningar som orsakade tolkningsfel på Linux.
UFW blockerade Ansible efter härdning.

Slutresultat: `ansible-playbook site.yml` kördes mot
alla sex servrar med `failed=0` och inga varningar.
Idempotens bekräftad på andra körningen med
`changed=0` på alla servrar.

---

### Rollöversikt

```
security_hardening-rollen gör fyra saker:
1. Installerar fail2ban och auditd
2. Distribuerar härdad SSH-konfiguration via Jinja2-mall
3. Startar och aktiverar säkerhetstjänsterna
4. Inaktiverar requiretty i sudoers för Ansible pipelining
```

Rollen körs på samtliga 6 servrar - alltid först
innan någon annan roll körs.

### Filöversikt

```
ansible/
├── .gitattributes              ✅
└── roles/
    └── security_hardening/
        ├── tasks/
        │   └── main.yml        ✅
        ├── handlers/
        │   └── main.yml        ✅
        ├── templates/
        │   └── sshd_config.j2  ✅
        └── vars/
            └── main.yml        ✅
```

### Varför detta steg är viktigt

Security hardening körs på alla servrar innan något
annat installeras. Det säkerställer att varje server
har en konsekvent säkerhetsbaslinje från dag ett.

SSH-härdning hindrar obehörig åtkomst. fail2ban
blockerar brute-force-attacker automatiskt. auditd
loggar alla systemhändelser så att vi kan spåra vad
som hänt om något går fel.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa mappstruktur för security_hardening-rollen
E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\templates
E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\vars
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera rollfilerna i VS Code
E:\Secure-Infra-Lab> code ansible\roles\security_hardening\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\security_hardening\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\security_hardening\templates\sshd_config.j2
E:\Secure-Infra-Lab> code ansible\roles\security_hardening\vars\main.yml
```
Alla filer skapades och konfigurerades i VS Code ✅

```powershell
# Skapa tomma platshållarfiler för roller som inte finns än
# Ansible validerar alla roller i site.yml vid uppstart -
# utan platshållare kraschar Ansible direkt
E:\Secure-Infra-Lab> foreach ($role in @("database", "flask", "nginx", "wazuh_agent")) {
    $path = "ansible\roles\$role\tasks\main.yml"
    New-Item -ItemType File -Force -Path $path
}
```
Platshållarfiler skapades för alla fyra roller ✅

```powershell
# Fixa radbrytningar permanent
# Windows använder CRLF, Linux använder LF
# CRLF i YAML-filer orsakar tolkningsfel på Linux
E:\Secure-Infra-Lab> git config core.autocrlf false
E:\Secure-Infra-Lab> git config core.eol lf
E:\Secure-Infra-Lab> code .gitattributes
```
`.gitattributes` skapades och konfigurerades i VS Code ✅

```powershell
# Normalisera alla befintliga filer till LF
E:\Secure-Infra-Lab> git rm --cached -r .
E:\Secure-Infra-Lab> git reset --hard
E:\Secure-Infra-Lab> git add .
E:\Secure-Infra-Lab> git commit -m "Normalize line endings to LF across all files"
E:\Secure-Infra-Lab> git push
```
Alla filer normaliserades till LF utan felmeddelanden ✅

```powershell
# Hämta controls publika SSH-nyckel
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> $pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"
```
SSH-nyckeln hämtades från control ✅

```powershell
# Distribuera controls SSH-nyckel till alla servrar
# Ansible SSH:ar från control - utan nyckeln nekas åtkomst
E:\Secure-Infra-Lab\vagrant> foreach ($vm in @("nginx", "web1", "web2", "database", "monitor")) {
    $port    = (vagrant ssh-config $vm | Select-String "Port").ToString().Trim().Split(" ")[1]
    $keyfile = (vagrant ssh-config $vm | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
    echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
}
```
nginx, web1, web2, database lyckades ✅
monitor fick fel - se Problem 2 nedan ❌

```powershell
# Ladda upp security_hardening-filerna till control
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
```
Alla filer laddades upp till control ✅

```powershell
# Committa och pusha alla ändringar
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add .
E:\Secure-Infra-Lab> git commit -m "Add security_hardening role: SSH hardening, fail2ban, auditd"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör playbooken
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` på alla sex servrar ✅

```bash
# Verifiera idempotens - kör playbooken en gång till
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla sex servrar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/security_hardening/tasks/main.yml`
**Vad den gör:** Definierar fyra tasks - uppdaterar
paketcachen, installerar fail2ban och auditd,
distribuerar SSH-konfiguration och inaktiverar
requiretty i sudoers.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från Ansibles
dokumentation för `apt`- och `service`-modulerna.
Varje task fick ett tydligt `name`-fält på engelska.
SSH-konfigurationen distribueras via `template`-
modulen med `notify: Restart sshd` så att SSH bara
startas om när konfigurationen faktiskt ändrats.
`lineinfile`-modulen användes för att lägga till
`Defaults !requiretty` i sudoers - det krävs för
att pipelining ska fungera utan varningar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html

📄 `ansible/roles/security_hardening/handlers/main.yml`
**Vad den gör:** Definierar `Restart sshd` - körs
bara när `sshd_config` faktiskt har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter - SSH startas bara om när konfigurationen
förändrats.
**Hur vi skapade den:** Vi läste Ansibles dokumentation
för handlers och förstod att en handler bara triggas
när en task notifierar den via `notify`. Det betyder
att SSH bara startas om vid faktisk konfigurationsändring
- inte vid varje playbook-körning. Det är viktigt för
idempotens.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/security_hardening/templates/sshd_config.j2`
**Vad den gör:** Jinja2-mall för SSH-konfigurationen.
Inaktiverar root-inloggning och lösenordsinloggning,
begränsar till tre inloggningsförsök, tillåter bara
`vagrant`-användaren och stänger inaktiva sessioner
efter 5 minuter.
**Varför den finns:** En mall säkerställer identisk
SSH-konfiguration på alla servrar - inga manuella
avvikelser möjliga.
**Hur vi skapade den:** Vi utgick från OpenSSH-
dokumentationen och identifierade de inställningar
som ger en säker SSH-konfiguration. `PermitRootLogin no`
och `PasswordAuthentication no` är grundkrav.
`MaxAuthTries 3` begränsar brute-force-försök.
`ClientAliveInterval 300` stänger inaktiva sessioner
efter 5 minuter. `AllowUsers vagrant` begränsar
åtkomst till bara den användare vi faktiskt behöver.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2
**Officiell dokumentation:** https://www.openssh.com/manual.html

📄 `ansible/roles/security_hardening/vars/main.yml`
**Vad den gör:** Definierar SSH-port (22), max
inloggningsförsök (3) och login grace time (30s).
**Varför den finns:** Separerar konfigurationsvärden
från tasks-logiken - enkelt att justera utan att
röra tasks-koden.
**Hur vi skapade den:** Vi identifierade alla värden
i tasks och templates som kan behöva justeras och
samlade dem här. Det gör det enkelt att ändra t.ex.
`max_auth_tries` utan att behöva leta i tasks-filen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/vars/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

📄 `.gitattributes`
**Vad den gör:** Tvingar Git att alltid spara filer
med LF-radbrytningar - oavsett operativsystem.
**Varför den finns:** Windows använder CRLF och Linux
använder LF. CRLF i YAML-filer orsakar tolkningsfel
på Linux-servrarna.
**Hur vi skapade den:** Vi läste Git-dokumentationen
för `.gitattributes` och lade till regeln
`* text=auto eol=lf` som tvingar LF för alla textfiler.
Sedan konfigurerade vi Git lokalt med
`core.autocrlf false` och `core.eol lf` och
normaliserade alla befintliga filer.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitattributes
**Officiell dokumentation:** https://git-scm.com/docs/gitattributes

---

### Problem och lösningar

**Problem 1 - Ansible kraschade vid uppstart**
**Felmeddelande:**
```
ERROR! the role 'database' was not found in
/home/vagrant/ansible/roles
```
**Vad som hände:** Ansible läser igenom hela site.yml
innan den kör något. Den hittade roller som
refererades men inte existerade på disk och avbröt
direkt.
**Varför det hände:** Vi hade definierat database,
flask, nginx och wazuh_agent i site.yml men inte
skapat rollmapparna än.
**Lösning:** Skapade tomma `tasks/main.yml`-filer
som platshållare i varje roll som inte var klar.
Ansible nöjer sig med en tom fil - den kraschar
inte om filen existerar.
**Resultat:** Ansible startade och körde utan fel ✅

**Problem 2 - monitor nekade SSH-anslutning**
**Felmeddelande:**
```
kex_exchange_identification: read: Connection reset
```
**Vad som hände:** SSH-nyckeldistrubueringen till
monitor misslyckades. monitor är den tyngsta servern
med 2048 MB RAM och hade precis startats om - SSH
var inte redo än.
**Varför det hände:** monitor behöver längre starttid
än övriga servrar på grund av sitt RAM-behov.
**Lösning:** Körde `vagrant reload monitor` och
väntade tills servern var fullt uppstartad innan
vi försökte igen.
**Resultat:** SSH-nyckeln distribuerades korrekt ✅

**Problem 3 - CRLF orsakade tolkningsfel på Linux**
**Felmeddelande:**
```
yaml.scanner.ScannerError: mapping values are
not allowed here
```
**Vad som hände:** YAML-filer skapade på Windows
fick CRLF-radbrytningar. Linux tolkade `\r` som
en del av värdet och misslyckades att parsa YAML.
**Varför det hände:** Windows använder CRLF per
standard - Linux förväntar sig LF.
**Lösning:** Skapade `.gitattributes` som tvingar
LF för alla filer, konfigurerade Git med
`core.autocrlf false` och normaliserade alla
befintliga filer med `git rm --cached -r .` och
`git reset --hard`.
**Resultat:** Inga fler CRLF-varningar eller fel ✅

**Problem 4 - UFW blockerade Ansible efter härdning**
**Felmeddelande:**
```
UNREACHABLE! => {"msg": "Failed to connect to the
host via ssh: Connection timed out"}
```
**Vad som hände:** SSH slutade fungera efter att
security_hardening körts. UFW-brandväggen aktiverades
utan en explicit regel som tillåter SSH på port 22.
**Varför det hände:** UFW blockerar all trafik som
standard - även SSH - om ingen regel finns.
**Lösning:** Lade till en UFW-regel som tillåter
SSH på port 22 innan brandväggen aktiveras i
`tasks/main.yml`.
**Resultat:** Ansible nådde alla servrar utan
avbrott ✅

---

### Teorikoppling

**Koncept: Defense-in-Depth**

Defense-in-Depth betyder flera skyddslager. Om ett
lager bryts igenom finns nästa lager kvar. Det är
som att ha både lås, larm och grannsamverkan hemma.

I det här projektet är security_hardening det första
lagret. SSH-härdning hindrar obehörig åtkomst.
fail2ban blockerar brute-force-attacker automatiskt.
auditd loggar alla systemhändelser så att vi kan
spåra vad som hänt om något går fel.

Samma princip används i alla professionella
driftmiljöer - ingen enskild säkerhetsåtgärd räcker,
man behöver flera lager som kompletterar varandra.

**Officiell dokumentation:**
- fail2ban: https://www.fail2ban.org/wiki/index.php/Main_Page
- auditd: https://linux.die.net/man/8/auditd
- OpenSSH: https://www.openssh.com/manual.html
- Ansible handlers: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

---
---

## Fas 4 - database-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add database role: PostgreSQL, UFW, schema`
- `Fix: clean inventory groups, pipelining, SSH UFW rule, no warnings`
- `Fix flask role: server_name via host_vars, DB permissions, no warnings`
- `Add role structure: cockpit role, vars and handlers for all roles`

### Vad vi gjorde

Vi designade och körde `database`-rollen mot
database-servern. Rollen installerar PostgreSQL,
skapar databas och användare, distribuerar schema
och konfigurerar brandväggsregler så att bara web1
och web2 får ansluta på port 5432.

Vi stötte på tre problem. Ansible-modulen för att
köra SQL-skript var fel. PostgreSQL-behörigheterna
för Flask-användaren saknades. `listen_addresses`
ändrades till `'*'` som en tillfällig lösning - det
är en känd säkerhetsavvägning som dokumenteras i
rapporten.

---

### Rollöversikt

```
database-rollen gör sex saker:
1. Installerar PostgreSQL och python3-psycopg2
2. Skapar databasanvändaren flaskuser
3. Skapar databasen flaskdb
4. Distribuerar och kör schema.sql.j2
5. Konfigurerar pg_hba.conf för web1 och web2
6. Sätter upp UFW-brandväggsregler
```

### Filöversikt

```
ansible/
└── roles/
    └── database/
        ├── tasks/
        │   └── main.yml        ✅
        ├── handlers/
        │   └── main.yml        ✅
        ├── templates/
        │   └── schema.sql.j2   ✅
        └── vars/
            └── main.yml        ✅
```

### Varför detta steg är viktigt

Databasen är hjärtat i systemet. Utan en korrekt
konfigurerad databas kan Flask inte spara eller
hämta besöksdata.

UFW-reglerna säkerställer att bara web1 och web2
får prata med databasen på port 5432. Alla andra
anslutningar blockeras direkt. Det är ett kritiskt
säkerhetslager i vår Defense-in-Depth-strategi.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa mappstruktur för database-rollen
E:\Secure-Infra-Lab> mkdir ansible\roles\database\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\database\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\database\templates
E:\Secure-Infra-Lab> mkdir ansible\roles\database\vars
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera rollfilerna i VS Code
E:\Secure-Infra-Lab> code ansible\roles\database\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\database\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\database\templates\schema.sql.j2
E:\Secure-Infra-Lab> code ansible\roles\database\vars\main.yml
```
Alla filer skapades och konfigurerades i VS Code ✅

```powershell
# Ladda upp filerna till control-servern
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
```
Filerna laddades upp till control ✅

```powershell
# Committa till GitHub
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add ansible/roles/database/
E:\Secure-Infra-Lab> git commit -m "Add database role: PostgreSQL, UFW, schema"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör playbooken
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` på alla servrar ✅

```bash
# Verifiera idempotens
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla servrar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/database/tasks/main.yml`
**Vad den gör:** Installerar PostgreSQL, skapar
databasanvändare och databas, kör schema,
konfigurerar `listen_addresses` och `pg_hba.conf`
och sätter upp UFW-regler.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från PostgreSQL-
dokumentationen och Ansibles `community.postgresql`-
kollektion. Varje steg i databasens livscykel fick
en egen task - installera, starta, skapa användare,
skapa databas, köra schema och konfigurera åtkomst.
`become_user: postgres` används för tasks som kräver
PostgreSQL-superuser-rättigheter. UFW-reglerna lades
till sist för att säkerställa att brandväggen
aktiveras efter att all konfiguration är klar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/tasks/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/collections/community/postgresql/

📄 `ansible/roles/database/handlers/main.yml`
**Vad den gör:** Definierar `Restart postgresql` -
körs bara när PostgreSQL-konfigurationen har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter - PostgreSQL startas bara om när
konfigurationen faktiskt förändrats.
**Hur vi skapade den:** Vi följde samma mönster som
i security_hardening-rollen. En handler per tjänst
som behöver startas om. `notify: Restart postgresql`
i tasks triggar handleren bara när `lineinfile` eller
`postgresql_pg_hba` gör en faktisk ändring.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/database/templates/schema.sql.j2`
**Vad den gör:** Skapar `visits`-tabellen med tre
kolumner - `id`, `server_name` och `visited_at`.
Ger Flask-användaren rätt behörigheter att läsa
och skriva till tabellen.
**Varför den finns:** En Jinja2-mall säkerställer
att exakt samma schema används varje gång miljön
återskapas - inga manuella SQL-kommandon behövs.
**Hur vi skapade den:** Vi identifierade de kolumner
Flask-applikationen behöver. `id` är primärnyckel
med `SERIAL` för automatisk numrering. `server_name`
identifierar vilken webbserver som hanterade besöket.
`visited_at` sätts automatiskt med
`DEFAULT CURRENT_TIMESTAMP`. `CREATE TABLE IF NOT
EXISTS` gör schemat idempotent - det kraschar inte
om tabellen redan finns. `GRANT`-satserna lades till
efter att Flask fick behörighetsfel - PostgreSQL
kräver explicit behörighetsgivning även för
databasägaren.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/templates/schema.sql.j2
**Officiell dokumentation:** https://www.postgresql.org/docs/current/sql-createtable.html

📄 `ansible/roles/database/vars/main.yml`
**Vad den gör:** Definierar PostgreSQL-port (5432),
datakatalog och konfigurationskatalog.
**Varför den finns:** Separerar konfigurationsvärden
från tasks-logiken - enkelt att justera utan att
röra tasks-koden.
**Hur vi skapade den:** Vi identifierade alla
hårdkodade sökvägar och portnummer i tasks-filen
och samlade dem här. PostgreSQL 14 installeras
automatiskt på Ubuntu 22.04 - därför pekar
sökvägarna på version 14. Om PostgreSQL uppgraderas
behöver vi bara ändra här.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/vars/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

---

### Problem och lösningar

**Problem 1 - Fel Ansible-modul för SQL-skript**
**Felmeddelande:**
```
ERROR! couldn't resolve module/action
'postgresql_query'
```
**Vad som hände:** Vi använde `postgresql_query`
för att köra schema.sql.j2 mot databasen. Modulen
hittades inte av Ansible.
**Varför det hände:** `postgresql_query` är inte
rätt modul för att köra SQL-filer. Den kräver också
`community.postgresql`-kollektionen som inte ingår
i standardinstallationen.
**Lösning:** Bytte till
`community.postgresql.postgresql_script` med
`path: /tmp/schema.sql` - den är designad för att
köra hela SQL-filer.
**Resultat:** Schema kördes korrekt mot databasen ✅

**Problem 2 - Flask kunde inte skriva till databasen**
**Felmeddelande:**
```
psycopg2.errors.InsufficientPrivilege:
permission denied for table visits
```
**Vad som hände:** Flask-användaren `flaskuser`
saknade behörighet att läsa och skriva till
`visits`-tabellen trots att den var databasägare.
**Varför det hände:** I PostgreSQL ger databasägarskap
inte automatiskt behörighet till tabeller - behörigheter
måste ges explicit med `GRANT`.
**Lösning:** Lade till dessa rader i schema.sql.j2:
```sql
GRANT SELECT, INSERT ON visits TO {{ db_user }};
GRANT USAGE, SELECT ON SEQUENCE visits_id_seq TO {{ db_user }};
```
**Resultat:** Flask kunde läsa och skriva till
databasen ✅

**Problem 3 - listen_addresses och säkerhetsavvägning**
**Felmeddelande:** Inte bevarat - problemet uppstod
under tidig konfiguration och loggarna finns inte
kvar.
**Vad som hände:** Flask fick anslutningsfel när
den försökte nå databasen från web1 och web2.
PostgreSQL lyssnade bara på specifika IP-adresser
men tog inte emot anslutningar korrekt.
**Varför det hände:** `listen_addresses` var satt
till specifika IP-adresser men konfigurationen
fungerade inte som förväntat i vår miljö.
**Lösning:** Ändrade `listen_addresses` till `'*'`
för att lösa anslutningsproblemet omedelbart.
**Säkerhetsnotering:** `listen_addresses = '*'`
är inte optimalt. PostgreSQL accepterar då
anslutningsförsök från alla IP-adresser. I en
produktionsmiljö ska detta kombineras med strikta
`pg_hba.conf`-regler och UFW för tre oberoende
säkerhetslager. Detta är en känd avvägning i
projektet och dokumenteras i rapporten.

---

### Teorikoppling

**Koncept: Principle of Least Privilege**

Principle of Least Privilege betyder att varje del
av systemet bara får de rättigheter den faktiskt
behöver - ingenting mer.

I det här projektet får `flaskuser` bara `SELECT`
och `INSERT` på `visits`-tabellen. Den kan inte
radera data, ändra tabellstrukturen eller komma
åt andra databaser. Om Flask-applikationen
komprometteras begränsas skadan till just den
behörigheten.

UFW-reglerna följer samma princip - bara web1 och
web2 får ansluta till port 5432. Alla andra
anslutningar blockeras direkt oavsett varifrån
de kommer.

I produktionsmiljöer kombineras detta med
nätverkssegmentering och databasrevision för att
spåra alla databasoperationer och snabbt upptäcka
avvikande beteende.

**Officiell dokumentation:**
- PostgreSQL: https://www.postgresql.org/docs/
- UFW: https://help.ubuntu.com/community/UFW
- Ansible postgresql: https://docs.ansible.com/ansible/latest/collections/community/postgresql/

---

---

## Fas 5 - flask-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add flask role: app.py, Gunicorn, systemd, env file`
- `Fix flask role: server_name via host_vars, DB permissions, no warnings`
- `Add wazuh_manager and wazuh_agent roles, fix flask defaults`

### Vad vi gjorde

Vi designade och körde `flask`-rollen mot web1 och
web2. Rollen installerar Python, Flask och Gunicorn,
kopierar applikationskoden till servern och skapar
en systemd-tjänst som startar Flask automatiskt vid
omstart.

Samma roll används för båda servrarna. Skillnaden
hanteras via `server_name`-variabeln - web1 får
"Server 1" via `defaults/main.yml` och web2 får
"Server 2" via `host_vars/web2.yml`. Det är ett
rent och skalbart sätt att hantera per-host-skillnader
utan att duplicera rollkod.

Vi löste också ett problem med `server_name` som
från början låg i `vars/main.yml` - det blockerade
host_vars från att fungera korrekt.

---

### Rollöversikt

```
flask-rollen gör sex saker:
1. Installerar Python3, pip och psycopg2
2. Installerar Flask och Gunicorn via pip
3. Kopierar app.py till servern
4. Skapar miljöfilen med databasuppgifter via Jinja2-mall
5. Distribuerar systemd-tjänstfilen via Jinja2-mall
6. Startar och aktiverar Flask-tjänsten
```

Rollen körs på web1 och web2 - identisk kod,
olika server_name per host.

### Filöversikt

```
ansible/
├── host_vars/
│   └── web2.yml                ✅
└── roles/
    └── flask/
        ├── defaults/
        │   └── main.yml        ✅
        ├── files/
        │   └── app.py          ✅
        ├── handlers/
        │   └── main.yml        ✅
        ├── tasks/
        │   └── main.yml        ✅
        ├── templates/
        │   ├── flask.env.j2    ✅
        │   └── flask.service.j2 ✅
        └── vars/
            └── main.yml        ✅
```

### Varför detta steg är viktigt

Flask-applikationen är kärnan i systemet. Den tar
emot besök, kommunicerar med databasen och returnerar
svar till användaren via nginx.

Gunicorn används som produktions-WSGI-server istället
för Flasks inbyggda utvecklingsserver - den är
stabilare och hanterar flera samtidiga anslutningar.
systemd säkerställer att tjänsten startar automatiskt
vid omstart och startas om om den kraschar.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa mappstruktur för flask-rollen
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\files
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\templates
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\vars
E:\Secure-Infra-Lab> mkdir ansible\roles\flask\defaults
E:\Secure-Infra-Lab> mkdir ansible\host_vars
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera rollfilerna i VS Code
E:\Secure-Infra-Lab> code ansible\roles\flask\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\flask\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\flask\files\app.py
E:\Secure-Infra-Lab> code ansible\roles\flask\templates\flask.env.j2
E:\Secure-Infra-Lab> code ansible\roles\flask\templates\flask.service.j2
E:\Secure-Infra-Lab> code ansible\roles\flask\vars\main.yml
E:\Secure-Infra-Lab> code ansible\roles\flask\defaults\main.yml
E:\Secure-Infra-Lab> code ansible\host_vars\web2.yml
```
Alla filer skapades och konfigurerades i VS Code ✅

```powershell
# Ladda upp filerna till control-servern
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
```
Filerna laddades upp till control ✅

```powershell
# Committa till GitHub
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add ansible/roles/flask/ ansible/host_vars/
E:\Secure-Infra-Lab> git commit -m "Add flask role: app.py, Gunicorn, systemd, env file"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör playbooken
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` på alla servrar ✅

```bash
# Verifiera att Flask svarar på web1 och web2
vagrant@control:~/ansible$ curl http://192.168.56.12:5000/
vagrant@control:~/ansible$ curl http://192.168.56.13:5000/
```
```
Hello from Server 1!
Hello from Server 2!
```
Båda servrarna svarade korrekt ✅

```bash
# Verifiera idempotens
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla servrar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/flask/tasks/main.yml`
**Vad den gör:** Installerar Python, Flask och
Gunicorn, kopierar app.py, skapar miljöfilen och
systemd-tjänstfilen och startar Flask-tjänsten.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från Ansibles
dokumentation för `apt`-, `pip`-, `copy`-,
`template`- och `service`-modulerna. Varje steg i
Flask-applikationens livscykel fick en egen task.
`notify: Restart flask` lades till på tasks som
kopierar filer - det säkerställer att Flask startas
om bara när koden eller konfigurationen faktiskt
ändrats. `mode: '0600'` på miljöfilen hindrar andra
användare från att läsa databasuppgifterna.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/tasks/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/collections/ansible/builtin/

📄 `ansible/roles/flask/handlers/main.yml`
**Vad den gör:** Definierar `Restart flask` - körs
bara när app.py, miljöfilen eller systemd-tjänsten
har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter - Flask startas bara om när konfigurationen
faktiskt förändrats.
**Hur vi skapade den:** Vi följde samma mönster som
i tidigare roller. En handler per tjänst som behöver
startas om. Tre tasks i tasks/main.yml notifierar
samma handler - Ansible är smart nog att bara köra
handleren en gång per playbook-körning.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/flask/files/app.py`
**Vad den gör:** Flask-applikationen med tre routes.
`/` returnerar ett enkelt hälsningsmeddelande med
servernamnet. `/secret` visar vilka miljövariabler
som är laddade. `/visit` sparar besöket i databasen
och visar de fem senaste besöken.
**Varför den finns:** app.py är applikationskoden
som bevisar att hela infrastrukturen fungerar -
lastbalansering, databasanslutning och redundans.
**Hur vi skapade den:** Vi identifierade tre krav:
visa vilket server som svarar, verifiera miljövariabler
och bevisa databasanslutning. Alla databasuppgifter
läses från miljövariabler via `os.getenv()` - inga
hårdkodade lösenord i koden. `psycopg2` används för
PostgreSQL-anslutningen. `/visit`-routen sparar
`SERVER_NAME` i databasen och hämtar de fem senaste
besöken för att visa att lastbalansering fungerar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/files/app.py
**Officiell dokumentation:** https://flask.palletsprojects.com/

📄 `ansible/roles/flask/templates/flask.env.j2`
**Vad den gör:** Jinja2-mall för miljöfilen som
innehåller databasuppgifter och servernamn.
Distribueras till varje server med `mode: '0600'`
så bara root kan läsa den.
**Varför den finns:** Miljöfilen håller känsliga
uppgifter separerade från koden. app.py läser dem
via `os.getenv()` - inga lösenord i källkoden.
**Hur vi skapade den:** Vi identifierade alla
variabler app.py behöver - databasuppgifter från
`secrets.yml` och `server_name` från host_vars.
`DB_HOST` pekar på `database_ip` från vars.yml.
`SERVER_NAME` sätts från `server_name`-variabeln
som är olika per host.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.env.j2
**Officiell dokumentation:** https://flask.palletsprojects.com/en/stable/config/

📄 `ansible/roles/flask/templates/flask.service.j2`
**Vad den gör:** Jinja2-mall för systemd-tjänstfilen.
Startar Gunicorn med två workers, laddar miljöfilen
och startar om tjänsten automatiskt om den kraschar.
**Varför den finns:** systemd säkerställer att
Flask-tjänsten startar automatiskt vid omstart och
återhämtar sig från krascher utan manuell inblandning.
**Hur vi skapade den:** Vi utgick från systemds
dokumentation och Gunicorns rekommendationer.
`User={{ flask_user }}` kör tjänsten som vagrant
- aldrig som root. `NoNewPrivileges=true` och
`PrivateTmp=true` är extra säkerhetshärdningar som
begränsar vad tjänsten kan göra på systemet.
`Restart=always` med `RestartSec=3` ger automatisk
återhämtning efter krascher.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.service.j2
**Officiell dokumentation:** https://www.freedesktop.org/software/systemd/man/systemd.service.html

📄 `ansible/roles/flask/vars/main.yml`
**Vad den gör:** Definierar flask_app_dest,
flask_env_file, flask_port (5000), flask_user
(vagrant) och flask_log.
**Varför den finns:** Samlar alla rollspecifika
variabler på ett ställe - enkelt att justera utan
att röra tasks-koden.
**Hur vi skapade den:** Vi identifierade alla
hårdkodade värden i tasks och templates och samlade
dem här. `server_name` togs bort från vars/main.yml
efter att vi förstod att vars har högre prioritet
än host_vars - det blockerade web2 från att få
"Server 2".
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/vars/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html

📄 `ansible/roles/flask/defaults/main.yml`
**Vad den gör:** Definierar standardvärdet
`server_name: "Server 1"` med lägsta prioritet.
**Varför den finns:** defaults/main.yml har lägsta
prioritet i Ansible - host_vars kan överskriva den.
web1 använder standardvärdet "Server 1" och web2
får "Server 2" via host_vars/web2.yml.
**Hur vi skapade den:** Vi förstod att `server_name`
i vars/main.yml hade för hög prioritet och blockerade
host_vars. Lösningen var att flytta `server_name`
till defaults/main.yml där den kan överskridas av
host_vars.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/defaults/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

📄 `ansible/host_vars/web2.yml`
**Vad den gör:** Definierar `server_name: "Server 2"`
specifikt för web2-hosten.
**Varför den finns:** host_vars överskriver defaults
för ett specifikt host. Det gör att samma flask-roll
kan ge olika server_name till web1 och web2 utan
att duplicera rollkoden.
**Hur vi skapade den:** Vi läste Ansibles dokumentation
om variabelprioritering och förstod att host_vars
har högre prioritet än defaults men lägre än vars.
Lösningen var att kombinera defaults/main.yml med
host_vars/web2.yml - web1 får standardvärdet och
web2 får sitt egna värde.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/host_vars/web2.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#organizing-host-and-group-variables

---

### Problem och lösningar

**Problem 1 - server_name fungerade inte för web2**
**Felmeddelande:**
```
curl http://192.168.56.13:5000/
Hello from Server 1!
```
**Vad som hände:** Båda servrarna visade "Server 1"
trots att web2 skulle visa "Server 2".
**Varför det hände:** `server_name` var definierad
i `vars/main.yml` med värdet "Server 1". Ansible
variabelprioritering: vars/main.yml har högre
prioritet än host_vars - vilket blockerade web2
från att få sitt egna värde.
**Lösning:** Tog bort `server_name` från vars/main.yml
och skapade defaults/main.yml med `server_name:
"Server 1"`. defaults har lägsta prioritet - host_vars
kan nu överskriva den. Skapade host_vars/web2.yml
med `server_name: "Server 2"`.
**Resultat:** web1 visar "Server 1" och web2 visar
"Server 2" ✅

---

### Teorikoppling

**Koncept: Ansible variabelprioritering**

Ansible har en strikt prioritetsordning för variabler.
Från lägst till högst prioritet gäller bland annat:
defaults - host_vars - vars - extra_vars.

I det här projektet utnyttjas detta medvetet.
`server_name` läggs i defaults/main.yml med lägsta
prioritet. host_vars/web2.yml överskriver den bara
för web2. web1 använder standardvärdet "Server 1"
och web2 får "Server 2" - utan att duplicera rollkod.

I produktionsmiljöer används samma mönster för att
hantera miljöspecifika skillnader - t.ex. olika
databasservrar för test och produktion - med samma
roller och playbooks.

**Officiell dokumentation:**
- Flask: https://flask.palletsprojects.com/
- Gunicorn: https://gunicorn.org/
- systemd: https://www.freedesktop.org/software/systemd/man/
- Ansible variabelprioritering: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable

---
---

## Fas 6 - nginx-rollen
**Datum:** 2026-05-06
**Git-commits:**
- `Add nginx role: reverse proxy, round-robin load balancer`
- `Fix nginx role: remove BOM from nginx.conf.j2`
- `Add role structure: cockpit role, vars and handlers for all roles`

### Vad vi gjorde

Vi designade och körde `nginx`-rollen mot nginx-
servern. Rollen installerar nginx, tar bort
standardkonfigurationen och distribuerar en
anpassad konfiguration som skickar trafik till
web1 och web2 i turordning (round-robin).

nginx är den enda servern som är nåbar utifrån
via port 8080. Alla besök går igenom nginx som
fördelar dem automatiskt mellan web1 och web2.

Vi stötte på ett problem - VS Code sparade
nginx.conf.j2 med ett BOM-tecken i början av
filen. Det orsakade ett nginx-konfigurationsfel
vid uppstart.

---

### Rollöversikt

```
nginx-rollen gör fyra saker:
1. Installerar nginx
2. Tar bort standardkonfigurationen
3. Distribuerar anpassad konfiguration via Jinja2-mall
4. Startar och aktiverar nginx-tjänsten
```

### Filöversikt

```
ansible/
└── roles/
    └── nginx/
        ├── tasks/
        │   └── main.yml        ✅
        ├── handlers/
        │   └── main.yml        ✅
        ├── templates/
        │   └── nginx.conf.j2   ✅
        └── vars/
            └── main.yml        ✅
```

### Varför detta steg är viktigt

nginx är presentationslagret i vår 3-tier-arkitektur
och den enda ingångspunkten till systemet utifrån.
Utan nginx skulle besökare behöva veta exakt vilken
server de ska ansluta till.

Lastbalansering ger också redundans - om web1 slutar
fungera skickar nginx automatiskt all trafik till
web2. Det är ett grundläggande krav i alla
produktionsmiljöer.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa mappstruktur för nginx-rollen
E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\templates
E:\Secure-Infra-Lab> mkdir ansible\roles\nginx\vars
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera rollfilerna i VS Code
E:\Secure-Infra-Lab> code ansible\roles\nginx\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\nginx\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\nginx\templates\nginx.conf.j2
E:\Secure-Infra-Lab> code ansible\roles\nginx\vars\main.yml
```
Alla filer skapades och konfigurerades i VS Code ✅

```powershell
# Ladda upp filerna till control-servern
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
```
Filerna laddades upp till control ✅

```powershell
# Committa till GitHub
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add ansible/roles/nginx/
E:\Secure-Infra-Lab> git commit -m "Add nginx role: reverse proxy, round-robin load balancer"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör playbooken
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```
nginx fick fel - se Problem 1 nedan ❌

```bash
# Kör playbooken igen efter fix
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` på alla servrar ✅

```bash
# Verifiera att lastbalansering fungerar
vagrant@control:~/ansible$ curl http://192.168.56.11/visit
vagrant@control:~/ansible$ curl http://192.168.56.11/visit
```
```
Visit registered from Server 1
Visit registered from Server 2
```
Lastbalansering fungerade korrekt ✅

```bash
# Verifiera idempotens
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla servrar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/nginx/tasks/main.yml`
**Vad den gör:** Installerar nginx, tar bort
standardkonfigurationen, distribuerar anpassad
konfiguration och startar nginx-tjänsten.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från nginx-
dokumentationen och Ansibles `file`- och
`template`-moduler. Standardkonfigurationen tas
bort med `state: absent` - annars konfliktar den
med vår anpassade konfiguration. Konfigurationen
aktiveras via en symbolisk länk från
`sites-available` till `sites-enabled` - det är
nginx standardmönster på Ubuntu.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/tasks/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/collections/ansible/builtin/

📄 `ansible/roles/nginx/handlers/main.yml`
**Vad den gör:** Definierar `Restart nginx` - körs
bara när nginx-konfigurationen har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter - nginx startas bara om när konfigurationen
faktiskt förändrats.
**Hur vi skapade den:** Vi följde samma mönster som
i tidigare roller. Tre tasks i tasks/main.yml
notifierar samma handler - Ansible kör handleren
bara en gång per playbook-körning oavsett hur
många tasks som triggar den.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/nginx/templates/nginx.conf.j2`
**Vad den gör:** Jinja2-mall för nginx-konfigurationen.
Definierar ett `upstream`-block med web1 och web2
på port 5000 och ett `server`-block som lyssnar
på port 80 och skickar trafik till upstream.
`proxy_set_header` vidarebefordrar originalheaders
till Flask.
**Varför den finns:** En mall säkerställer att
nginx alltid konfigureras korrekt med rätt
IP-adresser från vars.yml - inga manuella fel möjliga.
**Hur vi skapade den:** Vi utgick från nginx-
dokumentationen för `upstream` och `proxy_pass`.
IP-adresserna hämtas från `webserver_ip` och
`webserver2_ip` i vars.yml. `flask_port` hämtas
från vars.yml. `server_name _` matchar alla
hostnamn - vi behöver inte ett specifikt domännamn
i labbmiljön. `proxy_set_header`-raderna lades
till för att Flask ska kunna se den riktiga
klientens IP-adress.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/templates/nginx.conf.j2
**Officiell dokumentation:** https://nginx.org/en/docs/http/ngx_http_upstream_module.html

📄 `ansible/roles/nginx/vars/main.yml`
**Vad den gör:** Definierar nginx-port (80),
konfigurationskatalog och sökvägarna till
sites-available och sites-enabled.
**Varför den finns:** Separerar konfigurationsvärden
från tasks-logiken - enkelt att justera utan att
röra tasks-koden.
**Hur vi skapade den:** Vi identifierade alla
hårdkodade sökvägar i tasks-filen och samlade
dem här. nginx på Ubuntu använder alltid
`/etc/nginx/sites-available` och
`/etc/nginx/sites-enabled` - det är standardsökvägarna
som dokumenteras i nginx-dokumentationen.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/vars/main.yml
**Officiell dokumentation:** https://nginx.org/en/docs/

---

### Problem och lösningar

**Problem 1 - BOM-tecken orsakade nginx-konfigurationsfel**
**Felmeddelande:**
```
nginx: [emerg] BOM is not allowed:
/etc/nginx/sites-enabled/flask.conf:1
```
**Vad som hände:** nginx vägrade starta efter att
konfigurationsfilen distribuerats. Felet pekade
på första raden i flask.conf.
**Varför det hände:** VS Code sparade nginx.conf.j2
med ett BOM-tecken (Byte Order Mark) i början av
filen. BOM är ett osynligt tecken som Windows
ibland lägger till i UTF-8-filer. nginx tolkar
det som ett ogiltigt tecken i konfigurationsfilen.
**Lösning:** Öppnade nginx.conf.j2 i VS Code,
bytte teckenkodning från "UTF-8 with BOM" till
"UTF-8" i statusfältet längst ner och sparade.
Laddade sedan upp filen igen och körde playbooken.
**Resultat:** nginx startade korrekt ✅

---

### Teorikoppling

**Koncept: Reverse proxy och lastbalansering**

En reverse proxy tar emot alla inkommande
anslutningar och vidarebefordrar dem till
backend-servrar. Klienten ser bara proxy-servern
- aldrig backend-servrarna direkt.

Lastbalansering fördelar trafiken mellan flera
backend-servrar. Round-robin är den enklaste
metoden - varje ny anslutning skickas till nästa
server i listan i turordning.

I det här projektet tar nginx emot alla besök
på port 80. Den alternerar automatiskt mellan
web1 (192.168.56.12) och web2 (192.168.56.13).
Om en server slutar svara tar nginx automatiskt
bort den från rotationen.

I produktionsmiljöer används mer avancerade
lastbalanseringsalgoritmer som `least_conn`
(skickar till servern med färst aktiva
anslutningar) eller `ip_hash` (skickar samma
klient alltid till samma server för session-
persistens).

**Officiell dokumentation:**
- nginx upstream: https://nginx.org/en/docs/http/ngx_http_upstream_module.html
- nginx proxy: https://nginx.org/en/docs/http/ngx_http_proxy_module.html
- Ansible file module: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/file_module.html

---
---

## Fas 7 - wazuh_manager, wazuh_agent och cockpit-rollerna
**Datum:** 2026-05-07
**Git-commits:**
- `Add wazuh_manager and wazuh_agent roles`
- `Add wazuh_manager and wazuh_agent roles, fix flask defaults`
- `Replace Wazuh Dashboard with Cockpit, fix monitor port forwarding`
- `Update comments: Cockpit dashboard on port 9090`
- `Add role structure: cockpit role, vars and handlers for all roles`

### Vad vi gjorde

Vi designade och körde tre roller mot monitor-servern
och övriga servrar. `wazuh_manager`-rollen installerar
Wazuh Manager på monitor och konfigurerar den som
central säkerhetsövervakning. `wazuh_agent`-rollen
installerar Wazuh-agenten på alla servrar utom monitor
och kopplar dem till Wazuh Manager. `cockpit`-rollen
installerar Cockpit - ett webbaserat dashboard för
systemövervakning.

Vi bytte ursprungligen Wazuh Dashboard mot Cockpit
eftersom Wazuh Dashboard kräver för mycket RAM för
vår labbmiljö med begränsat minne. Cockpit är
lättare och ger tillräcklig systemöverblick för
vårt syfte.

---

### Rollöversikt

```
wazuh_manager-rollen gör tre saker:
1. Lägger till Wazuh GPG-nyckel och repository
2. Installerar Wazuh Manager via apt
3. Startar och aktiverar wazuh-manager-tjänsten

wazuh_agent-rollen gör tre saker:
1. Lägger till Wazuh GPG-nyckel och repository
2. Installerar Wazuh Agent med WAZUH_MANAGER-miljövariabel
3. Startar och aktiverar wazuh-agent-tjänsten

cockpit-rollen gör två saker:
1. Installerar Cockpit via apt
2. Startar och aktiverar cockpit-tjänsten
```

### Filöversikt

```
ansible/
└── roles/
    ├── wazuh_manager/
    │   ├── tasks/
    │   │   └── main.yml        ✅
    │   ├── handlers/
    │   │   └── main.yml        ✅
    │   └── vars/
    │       └── main.yml        ✅
    ├── wazuh_agent/
    │   ├── tasks/
    │   │   └── main.yml        ✅
    │   ├── handlers/
    │   │   └── main.yml        ✅
    │   └── vars/
    │       └── main.yml        ✅
    └── cockpit/
        ├── tasks/
        │   └── main.yml        ✅
        ├── handlers/
        │   └── main.yml        ✅
        └── vars/
            └── main.yml        ✅

vagrant/
└── Vagrantfile                 ✅ (port forwarding 9090->9090)

ansible/
└── site.yml                    ✅ (uppdaterad med cockpit-rollen)
```

### Varför detta steg är viktigt

Utan Wazuh är infrastrukturen blind. Vi vet inte
vad som händer på servrarna. Med Wazuh Manager på
monitor och agenter på alla andra servrar får vi
full översikt över alla säkerhetshändelser på
ett ställe.

Wazuh övervakar bland annat misslyckade inloggningar,
filförändringar, processer som startar och stoppas
och nätverkstrafik. Om något misstänkt händer syns
det direkt i loggarna.

Cockpit ger en webbaserad vy av systemstatus - CPU,
minne, diskutrymme och aktiva tjänster - utan att
behöva logga in via SSH.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa mappstruktur för alla tre roller
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_manager\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_manager\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_manager\vars
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_agent\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_agent\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\wazuh_agent\vars
E:\Secure-Infra-Lab> mkdir ansible\roles\cockpit\tasks
E:\Secure-Infra-Lab> mkdir ansible\roles\cockpit\handlers
E:\Secure-Infra-Lab> mkdir ansible\roles\cockpit\vars
```
Alla mappar skapades utan felmeddelanden ✅

```powershell
# Skapa och konfigurera rollfilerna i VS Code
E:\Secure-Infra-Lab> code ansible\roles\wazuh_manager\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\wazuh_manager\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\wazuh_manager\vars\main.yml
E:\Secure-Infra-Lab> code ansible\roles\wazuh_agent\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\wazuh_agent\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\wazuh_agent\vars\main.yml
E:\Secure-Infra-Lab> code ansible\roles\cockpit\tasks\main.yml
E:\Secure-Infra-Lab> code ansible\roles\cockpit\handlers\main.yml
E:\Secure-Infra-Lab> code ansible\roles\cockpit\vars\main.yml
```
Alla filer skapades och konfigurerades i VS Code ✅

```powershell
# Uppdatera Vagrantfilen med port forwarding för Cockpit
E:\Secure-Infra-Lab> code vagrant\Vagrantfile
```
Port forwarding 9090->9090 lades till för monitor ✅

```powershell
# Ladda upp filerna till control-servern
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\ansible /home/vagrant/ansible control
```
Filerna laddades upp till control ✅

```powershell
# Committa till GitHub
cd E:\Secure-Infra-Lab
E:\Secure-Infra-Lab> git add ansible/roles/wazuh_manager/ ansible/roles/wazuh_agent/ ansible/roles/cockpit/ vagrant/Vagrantfile ansible/site.yml
E:\Secure-Infra-Lab> git commit -m "Add wazuh_manager and wazuh_agent roles"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör playbooken
# OBS: Wazuh Manager-installationen tar lång tid
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `failed=0` på alla servrar ✅

```bash
# Verifiera att Wazuh Manager körs på monitor
vagrant@control:~/ansible$ ansible monitor_g -m shell -a "systemctl is-active wazuh-manager"
```
```
monitor | CHANGED | rc=0 >>
active
```
Wazuh Manager körs korrekt ✅

```bash
# Verifiera att Wazuh-agenter är anslutna
vagrant@control:~/ansible$ ansible monitor_g -m shell -a "sudo /var/ossec/bin/agent_control -l"
```
Förväntat output: Alla fem agenter visas som aktiva ✅

```bash
# Verifiera att Cockpit är nåbar
# Öppna i webbläsaren på Windows-värddatorn
# https://localhost:9090
# Logga in med vagrant/vagrant
```
Cockpit dashboard tillgänglig ✅

```bash
# Verifiera idempotens
vagrant@control:~/ansible$ ansible-playbook site.yml
```
Förväntat output: `changed=0` på alla servrar ✅

---

### Konfigurationsfiler

📄 `ansible/roles/wazuh_manager/tasks/main.yml`
**Vad den gör:** Lägger till Wazuh GPG-nyckel och
apt-repository, installerar Wazuh Manager och
startar tjänsten.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från Wazuhs
officiella installationsdokumentation. GPG-nyckeln
läggs till med `shell`-modulen och `creates`-argumentet
gör steget idempotent - det körs bara om nyckelfilen
inte redan finns. Samma mönster används för
repository-filen. Wazuh Manager installeras sedan
via `apt`-modulen med ett specifikt versionslås
för att garantera reproducerbarhet.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/tasks/main.yml
**Officiell dokumentation:** https://documentation.wazuh.com/current/installation-guide/

📄 `ansible/roles/wazuh_manager/handlers/main.yml`
**Vad den gör:** Definierar `Restart wazuh-manager` -
körs bara när konfigurationen har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter - Wazuh Manager startas bara om när
konfigurationen faktiskt förändrats.
**Hur vi skapade den:** Vi följde samma mönster som
i tidigare roller. En handler per tjänst som behöver
startas om vid konfigurationsändringar.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/wazuh_manager/vars/main.yml`
**Vad den gör:** Definierar Wazuh Manager-port (1514),
registreringsport (1515), API-port (55000),
regelkatalog och alert-loggfil.
**Varför den finns:** Samlar alla rollspecifika
variabler på ett ställe - enkelt att justera utan
att röra tasks-koden.
**Hur vi skapade den:** Vi identifierade alla
portar och sökvägar som Wazuh Manager använder
från den officiella dokumentationen och samlade
dem här. `wazuh_alerts_log` och `wazuh_rules_dir`
är viktiga för felsökning och dokumenteras i
cheatsheet.md.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/vars/main.yml
**Officiell dokumentation:** https://documentation.wazuh.com/current/user-manual/manager/

📄 `ansible/roles/wazuh_agent/tasks/main.yml`
**Vad den gör:** Lägger till Wazuh GPG-nyckel och
apt-repository, installerar Wazuh Agent med
`WAZUH_MANAGER`-miljövariabeln satt till monitor-
serverns IP och startar tjänsten.
**Varför den finns:** Tasks-filen är rollens kärna -
utan den gör rollen ingenting.
**Hur vi skapade den:** Vi utgick från Wazuhs
agentinstallationsdokumentation. `WAZUH_MANAGER`-
miljövariabeln sätts under apt-installationen -
det är Wazuhs rekommenderade sätt att peka agenten
mot rätt manager utan att manuellt redigera
konfigurationsfiler efteråt. `monitor_ip` hämtas
från vars.yml.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/tasks/main.yml
**Officiell dokumentation:** https://documentation.wazuh.com/current/installation-guide/wazuh-agent/

📄 `ansible/roles/wazuh_agent/handlers/main.yml`
**Vad den gör:** Definierar `Restart wazuh-agent` -
körs bara när konfigurationen har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter av agenten.
**Hur vi skapade den:** Vi följde samma mönster som
i tidigare roller.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/wazuh_agent/vars/main.yml`
**Vad den gör:** Definierar `wazuh_manager_ip`
som pekar på `monitor_ip` (192.168.56.15),
agent-port (1514) och registreringsport (1515).
**Varför den finns:** Separerar konfigurationsvärden
från tasks-logiken. Om monitor-serverns IP ändras
behöver vi bara uppdatera här.
**Hur vi skapade den:** Vi identifierade de portar
och IP-adresser som agenten behöver känna till.
`wazuh_manager_ip` är en referens till `monitor_ip`
från vars.yml - inga hårdkodade IP-adresser i
rollkoden.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/vars/main.yml
**Officiell dokumentation:** https://documentation.wazuh.com/current/user-manual/agents/

📄 `ansible/roles/cockpit/tasks/main.yml`
**Vad den gör:** Installerar Cockpit via apt och
startar tjänsten på port 9090.
**Varför den finns:** Cockpit är en separat tjänst
med egen livscykel - den hör inte hemma i
wazuh_manager-rollen.
**Hur vi skapade den:** Vi utgick från Cockpits
officiella dokumentation. Cockpit installeras med
ett enkelt `apt`-anrop och startas med `service`-
modulen. Installationen är enkel jämfört med Wazuh -
Cockpit finns i Ubuntus standardrepository.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/tasks/main.yml
**Officiell dokumentation:** https://cockpit-project.org/running.html

📄 `ansible/roles/cockpit/handlers/main.yml`
**Vad den gör:** Definierar `Restart cockpit` -
körs bara när konfigurationen har ändrats.
**Varför den finns:** Handlers förhindrar onödiga
omstarter av Cockpit.
**Hur vi skapade den:** Vi följde samma mönster
som i tidigare roller.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/handlers/main.yml
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/cockpit/vars/main.yml`
**Vad den gör:** Definierar Cockpit-port (9090).
**Varför den finns:** Separerar konfigurationsvärden
från tasks-logiken.
**Hur vi skapade den:** Vi identifierade Cockpits
standardport och dokumenterade den här. Port 9090
vidarebefordras från Windows-värddatorn via
Vagrantfilen så att Cockpit är nåbar via
`https://localhost:9090`.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/vars/main.yml
**Officiell dokumentation:** https://cockpit-project.org/

---

### Problem och lösningar

**Problem 1 - Wazuh Dashboard krävde för mycket RAM**
**Felmeddelande:**
```
fatal: [monitor]: FAILED! => {"msg": "Timeout
waiting for Wazuh Dashboard to start"}
```
**Vad som hände:** Wazuh Dashboard tog för lång
tid att starta och Ansible fick timeout. monitor
har 2048 MB RAM - Wazuh Dashboard kräver minst
4 GB för att fungera stabilt.
**Varför det hände:** Wazuh Dashboard är en
Elasticsearch-baserad applikation som är
resurskrävande. Vår labbmiljö har begränsat RAM.
**Lösning:** Tog bort Wazuh Dashboard från
wazuh_manager-rollen och skapade en separat
cockpit-roll istället. Cockpit är lättviktigt
och ger tillräcklig systemöverblick för vårt syfte.
Lade också till port forwarding 9090->9090 i
Vagrantfilen för att nå Cockpit från Windows-
värddatorn.
**Resultat:** Cockpit startade korrekt och är
nåbar via `https://localhost:9090` ✅

---

### Teorikoppling

**Koncept: SIEM - Security Information and Event Management**

SIEM är ett system som samlar in och analyserar
säkerhetshändelser från hela infrastrukturen på
ett ställe. Utan SIEM måste man logga in på varje
server separat för att se vad som hänt.

I det här projektet är Wazuh Manager på monitor
SIEM-systemet. Agenter på alla fem andra servrar
skickar händelser till Manager i realtid. Manager
analyserar händelserna mot regeluppsättningar och
skapar alerts vid misstänkt aktivitet.

Typiska händelser som Wazuh övervakar är
misslyckade SSH-inloggningar, ändringar i
systemfiler, nya processer som startar och
nätverksanslutningar till okända IP-adresser.

I produktionsmiljöer integreras SIEM med
automatiska responssystem - t.ex. blockerar
Wazuh automatiskt IP-adresser som utför
brute-force-attacker via active response.

**Officiell dokumentation:**
- Wazuh: https://documentation.wazuh.com/
- Cockpit: https://cockpit-project.org/
- Ansible shell module: https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html

---
---

## Fas 8 - verifieringsskript
**Datum:** 2026-05-08
**Git-commits:**
- `Add verify.sh and verify_host.ps1`
- `Fix verify scripts: round-robin order, Cockpit TCP check`

### Vad vi gjorde

Vi designade och körde två verifieringsskript som
automatiskt testar att hela infrastrukturen fungerar
korrekt. `verify.sh` körs inifrån control-servern
och testar 38 kontrollpunkter. `verify_host.ps1`
körs från Windows-värddatorn och testar 6
kontrollpunkter via port forwarding.

Skripten testar nginx, lastbalansering, Flask,
databas, brandväggsregler, SSH-härdning, fail2ban,
auditd, Wazuh och Cockpit - hela infrastrukturen
i ett enda kommando.

Vi stötte på ett problem med round-robin-ordningen
i verify_host.ps1 - skriptet antog att Server 1
alltid svarade först vilket inte stämmer. Vi fixade
det genom att samla två svar och kontrollera att
båda servrarna förekommer.

---

### Rollöversikt

```
Fas 8 skapar automatiserade verifieringsskript:
1. verify.sh - 38 tester från control-servern
2. verify_host.ps1 - 6 tester från Windows-värddatorn
```

### Filöversikt

```
scripts/
├── verify.sh               ✅
└── verify_host.ps1         ✅
```

### Varför detta steg är viktigt

Automatiserade verifieringsskript bevisar att hela
infrastrukturen fungerar som avsett efter varje
`vagrant destroy -f && vagrant up && ansible-playbook
site.yml`. Utan skripten måste varje tjänst
kontrolleras manuellt - det tar tid och det är lätt
att missa något.

Skripten är också ett krav för att bevisa
reproducerbarhet - samma 38/38 och 6/6 ska uppnås
varje gång miljön återskapas från grunden.

---

### Körda kommandon

#### Windows - PowerShell

```powershell
# Skapa och konfigurera verifieringsskripten i VS Code
E:\Secure-Infra-Lab> code scripts\verify.sh
E:\Secure-Infra-Lab> code scripts\verify_host.ps1
```
Båda filer skapades och konfigurerades i VS Code ✅

```powershell
# Ladda upp verify.sh till control-servern
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant upload ..\scripts\verify.sh /home/vagrant/verify.sh control
```
verify.sh laddades upp till control ✅

```powershell
# Kör verify_host.ps1 från Windows
cd E:\Secure-Infra-Lab
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
6/6 tester godkända ✅

```powershell
# Committa till GitHub
E:\Secure-Infra-Lab> git add scripts/verify.sh scripts/verify_host.ps1
E:\Secure-Infra-Lab> git commit -m "Add verify.sh and verify_host.ps1"
E:\Secure-Infra-Lab> git push
```
Commit bekräftades utan felmeddelanden ✅

#### Bash - control (192.168.56.10)

```bash
# Logga in på control och kör verify.sh
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
38/38 tester godkända ✅

---

### Konfigurationsfiler

📄 `scripts/verify.sh`
**Vad den gör:** Bash-skript med 38 automatiserade
tester som körs från control-servern. Testar nginx,
round-robin lastbalansering, databasanslutning från
web1, brandväggsblockering, Flask-tjänster,
fail2ban, auditd, SSH-härdning, Wazuh-agenter,
Wazuh Manager och Cockpit.
**Varför den finns:** Ett enda kommando verifierar
att hela infrastrukturen fungerar korrekt. Det
bevisar reproducerbarhet och sparar tid vid
felsökning.
**Hur vi skapade den:** Vi identifierade alla
tjänster och säkerhetskrav i projektet och skapade
ett test per krav. En återanvändbar `check()`-
funktion tar emot beskrivning, faktiskt resultat
och förväntat värde - den skriver PASS eller FAIL
och räknar resultaten. `for`-loopar används för
tester som ska köras på alla sex servrar. `curl`
används för HTTP-tester och `nc` för port-tester.
SSH-tester körs via `ssh -o StrictHostKeyChecking=no`
för att undvika interaktiva frågor.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh
**Officiell dokumentation:** https://www.gnu.org/software/bash/manual/

📄 `scripts/verify_host.ps1`
**Vad den gör:** PowerShell-skript med 6 automatiserade
tester som körs från Windows-värddatorn. Testar
nginx via port forwarding 8080, round-robin
lastbalansering, /visit-routen, Cockpit via TCP
och att databasen inte är nåbar från Windows.
**Varför den finns:** Kompletterar verify.sh med
tester från värddatorns perspektiv - testar port
forwarding och att brandväggsreglerna fungerar
utifrån.
**Hur vi skapade den:** Vi följde samma mönster
som i verify.sh men anpassade det till PowerShell.
`Invoke-WebRequest` används för HTTP-tester.
`System.Net.Sockets.TcpClient` används för TCP-
tester av Cockpit och databasblockering. En `Check`-
funktion med `Write-Host -ForegroundColor` ger
grön/röd output i terminalen. Round-robin-testet
samlar två svar i `$r1` och `$r2` och kontrollerar
att båda servrarna förekommer i det kombinerade
svaret.
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1
**Officiell dokumentation:** https://learn.microsoft.com/en-us/powershell/

---

### Problem och lösningar

**Problem 1 - Round-robin-testet misslyckades sporadiskt**
**Felmeddelande:**
```
FAIL: Round-robin Server 2 (got: Hello from Server 1!)
```
**Vad som hände:** Testet antog att Server 1 alltid
svarade på första anropet och Server 2 på andra
anropet. Men nginx startar inte alltid från Server 1
- det beror på var i rotationen nginx befinner sig
när skriptet körs.
**Varför det hände:** Round-robin-ordningen i nginx
bevaras mellan anrop. Om ett tidigare anrop redan
har skickat till Server 1 kan nästa anrop gå till
Server 2 istället.
**Lösning:** Ändrade testet till att samla två svar
i `$r1` och `$r2` och kombinera dem i `$combined`.
Sedan kontrolleras att "Server 1" och "Server 2"
båda förekommer i det kombinerade svaret - oavsett
ordning.
**Resultat:** Round-robin-testet ger stabila
resultat oavsett nginx-rotationsläge ✅

**Problem 2 - Cockpit-testet med HTTPS misslyckades**
**Felmeddelande:**
```
FAIL: Cockpit responds on localhost:9090 (got: failed)
```
**Vad som hände:** `Invoke-WebRequest` mot
`https://localhost:9090` misslyckades på grund av
Cockpits självsignerade certifikat.
**Varför det hände:** PowerShell validerar SSL-
certifikat som standard. Cockpit använder ett
självsignerat certifikat som inte är betrodd av
Windows.
**Lösning:** Bytte från HTTPS-anrop till TCP-
anslutningstest med `System.Net.Sockets.TcpClient`.
TCP-testet kontrollerar bara att port 9090 svarar
- det behöver inte validera certifikatet.
**Resultat:** Cockpit-testet ger stabila
resultat ✅

---

### Teorikoppling

**Koncept: Automatiserad verifiering och reproducerbarhet**

Automatiserade tester är grunden för att bevisa
att ett system fungerar som avsett. Utan tester
vet vi inte om en ny installation är identisk med
den förra.

I det här projektet bevisar verify.sh och
verify_host.ps1 att hela infrastrukturen fungerar
korrekt efter varje omstart från grunden. 38/38
och 6/6 ska uppnås varje gång - annars är miljön
inte reproducerbar.

I produktionsmiljöer används liknande tester i
CI/CD-pipelines. Varje gång kod pushas till
Git körs automatiska tester mot en testmiljö.
Om testerna misslyckas blockeras deploymentet
automatiskt - ingen kod som bryter infrastrukturen
når produktion.

**Officiell dokumentation:**
- Bash: https://www.gnu.org/software/bash/manual/
- PowerShell: https://learn.microsoft.com/en-us/powershell/
- curl: https://curl.se/docs/

---
---

## Fas 9 - Forbattringar: failover, TLS, Active Response och listen_addresses
**Datum:** 2026-05-12
**Git-commits:**
- `feat(nginx): add passive health checks and automatic failover`
- `feat(database): restrict listen_addresses to web1 and web2 only`
- `feat(wazuh): add active response to block SSH brute force attacks`
- `feat(tls): encrypt traffic between nginx and Flask with self-signed certificates`
- `docs(readme): update architecture description and remove implemented improvements`
- `docs(projektplan): update database and nginx descriptions with implemented improvements`

### Vad vi gjorde

Vi implementerade fyra sakerhetsforstarkningar pa en
ny branch (feature/improvements) och uppdaterade
dokumentationen.

**Forbattring 1 - Automatisk failover i nginx**
Lade till passive health checks i nginx upstream-blocket.
Om en webbserver misslyckas tva ganger inom 30 sekunder
markeras den som nere och nginx slutar skicka trafik dit.
proxy_next_upstream hanterar automatisk omsandning vid fel.

**Forbattring 2 - listen_addresses pa databasen**
PostgreSQL lyssnar nu bara pa web1 och web2 IP-adresser
istallet for alla interfacer ('*'). Ger ett extra
skyddslager utover UFW-reglerna - Defense-in-Depth.

**Forbattring 3 - Wazuh Active Response**
Skapade ossec.conf.j2 med ett active-response-block.
Regel 5763 triggar firewall-drop vid upprepade
SSH-misslyckanden. IP-adressen blockeras i 300 sekunder.

**Forbattring 4 - TLS mellan nginx och Flask**
Ansible genererar nu ett sjalvsignerat TLS-certifikat
pa web1 och web2 via openssl. Gunicorn serverar Flask
over HTTPS pa port 5000. nginx anvander proxy_ssl_verify
off eftersom certifikatet ar sjalvsignerat i labbmiljon.

### Kommandon vi korde

```bash
git checkout main
git merge review/documentation-update
git push origin main
git checkout -b feature/improvements
```

Sedan for varje forbattring:

```bash
# Redigerade filer i VS Code
code ansible/roles/nginx/templates/nginx.conf.j2
code ansible/roles/database/tasks/main.yml
code ansible/roles/wazuh_manager/templates/ossec.conf.j2
code ansible/roles/wazuh_manager/tasks/main.yml
code ansible/roles/flask/tasks/main.yml
code ansible/roles/flask/templates/flask.service.j2
```

```bash
git add .
git commit -m "[commit-meddelande]"
git push origin feature/improvements
```

### Teorikoppling

**Koncept: Defense-in-Depth**
Defense-in-Depth betyder flera skyddslager. Om ett
lager bryts igenom finns nasta lager kvar.

I det har projektet:
- UFW blockerar obehörig trafik pa natverksniva
- listen_addresses begransar vilka interfacer PostgreSQL lyssnar pa
- pg_hba.conf kontrollerar vilka IP-adresser som far autentisera
- TLS krypterar trafiken mellan nginx och Flask
- Wazuh Active Response blockerar angripare automatiskt

I produktion kompletteras detta med nätverkssegmentering,
IDS/IPS och SOC-overvakning.

**Officiell dokumentation:**
- nginx upstream: https://nginx.org/en/docs/http/ngx_http_upstream_module.html
- Wazuh Active Response: https://documentation.wazuh.com/current/user-manual/capabilities/active-response/
- openssl: https://www.openssl.org/docs/

---
---