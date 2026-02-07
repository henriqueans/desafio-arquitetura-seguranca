# Desafio 1 – Arquitetura de Segurança em Nuvem

## 1. Identidade e Acesso (Microsoft Entra ID)

### 1.1 Provedor de Identidade Central
- Todo o ambiente utiliza o **Microsoft Entra ID** como identidade principal.
- Aplicações corporativas e SaaS são registradas no Entra ID.
- Os usuários são organizados por:
  - Colaboradores internos
  - Terceiros
  - Contas administrativas
  - Identidades gerenciadas (workload identities)

### 1.2 Controles de Acesso
- MFA obrigatório para 100% dos usuários.
- FIDO2 recomendado para administradores.
- Acesso Just-In-Time via **PIM** para funções sensíveis.
- Zero Trust aplicado:
  - Verificação de dispositivo
  - Verificação de risco do usuário
  - Verificação de localização
  - Sessão com restrições

### 1.3 Privilégios
- Atribuições somente via grupos.
- Sem permissões diretas a usuários.
- Segregação clara entre:
  - Contas de usuário
  - Contas administrativas
  - Contas de serviço

---

## 2. Governança, Políticas e Conformidade

### 2.1 Azure Policy
- Políticas aplicadas em toda a hierarquia:
  - Proibir recursos não aprovados.
  - Aplicar tags obrigatórias.
  - Garantir criptografia em repouso.
  - Impedir IP públicos em servidores sensíveis.

### 2.2 Blueprints / Landing Zones
- Ambientes padronizados para:
  - Produção
  - Homologação
  - Desenvolvimento

### 2.3 Auditoria
- **Defender for Cloud** habilitado.
- Avaliações de conformidade baseadas em:
  - CIS v8
  - NIST SP 800-53
  - ISO 27001

---

## 3. Segurança de Rede

### 3.1 Perímetro
- Uso de **Azure Firewall** com:
  - IDS/IPS
  - Regras de filtragem de saída
  - Geo-blocking
  - TLS inspection

### 3.2 Proteção de Aplicações Web
- **WAF** aplicado em:
  - Application Gateway
  - Front Door (para apps globais)

### 3.3 Segmentação
- VNets separadas para:
  - App
  - Banco de Dados
  - Serviços internos
- Sub-redes com NSGs detalhados.
- Sem comunicação leste-oeste desnecessária.

### 3.4 Acesso Remoto
- Acesso via **Azure Bastion**.
- Acesso Just-In-Time para VMs sensíveis.

---

## 4. Segurança de Workloads

### 4.1 Máquinas Virtuais
- Defender for Endpoint instalado.
- Hardening baseado em CIS.
- Patch Management automatizado.
- Discos com criptografia (Azure Disk Encryption).

### 4.2 Containers e Kubernetes
- Cluster AKS com:
  - RBAC habilitado
  - Policies restritivas (OPA/Gatekeeper)
  - Scanner de imagens no ACR
  - Network Policies aplicadas

### 4.3 Storage
- Acesso somente via Private Endpoint.
- Public Access totalmente bloqueado.
- Defender for Storage habilitado.
- Logs habilitados (read/write/remote access).

---

## 5. Segurança de Dados

### 5.1 Banco de Dados
- Acesso somente interno via Private Link.
- Autenticação Entra ID.
- Backup automatizado.
- Defender for SQL habilitado.

### 5.2 Segredos e Certificados
- Armazenados no **Azure Key Vault**.
- Acesso autorizado via Managed Identities.
- Rotação automática configurada.

---

## 6. Monitoramento e Resposta a Incidentes

### 6.1 Coleta de Logs
- Azure Monitor + Log Analytics.
- Logs de:
  - Entra ID
  - Firewall
  - WAF
  - Key Vault
  - Storage
  - AKS
  - SQL

### 6.2 Detecção
- Microsoft Defender XDR:
  - Identidade
  - Email
  - Endpoint
  - Cloud Apps
  - Workloads

### 6.3 SOC e Automação
- Playbooks automatizados (Logic Apps):
  - Bloqueio de conta
  - Reset forçado de senha/MFA
  - Isolamento de máquina
  - Persistência de evidências

---

## 7. Considerações Finais

A arquitetura proposta segue:

- Zero Trust como pilar central  
- Princípio do menor privilégio  
- Identidade como perímetro de segurança  
- Segmentação rígida  
- Camadas de proteção (defense-in-depth)  
- Monitoramento constante e resposta rápida  

A imagem referenciada deve ser colocada no arquivo `arquitetura.png` dentro da pasta `desafio-1`.//**Nao criada**

