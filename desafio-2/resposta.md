# Desafio 2 – Plano de Segurança e Acessos

## 1. Governança e Modelos de Acesso

### 1.1 Estrutura de Identidade
- Microsoft Entra ID como provedor de identidade central.
- Usuários separados em:
  - **Colaboradores internos**
  - **Prestadores/terceiros**
  - **Serviços e workloads**
- Segmentação por grupos baseados em função (RBAC).

### 1.2 Princípios de Segurança
- Princípio do menor privilégio.
- Zero Trust aplicado em:
  - Identidade
  - Dispositivos
  - Sessões
  - Aplicações
  - Acessos administrativos
- Revisão periódica de acessos (PIM – Microsoft Entra ID).

---

## 2. Gestão de Acessos

### 2.1 Acesso administrativo
- Separação entre contas de produção e contas administradoras.
- Administradores usam:
  - MFA obrigatório
  - Acesso Just-In-Time (PIM)
  - Aprovação obrigatória para elevação de privilégio

### 2.2 Autenticação
- MFA para 100% dos usuários.
- FIDO2 para reduzir phishing.
- Políticas de risco:
  - Bloqueio automático se risco alto (Entra ID Protection).
  - Reset seguro com MFA e autenticação forte.

### 2.3 Autorização (RBAC)
- Sem permissão direta a usuários.
- Sempre via:
  - Grupos
  - Funções predefinidas
  - Perfis de acesso

---

## 3. Aplicações e Workloads

### 3.1 Apps internos e SaaS
- Registro de aplicativos no Entra ID.
- OAuth2 + OpenID Connect.
- Segregação de ambientes (dev/test/prod).
- Aplicações sensíveis exigem:
  - Conditional Access
  - MFA
  - Dispositivo corporativo ou compliant

### 3.2 APIs e integrações
- Uso de Managed Identities.
- Autenticação baseada em tokens.
- Segredo e certificados armazenados no Azure Key Vault.

---

## 4. Segurança de Dispositivos

### 4.1 Estações de Trabalho
- Microsoft Intune para gestão.
- Regras:
  - Defender for Endpoint ativo
  - BitLocker obrigatório
  - Bloqueio de dispositivos comprometidos

### 4.2 Servidores
- Patch Management automatizado.
- Monitoramento contínuo.
- Hardening seguindo CIS Benchmarks.

---

## 5. Segurança de Rede

### 5.1 Segmentação
- Sub-redes separadas:
  - Aplicações
  - Banco de dados
  - Serviços internos
  - Gateways

### 5.2 Firewalls
- Azure Firewall com:
  - IDS/IPS
  - Filtros de saída
  - Geo-blocking
  - Bloqueio de portas críticas

### 5.3 Proteção de cargas
- Web Application Firewall (WAF) para apps públicos.
- DDoS Protection Standard.

---

## 6. Monitoramento e Resposta

### 6.1 Telemetria centralizada
- Azure Monitor
- Log Analytics
- Defender XDR integrado

### 6.2 SOC
- Detecção:
  - Incidentes de identidade
  - Ataques de rede
  - Ameaças em hosts
- Resposta:
  - Automação com Logic Apps
  - Playbooks (bloquear usuário, reset MFA, isolar máquina)

---

## 7. Conformidade

- Mapeamento aos frameworks:
  - CIS v8
  - NIST SP 800-53
  - ISO 27001
- Políticas configuradas via Defender for Cloud.

---

## 8. Conclusão

Este plano demonstra como aplicar práticas modernas de segurança (Zero Trust, RBAC, autenticação forte, segmentação de rede, automação e monitoramento contínuo) para construir um ambiente seguro, escalável e confiável.

