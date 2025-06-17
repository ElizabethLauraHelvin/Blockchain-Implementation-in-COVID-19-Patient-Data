from selenium import webdriver
import time
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

def automate_frontend_and_get_times(url):
    driver = webdriver.Chrome()
    driver.get(url)

    # Tunggu sampai halaman selesai dimuat
    WebDriverWait(driver, 30).until(
        lambda d: d.execute_script('return document.readyState') == 'complete'
    )

    try:
        print("Menunggu tombol Deploy...")
        deploy_button = WebDriverWait(driver, 30).until(
            EC.element_to_be_clickable((By.ID, "deployBtn"))
        )
    except TimeoutException:
        driver.save_screenshot("debug_deploy_not_found.png")
        print("Timeout: Tombol Deploy tidak ditemukan. Screenshot disimpan.")
        driver.quit()
        raise

    print("Deploy button found!")
    deploy_button.click()

    # Tunggu hingga teks "Deploy Success" muncul
    timeout = 60
    end_deploy = None
    start_deploy = time.time()
    for _ in range(timeout):
        if "Deploy Success" in driver.page_source:
            end_deploy = time.time()
            break
        time.sleep(1)

    deployment_time = end_deploy - start_deploy if end_deploy else None
    print(f"Deployment Time (UI): {deployment_time} seconds")

    # Klik tombol transaksi
    tx_button = driver.find_element(By.ID, "sendTxBtn")
    start_tx = time.time()
    tx_button.click()

    # Tunggu hingga "Tx Success" muncul
    end_tx = None
    for _ in range(timeout):
        if "Tx Success" in driver.page_source:
            end_tx = time.time()
            break
        time.sleep(1)

    tx_time = end_tx - start_tx if end_tx else None
    print(f"Transaction Completion Time (UI): {tx_time} seconds")

    # Ambil tx hash
    tx_hash_elem = driver.find_element(By.ID, "txHash")
    tx_hash = tx_hash_elem.text.strip()

    driver.quit()
    return deployment_time, tx_time, tx_hash
