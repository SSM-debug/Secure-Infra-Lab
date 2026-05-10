
## Teknisk dokumentation - Secure-Infra-Lab

Projekt: Secure-Infra-Lab 
Författare: Sushanta Shekhar Modak & Farhad Norman  
GitHub: https://github.com/SSM-debug/Secure-Infra-Lab  


Den här loggen beskriver allt vi gjort i projektet,fas för fas. För varje fas förklarar vi vad vi gjorde, vilka kommandon vi körde, vad vi såg på skärmen och hur vi löste problem som dök upp.

Loggen är skriven så att vem som helst ska kunna följamed — även den som inte jobbat med projektet tidigare.

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

