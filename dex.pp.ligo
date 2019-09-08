# 1 "dex.ligo"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4











































# 32 "<command-line>" 2
# 1 "dex.ligo"
type storageTypeDex is record [
    totalTezos: nat;
    totalTokens: nat;
    token: address;
];

type balance is record [
    balance : tez;
    allowed : map(address, tez);
]

type balances is map(address, balance);

type storageType is record [
    owner : address;
    name: string;
    totalSupply: tez;
    currentSupply: tez;
    balances: balances;
    rate: nat;
];

type actionTransferFrom is record [
    addrFrom : address;
    addrTo : address;
    amount : tez;
]

type actionTransfer is record [
    addrTo : address;
    amount : tez;
]

type actionConvertToTez is record [
    dex : address;
    amount : nat;
]


type actionBuy is record [
    amount : tez;
]

type actionBuyTez is record [
    amount : nat;
]

type action is
| TransferFrom of actionTransferFrom
| Transfer of actionTransfer
| Approve of actionTransfer
| Buy of actionBuy
| ConvertToTez of actionConvertToTez

type actionDex is
| BuyTez of actionBuyTez
| BuyToken of actionBuyTez

function buyTez(const action : actionBuyTez ; const s : storageTypeDex) : (list(operation) * storageTypeDex) is
  block { 
    if sender  =/= s.token then fail("Permition denaed");
    else skip;
    const availableTez: nat = s.totalTezos;
    const tezAmount: nat = action.amount * s.totalTokens / ( s.totalTezos + action.amount);
    const totalTezos : int = s.totalTezos - tezAmount;
    const totalTokens : nat = s.totalTokens + tezAmount;
    if tezAmount  >= availableTez then fail("Not enough tez");
    else skip;
    s.totalTezos := abs(totalTezos);
    s.totalTokens := totalTokens;
    const contract : contract(unit) = get_contract(source);
    const payment : operation = transaction(unit, tezAmount * 1mtz, contract);
    const operations : list(operation) = list payment end;
  } with (operations, s)

function buyToken(const action : actionBuyTez ; const s : storageTypeDex) : (list(operation) * storageTypeDex) is
  block { 
    if amount  =/= action.amount*1mtz then fail("Not enough tez");
    else skip;
    const availableTokens: nat = s.totalTokens;
    const tokenAmount: nat = action.amount * s.totalTezos / ( s.totalTokens + action.amount);
    const totalTezos : nat = s.totalTezos + tokenAmount;
    const totalTokens : int = s.totalTokens - tokenAmount;
    if tokenAmount  >= availableTokens then fail("Not enough tez");
    else skip;
    const params: action = Transfer(record addrTo=sender; amount=tokenAmount*1mtz; end);
    s.totalTezos := totalTezos;
    s.totalTokens := abs(totalTokens);
    const contract : contract(action) = get_contract(s.token);
    const payment : operation = transaction(params, 0mtz, contract);
    const operations : list(operation) = list payment end;
  } with (operations , s)

function main(const action : actionDex; const s : storageTypeDex) : (list(operation) * storageTypeDex) is 
 block {skip} with 
 case action of
 | BuyTez (bt) -> buyTez (bt, s)
 | BuyToken (bt) -> buyToken (bt, s)
end
