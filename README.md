# Wallet API

## Descrição

Para a criação da arquitetura e implementação do código, vou abstrair alguns processos, como o serviço de autenticação, validação de fraudes, cadastro de usuários, etc. Nesse projeto vou me ater em implementar o serviço de carteira digital e, para identificação dos usuários, utilizarei o user_id vindo no token JWT.

O depósito irá postar em um tópico kafka e retornará os dados da transação e posteriormente a aplicação irá ler o tópico e realizar a operação de fato. A intenção ter uma arquitetura onde n serviços (pix, empréstimo, TED/TEF, etc) possam realizar depósito na conta mantendo a resiliência e escalabilidade.

A transferência e retirada são sincronos, pois dependem do saldo em conta e precisam ser uma transação atomica.

Aqui está um diagrama UML simples da arquitetura da API:

```mermaid
sequenceDiagram
    Usuário ->> API Gateway: Solicitação
    note right of API Gateway: Valida necessidade de renovação de token
    API Gateway ->> Serviço de Autenticação: Renova token
    Serviço de Autenticação ->> API Gateway: Token JWT renovado
    API Gateway ->> Serviço de Fraudes: Verifica fraude
    Serviço de Fraudes ->> API Gateway: Resposta da validação
    API Gateway ->> Serviço de Carteira Digital: Solicitação de operação de carteira/transação
    note right of Serviço de Carteira Digital: Processa a operação da carteira/transação
    Serviço de Carteira Digital ->> API Gateway: Resposta da operação da carteira/transação
    API Gateway ->> Usuário: Resposta

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


### Kafka

Será necessário criar um topico no kafka, para isso, é possível utiliar o comando 
`kafka-topics --bootstrap-server kafka:29092 --create --if-not-exists --topic FinancialTransactions --replication-factor 1 --partitions 1` no container do kafka


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

## Swagger: https://github.com/hebertsouza87/elixir_wallet/blob/main/swagger.yaml