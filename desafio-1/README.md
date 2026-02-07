# Desafio 01 – Avaliação e Redesenho de Arquitetura (Security Design Review)

Este documento apresenta a análise do ambiente atual (As-Is), os principais riscos identificados e a proposta de redesenho (To-Be) considerando boas práticas de segurança, operação e confiabilidade em AWS.

---

## 1. Visão Geral do Cenário

O ambiente atual suporta uma aplicação web de produção hospedada em AWS, com integração a um ambiente on-premises e envio de dados para um serviço externo por FTP.  
A arquitetura tem funcionamento básico, porém vários pontos expostos trazem riscos significativos.

---

## 2. Análise do Cenário Atual (As-Is)

Abaixo está a classificação dos riscos considerando **Probabilidade x Impacto** e também a **prioridade de tratamento**.

### 🔥 Principais Riscos Identificados

#### **1. EC2 em sub-redes públicas com SSH aberto à Internet**
- **Probabilidade:** Alta  
- **Impacto:** Alto  
- **Risco:** Comprometimento direto das instâncias e pivot para o RDS.  
- **Prioridade:** Crítica  

#### **2. RDS acessível pela Internet (porta 3306 aberta)**
- **Probabilidade:** Alta  
- **Impacto:** Muito alto (vazamento de dados + compliance)  
- **Prioridade:** Crítica

#### **3. API acessada via Internet usando Basic Authentication**
- **Probabilidade:** Alta  
- **Impacto:** Médio/Alto  
- **Risco:** Credenciais fracas/roubo, ataque MITM caso não haja TLS adequado.  
- **Prioridade:** Alta

#### **4. Envio de dados pessoais por FTP (sem criptografia)**
- **Probabilidade:** Alta  
- **Impacto:** Alto  
- **Risco:** Vazamento de dados sensíveis em trânsito.  
- **Prioridade:** Alta  

#### **5. Administração AWS com usuários IAM locais**
- **Probabilidade:** Média  
- **Impacto:** Alto  
- **Risco:** Falta de centralização, credenciais expostas, ausência de MFA corporativo.  
- **Prioridade:** Média/Alta

#### **6. Ausência de limites de confiança claros**
- **Probabilidade:** Média  
- **Impacto:** Médio  
- **Prioridade:** Média

#### **7. Observabilidade limitada**
- **Probabilidade:** Média  
- **Impacto:** Médio  
- **Prioridade:** Média

---

## 3. Arquitetura Proposta (To-Be) — Visão Geral

> O diagrama em **draw.io** será gerado separadamente na próxima etapa.

A arquitetura redesenhada segue alguns princípios centrais:

- **Remover exposição desnecessária**  
- **Isolar camadas por zonas de confiança**  
- **Criar conectividade segura com on-premises**  
- **Melhorar a proteção de dados e segredos**  
- **Centralizar identidade**  
- **Adicionar observabilidade mínima saudável**

A seguir, os principais pontos da nova proposta:

### **3.1 Camada de Aplicação**
- EC2 movidos para **sub-redes privadas**
- Acesso SSH substituído por **SSM Session Manager**
- ALB permanece em sub-redes públicas, mas com restrições mais rígidas

### **3.2 Banco de Dados**
- RDS movido para **sub-redes privadas**
- Remoção total de exposição à Internet
- Acesso permitido apenas via VPC e Security Groups restritos

### **3.3 Integração com On-Premises**
- Saída da API por **AWS API Gateway**  
- API acessível via **PrivateLink** ou VPN, evitando exposição pública  
- Autenticação via **OAuth2/OpenID Connect** integrado ao Microsoft Entra ID  
- Remoção do Basic Auth

### **3.4 Backup / Transferência de Dados**
- Substituir FTP por:
  - **AWS Transfer Family (SFTP)** ou  
  - Tunelamento seguro via VPN/Direct Connect

### **3.5 Identidade & Governança**
- Remover usuários IAM locais  
- Implementar **IAM Identity Center** integrado ao Microsoft Entra ID  
- MFA corporativo obrigatório  

### **3.6 Observabilidade**
- CloudTrail (todos os eventos)  
- CloudWatch (métricas + logs da aplicação)  
- GuardDuty  
- AWS Config  
- Alarmes essenciais  

---

## 4. Justificativas Técnicas das Mudanças

### **EC2 em sub-redes privadas + SSM**
- **Objetivo:** reduzir superfície de ataque  
- **Justificativa:** evita SSH exposto, elimina chaves e portas abertas  
- **Impacto:** melhora grande em segurança, custo baixo

### **RDS somente privado**
- **Objetivo:** proteger dados críticos  
- **Justificativa:** exposição do banco à Internet é um dos maiores riscos  
- **Impacto:** zero impacto operacional, alta mitigação

### **API Gateway + PrivateLink / VPN**
- **Objetivo:** remover exposição pública e melhorar autenticação  
- **Justificativa:** Basic Auth é insuficiente, PrivateLink remove Internet do caminho  
- **Impacto:** aumenta segurança e observabilidade  
- **Complexidade:** moderada

### **IAM Identity Center + Entra ID**
- **Objetivo:** governança centralizada + MFA unificado  
- **Impacto:** melhora auditabilidade e reduz risco humano

### **Substituir FTP**
- **Objetivo:** garantir criptografia de dados pessoais  
- **Justificativa:** FTP puro é inseguro e não compliant  
- **Impacto:** mínimo — SFTP é amplamente suportado

---

## 5. Roadmap de Implantação

### **Fase 1 — Imediata (0–30 dias)**
- Criar nova VPC com sub-redes privadas/públicas  
- Mover RDS para sub-rede privada  
- Ativar GuardDuty, CloudTrail e AWS Config  
- Remover SSH e migrar para SSM  
- Criar API Gateway e configurar OAuth2 (Entra ID)

### **Fase 2 — 30–60 dias**
- Implementar PrivateLink **ou** VPN corporativa  
- Migrar EC2 web tier para privadas  
- Ajustar ALB com regras de segurança mais rígidas  
- Migrar fluxos de FTP → SFTP (Transfer Family)

### **Fase 3 — >90 dias**
- Revisão de SGs e políticas IAM  
- Criar padrão de logs e dashboards  
- Hardening continuo dos workloads  
- Testar plano de recuperação e rollback

---

## 6. Plano de Rollback (Alto Nível)
- Cada migração (RDS, EC2, API) deve manter ambiente antigo funcionando em paralelo  
- Em caso de falha:
  - voltar DNS para o ALB antigo  
  - restaurar RDS com snapshot anterior  
  - reverter rota API para endpoint antigo  
- Tempo de rollback esperado: 30–60 minutos, dependendo da carga

---

## 7. Riscos Residuais
- Dependência do ambiente on-premises para autenticação (Entra ID)  
- Latência variável caso integração use VPN  
- Terceiro de backup precisar adaptar-se ao SFTP  
- Aplicação legada pode precisar de ajustes para OAuth2

---

## 8. Assunções (Premissas)
- A aplicação suporta operação atrás de ALB  
- On-premises consegue adotar OAuth2 ou outro método moderno  
- O time de redes pode criar VPN/Direct Connect  
- O serviço externo aceita SFTP ou transferência segura

---

