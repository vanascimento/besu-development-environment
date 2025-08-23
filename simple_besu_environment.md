# Configurando um Ambiente de Desenvolvimento Hyperledger Besu com QBFT e Blockscout

## Introdução

Depois de ver diversas palestras e discussões sobre blockchain, eu não sabia como esses conceitos funcionavam na prática usando código. Todo mundo falava sobre "descentralização", "contratos inteligentes" e "tokens", mas a documentação da tecnologia pode ser um pouco desafiadora para quem está começando.

Minha curiosidade real veio com o anúncio de que o Banco Central do Brasil iria utilizar blockchain na CBDC (Central Bank Digital Currency), o que me fez querer entender como essa tecnologia realmente funcionava por baixo dos panos. O objetivo deste post é poupar o tempo de quem também quer entender como essa tecnologia funciona na prática, provendo um repositório com o ferramental para executar uma rede privada de Hyperledger Besu e exemplos de contratos, incluindo o deploy de um token ERC-20 que é utilizado para representar stablecoins na rede Ethereum.

Neste post, vou te mostrar **exatamente** como configurar um ambiente de desenvolvimento Hyperledger Besu com QBFT que **funciona de verdade**. Sem promessas vazias, sem conceitos abstratos - apenas código funcional e configurações que você pode usar imediatamente.

**Por que você deveria me ouvir?** Porque o Hyperledger Besu é a mesma tecnologia que o Banco Central do Brasil está usando no piloto do **Real Digital (DREX)**. Se é bom o suficiente para eles, é bom o suficiente para nós.

Vou compartilhar os desafios reais que enfrentei, as soluções que implementei e todo o código que você precisa. Pronto para sair da teoria e ir para a prática?

## 🎯 Público-Alvo

**Este post é destinado a usuários intermediários.** Para acompanhar o conteúdo, você precisa ter conhecimento básico de:

- **Solidity**: Linguagem de contratos inteligentes do Ethereum
- **Conceitos básicos de Ethereum**: Blocos, transações, gas, endereços
- **Docker**: Comandos básicos (docker-compose, docker run)
- **Terminal/Linha de comando**: Navegação e execução de comandos

**Não se preocupe se você não for expert** - vou explicar cada passo de forma clara. Mas se você nunca ouviu falar de Solidity ou Ethereum, recomendo primeiro dar uma olhada nos conceitos básicos.

## Por que Hyperledger Besu?

O Hyperledger Besu é uma implementação Java da especificação Ethereum, desenvolvida pela Hyperledger Foundation. É especialmente adequado para ambientes corporativos devido a:

- **Compatibilidade com Ethereum**: Suporta contratos inteligentes Solidity e ferramentas do ecossistema Ethereum
- **Consenso configurável**: Suporta PoW, PoA, IBFT2.0 e QBFT
- **Governança**: Desenvolvido pela comunidade open-source com suporte empresarial
- **Performance**: Otimizado para redes privadas e consórcios

## Por que QBFT?

O QBFT (Quorum Byzantine Fault Tolerance) é um algoritmo de consenso que oferece:

- **Finalidade imediata**: Blocos são finalizados assim que são criados
- **Tolerância a falhas bizantinas**: Funciona mesmo com até 1/3 dos nós sendo maliciosos
- **Eficiência**: Menor overhead de comunicação comparado a outros algoritmos BFT
- **Ideal para consórcios**: Perfeito para redes privadas corporativas

## Estrutura do Projeto

Criei uma estrutura organizada para facilitar o desenvolvimento:

```
block-launcher/
├── besu-qbft-docker/     # Rede Besu com QBFT
├── blockscout/           # Explorador de blocos
└── smartcontracts/       # Contratos inteligentes de exemplo
```

## Configurando a Rede Besu

### 1. Estrutura da Rede

A rede consiste em 4 nós validadores configurados com Docker Compose:

- **Validator1**: Nó inicial (bootnode) na porta 8545
- **Validator2**: Nó secundário na porta 8546
- **Validator3**: Nó terciário na porta 8547
- **Validator4**: Nó quaternário na porta 8548

### 2. Configuração do Genesis

O arquivo `genesis.json` define a configuração inicial da blockchain:

```json
{
  "config": {
    "chainId": 1337,
    "qbft": {
      "blockperiodseconds": 2,
      "epochlength": 30000,
      "requesttimeoutseconds": 4
    }
  },
  "alloc": {
    "fe3b557e8fb62b89f4916b721be55ceb828dbd73": {
      "balance": "0xad78ebc5ac6200000"
    }
  }
}
```

**Parâmetros importantes:**

- `chainId`: Identificador único da rede (1337 para desenvolvimento)
- `blockperiodseconds`: Tempo entre blocos (2 segundos)
- `epochlength`: Número de blocos por época (30000)
- `requesttimeoutseconds`: Timeout para requisições de consenso (4 segundos)

### 3. Contas Pré-Fundadas

Para facilitar o desenvolvimento e testes, o genesis.json inclui várias contas com ETH pré-fundado:

| Endereço                                   | Chave Privada                                                      | Mnemônico                                                                  | Saldo      | Comentário          |
| ------------------------------------------ | ------------------------------------------------------------------ | -------------------------------------------------------------------------- | ---------- | ------------------- |
| `fe3b557e8fb62b89f4916b721be55ceb828dbd73` | `8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` | -                                                                          | 0.1 ETH    | Conta de teste      |
| `627306090abaB3A6e1400e9345bC60c78a8BEf57` | `c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3` | -                                                                          | 90,000 ETH | Conta principal     |
| `f17f52151EbEF6C7334FAD080c5704D77216b732` | `ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f` | -                                                                          | 90,000 ETH | Conta secundária    |
| `da6c0ca76e69b32c71301356043fb56d702dfb3d` | -                                                                  | `exit warm sadness vault clip rent educate pluck gentle vehicle news verb` | 90,000 ETH | Conta com mnemônico |

**⚠️ Importante:** Estas chaves privadas e mnemônicos são **APENAS para desenvolvimento**. Em produção, nunca compartilhe ou comite chaves privadas no código.

### 4. Configurando o MetaMask

Para facilitar o desenvolvimento e testes, você pode importar essas contas no MetaMask:

#### **Opção 1: Importar por Chave Privada**

1. Abra o MetaMask
2. Clique no menu (três pontos) → "Importar conta"
3. Selecione "Chave privada"
4. Cole uma das chaves privadas da tabela acima
5. Clique em "Importar"

#### **Opção 2: Importar por Mnemônico**

1. No MetaMask, clique em "Criar/Importar carteira"
2. Selecione "Importar carteira"
3. Digite o mnemônico: `exit warm sadness vault clip rent educate pluck gentle vehicle news verb`
4. Defina uma senha e confirme

#### **Configurando a Rede Besu**

1. No MetaMask, clique em "Adicionar rede"
2. Preencha os dados:
   - **Nome da rede**: Besu QBFT Dev
   - **URL RPC**: http://localhost:8545
   - **Chain ID**: 1337
   - **Moeda**: ETH
   - **URL do explorador**: http://localhost

**💡 Dica:** Use a conta com 90,000 ETH para deploy de contratos e testes extensivos. A conta com 0.1 ETH é ideal para testes pequenos.

### 5. Configuração dos Nós

Cada nó é configurado com:

- **Identidade única**: Nome distinto para cada validator
- **Chaves de validação**: Arquivos de chave privada para assinatura de blocos
- **Configuração de rede**: IPs e portas específicas para P2P
- **Bootnodes**: Configuração para descoberta de nós

### 6. Iniciando a Rede

```bash
cd besu-qbft-docker
docker-compose up -d
```

A rede estará disponível em:

- Validator1: http://localhost:8545
- Validator2: http://localhost:8546
- Validator3: http://localhost:8547
- Validator4: http://localhost:8548

## Configurando o Blockscout

### 1. Por que Blockscout?

O Blockscout é um explorador de blockchain open-source que oferece:

- **Interface web intuitiva**: Para visualizar transações e blocos
- **API REST**: Para integração com aplicações
- **Suporte a contratos**: Verificação e visualização de contratos inteligentes
- **Métricas em tempo real**: Estatísticas da rede

### 2. Configuração

O Blockscout é configurado para se conectar à rede Besu através do arquivo `docker-compose.yml` da pasta blockscout:

```yaml
services:
  backend:
    environment:
      - ETHEREUM_JSONRPC_VARIANT=besu
      - ETHEREUM_JSONRPC_HTTP_URL=http://host.docker.internal:8545
```

### 3. Iniciando o Explorador

```bash
cd blockscout
docker-compose up -d
```

O explorador estará disponível em: http://localhost

## Testando o Ambiente

### 1. Verificando a Conexão

```bash
# Verificar se os nós estão sincronizados
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

### 2. Teste de Stress (Opcional)

Para testar a performance da rede, você pode usar o Pandora's Box:

```bash
# Instalar
npm install -g pandoras-box

# Teste com transferências ETH
pandoras-box -url http://127.0.0.1:8545 \
  -m "exit warm sadness vault clip rent educate pluck gentle vehicle news verb" \
  -t 10000 -b 500 -s 100 -o ./myOutput.json
```

## Desenvolvendo Contratos Inteligentes

### 1. Estrutura de Exemplo

Incluí um contrato simples de contador para demonstração:

```solidity
// contracts/Counter.sol
contract Counter {
    uint256 public counter;

    function increment() public {
        counter++;
    }

    function decrement() public {
        counter--;
    }
}
```

### 2. Deploy e Teste

```bash
cd smartcontracts
npm install
npx hardhat test
npx hardhat run scripts/deploy.ts --network localhost
```

## Monitoramento e Debugging

### 1. Logs dos Nós

```bash
# Ver logs de um nó específico
docker-compose logs -f validator1

# Ver logs de todos os nós
docker-compose logs -f
```

### 2. Métricas da Rede

- **Blockscout**: http://localhost (interface web)
- **APIs**: Endpoints REST para integração
- **Logs**: Informações detalhadas de cada nó

## Resolução de Problemas Comuns

### 1. Nós não sincronizam

- Verificar se as chaves estão corretas
- Confirmar se os bootnodes estão acessíveis
- Verificar logs para erros de rede

### 2. Portas já em uso

- Parar outros serviços que possam estar usando as portas
- Modificar as portas no docker-compose.yml se necessário

### 3. Problemas de permissão

- Verificar se os diretórios de dados têm permissões corretas
- Usar `sudo` se necessário para operações Docker

## Limpeza e Reset

### 1. Parando a Rede

```bash
docker-compose down
```

### 2. Resetando Dados

```bash
# Remover dados persistentes
rm -rf ./data/validator{1,2,3,4}/*

# Reconstruir containers
docker-compose up --build
```

## Próximos Passos

Com este ambiente configurado, você pode:

1. **Desenvolver contratos inteligentes** usando Solidity
2. **Testar aplicações DApp** com a rede local
3. **Implementar lógicas de negócio** específicas do seu caso de uso
4. **Integrar com sistemas existentes** através das APIs JSON-RPC
5. **Escalar a rede** adicionando mais validadores conforme necessário

## Conclusão

Configurar um ambiente de desenvolvimento blockchain corporativo não precisa ser complicado. Com as ferramentas certas e uma configuração bem estruturada, você pode ter um ambiente robusto para desenvolvimento e testes.

Este setup oferece:

- ✅ Rede Besu funcional com consenso QBFT
- ✅ Explorador de blocos completo (Blockscout)
- ✅ Ambiente Docker isolado e reproduzível
- ✅ Estrutura organizada para desenvolvimento
- ✅ Documentação clara para manutenção

Agora você tem uma base sólida para começar a desenvolver aplicações blockchain corporativas. O próximo passo é explorar os contratos inteligentes e começar a construir sua solução!

## Recursos Adicionais

- [Documentação oficial do Hyperledger Besu](https://besu.hyperledger.org/)
- [Documentação do Blockscout](https://docs.blockscout.com/)
- [Especificações QBFT](https://docs.quorum.consensys.net/en/latest/configure-and-manage/configure/consensus-protocols/qbft/)
- [Comunidade Hyperledger](https://www.hyperledger.org/community)

---

_Este post foi baseado na experiência prática de configuração de um ambiente de desenvolvimento blockchain. Se você encontrar algum problema ou tiver dúvidas, sinta-se à vontade para compartilhar nos comentários!_
