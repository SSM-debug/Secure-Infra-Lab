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

## Fas 1 — Vagrantfile och VM-uppstart
**Datum:** 2026-05-02  
**Git-commits:**
- `Initial structure: Vagrantfile for 6 VMs`
- `Add .gitignore and fix control provisioner: install Ansible via pip instead of apt`

### Vad vi gjorde

Vi började från noll. Först skapade vi en projektmapp
på Windows och kopplade den till Git. Sedan skrev vi
en Vagrantfile som beskriver alla sex servrar som kod.
Vi skapade ett GitHub-repository och publicerade
projektet där.

När vi startade control-servern för första gången
märkte vi att Ansible-versionen som installerades var
för gammal. Vi fixade det direkt i Vagrantfilen.

Vi skapade också en `.gitignore`-fil för att hindra
känsliga filer från att hamna på GitHub av misstag.

Till slut startade vi alla sex servrar en i taget och
kontrollerade att alla var uppe och körde.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn

```powershell
# Skapa projektmappen på E-disken
# Varför E:\ och inte C:\: Vagrant och VirtualBox
# fungerar bättre med korta sökvägar utan mellanslag
PS C:\> mkdir E:\Secure-Infra-Lab
PS C:\> cd E:\Secure-Infra-Lab
```
Förväntat output: Mappen skapas utan felmeddelanden.  
Vad vi fick: Mappen skapades korrekt ✅

```powershell
# Starta Git-versionshantering i mappen
# Varför: Vi vill spåra alla ändringar och kunna
# gå tillbaka till tidigare versioner
PS E:\Secure-Infra-Lab> git init
```
Förväntat output: `Initialized empty Git repository in E:/Secure-Infra-Lab/.git/`  
Vad vi fick: Exakt det förväntade ✅

```powershell
# Skapa hela mappstrukturen i ett kommando
# Varför: Bättre att ha strukturen klar från början
# än att skapa mappar efterhand
PS E:\Secure-Infra-Lab> mkdir vagrant, ansible\roles\security_hardening, `
      ansible\roles\flask, ansible\roles\nginx, `
      ansible\roles\database, ansible\roles\wazuh_agent, `
      ansible\vars, docs
```
Förväntat output: Inga felmeddelanden.  
Vad vi fick: Alla mappar skapades korrekt ✅

```powershell
# Öppna Vagrantfilen i VS Code och klistra in innehållet
PS E:\Secure-Infra-Lab> code E:\Secure-Infra-Lab\vagrant\Vagrantfile
```
Förväntat output: VS Code öppnar en tom fil.  
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Spara nuläget i Git — första commit
PS E:\Secure-Infra-Lab> git add .
PS E:\Secure-Infra-Lab> git commit -m "Initial structure: Vagrantfile for 6 VMs"
```
Förväntat output:
```
[main (root-commit) xxxxxxx] Initial structure: Vagrantfile for 6 VMs
 1 file changed, 126 insertions(+)
```
Vad vi fick: Exakt det förväntade ✅

```powershell
# Koppla lokalt repo till GitHub och publicera
PS E:\Secure-Infra-Lab> git remote add origin https://github.com/SSM-debug/Secure-Infra-Lab.git
PS E:\Secure-Infra-Lab> git push -u origin main
```
Förväntat output: `Branch 'main' set up to track remote branch 'main' from 'origin'.`  
Vad vi fick: Exakt det förväntade ✅

```powershell
# Gå in i vagrant-mappen — Vagrantfilen måste ligga här
# Varför: vagrant up letar alltid efter Vagrantfile
# i den aktuella mappen
PS E:\Secure-Infra-Lab> cd E:\Secure-Infra-Lab\vagrant

# Starta control-servern först för att testa
# Varför en i taget: Om något går fel vet vi
# exakt vilken server som krånglar
PS E:\Secure-Infra-Lab\vagrant> vagrant up control
```
Förväntat output på slutet: `=== control: ready ===`  
Vad vi fick: `ansible 2.10.8` — för gammal version ❌  
Fel vi fick: Ansible 2.10.8 från apt är föråldrad och
saknar stöd för moduler vi behöver.  
Hur vi löste det: Uppdaterade Vagrantfilens
provisioner-skript för control att installera Ansible
via `pip3 install ansible` istället för `apt-get install ansible`.

```powershell
# Starta om control med den uppdaterade Vagrantfilen
# Varför --provision: Kör provisioner-skriptet igen
# även om servern redan startats en gång
PS E:\Secure-Infra-Lab\vagrant> vagrant reload --provision control
```
Förväntat output på slutet: `=== control: ready ===`  
Vad vi fick: `ansible [core 2.17.14]` ✅

```powershell
# Starta resterande servrar en i taget
PS E:\Secure-Infra-Lab\vagrant> vagrant up nginx
PS E:\Secure-Infra-Lab\vagrant> vagrant up web1
PS E:\Secure-Infra-Lab\vagrant> vagrant up web2
PS E:\Secure-Infra-Lab\vagrant> vagrant up database
PS E:\Secure-Infra-Lab\vagrant> vagrant up monitor
```
Förväntat output för varje server: `=== [servernamn]: ready ===`  
Vad vi fick: Alla servrar startade korrekt ✅

```powershell
# Kontrollera att alla servrar är uppe
PS E:\Secure-Infra-Lab\vagrant> vagrant status
```
Förväntat output:
```
control     running (virtualbox)
nginx       running (virtualbox)
web1        running (virtualbox)
web2        running (virtualbox)
database    running (virtualbox)
monitor     running (virtualbox)
```
Vad vi fick: Exakt det förväntade ✅

```powershell
# Gå tillbaka till projektmappen för Git-kommandon
PS E:\Secure-Infra-Lab\vagrant> cd E:\Secure-Infra-Lab

# Fixa .gitignore — hindra känsliga filer från GitHub
PS E:\Secure-Infra-Lab> git rm -r --cached vagrant/.vagrant/
PS E:\Secure-Infra-Lab> git add .gitignore vagrant/Vagrantfile
PS E:\Secure-Infra-Lab> git commit -m "Add .gitignore and fix control provisioner: install Ansible via pip instead of apt"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output: Commit bekräftas utan felmeddelanden.  
Vad vi fick: Exakt det förväntade ✅

---

### Konfigurationsfiler

📄 `vagrant/Vagrantfile`  
**Vad den gör:** Beskriver alla sex servrar som kod —
IP-adresser, RAM, CPU och vad som ska installeras
när servern startas.  
**Varför den finns:** Med den här filen kan vi köra
`vagrant up` och få exakt samma sex servrar varje gång,
på vilken dator som helst.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/vagrant/Vagrantfile  
**Officiell dokumentation:** https://developer.hashicorp.com/vagrant/docs/vagrantfile

📄 `.gitignore`  
**Vad den gör:** Talar om för Git vilka filer som ska
ignoreras. Vi ignorerar `vagrant/.vagrant/` (innehåller
SSH-nycklar) och `vagrant/secrets.yml` (innehåller lösenord).  
**Varför den finns:** Om SSH-nycklar eller lösenord
hamnar på GitHub är de komprometterade för alltid —
även om man tar bort dem efteråt finns de kvar i
Git-historiken.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitignore  
**Officiell dokumentation:** https://git-scm.com/docs/gitignore

---

### Problem och lösningar

**Problem — Ansible 2.10.8 för gammal**  
**Felmeddelande:** `ansible 2.10.8`  
**Vad som hände:** Ubuntu 22.04 installerar Ansible 2.10.8
via apt. Det är en version från 2021 som saknar stöd
för moduler vi behöver.  
**Lösning:** Vi ändrade provisioner-skriptet i Vagrantfilen
till att köra `pip3 install ansible` istället. Det
installerar senaste versionen direkt från PyPI.  
**Resultat efter fix:** `ansible [core 2.17.14]` ✅

---

### Teorikoppling

**Koncept: Infrastructure-as-Code (IaC)**

Traditionellt konfigurerar man servrar för hand — man
loggar in, klickar runt och installerar saker manuellt.
Det tar tid och det blir lätt fel. Nästa gång man gör
samma sak blir resultatet lite annorlunda.

Infrastructure-as-Code löser det här. Istället för att
klicka beskriver man serverna i en textfil. Kör man
filen får man exakt samma resultat varje gång.

I det här projektet beskriver Vagrantfilen alla sex
servrar. `vagrant up` skapar dem automatiskt. Om vi
förstör allt och kör `vagrant up` igen får vi identiska
servrar på några minuter.

Samma princip används i stora företag med verktyg som
Terraform och AWS CloudFormation — tusentals servrar
i molnet skapas och förstörs automatiskt från
versionshanterade textfiler.

**Officiell dokumentation:**  
- Vagrant: https://developer.hashicorp.com/vagrant/docs  
- VirtualBox: https://www.virtualbox.org/manual/

---

## Fas 2 — Ansible-konfiguration
**Datum:** 2026-05-02  
**Git-commit:** `Add Ansible config: ansible.cfg, inventory.ini, site.yml`

### Vad vi gjorde

Vi skapade de tre filerna som Ansible behöver för att
fungera. `ansible.cfg` är inställningsfilen.
`inventory.ini` listar alla servrar. `site.yml` är
huvudplanen som bestämmer vad som installeras var och
i vilken ordning.

Ordningen i `site.yml` är viktig. Databasen måste
konfigureras innan webbservrarna startar, annars
försöker Flask ansluta till en databas som inte finns
än.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn

```powershell
# Skapa ansible.cfg i VS Code
# Varför: Utan den måste vi ange alla inställningar
# som flaggor varje gång vi kör Ansible
PS E:\Secure-Infra-Lab> code E:\Secure-Infra-Lab\ansible\ansible.cfg
```
Förväntat output: VS Code öppnar en tom fil.  
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Skapa inventory.ini i VS Code
# Varför: Ansible måste veta vilka servrar som finns
# och hur man når dem
PS E:\Secure-Infra-Lab> code E:\Secure-Infra-Lab\ansible\inventory.ini
```
Förväntat output: VS Code öppnar en tom fil.  
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Skapa site.yml i VS Code
# Varför: Huvudplanen som bestämmer vad som
# installeras på vilken server och i vilken ordning
PS E:\Secure-Infra-Lab> code E:\Secure-Infra-Lab\ansible\site.yml
```
Förväntat output: VS Code öppnar en tom fil.  
Vad vi fick: Filen öppnades korrekt ✅

```powershell
# Publicera alla tre filer till GitHub
PS E:\Secure-Infra-Lab> git add ansible/ansible.cfg ansible/inventory.ini ansible/site.yml
PS E:\Secure-Infra-Lab> git commit -m "Add Ansible config: ansible.cfg, inventory.ini, site.yml"
PS E:\Secure-Infra-Lab> git push
```
Förväntat output:
```
[main xxxxxxx] Add Ansible config: ansible.cfg, inventory.ini, site.yml
 3 files changed, X insertions(+)
```
Vad vi fick: Exakt det förväntade ✅

---

### Konfigurationsfiler

📄 `ansible/ansible.cfg`  
**Vad den gör:** Globala inställningar för Ansible.
Talar om var inventory-filen finns, stänger av SSH
host key-verifiering och tillåter tillfälliga filer
som Ansible behöver.  
**Varför den finns:** Utan den måste vi skriva långa
flaggor varje gång vi kör ett Ansible-kommando.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/ansible.cfg  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html

📄 `ansible/inventory.ini`  
**Vad den gör:** Listar alla sex servrar med
IP-adresser, SSH-användare och nyckelfilssökvägar.
Definierar också `[all:children]` för att undvika
varningar om namnkonflikter.  
**Varför den finns:** Ansible vet ingenting om våra
servrar utan den här filen.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/inventory.ini  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html

📄 `ansible/site.yml`  
**Vad den gör:** Huvudplanen. Bestämmer vilken roll
som körs på vilken server och i vilken ordning.
Laddar variabler från `vars/vars.yml` och `secrets.yml`.  
**Varför den finns:** Utan en tydlig körordning kan
applikationen försöka ansluta till en databas som
inte finns än.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/site.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html

📄 `ansible/vars/vars.yml`  
**Vad den gör:** Samlar IP-adresser och portnummer
på ett ställe. Alla roller hämtar värden härifrån
istället för att varje roll har sina egna kopior.  
**Varför den finns:** Om vi byter IP-adress på en
server behöver vi bara ändra på ett ställe.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/vars/vars.yml

---

### Problem och lösningar

Inga problem uppstod under den här fasen.

---

### Teorikoppling

**Koncept: Inventory och körordning i Ansible**

Inventory-filen är som en adressbok för Ansible.
Utan den vet Ansible inte att våra servrar existerar.

Körordningen i `site.yml` är lika viktig som att
laga mat i rätt ordning. Du kokar pastan innan du
häller på såsen — inte tvärtom. På samma sätt
konfigurerar vi databasen innan webbservrarna,
annars försöker Flask ansluta till något som inte
finns än.

I stora produktionsmiljöer används dynamiska
inventories som uppdateras automatiskt när nya
servrar startas i molnet. Nya servrar registreras
direkt utan att någon behöver uppdatera en fil manuellt.

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

Vi byggde `security_hardening`-rollen och körde den
mot alla sex servrar. Rollen gör tre saker: den
distribuerar en härdad SSH-konfiguration, installerar
fail2ban som blockerar inloggningsattacker och
installerar auditd som loggar systemhändelser.

Vi stötte på tre problem under den här fasen. Ansible
kraschade för att rollerna för database, flask, nginx
och wazuh_agent inte existerade än. Control-servern
saknade SSH-nyckel för att nå de andra servrarna.
Windows konverterade radbrytningar på fel sätt.
Alla tre problem löste vi permanent.

Slutresultat: `ansible-playbook site.yml` kördes mot
alla sex servrar med `failed=0`. Vi körde sedan om
playbooken och fick `changed=0` på alla servrar —
bevis på att rollen är idempotent.

---

### Körda kommandon

#### PowerShell — Windows-värddatorn

```powershell
# Skapa mappstruktur för security_hardening-rollen
# Varför: Ansible letar alltid efter tasks/, handlers/
# och templates/ inuti en roll — strukturen måste stämma
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\tasks
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\handlers
PS E:\Secure-Infra-Lab> mkdir ansible\roles\security_hardening\templates
```
Förväntat output: Inga felmeddelanden.  
Vad vi fick: Mapparna skapades korrekt ✅

```powershell
# Skapa rollfilerna i VS Code
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\tasks\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\handlers\main.yml
PS E:\Secure-Infra-Lab> code ansible\roles\security_hardening\templates\sshd_config.j2
```
Förväntat output: VS Code öppnar varje fil.  
Vad vi fick: Filerna öppnades korrekt ✅

```powershell
# Skapa tomma platshållarfiler för roller som inte finns än
# Varför: Ansible validerar ALLA roller i site.yml vid uppstart
# — även roller vi inte kör just nu. Utan platshållare kraschar Ansible
PS E:\Secure-Infra-Lab> foreach ($role in @("database", "flask", "nginx", "wazuh_agent")) {
    $path = "E:\Secure-Infra-Lab\ansible\roles\$role\tasks\main.yml"
    Set-Content -Path $path -Value "---`n# Placeholder — role not yet implemented"
    Write-Host "Created: $path"
}
```
Förväntat output: `Created: E:\...\[rollnamn]\tasks\main.yml` för varje roll.  
Vad vi fick: Alla fyra platshållarfiler skapades ✅

```powershell
# Fixa radbrytningsproblem en gång för alla
# Varför: Windows använder CRLF, Linux använder LF
# Fel radbrytningar kan göra att Bash-skript och
# YAML-filer inte fungerar på Linux-servrarna
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
Vad vi fick: Exakt det förväntade — inga fler CRLF-varningar ✅

```powershell
# Hämta controls publika nyckel och spara i en variabel
# Varför: Vi behöver nyckeln för att kopiera den
# till alla andra servrar
PS E:\Secure-Infra-Lab\vagrant> $pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"
```
Förväntat output: Ingen synlig output — nyckeln sparas i variabeln.  
Vad vi fick: Nyckeln hämtades korrekt ✅

```powershell
# Kopiera controls publika nyckel till alla andra servrar
# Varför: Ansible SSH:ar från control till alla servrar
# Utan nyckeln i authorized_keys nekas åtkomst
PS E:\Secure-Infra-Lab\vagrant> foreach ($vm in @("nginx", "web1", "web2", "database", "monitor")) {
    $port = (vagrant ssh-config $vm | Select-String "Port").ToString().Trim().Split(" ")[1]
    $keyfile = (vagrant ssh-config $vm | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
    echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
}
```
Förväntat output: `Warning: Permanently added '[127.0.0.1]:XXXX'` för varje server.  
Vad vi fick: nginx, web1, web2, database lyckades ✅  
Fel vi fick på monitor: `kex_exchange_identification: read: Connection reset`  
Orsak: Monitor hade precis startats om och SSH var inte redo än.  
Lösning: Körde `vagrant reload monitor` och försökte igen — lyckades ✅

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
# i /home/vagrant/ansible/roles/
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
# -N "": inget lösenord på nyckeln — krävs för automation
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
-rw------- id_rsa      (privat nyckel — stannar här)
-rw-r--r-- id_rsa.pub  (publik nyckel — kopieras till andra servrar)
```
Vad vi fick: Exakt det förväntade ✅

```bash
# Gå till ansible-mappen och kör playbooken mot bara control
# Varför: Säkrare att testa mot en server innan vi
# kör mot alla sex
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
Orsak: Monitor hade precis startats om och var inte helt redo.  
Lösning: Körde playbooken igen mot bara monitor:
```bash
vagrant@control:~/ansible$ ansible-playbook site.yml --limit monitor
```
Resultat: `ok=8  changed=4  failed=0` ✅

```bash
# Verifiera idempotens — kör playbooken en gång till
# Förväntat: changed=0 på alla servrar eftersom
# allt redan är konfigurerat
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
Control visade `changed=1` — det är apt cache-uppdateringen
som alltid räknas som changed. Alla andra visade
`changed=0` — idempotens bekräftad ✅

---

### Konfigurationsfiler

📄 `ansible/roles/security_hardening/tasks/main.yml`  
**Vad den gör:** Listan över allt som ska göras —
uppdatera paketcachen, installera fail2ban och auditd,
distribuera SSH-konfigurationen och starta tjänsterna.  
**Varför den finns:** Det är ingångspunkten för rollen.
Ansible letar alltid efter `tasks/main.yml` när en
roll körs.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_reuse_roles.html

📄 `ansible/roles/security_hardening/handlers/main.yml`  
**Vad den gör:** Definierar `Restart sshd` — en åtgärd
som bara körs om SSH-konfigurationen faktiskt ändrades.  
**Varför den finns:** Om SSH-konfigurationen inte ändrats
ska SSH inte startas om. Onödiga omstarter av SSH
bryter aktiva sessioner.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/handlers/main.yml  
**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_handlers.html

📄 `ansible/roles/security_hardening/templates/sshd_config.j2`  
**Vad den gör:** Mall för SSH-serverkonfigurationen.
Stänger av root-inloggning och lösenordsinloggning.
Begränsar inloggningsförsök till tre. Tillåter bara
användaren `vagrant`.  
**Varför den finns:** Standardkonfigurationen för SSH
tillåter lösenordsinloggning vilket gör servern sårbar
för automatiserade inloggningsattacker.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2  
**Officiell dokumentation:** https://man.openbsd.org/sshd_config

📄 `.gitattributes`  
**Vad den gör:** Talar om för Git att alltid använda
LF-radbrytningar för alla filer — oavsett om man
jobbar på Windows eller Linux.  
**Varför den finns:** Windows använder CRLF och Linux
använder LF. Utan den här filen konverterar Git på
Windows alla filer till CRLF vilket kan göra att
Bash-skript och YAML-filer inte fungerar på Linux.  
**Se filen:** https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/.gitattributes  
**Officiell dokumentation:** https://git-scm.com/docs/gitattributes

---

### Problem och lösningar

**Problem 1 — Ansible kraschade för att roller saknades**  
**Felmeddelande:** `the role 'database' was not found in /home/vagrant/ansible/roles`  
**Vad som hände:** Ansible kontrollerar alla roller som
nämns i site.yml när den startar — även roller som inte
körs just nu. database, flask, nginx och wazuh_agent
fanns inte än.  
**Lösning:** Vi skapade tomma platshållarfiler för varje
roll. De innehåller bara en kommentar och gör ingenting.
De ersätts med riktig kod när vi kommer till respektive fas.

**Problem 2 — Control saknade SSH-nyckel**  
**Felmeddelande:** `/home/vagrant/.ssh/id_rsa: No such file or directory` och `Permission denied (publickey)`  
**Vad som hände:** Vagrant skapar SSH-nycklar för att
du ska kunna logga in i VMs från Windows. Men dessa
nycklar delas inte automatiskt mellan VMs. Control
saknade ett eget nyckelpar.  
**Lösning:** Vi genererade ett nytt ED25519-nyckelpar
på control med `ssh-keygen`. Sedan kopierade vi den
publika nyckeln till `authorized_keys` på varje server
via Vagrants egna nycklar från Windows-sidan.

**Problem 3 — Monitor nekade SSH-anslutning**  
**Felmeddelande:** `kex_exchange_identification: read: Connection reset`  
**Vad som hände:** Monitor hade precis startats om och
SSH-tjänsten var inte redo än. Monitor har 2048 MB RAM
och behöver längre tid för att starta.  
**Lösning:** `vagrant reload monitor` följt av ett nytt
försök efter att servern var helt uppe.

**Problem 4 — Fel radbrytningar (CRLF/LF)**  
**Felmeddelande:** `warning: LF will be replaced by CRLF`  
**Vad som hände:** Git på Windows konverterade alla filer
till CRLF automatiskt. Det kan göra att Bash-skript och
YAML-filer inte fungerar på Linux-servrar.  
**Lösning:** Vi skapade `.gitattributes` med regeln
`* text=auto eol=lf` och normaliserade alla befintliga
filer med:
```powershell
PS E:\Secure-Infra-Lab> git rm --cached -r .
PS E:\Secure-Infra-Lab> git reset --hard
```

---

### Teorikoppling

**Koncept 1: SSH-nyckelautentisering**

SSH-nycklar fungerar som ett digitalt lås och nyckel.
Den publika nyckeln är låset — den läggs på servern.
Den privata nyckeln är nyckeln — den stannar hos den
som ska logga in. Inget lösenord skickas över nätverket.

I det här projektet har control-servern den privata
nyckeln. Vi kopierade den publika nyckeln till alla
andra servrar. Nu kan Ansible logga in automatiskt
utan lösenord — och lösenordsinloggning är helt
avstängd via `sshd_config.j2`.

I stora produktionsmiljöer hanteras SSH-nycklar via
centraliserade system som HashiCorp Vault. Nycklarna
byts ut automatiskt med jämna mellanrum.

**Officiell dokumentation:** https://www.openssh.com/manual.html

**Koncept 2: Idempotens**

Idempotens betyder att du kan göra samma sak hur
många gånger du vill utan att resultatet förändras.
Tänk på en ljusknapp — trycker du på "tänd" när
lampan redan är tänd händer ingenting.

Ansible fungerar likadant. Innan varje åtgärd
kontrollerar Ansible om det redan är gjort. Är det
redan gjort hoppar Ansible över det — `changed=0`.

Det här är viktigt i produktion. Man kan köra
playbooken varje natt för att säkerställa att alla
servrar är korrekt konfigurerade. Om någon ändrat
något manuellt återställs det automatiskt.

**Officiell dokumentation:** https://docs.ansible.com/ansible/latest/reference_appendices/glossary.html

**Koncept 3: Defense-in-Depth**

Defense-in-Depth betyder att man skyddar ett system
på flera oberoende sätt. Om ett skydd kringgås finns
nästa skydd kvar.

Vi stänger av lösenordsinloggning — SSH-nycklar krävs.
fail2ban blockerar IP-adresser som försöker logga in
för många gånger. auditd loggar allt som händer.
Wazuh samlar loggarna centralt och varnar om något
misstänkt sker.

En angripare som lyckas ta sig förbi ett lager möter
direkt nästa.

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