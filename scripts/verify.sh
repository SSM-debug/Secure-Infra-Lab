#!/bin/bash
# Secure-Infra-Lab — Verification Script
# Run from control-VM: bash /home/vagrant/verify.sh

PASS=0
FAIL=0

check() {
    local desc=$1
    local result=$2
    local expected=$3
    if echo "$result" | grep -q "$expected"; then
        echo "PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $desc (got: $result)"
        FAIL=$((FAIL + 1))
    fi
}

echo "=============================="
echo " Secure-Infra-Lab Verify"
echo "=============================="

# Test 1 — nginx svarar
check "nginx HTTP 200" "$(curl -s -o /dev/null -w '%{http_code}' http://192.168.56.11/)" "200"

# Test 2 — Round-robin Server 1
check "Round-robin Server 1" "$(curl -s http://192.168.56.11/)" "Server 1"

# Test 3 — Round-robin Server 2
check "Round-robin Server 2" "$(curl -s http://192.168.56.11/)" "Server 2"

# Test 4 — web1 når database
check "web1 reaches database:5432" "$(ssh -o StrictHostKeyChecking=no vagrant@192.168.56.12 'nc -zv 192.168.56.14 5432 2>&1')" "succeeded"

# Test 5 — extern når EJ database
check "External blocked from database:5432" "$(nc -zv 192.168.56.14 5432 2>&1)" "refused\|timed out\|filtered"

# Test 6 — Flask web1
check "Flask active on web1" "$(ssh -o StrictHostKeyChecking=no vagrant@192.168.56.12 'systemctl is-active flask')" "active"

# Test 7 — Flask web2
check "Flask active on web2" "$(ssh -o StrictHostKeyChecking=no vagrant@192.168.56.13 'systemctl is-active flask')" "active"

# Test 8 — fail2ban alla VMs
for ip in 192.168.56.10 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.14 192.168.56.15; do
    check "fail2ban active on $ip" "$(ssh -o StrictHostKeyChecking=no vagrant@$ip 'systemctl is-active fail2ban')" "active"
done

# Test 9 — auditd alla VMs
for ip in 192.168.56.10 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.14 192.168.56.15; do
    check "auditd active on $ip" "$(ssh -o StrictHostKeyChecking=no vagrant@$ip 'systemctl is-active auditd')" "active"
done

# Test 10 — PasswordAuthentication no
for ip in 192.168.56.10 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.14 192.168.56.15; do
    check "PasswordAuth disabled on $ip" "$(ssh -o StrictHostKeyChecking=no vagrant@$ip 'sudo sshd -T | grep passwordauthentication')" "no"
done

# Test 11 — PermitRootLogin no
for ip in 192.168.56.10 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.14 192.168.56.15; do
    check "PermitRootLogin disabled on $ip" "$(ssh -o StrictHostKeyChecking=no vagrant@$ip 'sudo sshd -T | grep permitrootlogin')" "no"
done

# Test 12 — wazuh-agent alla VMs (utom monitor)
for ip in 192.168.56.10 192.168.56.11 192.168.56.12 192.168.56.13 192.168.56.14; do
    check "wazuh-agent active on $ip" "$(ssh -o StrictHostKeyChecking=no vagrant@$ip 'systemctl is-active wazuh-agent')" "active"
done

# Test 13 — wazuh-manager på monitor
check "wazuh-manager active on monitor" "$(ssh -o StrictHostKeyChecking=no vagrant@192.168.56.15 'systemctl is-active wazuh-manager')" "active"

# Test 14 — Cockpit på monitor
check "Cockpit responding on port 9090" "$(curl -sk -o /dev/null -w '%{http_code}' https://192.168.56.15:9090/)" "200"

echo "=============================="
echo " Results: PASS=$PASS FAIL=$FAIL"
echo "=============================="