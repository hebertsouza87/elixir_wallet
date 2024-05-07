# Digital Wallet API

Simples API de cadastro de carteira digital, com operações básicas.

## Arquitetura

A arquitetura do projeto é projetada para ser resiliente e escalável, permitindo que vários serviços (pix, empréstimo, TED/TEF, etc) realizem depósitos na conta.

O depósito posta em um tópico kafka que outro processo realiza a leitura e posterior gravação do registro no banco. Desta forma o depósito não depende da disponibilidade do banco de dados e exemplifica o processo de entrada de depósito que pode vir de outras origens.

A transferência e a retirada são síncronas, pois dependem do saldo em conta e precisam ser uma transação atômica.

Para identificação dos usuários, será utilizado o user_id vindo no token JWT.


### Infraestrutura

A infraestrutura do projeto é baseada em uma arquitetura de microserviços gerenciada pelo Kubernetes. O diagrama a seguir mostra uma ideia de como deverá ser a inifraestrutura do ecosistema da aplicação.

```mermaid
graph LR
  User -->|Request| APIGateway
  APIGateway --> |Request| LoadBalancer
  LoadBalancer -->|Distribute Request| Kubernetes
  Kubernetes -->|Manage Pods| AutoScaling
  AutoScaling -->|Scale Pods| MultiAZ
  MultiAZ -->|Run Pods| DigitalWallet
  MultiAZ -->|Run Pods| AuthService
  MultiAZ -->|Run Pods| FraudService
  MultiAZ -->|Run Pods| Database
  MultiAZ -->|Run Pods| BankAPI
  MultiAZ -->|Run Pods| AuditService
  MultiAZ -->|Run Pods| MonitoringService
```

### Diagramas de Sequência

Os diagramas a seguir mostram como as operações de retirada/transferência e depósito são processadas.

#### Retirada/Transferência entre Carteiras

```mermaid
sequenceDiagram
    User ->> APIGateway: Request
    APIGateway ->> AuthService: Validate Token
    AuthService -->> APIGateway: Token Valid
    APIGateway ->> FraudService: Check for Fraud
    FraudService -->> APIGateway: No Fraud Detected
    APIGateway ->> DigitalWallet: Forward Request
    DigitalWallet ->> Database: CRUD Operations
    Database -->> DigitalWallet: Saved Operation
    DigitalWallet -->> APIGateway: Operation Response
    APIGateway -->> User: Forward Response
    DigitalWallet ->> AuditService: Activity Logs
    AuditService ->> MonitoringService: Monitor Activities
```

#### Depósito

```mermaid
sequenceDiagram
    DigitalWallet ->> Kafka: Deposit Topic
    Kafka -->> DigitalWallet: Deposit Transaction
    DigitalWallet ->> Database: CRUD Operations
    Database -->> DigitalWallet: Saved Operation
    DigitalWallet ->> AuditService: Activity Logs
    AuditService ->> MonitoringService: Monitor Activities
```

### Modelo de Dados

O modelo de dados do projeto consiste em duas tabelas: `Wallets` e `Transactions`. A tabela `Wallets` contém informações sobre as carteiras dos usuários, enquanto a tabela `Transactions` registra todas as transações realizadas, podendo ser utilizada para gerar extrado e auditoria.

```mermaid
classDiagram
    Wallets -- Transactions : has many
    class Wallets {
        +id (UUID)
        balance (Decimal)
        userId (UUID)
        number (Serial)
        inserted_at (DateTime)
        updated_at (DateTime)
        index on userId (unique)
        index on number (unique)
    }
    class Transactions {
        +id (UUID)
        amount (Decimal)
        walletOriginId (UUID)
        walletDestinationId (UUID)
        operation (String)
        walletOriginNumber (Integer)
        walletDestinationNumber (Integer)
        inserted_at (DateTime)
        updated_at (DateTime)
        index on walletOriginId
        index on walletDestinationId
    }
```

## Como executar

### Sem Docker

1. Clone o repositório.
2. Instale as dependências com `mix deps.get`.
3. Crie e migre o banco de dados com `mix ecto.setup`.
4. Inicie o servidor Phoenix com `mix phx.server`.

Agora você pode visitar [`localhost:4000`](http://localhost:4000) do seu navegador.

### Com Docker

1. Clone o repositório.
2. Construa e suba imagem Docker com `docker-compose up --build`.

Agora você pode visitar [`localhost:4000`](http://localhost:4000) do seu navegador.


## Endpoints

- `POST /api/dev/token`: 
Para facilitar, em ambiente de dev temos um endpoint que gera um token JWT valido, para ser usado na aplicação. (pode gerar um uuid valido nesse site: https://www.uuidgenerator.net/)

```
curl --location 'http://localhost:4000/api/dev/token' \
--header 'Content-Type: application/json' \
--data '{"user_id":"d02f68d3-079b-4f5b-93ac-2628d0b624fb"}'
```
- `POST /api/wallets`: Cria uma carteira
```
curl --location --request POST 'http://127.0.0.1:4000/api/wallets' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZDAyZjY4ZDMtMDc5Yi00ZjViLTkzYWMtMjYyOGQwYjYyNGZiIn0.21XAlWktFy93r2VrOdBlslnKpc78D6mJgF0mgUzBbPg' \
--data '{}'
```
- `POST /api/deposit`: Deposita uma quantia na carteira do usuário.
```
curl --location 'http://localhost:4000/api/deposit' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZDAyZjY4ZDMtMDc5Yi00ZjViLTkzYWMtMjYyOGQwYjYyNGZiIn0.21XAlWktFy93r2VrOdBlslnKpc78D6mJgF0mgUzBbPg' \
--data '{"amount": 1.10}'
```

- `POST /api/withdraw`: Retira uma quantia da carteira do usuário.
```
curl --location 'http://localhost:4000/api/withdraw' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZDAyZjY4ZDMtMDc5Yi00ZjViLTkzYWMtMjYyOGQwYjYyNGZiIn0.21XAlWktFy93r2VrOdBlslnKpc78D6mJgF0mgUzBbPg' \
--data '{"amount": 1.50}'
```
- `POST /api/transfer`: Transfere uma quantia da carteira do usuário para outra carteira.
```
curl --location 'http://localhost:4000/api/transfer' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiZDAyZjY4ZDMtMDc5Yi00ZjViLTkzYWMtMjYyOGQwYjYyNGZiIn0.21XAlWktFy93r2VrOdBlslnKpc78D6mJgF0mgUzBbPg' \
--data '{"amount": 0.01,
"to_wallet_number": 2}'
```

### Swagger: https://github.com/hebertsouza87/elixir_wallet/blob/main/swagger.yaml



Esta foi a arquitetura que montei pensando em implementar.

Vou expor uma outra ideia de arquitetura mais complexa e completa, que atenderia melhor a solicitação, mas que seria inviável de implementar em tão pouco tempo.

```mermaid
sequenceDiagram
    User ->> APIGateway: Request
    APIGateway ->> AuthService: Validate Token
    AuthService -->> APIGateway: Token Valid
    APIGateway ->> FraudService: Check for Fraud
    FraudService -->> APIGateway: No Fraud Detected
    APIGateway ->> Transfer: Forward Request
    Transfer ->> Balance: Reserv found
    Balance -->> Transfer: Balance Details
    Transfer ->> Kafka: Post topic
    Kafka -->> Transfer: Saved topic
    Transfer ->> Balance: Confirm operation
    Balance ->> Transfer: Confirm operation
    Transfer -->> APIGateway: Operation Response
    APIGateway -->> User: Forward Response
    Transfer ->> AuditService: Activity Logs
    AuditService ->> MonitoringService: Monitor Activities
```

APIGateway: Ponto de entrada para todas as solicitações. Ele encaminha a solicitação para o serviço apropriado após a autenticação e a verificação de fraude.

AuthService: Serviço é responsável por validar o token fornecido pelo usuário.

UserService: Serviço responsável pelo cadastro de usuário.

FraudService: Este serviço verifica se a solicitação é fraudulenta. Se não for, a solicitação é encaminhada para o próximo serviço.

Transfer: Este serviço é responsável por realizar as transações financeiras. Ele interage com o serviço Balance para reservar fundos e confirmar a operação. Também é o serviço responsável por desfazer a transação se não for possível confirmar a transação com o balance (essa confirmação pode ser feita por uma fila o que mitigaria esse problema)

Balance: Este serviço é responsável por gerir o saldo da conta. Ele reserva fundos quando solicitado pelo serviço Transfer e confirma a operação quando recebe a confirmação do serviço Transfer.

DigitalWallet: Este serviço é responsável pelo cadastro das carteiras. Que não aparece nesse diagrama, pois ele seria consultado em outro momento que não o transacional.