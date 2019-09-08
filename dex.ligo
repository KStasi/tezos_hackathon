type storageType is record [
    totalTezos: nat;
    totalTokens: nat;
    token: address;
];

type actionBuy is record [
    amount : nat;
]

type actionTransfer is record [
    addrTo : address;
    amount : tez;
]

type action is
| BuyTez of actionBuy
| BuyToken of actionBuy

function buyTez(const action : actionBuy ; const s : storageType) : (list(operation) * storageType) is
  block { 
   const availableTez: tez = s.totalTezos * 1mtz;
   if sender  =/= s.token then fail("Permition denaed");
    else skip;
    if amount  >= availableTez then fail("Not enough tez");
    else skip;
    const tezAmount: nat = action.amount * s.totalTokens / ( s.totalTezos + action.amount);
    const totalTezos : int = s.totalTezos - tezAmount;
    const totalTokens : nat = s.totalTezos + tezAmount;
    s.totalTezos := abs(totalTezos);
    s.totalTokens := totalTokens;
    const contract : contract(unit) = get_contract(source);
    const payment : operation = transaction(unit, tezAmount * 1mtz, contract);
    const operations : list(operation) = list payment end;
  } with (operations, s)

function buyToken(const action : actionBuy ; const s : storageType) : (list(operation) * storageType) is
  block { 
   const availableTokens: tez = s.totalTokens * 1mtz;
    if amount  >= availableTokens then fail("Not enough tez");
    else skip;
    if amount  >= action.amount*1mtz then fail("Not enough tez");
    else skip;
    const tokenAmount: nat = action.amount * s.totalTezos / ( s.totalTokens + action.amount);
    const params: actionTransfer = record addrTo=sender; amount=tokenAmount*1mtz; end;
    const totalTezos : nat = s.totalTezos + tokenAmount;
    const totalTokens : int = s.totalTezos - tokenAmount;
    s.totalTezos := totalTezos;
    s.totalTokens := abs(totalTokens);
    const contract : contract(actionTransfer) = get_contract(s.token);
    const payment : operation = transaction(params, 0mtz, contract);
    const operations : list(operation) = list payment end;
  } with ((nil: list(operation)) , s)

function main(const action : action; const s : storageType) : (list(operation) * storageType) is 
 block {skip} with 
 case action of
 | BuyTez (bt) -> buyTez (bt, s)
 | BuyToken (bt) -> buyToken (bt, s)
end
