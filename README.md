# Secure-Infra-Lab

En automatiserad infrastruktur med sex virtuella servrar som sätts upp helt automatiskt med ett enda kommando. Systemet implementerar Infrastructure-as-Code, Defense-in-Depth och fullständig reproducerbarhet - från tom hårdvara till ett fungerande system med lastbalansering, databas och SIEM-övervakning.

**GitHub:** https://github.com/SSM-debug/Secure-Infra-Lab

---

## Innehållsförteckning

- [Arkitektur](#arkitektur)
- [Miljöer och IP-adresser](#miljöer-och-ip-adresser)
- [Mappstruktur](#mappstruktur)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Secrets](#secrets)
- [Ansible-roller](#ansible-roller)
- [Säkerhetsåtgärder](#säkerhetsåtgärder)
- [STRIDE-analys och hotmodellering](#stride-analys-och-hotmodellering)
- [Verifiering och testresultat](#verifiering-och-testresultat)
- [Produktion och skalbarhet](#produktion-och-skalbarhet)
- [Designval och motivering](#designval-och-motivering)
- [Tekniska begränsningar och framtida förbättringar](#tekniska-begränsningar-och-framtida-förbättringar)

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
|  |  Runs playbooks against all servers via SSH       |  |
|  +-------------------+--------------------------------+  |
|                      | SSH (Ansible)                    |
|          +-----------+-----------+                      |
|          v           v           v                      |
|  +------------+ +----------+ +----------+              |
|  | nginx (.11)|  |web1 (.12)| |web2 (.13)|              |
|  | 512 MB     |  | 512 MB   | | 512 MB   |              |
|  | Port 8080  |  | Flask +  | | Flask +  |              |
|  | Load       |  | Gunicorn | | Gunicorn |              |
|  | Balancer   |  | Server 1 | | Server 2 |              |
|  +-----+------+ +----+-----+ +----+-----+              |
|        |              |            |                     |
|        | round-robin  |            |                     |
|        +--------------+------------+                     |
|                       | port 5432                        |
|                       | UFW: web1 and web2 only          |
|                       v                                  |
|  +----------------------------------------------------+  |
|  |  database (.14) - 512 MB                          |  |
|  |  PostgreSQL                                       |  |
|  |  UFW blocks all except web1 and web2              |  |
|  +----------------------------------------------------+  |
|                                                          |
|  +----------------------------------------------------+  |
|  |  monitor (.15) - 2048 MB                          |  |
|  |  Wazuh Manager + Cockpit (port 9090)              |  |
|  |  Receives security events from all agents         |  |
|  +----------------------------------------------------+  |
|        ^           ^           ^          ^          ^   |
|        | Wazuh agent (all servers except monitor)       |
+----------------------------------------------------------+
```

### 3-tier-arkitektur

**Lager 1 - nginx (.11)** tar emot all inkommande
trafik via port 8080. Det är den enda servern som
är nåbar utifrån. Alla förfrågningar distribueras
automatiskt mellan web1 och web2 via round-robin.

**Lager 2 - web1 (.12) och web2 (.13)** kör
Flask-applikationen via Gunicorn. Båda servrarna
kör identisk kod men identifierar sig som
"Server 1" respektive "Server 2". nginx kommunicerar
med Flask över HTTPS - trafiken mellan lastbalanseraren
och webbservrarna är krypterad med TLS. Om en server
slutar svara tar den andra över automatiskt via
passive health checks.

**Lager 3 - database (.14)** kör PostgreSQL och
är helt isolerad från omvärlden. Bara web1 och
web2 kan ansluta på port 5432 - begränsat av
både UFW och pg_hba.conf.

**monitor (.15)** deltar inte i trafikflödet.
Den övervakar säkerhetshändelser från alla fem
övriga servrar via Wazuh-agenter och ger
systemöverblick via Cockpit på port 9090.

> Fullständig arkitekturbeskrivning finns i
> [docs/projektplan.md - Avsnitt 3](docs/projektplan.md).

### draw.io-diagram

Öppna [docs/architecture.drawio](docs/architecture.drawio)
på https://diagrams.net för ett visuellt
arkitekturdiagram. File > Export as > PNG för
att spara som bild.

<details>
<summary>Visa draw.io XML</summary>

```xml

<mxfile host="app.diagrams.net">
  <diagram name="Secure-Infra-Lab" id="0">
    <mxGraphModel dx="1885" dy="1084" grid="0" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="0" pageScale="1" pageWidth="1700" pageHeight="1200" math="0" shadow="0">
      <root>
        <mxCell id="0" />
        <mxCell id="1" parent="0" />
        <mxCell id="host" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#dae8fc;strokeColor=#6c8ebf;strokeWidth=2;           fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;Windows 11 (host)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;:8080 nginx  |  :9090 Cockpit" vertex="1">
          <mxGeometry height="70" width="249" x="615" y="40" as="geometry" />
        </mxCell>
        <mxCell id="net" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=none;strokeColor=#aaaaaa;strokeWidth=2;           dashed=1;fontSize=13;           verticalAlign=top;spacingTop=12;           fontColor=#666666;" value="&lt;font style=&quot;font-size: 13px;&quot;&gt;&lt;b&gt;Private network — 192.168.56.0/24&lt;/b&gt;&lt;/font&gt;" vertex="1">
          <mxGeometry height="760" width="1460" x="100" y="160" as="geometry" />
        </mxCell>
        <mxCell id="control" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#006EAF;strokeColor=#004d80;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;control (.10)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Ansible control node&lt;br&gt;192.168.56.10 | 1024 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="230" as="geometry" />
        </mxCell>
        <mxCell id="nginx" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#00897B;strokeColor=#004D40;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;nginx (.11)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Load balancer&lt;br&gt;192.168.56.11 | Port 8080 | 512 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="420" as="geometry" />
        </mxCell>
        <mxCell id="web1" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;web1 (.12)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Flask + Gunicorn | Server 1&lt;br&gt;192.168.56.12 | 512 MB" vertex="1">
          <mxGeometry height="80" width="220" x="200" y="610" as="geometry" />
        </mxCell>
        <mxCell id="web2" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;web2 (.13)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Flask + Gunicorn | Server 2&lt;br&gt;192.168.56.13 | 512 MB" vertex="1">
          <mxGeometry height="80" width="220" x="1060" y="610" as="geometry" />
        </mxCell>
        <mxCell id="database" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#00BCD4;strokeColor=#006EAF;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;database (.14)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;PostgreSQL + UFW&lt;br&gt;192.168.56.14 | 512 MB" vertex="1">
          <mxGeometry height="80" width="220" x="630" y="800" as="geometry" />
        </mxCell>
        <mxCell id="monitor" parent="1" style="rounded=1;whiteSpace=wrap;html=1;           fillColor=#4527A0;strokeColor=#1A0073;strokeWidth=2;           fontColor=#ffffff;fontSize=12;align=center;" value="&lt;font style=&quot;font-size: 14px;&quot;&gt;&lt;b&gt;monitor (.15)&lt;/b&gt;&lt;/font&gt;&lt;br&gt;Wazuh Manager + Cockpit&lt;br&gt;192.168.56.15 | Port 9090 | 2048 MB" vertex="1">
          <mxGeometry height="80" width="220" x="1060" y="800" as="geometry" />
        </mxCell>
        <mxCell id="p_host_nginx" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#6c8ebf;strokeWidth=2.5;           fontStyle=1;fontSize=12;           exitX=0.5;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#FF870F;" value=":8080">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="742" y="314" as="sourcePoint" />
            <mxPoint x="742.0666666666666" y="417" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="p_host_mon" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#6c8ebf;strokeWidth=2;           dashed=1;fontStyle=1;fontSize=12;           exitX=1;exitY=0.5;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#FF9EA7;dashed=1;" value=":9090">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1503" y="75" />
              <mxPoint x="1503" y="750" />
              <mxPoint x="1183" y="750" />
            </Array>
            <mxPoint x="863" y="75" as="sourcePoint" />
            <mxPoint x="1183.066666666667" y="800" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="p_host_ctrl" edge="1" parent="1" source="host" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#6c8ebf;strokeWidth=2.5;           exitX=0.5;exitY=1;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#FF9A16;" target="control" value="">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="ssh_web1" edge="1" parent="1" source="control" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#9E9E9E;strokeWidth=1.5;           dashed=1;fontStyle=0;fontSize=11;           exitX=0;exitY=0.5;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#57FF44;dashed=1;" target="web1" value="SSH">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="500" y="270" />
              <mxPoint x="310" y="270" />
              <mxPoint x="310" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="ssh_web2" edge="1" parent="1" source="control" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#9E9E9E;strokeWidth=1.5;           dashed=1;fontStyle=0;fontSize=11;           exitX=1;exitY=0.5;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#58FF4C;dashed=1;" target="web2" value="SSH">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="980" y="270" />
              <mxPoint x="1170" y="270" />
              <mxPoint x="1170" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="ssh_db" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#9E9E9E;strokeWidth=1.5;           dashed=1;fontStyle=0;fontSize=11;           exitX=0;exitY=1;exitDx=0;exitDy=0;           entryX=0;entryY=0;entryDx=0;entryDy=0;strokeColor=#6AFF44;dashed=1;" value="SSH">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="545" y="381" />
              <mxPoint x="545" y="801" />
            </Array>
            <mxPoint x="725.0666666666666" y="311" as="sourcePoint" />
            <mxPoint x="615" y="801.0666666666666" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="ssh_mon" edge="1" parent="1" source="control" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#9E9E9E;strokeWidth=1.5;           dashed=1;fontStyle=0;fontSize=11;           exitX=1;exitY=1;exitDx=0;exitDy=0;           entryX=0;entryY=0;entryDx=0;entryDy=0;strokeColor=#55FF42;dashed=1;" target="monitor" value="SSH">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="920" y="380" />
              <mxPoint x="1010" y="380" />
              <mxPoint x="1010" y="800" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="rr_web1" edge="1" parent="1" source="nginx" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#00897B;strokeWidth=2.5;           fontStyle=1;fontSize=12;           exitX=0;exitY=1;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#3019FF;" target="web1" value="round-robin | HTTPS">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="500" y="560" />
              <mxPoint x="310" y="560" />
              <mxPoint x="310" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="rr_web2" edge="1" parent="1" source="nginx" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#00897B;strokeWidth=2.5;           fontStyle=1;fontSize=12;           exitX=1;exitY=1;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;strokeColor=#2D1EFF;" target="web2" value="round-robin | HTTPS">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="980" y="560" />
              <mxPoint x="1170" y="560" />
              <mxPoint x="1170" y="610" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="db_web1" edge="1" parent="1" source="web1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#1565C0;strokeWidth=2;           fontStyle=0;fontSize=11;           exitX=0.5;exitY=1;exitDx=0;exitDy=0;           entryX=0;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#38F8FF;" target="database" value="port 5432">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="310" y="760" />
              <mxPoint x="630" y="760" />
            </Array>
          </mxGeometry>
        </mxCell>
        <mxCell id="db_web2" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#1565C0;strokeWidth=2;           fontStyle=0;fontSize=11;           exitX=0.5;exitY=1;exitDx=0;exitDy=0;           entryX=1;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#38F1FF;" value="port 5432">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1146" y="760" />
              <mxPoint x="826" y="760" />
            </Array>
            <mxPoint x="1146.066666666667" y="690" as="sourcePoint" />
            <mxPoint x="826" y="800" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="w_ctrl" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#C62828;strokeWidth=1.5;           dashed=1;           exitX=1;exitY=0;exitDx=0;exitDy=0;           entryX=0;entryY=0.2;entryDx=0;entryDy=0;strokeColor=#FF9BA2;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1369" y="237" />
              <mxPoint x="1369" y="827" />
              <mxPoint x="1269" y="827" />
            </Array>
            <mxPoint x="839" y="237.0666666666666" as="sourcePoint" />
            <mxPoint x="1269" y="827.0666666666666" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="w_nginx" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#C62828;strokeWidth=1.5;           dashed=1;           exitX=1;exitY=0;exitDx=0;exitDy=0;           entryX=0;entryY=0.35;entryDx=0;entryDy=0;strokeColor=#FF9EA7;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1379" y="458" />
              <mxPoint x="1379" y="866" />
              <mxPoint x="1279" y="866" />
            </Array>
            <mxPoint x="849" y="458.0666666666666" as="sourcePoint" />
            <mxPoint x="1279" y="866.0666666666666" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="w_web1" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#C62828;strokeWidth=1.5;           dashed=1;           exitX=1;exitY=0.5;exitDx=0;exitDy=0;           entryX=0;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#FFA0AD;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <Array as="points">
              <mxPoint x="1374" y="662" />
              <mxPoint x="1374" y="852" />
              <mxPoint x="1274" y="852" />
            </Array>
            <mxPoint x="414" y="662.0666666666666" as="sourcePoint" />
            <mxPoint x="1274" y="852.0666666666666" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="w_web2" edge="1" parent="1" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#C62828;strokeWidth=1.5;           dashed=1;           exitX=0.5;exitY=1;exitDx=0;exitDy=0;           entryX=0.5;entryY=0;entryDx=0;entryDy=0;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="1165" y="690" as="sourcePoint" />
            <mxPoint x="1165" y="800" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="w_db" edge="1" parent="1" source="database" style="edgeStyle=orthogonalEdgeStyle;           strokeColor=#C62828;strokeWidth=1.5;           dashed=1;           exitX=1;exitY=0.5;exitDx=0;exitDy=0;           entryX=0;entryY=0.5;entryDx=0;entryDy=0;strokeColor=#FF9696;dashed=1;" target="monitor" value="">
          <mxGeometry relative="1" as="geometry" />
        </mxCell>
        <mxCell id="wlabel" parent="1" style="text;html=1;align=center;           fontSize=11;fontStyle=2;fontColor=#C62828;" value="Wazuh events (alla 5 servrar)" vertex="1">
          <mxGeometry height="20" width="240" x="1050" y="690" as="geometry" />
        </mxCell>
        <mxCell id="ufw" parent="1" style="text;html=1;align=center;           fontSize=10;fontStyle=2;fontColor=#1565C0;" value="UFW: port 5432 tillåts bara från web1 och web2" vertex="1">
          <mxGeometry height="18" width="340" x="530" y="888" as="geometry" />
        </mxCell>
        <mxCell id="leg" parent="1" style="rounded=1;fillColor=#ffffff;           strokeColor=#cccccc;strokeWidth=1;" value="" vertex="1">
          <mxGeometry height="142" width="396" x="275" y="971" as="geometry" />
        </mxCell>
        <mxCell id="legtitle" parent="1" style="text;html=1;fontSize=13;" value="&lt;b&gt;Legend&lt;/b&gt;" vertex="1">
          <mxGeometry height="20" width="100" x="285" y="972" as="geometry" />
        </mxCell>
        <mxCell id="ll1" edge="1" parent="1" style="endArrow=block;endFill=1;           strokeColor=#6c8ebf;strokeWidth=2.5;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1006" as="sourcePoint" />
            <mxPoint x="345" y="1006" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt1" parent="1" style="text;html=1;fontSize=11;" value="Port forwarding (host)" vertex="1">
          <mxGeometry height="18" width="200" x="353" y="998" as="geometry" />
        </mxCell>
        <mxCell id="ll2" edge="1" parent="1" style="endArrow=block;endFill=1;           strokeColor=#9E9E9E;strokeWidth=1.5;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1028" as="sourcePoint" />
            <mxPoint x="345" y="1028" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt2" parent="1" style="text;html=1;fontSize=11;" value="SSH — Ansible provisioning" vertex="1">
          <mxGeometry height="18" width="200" x="353" y="1020" as="geometry" />
        </mxCell>
        <mxCell id="ll3" edge="1" parent="1" style="endArrow=block;endFill=1;           strokeColor=#00897B;strokeWidth=2.5;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1050" as="sourcePoint" />
            <mxPoint x="345" y="1050" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt3" parent="1" style="text;html=1;fontSize=11;" value="Round-robin lastbalansering" vertex="1">
          <mxGeometry height="18" width="200" x="353" y="1042" as="geometry" />
        </mxCell>
        <mxCell id="ll4" edge="1" parent="1" style="endArrow=block;endFill=1;           strokeColor=#1565C0;strokeWidth=2;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1070" as="sourcePoint" />
            <mxPoint x="345" y="1070" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt4" parent="1" style="text;html=1;fontSize=11;" value="PostgreSQL port 5432 (UFW-begränsad)" vertex="1">
          <mxGeometry height="18" width="260" x="353" y="1062" as="geometry" />
        </mxCell>
        <mxCell id="ll5" edge="1" parent="1" style="endArrow=block;endFill=1;           strokeColor=#C62828;strokeWidth=1.5;dashed=1;" value="">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="285" y="1090" as="sourcePoint" />
            <mxPoint x="345" y="1090" as="targetPoint" />
          </mxGeometry>
        </mxCell>
        <mxCell id="lt5" parent="1" style="text;html=1;fontSize=11;" value="Wazuh security events" vertex="1">
          <mxGeometry height="18" width="200" x="353" y="1082" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--2" parent="1" style="image;aspect=fixed;html=1;points=[];align=center;fontSize=12;image=img/lib/azure2/management_governance/Managed_Desktop.svg;" value="" vertex="1">
          <mxGeometry height="34.35" width="36.97" x="622" y="54" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--3" parent="1" style="outlineConnect=0;dashed=0;verticalLabelPosition=bottom;verticalAlign=top;align=center;html=1;shape=mxgraph.aws3.application_load_balancer;fillColor=#F58534;gradientColor=none;" value="" vertex="1">
          <mxGeometry height="42" width="44" x="641" y="423" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--4" parent="1" style="aspect=fixed;sketch=0;html=1;dashed=0;whitespace=wrap;verticalLabelPosition=bottom;verticalAlign=top;fillColor=#2875E2;strokeColor=#ffffff;points=[[0.005,0.63,0],[0.1,0.2,0],[0.9,0.2,0],[0.5,0,0],[0.995,0.63,0],[0.72,0.99,0],[0.5,1,0],[0.28,0.99,0]];shape=mxgraph.kubernetes.icon2;prIcon=control_plane" value="" vertex="1">
          <mxGeometry height="44" width="45.83" x="636.17" y="237" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--5" parent="1" style="image;aspect=fixed;perimeter=ellipsePerimeter;html=1;align=center;shadow=0;dashed=0;spacingTop=3;image=img/lib/active_directory/web_server.svg;" value="" vertex="1">
          <mxGeometry height="45" width="36" x="202" y="612" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--6" parent="1" style="image;aspect=fixed;perimeter=ellipsePerimeter;html=1;align=center;shadow=0;dashed=0;spacingTop=3;image=img/lib/active_directory/web_server.svg;" value="" vertex="1">
          <mxGeometry height="45" width="36" x="1062" y="610" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--8" parent="1" style="image;aspect=fixed;perimeter=ellipsePerimeter;html=1;align=center;shadow=0;dashed=0;spacingTop=3;image=img/lib/active_directory/database_server.svg;" value="" vertex="1">
          <mxGeometry height="50" width="41" x="636.17" y="802" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--9" parent="1" style="image;points=[];aspect=fixed;html=1;align=center;shadow=0;dashed=0;image=img/lib/allied_telesis/security/DVS_Surveillance_Monitor.svg;" value="" vertex="1">
          <mxGeometry height="44" width="30.8" x="1064.6" y="802" as="geometry" />
        </mxCell>
        <mxCell id="81_CpS4Z2893Y3f9dSt--14" parent="1" style="text;html=1;align=center;           fontSize=10;fontStyle=2;fontColor=#1565C0;" value="&lt;font style=&quot;font-size: 72px;&quot;&gt;Secure-Infra-Lab&lt;/font&gt;" vertex="1">
          <mxGeometry height="87" width="617" x="709" y="981" as="geometry" />
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
```

</details>

---

## Miljöer och IP-adresser

| Server | IP-adress | Roll | Port forwarding | RAM |
|--------|-----------|------|----------------|-----|
| control | 192.168.56.10 | Ansible control node | - | 1024 MB |
| nginx | 192.168.56.11 | Load balancer | 80 -> host:8080 | 512 MB |
| web1 | 192.168.56.12 | Flask + Gunicorn (Server 1) | - | 512 MB |
| web2 | 192.168.56.13 | Flask + Gunicorn (Server 2) | - | 512 MB |
| database | 192.168.56.14 | PostgreSQL + UFW | - | 512 MB |
| monitor | 192.168.56.15 | Wazuh Manager + Cockpit | 9090 -> host:9090 | 2048 MB |
| **Totalt** | | | | **5120 MB** |

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
|   +-- verify.sh           # 38 automated tests from control
|   +-- verify_host.ps1     # 6 automated tests from Windows host
|
+-- vagrant/
|   +-- Vagrantfile         # Defines all 6 VMs
|   +-- secrets.yml         # GITIGNORED - create manually
|
+-- ansible/
    +-- ansible.cfg         # Ansible configuration
    +-- inventory.ini       # Servers and groups
    +-- site.yml            # Master playbook
    +-- vars/vars.yml       # Shared variables
    +-- host_vars/web2.yml  # server_name override for web2
    |
    +-- roles/
        +-- security_hardening/
        +-- flask/
        +-- nginx/
        +-- database/
        +-- wazuh_manager/
        +-- wazuh_agent/
        +-- cockpit/
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

> Detaljerad beskrivning av varje fil finns i
> [docs/log.md](docs/log.md) under respektive fas.

---

## Krav och förutsättningar

**Programvara på Windows-hosten:**

- [VirtualBox](https://www.virtualbox.org/) - testat med 7.x
- [Vagrant](https://www.vagrantup.com/) - testat med 2.x
- [Git](https://git-scm.com/)
- [VS Code](https://code.visualstudio.com/) (rekommenderas för YAML-redigering)

**Hårdvarukrav:**

- Minst 8 GB RAM (projektet använder totalt 5120 MB)
- Minst 20 GB ledigt diskutrymme

---

## Kom igång

```powershell
# Clone the repository
cd E:\
E:\> git clone https://github.com/SSM-debug/Secure-Infra-Lab.git
E:\> cd Secure-Infra-Lab
```

```powershell
# Create the secrets file (see Secrets section below)
E:\Secure-Infra-Lab> code vagrant\secrets.yml
```

```powershell
# Start all 6 VMs
# NOTE: First startup takes 10-15 minutes
cd E:\Secure-Infra-Lab\vagrant
E:\Secure-Infra-Lab\vagrant> vagrant up
```

Förväntat output per server: `=== [servername]: ready ===`


```powershell
# Log in to control and run the playbook
E:\Secure-Infra-Lab\vagrant> vagrant ssh control
```

```bash
# Run the playbook - configures the entire infrastructure automatically
# NOTE: Wazuh Manager installation takes 10-15 minutes
vagrant@control:~$ cd ansible
vagrant@control:~/ansible$ ansible-playbook site.yml
```

Förväntat slutresultat: `failed=0` på alla servrar.

```bash
# Verify that everything works (38 tests)
vagrant@control:~$ bash verify.sh
```

```powershell
# Verify from Windows (6 tests)
E:\Secure-Infra-Lab> .\scripts\verify_host.ps1
```

**Tillgängliga tjänster efter uppstart:**

| URL | Beskrivning |
|-----|-------------|
| http://localhost:8080/ | Flask via nginx - visar Server 1 eller Server 2 |
| http://localhost:8080/visit | Registrerar besök i databasen och visar de 5 senaste |
| http://localhost:8080/secret | Visar laddade miljövariabler |
| https://localhost:9090 | Cockpit dashboard (vagrant/vagrant) |

> Detaljerade kommandon för varje fas finns i
> [docs/log.md](docs/log.md).

---

## Secrets

Filen `vagrant/secrets.yml` innehåller databasuppgifter
och måste skapas manuellt. Den gitignoreras och finns
aldrig i repot.

Skapa filen med exakt detta innehåll:

```yaml
---
db_name: flaskdb
db_user: flaskuser
db_password: your-password-here
```

Filen laddas upp till control och refereras i playbooken:

```yaml
vars_files:
  - vars/vars.yml
  - secrets.yml
```

Verifiera att filen aldrig committats:

```powershell
E:\Secure-Infra-Lab> git log --all -- vagrant/secrets.yml
```

Förväntat svar: tom output. Inga commits - filen
har aldrig publicerats på GitHub.

---

## Ansible-roller

### security_hardening

Körs FÖRST på alla sex servrar innan några tjänster
installeras. Sätter en konsekvent säkerhetsbaslinje
på hela infrastrukturen.

**Härdningsåtgärder:**
- SSH root-inloggning inaktiverad (`PermitRootLogin no`)
- Lösenordsinloggning inaktiverad - bara SSH-nycklar fungerar
- Max 3 inloggningsförsök (`MaxAuthTries 3`)
- Inaktiva sessioner stängs efter 5 minuter (`ClientAliveInterval 300`)
- fail2ban: blockerar IP efter 5 misslyckade försök inom 10 minuter
- auditd: loggar alla kommandon, filändringar och inloggningar

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/tasks/main.yml)
- [templates/sshd_config.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/security_hardening/templates/sshd_config.j2)

**Officiell dokumentation:** [docs.ansible.com](https://docs.ansible.com/ansible/latest/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 3](docs/log.md).

---

### database

Installerar PostgreSQL på database-servern, skapar
databasen och användaren med minsta privilegium och
konfigurerar brandväggsregler.

**Säkerhetsåtgärder:**
- flaskuser får bara SELECT och INSERT på visits-tabellen
- pg_hba.conf tillåter bara web1 och web2
- UFW blockerar port 5432 från alla utom web1 och web2

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/tasks/main.yml)
- [templates/schema.sql.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/database/templates/schema.sql.j2)

**Officiell dokumentation:** [postgresql.org/docs](https://www.postgresql.org/docs/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 4](docs/log.md).

---

### flask

Installerar Flask och Gunicorn på web1 och web2.
Samma roll används för båda servrarna - server_name
hanteras via `defaults/main.yml` (Server 1) och
`host_vars/web2.yml` (Server 2).

Flask-applikationen har tre routes:
- `/` - hälsningsmeddelande med servernamnet
- `/secret` - visar laddade miljövariabler
- `/visit` - registrerar besöket och visar 5 senaste

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/tasks/main.yml)
- [files/app.py](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/files/app.py)
- [templates/flask.service.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.service.j2)
- [templates/flask.env.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/flask/templates/flask.env.j2)

**Officiell dokumentation:** [flask.palletsprojects.com](https://flask.palletsprojects.com/) och [docs.gunicorn.org](https://docs.gunicorn.org/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 5](docs/log.md).

---

### nginx

Konfigurerar nginx som reverse proxy och
lastbalanserare. Distribuerar trafik mellan
web1 och web2 via round-robin.

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/tasks/main.yml)
- [templates/nginx.conf.j2](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/nginx/templates/nginx.conf.j2)

**Officiell dokumentation:** [nginx.org/en/docs](https://nginx.org/en/docs/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 6](docs/log.md).

---

### wazuh_manager

Installerar Wazuh Manager på monitor-servern.
Tar emot säkerhetshändelser från alla agenter och
analyserar dem mot regeluppsättningar i realtid.

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_manager/tasks/main.yml)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

> Detaljer om implementation finns i
> [docs/log.md - Fas 7](docs/log.md).

---

### wazuh_agent

Installerar Wazuh-agenten på control, nginx, web1,
web2 och database. Agenten skickar säkerhetshändelser
till Wazuh Manager på monitor (192.168.56.15).

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/wazuh_agent/tasks/main.yml)

**Officiell dokumentation:** [documentation.wazuh.com](https://documentation.wazuh.com/)

---

### cockpit

Installerar Cockpit på monitor-servern. Ger en
webbaserad vy av systemstatus utan att behöva
logga in via SSH.

Nåbar via: `https://localhost:9090` (vagrant/vagrant)

**Filer:**
- [tasks/main.yml](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/ansible/roles/cockpit/tasks/main.yml)

**Officiell dokumentation:** [cockpit-project.org](https://cockpit-project.org/)

> Detaljer om alla roller finns i
> [docs/projektplan.md - Avsnitt 8](docs/projektplan.md).

---

## Säkerhetsåtgärder

Vi implementerar Defense-in-Depth. Det innebär
flera oberoende skyddslager - om ett lager bryts
igenom finns nästa lager kvar.

| Åtgärd | Var | Hur det verifieras |
|--------|-----|--------------------|
| SSH root-inloggning inaktiverad | Alla servrar | `sudo sshd -T \| grep permitrootlogin` |
| Lösenordsinloggning inaktiverad | Alla servrar | `sudo sshd -T \| grep passwordauthentication` |
| UFW aktiv | database | `sudo ufw status verbose` |
| Port 5432 blockerad utifrån | database | verify_host.ps1 test 6 |
| Port 5432 tillgänglig från web1/web2 | database | verify.sh test 4 |
| fail2ban aktiv | Alla servrar | `systemctl is-active fail2ban` |
| auditd aktiv | Alla servrar | `systemctl is-active auditd` |
| Wazuh-agent aktiv | 5 servrar | `systemctl is-active wazuh-agent` |
| Flask kör som icke-root | web1, web2 | `ps aux \| grep gunicorn` |
| Secrets utanför Git | Alla | `git log --all -- vagrant/secrets.yml` |

**Designnotering om listen_addresses:**

PostgreSQL är konfigurerad med `listen_addresses`
satt till web1 och web2 IP-adresser specifikt
(`192.168.56.12,192.168.56.13`). Databasen lyssnar
bara på anslutningar från dessa två servrar - inte
på alla interface. Detta ger ett extra skyddslager
utöver pg_hba.conf och UFW - Defense-in-Depth.

> Fullständig säkerhetsanalys finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

---

## STRIDE-analys och hotmodellering

STRIDE är en metod för att identifiera säkerhetshot
systematiskt. Varje bokstav representerar en
hotkategori:

- **S**poofing - Utge sig för att vara något man inte är
- **T**ampering - Manipulera data eller kod
- **R**epudiation - Neka att man utfört en handling
- **I**nformation Disclosure - Exponera känslig information
- **D**enial of Service - Göra systemet otillgängligt
- **E**levation of Privilege - Skaffa högre rättigheter

### Hotmodelleringsscenario: vad händer om web1 komprometteras?

En angripare som får kontroll över web1 kan:
- Läsa databasuppgifter i `/home/vagrant/.env`
- Ansluta till databasen på port 5432 (web1 är tillåten av UFW)
- Skriva falska besök till visits-tabellen
- Försöka nå andra servrar på det interna nätverket

En angripare på web1 kan INTE:
- Nå andra servrar direkt - UFW tillåter bara nödvändig trafik
- Logga in på database-servern via SSH (bara control har access)
- Nå monitor-servern direkt från web1
- Eskalera till root utan att trigga auditd och Wazuh

Wazuh detekterar:
- Ovanliga processer som startar på web1
- SSH-inloggningsförsök till andra servrar
- Filändringar i känsliga kataloger
- Ovanlig databastrafik

> Detaljerad beskrivning av skyddslagren finns i
> [docs/projektplan.md - Avsnitt 7](docs/projektplan.md).

### CAP-teorem och distribuerade system

CAP-teoremet säger att ett distribuerat system
bara kan garantera två av tre egenskaper samtidigt:

- **C**onsistency - alla noder ser samma data
- **A**vailability - systemet svarar alltid
- **P**artition tolerance - systemet överlever nätverksfel

I detta projekt prioriterar vi **Availability** och
**Partition tolerance** (AP-system):

- Om web1 går ner fortsätter web2 svara - tillgänglighet
  prioriteras över konsistens
- Sessionsdata går förlorad vid failover - vi har ingen
  delad session-store mellan web1 och web2
- PostgreSQL är en Single Point of Failure (SPoF) -
  om databasen går ner slutar /visit fungera

I produktion åtgärdas detta med PostgreSQL-replikering
(primary/replica) eller en managed database-tjänst
som AWS RDS med Multi-AZ.

### SPoF-analys

| Komponent | SPoF? | Konsekvens | Lösning i produktion |
|-----------|-------|------------|---------------------|
| nginx | Ja | Hela systemet når inte | Keepalived/VRRP |
| web1 | Nej | web2 tar över automatiskt | Passive health checks |
| web2 | Nej | web1 tar över automatiskt | Passive health checks |
| database | Ja | /visit slutar fungera | PostgreSQL replikering |
| monitor | Nej | Övervakning faller bort | Redundant SIEM |
| control | Nej | Ansible körs inte | Ny control-VM |

### STRIDE-tabell

| Hot | Kategori | Komponent | Skydd vi har |
|-----|----------|-----------|--------------|
| Angripare utger sig för att vara web1 eller web2 | Spoofing | database | pg_hba.conf med IP-whitelist |
| Manipulation av Flask-applikationens kod | Tampering | web1, web2 | auditd loggar filändringar |
| Ingen loggning av databastransaktioner | Repudiation | database | auditd + Wazuh-agent |
| Databasuppgifter exponeras på GitHub | Information Disclosure | web1, web2 | secrets.yml gitignoreras |
| Flask-miljövariabler läcker i loggar | Information Disclosure | web1, web2 | EnvironmentFile med mode 0600 |
| nginx överbelastas | Denial of Service | nginx | round-robin fördelar last |
| SSH-brute-force mot alla servrar | Denial of Service | Alla | fail2ban blockerar efter 5 försök |
| Angripare eskalerar från web1 till database | Elevation of Privilege | database | UFW + pg_hba.conf |
| Obehörig SSH-åtkomst via root | Elevation of Privilege | Alla | PermitRootLogin no |

### Kvarvarande brister

**Brist 1 - nginx är Single Point of Failure**

Om nginx-servern kraschar är hela systemet otillgängligt
från omvärlden. Ingen redundans finns på lastbalanseringsnivå.

Accepterat i laboratoriet. I produktion: Keepalived/VRRP
för automatisk failover till en standby-nginx.

**Brist 2 - database är Single Point of Failure**

Ingen PostgreSQL-replikering finns. Om database-servern
kraschar slutar /visit fungera - ingen data kan sparas
eller lasas.

Accepterat i laboratoriet. I produktion: PostgreSQL
primary/replica-uppsattning eller AWS RDS Multi-AZ.

**Brist 3 - secrets.yml i klartext på disk**

Databasuppgifter lagras okrypterat i secrets.yml på
control-VM. Filen gitignoreras men är läsbar på disk.

Accepterat i laboratoriet. I produktion: HashiCorp Vault
eller AWS Secrets Manager för hantering av hemligheter.

**Brist 4 - Ingen CI/CD-pipeline**

Reproducerbarhet verifieras manuellt efter varje
destroy && up. Ingen automatisk verifiering vid
varje commit till GitHub.

Accepterat i laboratoriet. I produktion: GitHub Actions
som kör vagrant destroy && up && ansible-playbook
automatiskt vid varje push till main.

**Brist 5 - Självsignerat TLS-certifikat**

nginx accepterar Flask-certifikatet utan verifiering
(proxy_ssl_verify off). Krypteringen fungerar men
certifikatets identitet verifieras inte.

Accepterat i laboratoriet eftersom certifikatet
genereras av Ansible och båda parter är kända.
I produktion: CA-signerat certifikat eller internt CA.

---

## Verifiering och testresultat

Verifieringen bevisar att infrastrukturen är
korrekt konfigurerad och fullständigt reproducerbar.

### verify.sh - 38 tester från control

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify.sh)

```bash
vagrant@control:~$ bash verify.sh
```

Skriptet testar:

| Testkategori | Antal tester |
|-------------|-------------|
| nginx svarar på port 80 | 1 |
| Round-robin Server 1 | 1 |
| Round-robin Server 2 | 1 |
| web1 når databasen på port 5432 | 1 |
| Extern blockeras från databasen | 1 |
| Flask aktiv på web1 | 1 |
| Flask aktiv på web2 | 1 |
| fail2ban aktiv på alla 6 servrar | 6 |
| auditd aktiv på alla 6 servrar | 6 |
| Lösenordsinloggning inaktiverad | 6 |
| Root-inloggning inaktiverad | 6 |
| Wazuh-agent aktiv på 5 servrar | 5 |
| Wazuh Manager aktiv på monitor | 1 |
| Cockpit svarar på port 9090 | 1 |

Förväntat output:

```
==============================
 Secure-Infra-Lab Verify
==============================
PASS: nginx HTTP 200
PASS: Round-robin Server 1
PASS: Round-robin Server 2
...
==============================
 Results: PASS=38 FAIL=0
==============================
```

### verify_host.ps1 - 6 tester från Windows

[Se skriptet på GitHub](https://github.com/SSM-debug/Secure-Infra-Lab/blob/main/scripts/verify_host.ps1)

```powershell
E:\Secure-Infra-Lab> .\scripts\verify_host.ps1
```

Skriptet testar från värddatorns perspektiv:
- nginx svarar via port forwarding 8080
- Round-robin inkluderar Server 1
- Round-robin inkluderar Server 2
- /visit registrerar ett besök
- Cockpit svarar på port 9090
- Databasen är INTE nåbar från Windows (UFW fungerar)

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

### Reproducerbarhet

Dessa resultat ska uppnås varje gång efter:

```bash
vagrant destroy -f && vagrant up
ansible-playbook site.yml
bash verify.sh
```

38/38 och 6/6 varje gång - utan manuella ingrepp.
Det bevisar att infrastrukturen är fullständigt
reproducerbar.

---

## Produktion och skalbarhet

### Skillnader mot en produktionsmiljö

| Laboratoriet | Produktionsmiljön |
|-------------|------------------|
| Vagrant + VirtualBox | AWS, Azure eller dedikerad hårdvara |
| Statiska privata IP:er | DNS + cloud load balancers |
| secrets.yml | HashiCorp Vault eller AWS Secrets Manager |
| Cockpit för övervakning | Wazuh Dashboard (OpenSearch) + SOC-team |
| TLS internt (nginx-Flask, självsignerat) | TLS med CA-signerat certifikat |
| Manuell vagrant upload | CI/CD-pipeline med GitHub Actions |

### Skalbarhet i nuvarande design

Att lägga till en tredje webbserver kräver tre steg:

1. Lägg till servern i `ansible/inventory.ini`
2. Lägg till IP-adressen i `ansible/vars/vars.yml`
3. Kör `ansible-playbook site.yml`

nginx.conf.j2 uppdateras automatiskt via
Jinja2-variabler. Inga manuella ändringar i
nginx-konfigurationen behövs.

### Loggning och övervakning

Wazuh Manager på monitor samlar loggar från alla
fem servrar i realtid. Wazuh-regler genererar
alerts vid misstänkt aktivitet.

Cockpit ger en webbaserad realtidsvy av systemhälsa:
CPU, minne, disk och aktiva tjänster per server.

I produktion kompletteras Wazuh med automatisk
backup av PostgreSQL och integrering med ett
SOC-team för incidenthantering.

> Fullständig diskussion om skalbarhet finns i
> [docs/projektplan.md - Avsnitt 10](docs/projektplan.md).

---

## Designval och motivering

### Varför separata VMs för varje lager?

Att köra Flask och PostgreSQL på samma server
hade förenklat upplägget men eliminerat
nätverkssegmenteringen. Med separata VMs krävs
en nätverksanslutning mot databasen som UFW
begränsar till bara web1 och web2. Om
webbservern komprometteras kan angriparen inte
automatiskt nå databasen direkt.

### Varför Gunicorn istället för Flasks inbyggda server?

Flasks inbyggda server är entrådig och hanterar
en förfrågan i taget. Gunicorn kör flera
worker-processer parallellt och är den etablerade
standarden för Flask i produktion. systemd med
`Restart=always` ger automatisk återhämtning
vid krascher.

### Varför Jinja2-template för nginx.conf?

IP-adresserna till web1 och web2 hämtas från
`vars.yml` via Jinja2-variabler. Om en tredje
webbserver läggs till uppdateras nginx-konfigurationen
automatiskt nästa gång playbooken körs. Inga
manuella ändringar i nginx.conf behövs.

### Varför en gemensam flask-roll för web1 och web2?

DRY-principen (Don't Repeat Yourself). Samma
rollkod används för båda servrarna. Skillnaden
hanteras via Ansibles variabelprioritering:
`defaults/main.yml` sätter "Server 1" som
standardvärde och `host_vars/web2.yml` överskriver
det för web2. Inga duplicerade roller behövs.

### Varför security_hardening körs först?

Säkerheten måste vara på plats innan några
tjänster installeras. Om vi installerade Flask
först och härdade SSH efteråt skulle det finnas
ett tidsfönster då servern är oskyddad. Security
hardening som första steg garanterar att alla
servrar har en konsekvent säkerhetsbaslinje
från dag ett.

### Varför Wazuh istället för bara fail2ban?

fail2ban blockerar lokalt på varje server.
Det ger ingen överblick över vad som händer
på hela infrastrukturen. Wazuh är ett SIEM-system
som samlar händelser från alla servrar centralt
och korrelerar dem. En angripare som försöker
brute-force-attacker mot flera servrar syns
omedelbart i Wazuh - inte bara på den enskilda
servern.

> Fullständig diskussion om designval finns i
> [docs/projektplan.md](docs/projektplan.md).

---

## Tekniska begränsningar och framtida förbättringar

### Varför Cockpit istället för Wazuh Dashboard

Wazuh Manager är installerad och körs korrekt på
monitor-servern. Wazuh-agenter körs på alla fem
övriga servrar och skickar säkerhetshändelser
till Manager i realtid. Det är den
säkerhetskritiska delen och den fungerar fullt ut.

Wazuh Dashboard (som körs via OpenSearch Dashboards,
tidigare kallad Kibana) installerades inte.
Anledningen är teknisk: OpenSearch Dashboards
kräver minst 4 GB RAM enbart för sig själv.
Värddatorn har 6.4 GB tillgängligt RAM totalt.
Med sex VMs igång samtidigt (totalt 5120 MB
tilldelat) fanns inget utrymme kvar för dashboarden
utan att riskera att hela miljön kraschade.

Cockpit valdes som alternativt övervakningsgränssnitt.
Cockpit är resurseffektivt (under 100 MB RAM),
installeras via ett enda apt-kommando och ger
tillräcklig systemöverblick för denna miljö:
CPU, minne, diskutrymme, aktiva tjänster och
loggar per server.

I en produktionsmiljö med dedikerad hårdvara
eller molninfrastruktur installeras OpenSearch
Dashboards för fullständig SIEM-visualisering.

### Framtida förbättringsmöjligheter

**1. Wazuh Dashboard (OpenSearch)**
Aktivera fullständig SIEM-visualisering när
hårdvaran tillåter. Kräver minst 8 GB RAM på hosten.

**2. Secrets management**
Ersätt secrets.yml med HashiCorp Vault för
hantering av databasuppgifter och SSH-nycklar
i produktionsmiljö.

**3. CI/CD-pipeline**
Automatisera `vagrant destroy && vagrant up &&
ansible-playbook` med GitHub Actions för att
verifiera reproducerbarhet vid varje commit.

---

```
Projekt: Secure-Infra-Lab
Författare: Sushanta Shekhar Modak & Farhad Norman
GitHub: https://github.com/SSM-debug/Secure-Infra-Lab
Detaljerad logg: docs/log.md
Projektplan: docs/projektplan.md
Datum: 2026-05-11
```