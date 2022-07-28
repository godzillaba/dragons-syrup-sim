import os
import requests as req
from dotenv import load_dotenv
from web3 import Web3

w3 = Web3()

load_dotenv()

KEY = os.getenv("ALCHEMYKEY")
URL = "https://polygon-mainnet.g.alchemy.com/v2/" + KEY

QUICK = "0xB5C064F955D8e7F38fE0460C556a72987494eE17"
STAKING = "0xbaef1B35798bA6C2FA95d340dc6aAf284BBe2EEe"

def get_transfers(token, account_from = None, account_to = None, start_block = 0, end_block = None):
    body = {
        "jsonrpc": "2.0",
        "id": 0,
        "method": "alchemy_getAssetTransfers",
        "params": [
            {
                "fromBlock": hex(start_block),
                "contractAddresses": [token],
                "excludeZeroValue": True,
                "category": ["erc20"]
            }
        ]
    }

    if account_from != None:
        body["params"][0]["fromAddress"] = account_from
    if account_to != None:
        body["params"][0]["toAddress"] = account_to
    if end_block != None:
        body["params"][0]["toBlock"] = hex(end_block)

    headers = { "Content-Type": "application/json" }
    
    transfers = []

    while True:
        res = req.post(URL, json=body, headers=headers)
        res_json = res.json()

        for tx in res_json['result']['transfers']:
            # HACK UNDO
            # tx['from'] = tx['from'].lower()
            # tx['to'] = tx['to'].lower()
            # tx['rawContract']['address'] = tx['rawContract']['address'].lower()
            transfers.append(tx)

        if 'pageKey' in res_json['result']:
            body['params'][0]['pageKey'] = res_json['result']['pageKey']
        else:
            return transfers

def get_token_balance_timeseries(token, account, start_block = 0, end_block = None):
    account = account.lower()

    transfers = get_transfers(token, None, account, start_block=start_block, end_block=end_block)
    transfers.extend(get_transfers(token, account, None, start_block=start_block, end_block=end_block))

    def getblock(tx): return int(tx['blockNum'], 16)

    transfers.sort(key=getblock)

    balance = 0
    balances = {}

    for i,tx in enumerate(transfers):
        if tx['from'] == account:
            balance -= tx['value']
        elif tx['to'] == account:
            balance += tx['value']
        else:
            raise "fail"
        
        balances[getblock(tx)] = balance

    return balances

def get_stakers_timeseries(token, staking, start_block = 0, end_block = None):
    staking = staking.lower()

    transfers = get_transfers(token, None, staking, start_block=start_block, end_block=end_block)
    transfers.extend(get_transfers(token, staking, None, start_block=start_block, end_block=end_block))
    
    def getblock(tx): return int(tx['blockNum'], 16)

    transfers.sort(key=getblock)

    users = {}
    num_users = 0

    timeseries = {}

    for tx in transfers:
        assert(num_users >= 0)

        value = int(tx['rawContract']['value'], 16)

        if tx['from'] == staking:
            account = tx['to'].lower()

            users[account] -= value
            
            if users[account] <= 0:
                num_users -= 1
            
            assert(users[account] >= 0)
            
        elif tx['to'] == staking:
            account = tx['from'].lower()

            if account not in users:
                users[account] = 0

            if users[account] <= 0:
                num_users += 1
            
            users[account] += value

            assert(users[account] >= 0)
        else:
            raise "fail"

        timeseries[int(tx['blockNum'], 16)] = num_users

    return timeseries

def get_set_of_accounts(token, staking):
    transfers = get_transfers(token, None, staking)
    transfers.extend(get_transfers(token, staking, None))

    accounts = []

    for tx in transfers:
        if tx['from'].lower() != staking.lower():
            accounts.append(tx['from'])
        else:
            accounts.append(tx['to'])
    
    return [w3.toChecksumAddress(x) for x in list(set(accounts))]

# print(get_transfers(QUICK, STAKING, None)[0])
# print(get_token_balance_timeseries(QUICK, STAKING))

import matplotlib
import matplotlib.pyplot as plt
import numpy as np
matplotlib.use('Qt5Agg')

def plot_num_stakers():
    timeseries = get_stakers_timeseries(QUICK, STAKING)

    blocks = list(timeseries.keys())
    values = [timeseries[b] for b in blocks]

    plt.xlabel("Block Number")
    plt.ylabel("Unique Stakers")

    plt.title("Broken Syrup Contract Unique Staking Addresses")

    # print(values)
    plt.plot(blocks, values)
    plt.show()

def plot_quick_balance():
    timeseries = get_token_balance_timeseries(QUICK, STAKING)

    blocks = list(timeseries.keys())
    values = [timeseries[b] for b in blocks]

    plt.xlabel("Block Number")
    plt.ylabel("Staked QUICK")

    plt.title("Broken Syrup Contract QUICK Balance")

    # print(values)
    plt.plot(blocks, values)
    plt.show()

def save_set_of_stakers():
    accts = get_set_of_accounts(QUICK, STAKING)
    with open('./accts', 'w') as f:
        f.write(",\n".join(accts))

save_set_of_stakers()





# ##############
# def getval(tx): return -tx['value']
# transfers.sort(key=getval)

# import json
# with open('./bar', 'w') as f:
#     f.write(json.dumps(transfers, indent=4))
# exit()

# #############