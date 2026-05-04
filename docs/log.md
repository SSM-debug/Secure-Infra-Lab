# Projektlogg — Secure-Infra-Lab

---

## Fas 1 — Vagrantfile och VM-uppstart
**Datum:** 2026-05-02
**Git-commits:**
- `Initial structure: Vagrantfile for 6 VMs`
- `Add .gitignore and fix control provisioner: install Ansible via pip instead of apt`

### Vad vi gjorde
Skapade projektmappen lokalt på Windows och initierade Git-repo.
Byggde mappstrukturen för hela projektet i ett kommando.
Skrev Vagrantfilen för 6 VMs med rätt IP-adresser, RAM och CPU.
Skapade GitHub-repo, kopplade det lokala repot och pushade.
Upptäckte att Ansible 2.10.8 från apt är för gammal — fixade
provisioner-skriptet så att pip3 installerar senaste versionen.
Skapade .gitignore så att Vagrants interna filer och secrets
aldrig pushas till GitHub.
Startade alla 6 VMs en i taget och verifierade att alla kör.

### Kommandon vi körde

```powershell
# Create project folder
mkdir E:\Secure-Infra-Lab
cd E:\Secure-Infra-Lab

# Initialize Git
git init

# Create full folder structure in one command
mkdir vagrant, ansible\roles\security_hardening, ansible\roles\flask, `
      ansible\roles\nginx, ansible\roles\database, `
      ansible\roles\wazuh_agent, ansible\vars, docs

# Create and edit Vagrantfile in VS Code
code E:\Secure-Infra-Lab\vagrant\Vagrantfile

# First commit
git add .
git commit -m "Initial structure: Vagrantfile for 6 VMs"

# Connect to GitHub and push
git remote add origin https://github.com/SSM-debug/Secure-Infra-Lab.git
git push -u origin main

# After fixing provisioner — reload control VM
cd E:\Secure-Infra-Lab\vagrant
vagrant reload --provision control

# Start remaining VMs one by one
vagrant up nginx
vagrant up web1
vagrant up web2
vagrant up database
vagrant up monitor

# Verify all 6 VMs are running
vagrant status
```

### Fel som dök upp

**Fel 1 — Ansible för gammal**
**Fel:** `ansible 2.10.8`
**Orsak:** Ubuntu apt har föråldrad Ansible-version
**Lösning:** Ändrade control-provisioner i Vagrantfilen —
installerar nu via `pip3 install ansible` istället för apt

**Fel 2 — Vagrant interna filer spårades av Git**
**Fel:** `vagrant/.vagrant/` med SSH-nycklar på väg till GitHub
**Orsak:** Ingen .gitignore fanns i projektet
**Lösning:** Skapade .gitignore, körde:
`git rm -r --cached vagrant/.vagrant/`

**Fel 3 — Felstavat kommando**
**Fel:** `vagrant reload ..provision control`
**Orsak:** Dubbla punkter istället för dubbla bindestreck
**Lösning:** `vagrant reload --provision control`

### Teorikoppling

**Koncept:** Infrastructure-as-Code (IaC)
**Enkelt:** Istället för att klicka ihop VMs manuellt i VirtualBox
skriver vi kod som beskriver exakt hur miljön ska se ut.
Kör vi koden igen får vi identiskt samma resultat — varje gång.
Det kallas idempotens.
**Vårt projekt:** Vagrantfilen definierar alla 6 VMs med IP-adresser,
RAM, CPU och provisionering. Ett enda `vagrant up` bygger hela
infrastrukturen från noll automatiskt.
**Verkligheten:** Samma princip används i produktion med Terraform
och Azure/AWS — ett team kan skapa identiska miljöer i molnet
utan ett enda manuellt steg. Om en server kraschar ersätts den
automatiskt med en identisk kopia.



---

## Fas 2 — Ansible-konfiguration
**Datum:** 2026-05-02
**Git-commit:** `Add Ansible config: ansible.cfg, inventory.ini, site.yml`

### Vad vi gjorde
Skapade de tre kärnfilerna för Ansible-konfigurationen.
ansible.cfg talar om för Ansible var inventory-filen finns och
hur den ska bete sig. inventory.ini listar alla 6 servrar med
IP-adresser och hur Ansible når dem via SSH. site.yml är
master-playbooken som bestämmer vad som installeras på vilken
server och i vilken ordning — database först, sedan web1 och
web2, sedan nginx och monitor sist.

### Kommandon vi körde

```powershell
# Create and edit ansible.cfg
code E:\Secure-Infra-Lab\ansible\ansible.cfg

# Create and edit inventory.ini
code E:\Secure-Infra-Lab\ansible\inventory.ini

# Create and edit site.yml
code E:\Secure-Infra-Lab\ansible\site.yml

# Stage all three files
git add ansible/ansible.cfg ansible/inventory.ini ansible/site.yml

# Commit and push
git commit -m "Add Ansible config: ansible.cfg, inventory.ini, site.yml"
git push
```

### Fel som dök upp
Inga fel uppstod i denna fas.

### Teorikoppling

**Koncept:** Inventory och idempotens i Ansible
**Enkelt:** Inventory-filen är Ansibles telefonbok — den listar
alla servrar med adress och inloggningsuppgifter. Utan den vet
Ansible inte att servrarna existerar. site.yml är receptet —
den beskriver exakt vad som ska installeras och i vilken ordning.
Kör man playbooken igen händer ingenting om allt redan är rätt
konfigurerat. Det kallas idempotens.
**Vårt projekt:** inventory.ini listar alla 6 VMs med rätt
IP-adresser från Vagrantfilen. Control-VM använder
ansible_connection=local eftersom den kör Ansible på sig själv
— ingen SSH behövs. Alla andra VMs nås via SSH med Vagrants
automatgenererade privata nyckel.
**Verkligheten:** I produktion hos ett företag kan inventory-filen
lista hundratals servrar fördelade på flera datacenter. Ansible
kan då köra samma playbook mot alla servrar samtidigt —
exempelvis installera en säkerhetsuppdatering på hela flottan
på några minuter istället för att logga in på varje server
manuellt.



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
Skapade security_hardening-rollen med tre filer: tasks/main.yml,
handlers/main.yml och templates/sshd_config.j2. Rollen installerar
fail2ban och auditd, distribuerar en härdad SSH-konfiguration och
startar säkerhetstjänsterna. Vi skapade också vars/vars.yml med
delade nätverksvariabler och secrets.yml med databasuppgifter.

Vi löste tre större problem under fasen:
1. Platshållarroller saknades för database, flask, nginx, wazuh_agent
2. SSH-nycklar saknades på control-VM för att nå andra VMs
3. Windows CRLF-radbrytningar fixades med .gitattributes

Till slut körde vi ansible-playbook site.yml framgångsrikt mot
alla 6 VMs med failed=0 och bekräftade idempotens på andra körningen.

### Kommandon vi körde

**PowerShell — skapa rollstruktur:**
```powershell
# Create folder structure for security_hardening role
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\tasks
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\handlers
mkdir E:\Secure-Infra-Lab\ansible\roles\security_hardening\templates

# Create role files in VS Code
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\tasks\main.yml
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\handlers\main.yml
code E:\Secure-Infra-Lab\ansible\roles\security_hardening\templates\sshd_config.j2

# Create vars and secrets files
code E:\Secure-Infra-Lab\ansible\vars\vars.yml
code E:\Secure-Infra-Lab\vagrant\secrets.yml

# Create placeholder roles so Ansible does not crash
foreach ($role in @("database", "flask", "nginx", "wazuh_agent")) {
    $path = "E:\Secure-Infra-Lab\ansible\roles\$role\tasks\main.yml"
    Set-Content -Path $path -Value "---`n# Placeholder — role not yet implemented"
}

# Fix LF line endings
git config core.autocrlf false
git config core.eol lf
code E:\Secure-Infra-Lab\.gitattributes

# Normalize all existing files to LF
git rm --cached -r .
git reset --hard
git add .
git commit -m "Normalize line endings to LF across all files"
git push

# Generate SSH key on control-VM and copy to all other VMs
$pubkey = vagrant ssh control -c "cat /home/vagrant/.ssh/id_rsa.pub"

foreach ($vm in @("nginx", "web1", "web2", "database", "monitor")) {
    $port = (vagrant ssh-config $vm | Select-String "Port").ToString().Trim().Split(" ")[1]
    $keyfile = (vagrant ssh-config $vm | Select-String "IdentityFile").ToString().Trim().Split(" ")[1]
    echo $pubkey | ssh -i $keyfile -p $port -o StrictHostKeyChecking=no vagrant@127.0.0.1 "cat >> /home/vagrant/.ssh/authorized_keys"
}
```

**Bash — inuti control-VM:**
```bash
# Generate SSH key pair on control
ssh-keygen -t ed25519 -f /home/vagrant/.ssh/id_rsa -N ""

# Verify key was created
ls -la /home/vagrant/.ssh/

# Create placeholder role files inside control-VM
for role in database flask nginx wazuh_agent; do
    mkdir -p /home/vagrant/ansible/roles/$role/tasks
    echo -e "---\n# Placeholder — role not yet implemented" \
    > /home/vagrant/ansible/roles/$role/tasks/main.yml
done

# Verify all role files exist
find /home/vagrant/ansible/roles -name "main.yml"

# Create all Ansible files inside control-VM
cat > /home/vagrant/ansible/ansible.cfg << 'EOF'
[defaults]
inventory = /home/vagrant/ansible/inventory.ini
host_key_checking = False
allow_world_readable_tmpfiles = True
EOF

cat > /home/vagrant/ansible/inventory.ini << 'EOF'
[control]
control ansible_host=192.168.56.10 ansible_connection=local
[nginx]
nginx ansible_host=192.168.56.11 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa
[webserver]
web1 ansible_host=192.168.56.12 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa
[webserver2]
web2 ansible_host=192.168.56.13 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa
[database]
database ansible_host=192.168.56.14 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa
[monitor]
monitor ansible_host=192.168.56.15 ansible_user=vagrant ansible_private_key_file=/home/vagrant/.ssh/id_rsa
[all:children]
control
nginx
webserver
webserver2
database
monitor
EOF

# Run playbook on control only first
cd /home/vagrant/ansible
ansible-playbook site.yml --limit control

# Run playbook on all VMs
ansible-playbook site.yml

# Verify idempotens — run again, expect changed=0
ansible-playbook site.yml
```

### Fel som dök upp

**Fel 1 — Roller saknades**
**Fel:** `the role 'database' was not found`
**Orsak:** site.yml refererar alla roller direkt. Ansible
kraschar om en roll inte finns — även om vi bara kör
--limit control. Det spelar ingen roll att vi inte kör
database-playet just nu, Ansible validerar alla roller
vid uppstart.
**Lösning:** Skapade tomma platshållarfiler för database,
flask, nginx och wazuh_agent med innehållet
`--- # Placeholder — role not yet implemented`

**Fel 2 — SSH-nycklar saknades**
**Fel:** `/home/vagrant/.ssh/id_rsa: No such file or directory`
och `Permission denied (publickey)`
**Orsak:** Control-VM hade ingen SSH-nyckel att autentisera
med mot de andra VMs. Vagrant genererar separata nycklar
för varje VM men delar dem inte automatiskt med control.
**Lösning:** Genererade ett nytt SSH-nyckelpar på control
med `ssh-keygen`. Kopierade den publika nyckeln till
authorized_keys på varje VM via Vagrants egna privata
nycklar från Windows-värden.

**Fel 3 — Monitor SSH-anslutning nekad**
**Fel:** `kex_exchange_identification: read: Connection reset`
**Orsak:** Monitor-VM hade precis startats om och SSH-tjänsten
var inte redo ännu. Monitor har 2048 MB RAM och tar längre
tid att starta än övriga VMs.
**Lösning:** Väntade och försökte igen efter att monitor
hade startat om helt med `vagrant reload monitor`.

**Fel 4 — Windows CRLF radbrytningar**
**Fel:** `warning: LF will be replaced by CRLF`
**Orsak:** Windows använder CRLF (\r\n) som radbrytning
medan Linux använder LF (\n). Git på Windows konverterade
automatiskt alla filer till CRLF vilket kan orsaka fel
i Bash-skript och Ansible-filer på Linux-VMs.
**Lösning:** Skapade .gitattributes som tvingar LF för
alla filer. Normaliserade alla befintliga filer med
`git rm --cached -r . && git reset --hard && git add .`

### Teorikoppling

**Koncept 1:** SSH-nyckelautentisering
**Enkelt:** SSH-nycklar fungerar som ett lås och en nyckel.
Den publika nyckeln är låset — den läggs på servern i
authorized_keys. Den privata nyckeln är nyckeln — den
stannar på control-VM och lämnar aldrig den maskinen.
När Ansible SSH:ar till en server visar den sin privata
nyckel. Servern jämför med sitt lås (authorized_keys).
Matchar de — åtkomst beviljas utan lösenord.
**Vårt projekt:** Control-VM genererade ett nyckelpar med
ssh-keygen. Vi kopierade den publika nyckeln till
authorized_keys på nginx, web1, web2, database och monitor.
Nu kan Ansible SSH:a till alla VMs automatiskt.
**Verkligheten:** Alla professionella servermiljöer använder
SSH-nyckelautentisering. Lösenordsinloggning är avstängt
— precis som vi gjort med PasswordAuthentication no i
vår sshd_config.j2. GitHub, AWS och Azure fungerar alla
på samma sätt.

**Koncept 2:** Idempotens
**Enkelt:** Idempotens betyder att samma operation kan köras
hur många gånger som helst med samma resultat. Första
gången Ansible kör installeras allt — changed=5. Andra
gången ser Ansible att allt redan är rätt konfigurerat
och ändrar ingenting — changed=0.
**Vårt projekt:** Vi körde ansible-playbook site.yml två
gånger. Första körningen: changed=5 på de flesta VMs.
Andra körningen: changed=0 på alla VMs utom control som
hade changed=1 för apt cache-uppdatering. Det bekräftar
att rollen är idempotent.
**Verkligheten:** Utan idempotens skulle varje Ansible-körning
i produktion riskera att förstöra konfigurationer eller
starta om tjänster i onödan. Med idempotens kan man köra
playbooken dagligen för att säkerställa att servrar
alltid har rätt konfiguration — även om någon ändrat
något manuellt.

**Koncept 3:** Defense-in-Depth via SSH-härdning
**Enkelt:** SSH-härdning är som att byta ut ett enkelt
dörrlås mot ett modernt säkerhetslås med larmfunktion.
Standardkonfigurationen tillåter lösenordsinloggning
vilket är sårbart för brute-force-attacker. Vår härdade
konfiguration stänger av lösenordsinloggning helt,
begränsar inloggningsförsök och tillåter bara en
specifik användare.
**Vårt projekt:** sshd_config.j2 sätter PermitRootLogin no,
PasswordAuthentication no, MaxAuthTries 3 och
AllowUsers vagrant på alla 6 VMs. fail2ban blockerar
automatiskt IP-adresser som försöker logga in för många
gånger. auditd loggar alla inloggningar och
systemhändelser för forensisk analys.
**Verkligheten:** Servrar som är exponerade mot internet
utsätts för tusentals inloggningsförsök per dag från
automatiserade bots. En server utan SSH-härdning och
fail2ban kan komprometteras inom minuter om ett svagt
lösenord används. Med vår konfiguration är
lösenordsattacker omöjliga — bara SSH-nycklar fungerar.