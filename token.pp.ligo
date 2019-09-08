# 1 "token.ligo"
# 1 "<built-in>"
# 1 "<command-line>"
# 31 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4

# 17 "/usr/include/stdc-predef.h" 3 4











































# 32 "<command-line>" 2
# 1 "token.ligo"
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


function buy(const action : actionBuy ; const s : storageType) : (list(operation) * storageType) is
  block { 
    const availableSupply: tez = s.totalSupply - s.currentSupply;
    if amount  > availableSupply then fail("Total supply overruned");
    else skip;
    const balancesMap : balances = s.balances;
    const tokensAmount: tez = amount * s.rate;
    s.currentSupply := s.currentSupply + tokensAmount;
    const balanceFromInfo : balance = case balancesMap[sender] of
    | None -> record balance = 0mtz; allowed = ((map end) : map(address, tez)); end
    | Some(b) ->  get_force(sender, balancesMap)
    end;
    const allowed: map(address, tez) = balanceFromInfo.allowed;
    const balance: tez = balanceFromInfo.balance + tokensAmount;
    allowed[sender] := balance; 
    balancesMap[sender] := record 
        balance = balance;
        allowed = allowed;
    end;
    s.balances := balancesMap;
  } with ((nil: list(operation)) , s)

function transferFrom(const action : actionTransferFrom ; const s : storageType) : (list(operation) * storageType) is
  block {
    const balancesMap : balances = s.balances;
    const balanceFromInfo : balance = case balancesMap[sender] of
    | None -> record balance = 0mtz; allowed = ((map end) : map(address, tez)); end
    | Some(b) -> get_force(action.addrFrom, s.balances)
    end;

    const awailableAmount: tez = balanceFromInfo.balance;
    if action.amount > awailableAmount then fail("The amount isn't awailable")
    else skip;

    const allowedAmont: tez = case balanceFromInfo.allowed[sender] of
    | None -> 0mtz
    | Some(b) -> get_force(sender, balanceFromInfo.allowed)
    end;

    if action.amount > allowedAmont then fail("The amount isn't awailable")
    else skip;


    const balanceToInfo : balance = case balancesMap[action.addrTo] of
    | None -> record balance = 0mtz; allowed = ((map end) : map(address, tez)); end
    | Some(b) -> get_force(action.addrTo, s.balances)
    end;
    const allowed: map(address, tez) = balanceFromInfo.allowed;
    allowed[sender] :=  allowedAmont - action.amount;
    allowed[action.addrFrom] :=  awailableAmount - action.amount;

    balancesMap[action.addrFrom] := record 
        balance = awailableAmount - action.amount;
        allowed = allowed;
    end;
    balancesMap[action.addrTo] := record 
        balance = awailableAmount + action.amount;
        allowed = balanceToInfo.allowed;
    end;
    s.balances := balancesMap;
   } with ((nil: list(operation)) , s)

function transfer(const action : actionTransfer ; const s : storageType) : (list(operation) * storageType) is
  block {
        const act: actionTransferFrom = record addrFrom=sender; addrTo=action.addrTo; amount=action.amount end;
   } with transferFrom (act, s)

function convertToEth(const action : actionConvertToTez ; const s : storageType) : (list(operation) * storageType) is
  block {
        const act: actionTransferFrom = record addrFrom=sender; addrTo=action.dex; amount=action.amount*1mtz end;
        const params: actionBuyTez = record amount=action.amount; end;
        const contract : contract(actionBuyTez) = get_contract(action.dex);
        const payment : operation = transaction(params, 0mtz, contract);
        const operations : list(operation) = list payment end;
        const transferOPeration: (list(operation) * storageType) = transferFrom (act, s);
  } with (operations, transferOPeration.1)


function approve(const action : actionTransfer ; const s : storageType) : (list(operation) * storageType) is
  block { skip
    // const balancesMap : balances = s.balances;
    // const balanceFromInfo : balance = case balancesMap[sender] of
    // | None -> record balance = 0mtz; allowed = ((map end) : map(address, tez)); end
    // | Some(b) -> get_force(sender, balancesMap)
    // end;
    // const amount: tez = balanceFromInfo.balance;
    // if action.amount < amount then fail("The amount isn't awailable")
    // else skip;
    // const allowed:  map(address, tez) = balanceFromInfo.allowed;
    // allowed[action.addrTo] := action.amount;
    // balancesMap[sender] := record 
    //     balance = balanceFromInfo.balance;
    //     allowed = allowed;
    // end;
    // s.balances := balancesMap;
   } with ((nil: list(operation)) , s)


function main(const action : action; const s : storageType) : (list(operation) * storageType) is 
 block {skip} with 
 case action of
 | Buy (bt) -> buy (bt, s)
 | Transfer (tx) -> transfer (tx, s)
 | TransferFrom (tx) -> transferFrom (tx, s)
 | Approve (at) -> approve (at, s)
end

