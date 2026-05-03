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
