from selenium_automation import automate_frontend_and_get_times
from blockchain_metrics import analyze_transaction
from plot_metrics import plot_metrics
from web3 import Web3

def main():
    frontend_url = "http://localhost:3000/"  # ganti sesuai URL frontendmu

    deployment_time, tx_completion_time, tx_hash = automate_frontend_and_get_times(frontend_url)

    w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))

    blockchain_metrics = analyze_transaction(w3, tx_hash)

    plot_metrics(deployment_time, tx_completion_time, blockchain_metrics["execution_time"], blockchain_metrics["cost_eth"])

if __name__ == "__main__":
    main()
