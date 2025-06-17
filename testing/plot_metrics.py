import matplotlib.pyplot as plt

def plot_metrics(deployment_time, tx_completion_time, execution_time, cost_eth):
    labels = ['Deployment Time (UI)', 'Tx Completion Time (UI)', 'Execution Time (Blockchain)']
    times = [deployment_time, tx_completion_time, execution_time]

    fig, ax1 = plt.subplots()

    color = 'tab:blue'
    ax1.set_xlabel('Metric')
    ax1.set_ylabel('Time (seconds)', color=color)
    ax1.bar(labels, times, color=color)
    ax1.tick_params(axis='y', labelcolor=color)

    ax2 = ax1.twinx()
    color = 'tab:red'
    ax2.set_ylabel('Cost (ETH)', color=color)
    ax2.plot(labels[:2], [0, 0], color='white')  # dummy for align
    ax2.plot(labels[2:], [cost_eth], 'ro')  # plot cost on last label for visual

    ax2.tick_params(axis='y', labelcolor=color)

    plt.title('Blockchain Transaction Performance Metrics')
    plt.show()
