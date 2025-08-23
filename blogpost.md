# Configurando um Ambiente de Desenvolvimento Hyperledger Besu com QBFT e Blockscout

## Introdução

Depois de ver diversas palestras e discussões sobre blockchain, me faltava a compreensão prática do funcionamento da tecnologia. Conceitos como "descentralização", "contratos inteligentes" e "tokens", podem em um primeiro momento serem abstratos demais para uma compreensão das possibilidades que a tecnologia fornece.Entretando a documentação da tecnologia pode ser um pouco desafiadora para quem está começando.

Minha curiosidade real veio com o anúncio de que o Banco Central do Brasil iria utilizar blockchain na CBDC (Central Bank Digital Currency) do DREX, agora não mais, o que me fez querer entender como essa tecnologia realmente funcionava por baixo dos panos. O objetivo deste post é poupar o tempo de quem também quer entender como essa tecnologia funciona na prática, provendo um repositório com o ferramental para executar uma rede privada de Hyperledger Besu e exemplos de contratos, incluindo o deploy de um token ERC-20 que é utilizado para representar stablecoins na rede Ethereum e o ERC-721, utilizado para representação de tokens não fungíveis (NFT).

Neste post, vou te mostrar **exatamente** como configurar um ambiente de desenvolvimento Hyperledger Besu com QBFT que **funciona de verdade**. Sem promessas vazias, sem (muitos) conceitos abstratos - apenas código funcional e configurações que você pode usar imediatamente.

Vou compartilhar os desafios reais que enfrentei, as soluções que implementei e todo o código que você precisa.

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

### 4. Iniciando o Ambiente

Antes de configurar o MetaMask, você precisa iniciar o ambiente completo. Para isso, use o Makefile que está na raiz do projeto:

```bash
# Na raiz do projeto
make start
```

Este comando irá:

1. **Iniciar a rede Besu** com 4 validadores QBFT
2. **Iniciar o Blockscout** como explorador de blocos (acessível em http://localhost/)
3. **Configurar a rede** na porta 1337 (Chain ID 1337)

**⏱️ Aguarde alguns minutos** para que todos os serviços estejam funcionando. Você pode verificar o status com:

```bash
# Ver logs dos serviços
docker-compose logs -f

# Ou parar os serviços se necessário
make stop
```

### 5. Configurando o MetaMask

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

**🚀 Recomendação para Deploy:** Recomendo importar a chave privada `8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63` (conta com 0.1 ETH), pois será a conta utilizada para fazer deploy dos contratos inteligentes neste tutorial.

## Explorador de Blocos (Blockscout)

O Blockscout é um explorador de blockchain open-source que oferece:

- **Interface web intuitiva**: Para visualizar transações e blocos
- **API REST**: Para integração com aplicações
- **Suporte a contratos**: Verificação e visualização de contratos inteligentes
- **Métricas em tempo real**: Estatísticas da rede

**✅ Já configurado e iniciado** pelo comando `make start` - acesse em http://localhost/

## Desenvolvendo Contratos Inteligentes

### 1. O que é ERC-20?

**ERC-20** é um padrão técnico para tokens fungíveis na blockchain Ethereum. Ele define um conjunto de regras que todos os tokens devem seguir para serem compatíveis com a rede e com outras aplicações (wallets, exchanges, etc.).

**Características principais:**

- **Fungibilidade**: Cada token é idêntico e intercambiável
- **Padrão universal**: Funciona em qualquer wallet ou exchange que suporte Ethereum
- **Funcionalidades básicas**: Transferência, aprovação, consulta de saldo
- **Extensível**: Pode adicionar funcionalidades customizadas

**Exemplos de uso:** Stablecoins (USDT, USDC), tokens de governança, moedas de aplicações

### 2. Contrato BRLT - Token ERC-20

O contrato BRLT é um token ERC-20 que representa uma moeda digital brasileira. Vamos analisar o código:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BRLT is ERC20 {
    constructor() ERC20("BRLT", "BRLT") {
        _mint(msg.sender, 100000*10**18);
    }
}
```

**O que este contrato faz:**

- **Nome**: "BRLT" (Brazilian Real Token)
- **Símbolo**: "BRLT"
- **Supply inicial**: 100.000 tokens (com 18 casas decimais)
- **Destinatário**: Quem faz o deploy (msg.sender)
- **Herança**: Usa a implementação OpenZeppelin (segura e testada)

### 3. Deploy do Contrato BRLT

Para fazer o deploy do token BRLT na rede Besu:

```bash
cd smartcontracts
make deploy-brlt
```

Este comando irá:

1. **Compilar** o contrato
2. **Fazer deploy** na rede Besu (Chain ID 1337)
3. **Mintar** 100.000 BRLT para a conta do deployer
4. **Retornar** o endereço do contrato deployado

### 4. Importando o Token no MetaMask

Após o deploy, você pode importar o token BRLT no MetaMask para visualizá-lo e fazer transações:

#### **Passo a passo:**

1. **Abra o MetaMask** e certifique-se de estar conectado à rede Besu (Chain ID 1337)
2. **Clique em "Importar tokens"** na aba de ativos
3. **Cole o endereço do contrato** BRLT que foi retornado no deploy
4. **Confirme os detalhes** do token (nome: BRLT, símbolo: BRLT, decimais: 18)
5. **Clique em "Adicionar token"**

#### **Fazendo transações:**

- **Transferir BRLT**: Use a função "Enviar" para transferir tokens para outras contas
- **Ver saldo**: O saldo de BRLT aparecerá na lista de ativos
- **Histórico**: Todas as transações ficam registradas na blockchain

**💡 Dica:** Após importar, você verá 100.000 BRLT na conta que fez o deploy. Pode transferir parte desses tokens para outras contas para testar as funcionalidades!

### 5. Contrato Bound - Token ERC-721 (NFT)

O contrato Bound é um token **ERC-721** (NFT - Non-Fungible Token) que representa ativos únicos e não intercambiáveis. Diferente do ERC-20, cada token Bound é único e pode ter metadados específicos.

**O que é ERC-721:**

- **Não-fungível**: Cada token é único e não pode ser substituído por outro igual
- **Metadados únicos**: Cada token pode ter informações específicas (URI)
- **Propriedade**: Representa posse de um ativo digital único
- **Colecionáveis**: Ideal para arte digital, itens de jogo, documentos únicos

**Vamos analisar o código:**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Bound is ERC721URIStorage {
    uint256 private _nextTokenId;
    address private _owner;

    constructor() ERC721("Bound", "BOUND") {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    function createBound(address boundOwner, string memory tokenURI) public onlyOwner {
        _nextTokenId++;
        _safeMint(boundOwner, _nextTokenId);
        _setTokenURI(_nextTokenId, tokenURI);
    }
}
```

**O que este contrato faz:**

- **Nome**: "Bound" (representa ativos vinculados)
- **Símbolo**: "BOUND"
- **Controle de acesso**: Apenas o owner pode criar novos tokens
- **Mint automático**: Cada novo token recebe um ID único sequencial
- **Metadados**: Cada token pode ter uma URI específica com informações

### 6. Deploy do Contrato Bound

Para fazer o deploy do contrato Bound na rede Besu:

```bash
cd smartcontracts
make deploy-bound
```

Este comando irá:

1. **Compilar** o contrato
2. **Fazer deploy** na rede Besu (Chain ID 1337)
3. **Criar 5 tokens Bound** automaticamente (NTNB-1 até NTNB-5)
4. **Definir URIs** para cada token com metadados específicos
5. **Retornar** o endereço do contrato deployado

### 7. Importando o NFT Bound no MetaMask

Após o deploy, você pode importar os NFTs Bound no MetaMask:

#### **Passo a passo:**

1. **Abra o MetaMask** e certifique-se de estar conectado à rede Besu
2. **Clique em "Importar NFTs"** na aba de ativos
3. **Cole o endereço do contrato** Bound que foi retornado no deploy
4. **Digite o ID do token** (1, 2, 3, 4 ou 5)
5. **Clique em "Adicionar"**

#### **Visualizando os NFTs:**

- **5 tokens únicos**: NTNB-1, NTNB-2, NTNB-3, NTNB-4, NTNB-5
- **Metadados específicos**: Cada token tem uma URI única
- **Propriedade**: Tokens são criados para a conta do deployer
- **Transferência**: Pode transferir NFTs para outras contas

**💡 Dica:** Os NFTs Bound representam ativos únicos como títulos públicos digitais. Cada um tem um ID único e metadados específicos, tornando-os ideais para representar documentos ou ativos únicos na blockchain!

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
