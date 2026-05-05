# Projektlogg — Secure-Infra-Lab

**Projekt:** Secure-Infra-Lab  
**Författare:** Sushanta Shekhar Modak & Farhad Norman  
**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab  

Denna logg dokumenterar implementationsarbetet fas för fas.
Varje fas innehåller genomförda åtgärder, körda kommandon
med förväntad output, berörda konfigurationsfiler med
källhänvisningar samt analys av uppkomna problem.

---

## Fas 1 — Vagrantfile och VM-uppstart
**Datum:** 2026-05-02  
**Git-commits:**
- `Initial structure: Vagrantfile for 6 VMs`
- `Add .gitignore and fix control provisioner: install Ansible via pip instead of apt`

### Vad vi gjorde
Etablerade projektstrukturen lokalt på Windows och initierade
Git-versionshantering. Definierade samtliga sex virtuella
maskiner i en Vagrantfile med korrekta IP-adresser,
resursallokeringar och provisioneringsskript. Skapade ett
GitHub-repository och publicerade projektet. Identifierade att
Ansible 2.10.8 från Ubuntus pakethanterare är föråldrad och
uppdaterade provisioneringsskriptet för control-noden till att
installera senaste versionen via pip3. Skapade `.gitignore`
för att förhindra att interna Vagrant-filer och
hemlighetsfiler publiceras. Startade samtliga sex VMs och
verifierade att de är operativa.

### Körda kommandon

```powershell
# Skapa projektmapp och initiera versionshantering
mkdir E:\Secure-Infra-Lab
cd E:\Secure-Infra-Lab
git init
```
Förväntat output: `Initialized empty Git repository in E:/Secure-Infra-Lab/.git/`  
Felindikator: Felmeddelande om Git inte är installerat.

```powershell
# Skapa komplett mappstruktur i ett kommando
mkdir vagrant, ansible\roles\security_hardening, ansible\roles\flask, `
      ansible\roles\nginx, ansible\roles\database, `
      ansible\roles\wazuh_agent, ansible\vars, docs
```
Förväntat output: Inga felmeddelanden — mapparna skapas tysta.

```powershell
# Anslut lokalt repo till GitHub och publicera
git remote add origin https://github.com/SSM-debug/Secure-Infra-Lab.git
git push -u origin main
```
Förväntat output: `Branch 'main' set up to track remote branch 'main' from 'origin'.`

```powershell
# Starta VMs individuellt för kontrollerad felsökning
cd E:\Secure-Infra-Lab\vagrant
vagrant up control
vagrant up nginx
vagrant up web1
vagrant up web2
vagrant up database
vagrant up monitor
```
Förväntat output för varje VM: `=== [vmname]: ready ===`  
Felindikator: `Timed out while waiting for the machine to boot` indikerar resursbrist.

```powershell
# Verifiera att samtliga VMs är operativa
vagrant status
```
Förväntat output: Samtliga sex VMs visar `running (virtualbox)`.

```powershell
# Uppdatera control-provisioner och starta om med ny konfiguration
vagrant reload --provision control
```
Förväntat output: `=== control: ready ===` följt av Ansible-version 2.12 eller senare.

### Konfigurationsfiler

📄 `vagrant/Vagrantfile`  
**Vad den gör:** Definierar samtliga sex VMs med IP-adresser,
RAM-allokering, CPU-antal och provisioneringsskript. Vagrant
läser denna fil och skapar infrastrukturen automatiskt.  
**Varför den finns:** Infrastructure-as-Code — miljön är reproducerbar
och dokumenterad som kod istället för manuell konfiguration.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/vagrant/Vagrantfile  
**Officiell dokumentation:** https://developer.hashicorp.com/vagrant/docs/vagrantfile

📄 `.gitignore`  
**Vad den gör:** Instruerar Git att ignorera `vagrant/.vagrant/`
(Vagrant-interna filer med SSH-nycklar) och `vagrant/secrets.yml`
(databasuppgifter).  
**Varför den finns:** Förhindrar att känslig information
publiceras till GitHub, vilket vore en allvarlig säkerhetsbrist.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitignore  
**Officiell dokumentation:** https://git-scm.com/docs/gitignore

### Problem och lösningar

**Problem 1 — Ansible 2.10.8 för gammal**  
**Felmeddelande:** `ansible 2.10.8`  
**Orsak:** Ubuntus pakethanterare (apt) distribuerar en föråldrad
version av Ansible som saknar stöd för moduler vi använder.  
**Lösning:** Uppdaterade control-provisioneringsskriptet i
Vagrantfilen att installera Ansible via `pip3 install ansible`
istället för `apt-get install ansible`.  
**Förväntat resultat efter fix:** `ansible [core 2.17.x]`

**Problem 2 — Vagrant-interna filer spårades av Git**  
**Felmeddelande:** Git staging visade `vagrant/.vagrant/` med SSH-nycklar  
**Orsak:** Ingen `.gitignore` fanns i projektet.  
**Lösning:** Skapade `.gitignore` och körde
`git rm -r --cached vagrant/.vagrant/` för att avregistrera
redan spårade filer.

**Problem 3 — Felstavat kommando**  
**Felmeddelande:** `The machine with the name '..provision' was not found`  
**Orsak:** `..provision` skrevs istället för `--provision`.  
**Lösning:** `vagrant reload --provision control`

### Teorikoppling

**Koncept:** Infrastructure-as-Code (IaC)  
Traditionell infrastruktur konfigureras manuellt — ett
tidskrävande och felbenäget förfarande som producerar
unika miljöer som är svåra att reproducera. IaC beskriver
istället infrastrukturen i versionshanterade textfiler.
Miljön skapas, modifieras och förstörs via kod.

I detta projekt definierar Vagrantfilen exakt hur de sex
VM:erna skall se ut. `vagrant up` läser filen och skapar
infrastrukturen identiskt varje gång — oavsett om det
körs idag eller om sex månader på en annan dator.

I produktionsmiljöer används verktyg som Terraform för
att tillämpa samma princip mot molnleverantörer som AWS
och Azure — hundratals servrar skapas reproducerbart
från versionshanterade konfigurationsfiler.

**Officiell dokumentation:**  
- Vagrant: https://developer.hashicorp.com/vagrant/docs  
- VirtualBox: https://www.virtualbox.org/manual/

---

## Fas 2 — Ansible-konfiguration
**Datum:** 2026-05-02  
**Git-commit:** `Add Ansible config: ansible.cfg, inventory.ini, site.yml`

### Vad vi gjorde
Skapade de tre grundläggande konfigurationsfilerna för Ansible:
`ansible.cfg` med globala inställningar, `inventory.ini` med
samtliga sex noder och `site.yml` som master-playbook.
Definierade körordningen för rollerna — database konfigureras
alltid innan webservrarna startas, nginx konfigureras sist.

### Körda kommandon

```powershell
# Skapa konfigurationsfiler i VS Code
code E:\Secure-Infra-Lab\ansible\ansible.cfg
code E:\Secure-Infra-Lab\ansible\inventory.ini
code E:\Secure-Infra-Lab\ansible\site.yml

# Publicera till GitHub
git add ansible/ansible.cfg ansible/inventory.ini ansible/site.yml
git commit -m "Add Ansible config: ansible.cfg, inventory.ini, site.yml"
git push
```
Förväntat output: `[main xxxxxxx] Add Ansible config: ansible.cfg, inventory.ini, site.yml`

### Konfigurationsfiler

📄 `ansible/ansible.cfg`  
**Vad den gör:** Global konfigurationsfil för Ansible. Anger
sökväg till inventory-filen, inaktiverar SSH host key-verifiering
(lämpligt i labbmiljö) och tillåter world-readable temporära filer.  
**Varför den finns:** Utan denna fil måste samtliga inställningar
anges som flaggor vid varje kommandokörning.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/ansible.cfg  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html

📄 `ansible/inventory.ini`  
**Vad den gör:** Listar samtliga sex noder med IP-adresser,
SSH-användare och nyckelfilssökvägar. Definierar gruppstrukturen
`[all:children]` för att eliminera varningar om namnkonflikter.  
**Varför den finns:** Ansible måste känna till vilka servrar som
existerar och hur de nås innan någon automation kan utföras.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/inventory.ini  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

📄 `ansible/site.yml`  
**Vad den gör:** Master-playbook som definierar körordningen för
samtliga roller. Ett play per nodgrupp. Laddar variabler från
`vars/vars.yml` och `secrets.yml` vid varje körning.  
**Varför den finns:** Utan en definierad körordning kan
applikationslagret försöka ansluta till en databas som ännu
inte konfigurerats — vilket resulterar i fel.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/site.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html

📄 `ansible/vars/vars.yml`  
**Vad den gör:** Centraliserad variabelfil med IP-adresser och
portnummer som delas av alla roller.  
**Varför den finns:** Centraliserade variabler eliminerar
duplicering — en IP-adress definieras på ett ställe och
refereras från samtliga roller.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/vars/vars.yml

### Problem och lösningar

Inga fel uppstod under denna fas.

### Teorikoppling

**Koncept:** Ansible inventory och körordning  
Inventory-filen är Ansibles register över hanterade noder.
Utan ett korrekt inventory kan Ansible inte kommunicera med
servrarna. Körordningen i site.yml är kritisk — i ett
distribuerat system med beroenden måste infrastrukturens
fundament (databas) etableras innan beroende komponenter
(applikationsservrar) konfigureras.

I produktionsmiljöer används dynamiska inventories som
genereras automatiskt från molnleverantörers API:er —
nya servrar registreras omedelbart utan manuell
uppdatering av inventory-filen.

**Officiell dokumentation:**  
- Ansible inventory: https://docs.ansible.com/ansible/latest/inventory_guide/  
- Ansible playbooks: https://docs.ansible.com/ansible/latest/playbook_guide/

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
Implementerade `security_hardening`-rollen och körde den
mot samtliga sex noder. Rollen distribuerar en härdad
SSH-konfiguration, installerar fail2ban för
intrångsprevention och auditd för revisionsspårning.

Löste tre tekniska problem under fasen: avsaknad av
platshållarroller för ännu ej implementerade roller,
avsaknad av SSH-nyckelpar på control-noden samt
inkonsekventa radbrytningar (CRLF/LF) mellan Windows
och Linux. Samtliga problem åtgärdades permanent.

Slutresultat: `ansible-playbook site.yml` körd mot
alla sex noder med `failed=0`. Idempotens verifierad
på andra körningen med `changed=0` på samtliga noder.

### Körda kommandon

```powershell
# Skapa mappstruktur för security_hardening-rollen
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\tasks
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\handlers
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\templates

# Skapa rollfilerna i VS Code
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\tasks\main.yml
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\handlers\main.yml
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\templates\sshd_config.j2
```
Förväntat output: VS Code öppnar respektive fil för redigering.

```powershell
# Skapa platshållarroller för ännu ej implementerade roller
foreach ($role in @("database", "flask", "nginx", "wazuh_agent")) {
    $path = "E:\Secure-Infra-Lab\ansible\roles\$role\tasks\main.yml"
    Set-Content -Path $path -Value "---`n# Placeholder — role not yet implemented"
    Write-Host "Created: $path"
}
```
Förväntat output: `Created: E:\...\[rollnamn]\tasks\main.yml` för varje roll.

```powershell
# Åtgärda CRLF-problematik permanent
git config core.autocrlf false
git config core.eol lf
# Normalisera samtliga befintliga filer
git rm --cached -r .
git reset --hard
git add .
git commit -m "Normalize line endings to LF across all files"
git push
```
Förväntat output: Git bekräftar commit utan CRLF-varningar.

```powershell
# Hämta controls publika nyckel och distribuera till samtliga noder
$pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"
foreach ($vm in @("nginx", "web1", "web2", "database", "monitor")) {
    $port = (vagrant ssh-config $vm | Select-String "Port").ToString().Trim().Split(" ")[1]
    $keyfile = (vagrant ssh-config $vm | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
    echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
}
```
Förväntat output: `Warning: Permanently added '[127.0.0.1]:XXXX'` för varje nod — inga fel.  
Felindikator: `Permission denied (publickey)` indikerar att nyckeln inte distribuerats korrekt.

```bash
# Inuti control-noden — generera SSH-nyckelpar
ssh-keygen -t ed25519 -f /home/vagrant/.ssh/id_rsa -N ""
```
Förväntat output: Bekräftelse att nycklarna skapats i `/home/vagrant/.ssh/`.

```bash
# Kör playbooken mot control-noden för initial verifiering
cd /home/vagrant/ansible
ansible-playbook site.yml --limit control
```
Förväntat output:
```
PLAY RECAP
control : ok=7  changed=5  unreachable=0  failed=0
```

```bash
# Kör playbooken mot samtliga noder
ansible-playbook site.yml
```
Förväntat output: `failed=0` för samtliga sex noder.

```bash
# Verifiera idempotens — andra körningen
ansible-playbook site.yml
```
Förväntat output: `changed=0` på samtliga noder.

### Konfigurationsfiler

📄 `ansible/roles/security_hardening/tasks/main.yml`  
**Vad den gör:** Definierar åtgärdssekvensen — uppdaterar
paketcachen, installerar fail2ban och auditd, distribuerar
SSH-konfigurationen och startar säkerhetstjänsterna.  
**Varför den finns:** Ansible-roller kräver en `tasks/main.yml`
som ingångspunkt för rollens åtgärder.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

📄 `ansible/roles/security_hardening/handlers/main.yml`  
**Vad den gör:** Definierar `Restart sshd`-handleren som
triggas av `notify` i tasks-filen — men enbart om
SSH-konfigurationen faktiskt förändrats.  
**Varför den finns:** Handlers säkerställer att SSH-tjänsten
enbart startas om vid faktisk konfigurationsförändring.
Onödiga omstarter av SSH i produktion terminerar aktiva
sessioner.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/handlers/main.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/security_hardening/templates/sshd_config.j2`  
**Vad den gör:** Jinja2-mall för SSH-serverkonfigurationen.
Inaktiverar root-inloggning och lösenordsautentisering,
begränsar inloggningsförsök och tillåter enbart
definierade användare.  
**Varför den finns:** En härdad SSH-konfiguration är det
primära skyddet mot obehörig åtkomst till samtliga noder.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2  
**Officiell dokumentation:** https://man.openbsd.org/sshd_config

📄 `.gitattributes`  
**Vad den gör:** Instruerar Git att konsekvent använda LF-radbrytningar
för samtliga filer i repositoryt — oavsett operativsystem.  
**Varför den finns:** Windows använder CRLF medan Linux använder
LF. Utan denna fil konverterar Git på Windows filerna till CRLF
vilket kan orsaka tolkningsfel i Bash-skript och
YAML-konfigurationer på Linux-noder.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitattributes  
**Officiell dokumentation:** https://git-scm.com/docs/gitattributes

### Problem och lösningar

**Problem 1 — Saknade roller orsakade krasch vid uppstart**  
**Felmeddelande:** `the role 'database' was not found in /home/vagrant/ansible/roles`  
**Orsak:** Ansible validerar samtliga roller som refereras i
site.yml vid uppstart — även för plays som inte körs i
aktuell körning. Rollerna database, flask, nginx och
wazuh_agent existerade ännu inte.  
**Lösning:** Skapade minimala platshållarfiler
(`--- # Placeholder — role not yet implemented`) för varje
ännu ej implementerad roll. Placeras i rollens `tasks/main.yml`.

**Problem 2 — SSH-nyckel saknades på control-noden**  
**Felmeddelande:** `/home/vagrant/.ssh/id_rsa: No such file or directory` och `Permission denied (publickey)`  
**Orsak:** Vagrant genererar separata SSH-nyckelpar för varje
VM för kommunikation med värddatorn, men delar inte dessa
nycklar mellan VM:erna. Control-noden saknade ett nyckelpar
för intern SSH-kommunikation.  
**Lösning:** Genererade ett ED25519-nyckelpar på control med
`ssh-keygen`. Distribuerade den publika nyckeln till
`authorized_keys` på samtliga övriga noder via Vagrants
egna nyckelinfrastruktur från Windows-värden.

**Problem 3 — Monitor-noden otillgänglig via SSH**  
**Felmeddelande:** `kex_exchange_identification: read: Connection reset`  
**Orsak:** Monitor-noden hade startats om och SSH-tjänsten
var ännu inte operativ. Monitor allokerar 2048 MB RAM och
har längre uppstartstid än övriga noder.  
**Lösning:** `vagrant reload monitor` följt av förnyat
distributionsförsök efter fullständig uppstart.

**Problem 4 — Inkonsekventa radbrytningar (CRLF/LF)**  
**Felmeddelande:** `warning: LF will be replaced by CRLF`  
**Orsak:** Git på Windows konverterar automatiskt LF till
CRLF vid utcheckning. CRLF i YAML- och Bash-filer kan
orsaka tolkningsfel på Linux-noder.  
**Lösning:** Skapade `.gitattributes` med `* text=auto eol=lf`
och normaliserade samtliga befintliga filer via
`git rm --cached -r . && git reset --hard`.

### Teorikoppling

**Koncept 1:** SSH-nyckelautentisering  
SSH-nyckelpar består av en privat nyckel (stannar på
avsändaren) och en publik nyckel (registreras på
mottagaren i `authorized_keys`). Autentiseringen sker
via ett kryptografiskt utbyte utan att lösenord
överförs över nätverket.

I detta projekt genererade control-noden ett ED25519-nyckelpar.
Den publika nyckeln distribuerades till samtliga övriga
noder. Ansible autentiserar nu mot dessa noder utan
lösenord — och lösenordsautentisering är helt inaktiverad
via `sshd_config.j2`.

I produktionsmiljöer hanteras SSH-nycklar via centraliserade
system som HashiCorp Vault eller AWS Secrets Manager med
automatisk nyckelrotation och revision.

**Officiell dokumentation:** https://www.openssh.com/manual.html

**Koncept 2:** Idempotens i konfigurationshantering  
En idempotent operation producerar identiskt resultat
oavsett hur många gånger den körs. I Ansible kontrollerar
varje modul nuvarande tillstånd mot önskat tillstånd —
åtgärder vidtas enbart vid avvikelse.

Praktisk konsekvens: En playbook kan köras dagligen i
produktion för att säkerställa konfigurationskonformitet.
Om en operatör manuellt ändrat en inställning återställs
den automatiskt vid nästa körning — utan att påverka
komponenter som redan är korrekt konfigurerade.

**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html

**Koncept 3:** Defense-in-Depth via SSH-härdning  
SSH-härdning reducerar attackytan för samtliga noder.
Standardkonfigurationen för SSH tillåter lösenords-
autentisering — vilket exponerar systemet för
automatiserade brute-force-attacker. Vår härdade
konfiguration eliminerar denna attackvektor helt:
enbart kryptografiska nycklar accepteras.

fail2ban lägger till ett reaktivt skyddslager — IP-adresser
som uppvisar mönster karakteristiska för automatiserade
attacker blockeras automatiskt. auditd möjliggör forensisk
analys — vid en säkerhetsincident finns en fullständig
revisionslogg över systemhändelser.

**Officiell dokumentation:**
- fail2ban: https://www.fail2ban.org/wiki/index.php/MANUAL_0_8
- auditd: https://linux.die.net/man/8/auditd
- OpenSSH sshd_config: https://man.openbsd.org/sshd_config