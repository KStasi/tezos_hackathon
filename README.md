# Contracts overview 

This project is designed to provide a decentralized way to exchange Tokens to Tez and vice versa.
The [Bancor](https://medium.com/@shorupan/dex-deep-dive-bancor-bnt-protocol-explained-418bab851fb2) approach is used. To make the DEX more universal the standard token was proposed. 

Contracts are implemented on [Ligo](https://ligolang.org/). 

## Token

Before launching the dex we need to agree on the token interface. As the [ERC20](https://en.wikipedia.org/wiki/ERC-20) is quite suitable for given purposes, this contract is ERC20-like implementation on Tezos.

Apart from the standard interface, some extra functions were implemented. 

`buy` is the function to get initial tokens with a fixed price, it can be removed or changed to mint or any other functions which apply the logic of token distribution.
`convertToTez` is a part of DEX logic. As in Tesos smart contracts, there is no way to know the state of another contract and check if tokens were sent during transaction execution we need to assure tokens were attaches to DEX exchange. This method transfers tokens to DEX address and just after that triggers Dex contract to claim Tez.

## Dex

The contract provides methods for exchange. Dex allows exchange only one Token type(identified by address) because during the exchange from Token to Tez it waits for transaction only from Token contract. This approach prevents users to try to exchange worthless tokens to Tez and makes then approve the transfer. In future, this mechanism can be improved be allowed a number of tokens added by Dex owner and stored in the storage.

`buyTez` is listened to Token calls. If all requirements are met exchange from Token to Tez is executed.
`buyToken` is the method triggered by the user. It analyzes the attached amount of Tez and exchanges it to Tokens.

Before using Dex some initial amount of Tez and Tokens should be sent to its address.
 
## Usage

Contracts can be compiled, deployed and tested with commands in `commands.txt`.