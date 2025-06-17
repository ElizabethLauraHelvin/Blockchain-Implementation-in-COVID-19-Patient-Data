from web3 import Web3

def analyze_transaction(w3, tx_hash):
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    block = w3.eth.get_block(receipt.blockNumber)

    gas_used = receipt.gasUsed
    gas_price = w3.eth.gas_price  # bisa juga receipt.gasPrice tergantung node

    # Timestamp block
    block_timestamp = block.timestamp

    # Untuk execution time, kita bisa estimasi beda waktu blok sebelumnya dan sekarang
    prev_block = w3.eth.get_block(receipt.blockNumber - 1)
    prev_timestamp = prev_block.timestamp

    execution_time = block_timestamp - prev_timestamp

    cost_eth = gas_used * gas_price / 1e18  # ETH

    return {
        "gas_used": gas_used,
        "gas_price": gas_price,
        "cost_eth": cost_eth,
        "execution_time": execution_time,
        "block_number": receipt.blockNumber,
        "block_timestamp": block_timestamp
    }
