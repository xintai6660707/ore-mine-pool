# Server

### Who needs to run ore-mine-pool server
Miners with a total hash rate of approximately 2M H/s or more need to run the ore-mine-pool server. This way, you can establish your own ore mining cluster.

### How to run

```bash
1. Create a mining wallet using the solana command and place it in the keypair folder in the same directory as the mining program.
solana-keygen new --outfile keypair/wallet.json
2. Transfer some SOL to the wallet to pay for mining gas fees.
3. Use ore mine --keypair wallet file to initialize the mining Proof account (only once per wallet).
4. Run the server in the background.
nohup ./start.sh > start.log 2>&1 &
5. Connect your worker to your server by modifying the --server-url parameter in the worker startup parameters to your server address.
```


### Security Notice
Since we are a closed-source project, using the server will read the mining wallet stored on your server. Therefore, you may have concerns about fund security.  

If you do not trust us -> Use our public mining pool, where you only need to provide a wallet address to receive rewards. 

If you somewhat trust us -> You can set up your own server and periodically replenish the mining wallet with a small amount of gas fees.  

If you fully trust us -> You can stake ore in the wallet to get a staking coefficient and earn more mining rewards.

### Optimization

1.Modify --priority-fee to adjust the mining gas fee expenditure. It should not be less than 13000, otherwise, it will significantly affect the success rate of on-chain transactions.  

2.Modify --base-jito-tip to adjust the jito fee. The current calculation rule is (task difficulty - 14) * 2000 + base-jito-tip.  

3.Modify --min-difficulty to adjust the minimum difficulty requirement. Hashes below this difficulty will no longer be reported by the client.  

4.Wallet quantity: You need at least 2 wallets to enjoy seamless worker computation (one wallet in the result submission phase while the other is in the computation phase). The recommendation is 3-5 wallets, and it should not exceed 5.  

5.If you choose to stake and have limited funds, it is recommended to use fewer wallets to concentrate staking and enjoy a higher staking coefficient. Maintain an average difficulty above 28. This way, you will forgo some low-difficulty on-chain transactions below 28, but above 28, you will get a higher staking coefficient.

6.The current highest staking user fluctuates between 270-441. To make staking more efficient, it is recommended to stake below 270 per wallet.  

7.The rpc needs to use an rpc provider that has staked sol to use the swQoS rpc service, increasing the speed and success rate of on-chain transactions, such as helius and triton.  

### Fees

1.15%(All our fees are stake into the stake pool, and when the total amount of the pledge pool reaches 4000 ore, it will be reduced to 10%)

2.Miners bear the gas and rpc fees themselves.

If you think the fee is too high, feel free to use our public pool and staking pool, where the staking pool enjoys a 105% return after fees!