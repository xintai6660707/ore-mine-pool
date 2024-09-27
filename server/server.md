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

1.Modify --priority-fee to adjust the mining gas fee expenditure. It should not be less than 13000(If you add --mine-coal, then it should be not less than 6000), otherwise, it will significantly affect 
the success rate of on-chain transactions.

2.Modify --base-jito-tip to adjust the jito fee. The current calculation rule is (task difficulty - 14) * 2000 + base-jito-tip.  

3.Modify --min-difficulty to adjust the minimum difficulty requirement. Hashes below this difficulty will no longer be reported by the client.  

4.Add --dynamic-gas to support dynamic gas cost, When this parameter is used, the --priority-fee and --base-jito-tip parameters are overridden 

5.Modify --per-bundle-mine-count to bundle the list of mining wallets, and when it is set to 3, every 3 mining wallets will be sent to the chain as the same transaction. In this way, when there are 15 wallets on the server side, they are grouped by 3 for a total of 5 wallets, which will reduce the competition loss.

6.Add --mine-coal so that ORE and COAL will be double mining. The ORE and COAL proof accounts are synchronized at the first startup. If you had ORE stake in your ORE mining wallet before, account synchronization will result in the withdrawal of all ORE stake in your ORE mining wallet to your mining wallet, and you will need to re-stake the ore stake command after synchronization.

7.Wallet quantity: You need at least 2 wallets to enjoy seamless worker computation (one wallet in the result submission phase while the other is in the computation phase). The recommendation is 3-5 wallets, and it should not exceed 5.  

8.If you choose to stake and have limited funds, it is recommended to use fewer wallets to concentrate staking and enjoy a higher staking coefficient. Maintain an average difficulty above 28. This way, you will forgo some low-difficulty on-chain transactions below 28, but above 28, you will get a higher staking coefficient.

9.The rpc needs to use an rpc provider that has staked sol to use the swQoS rpc service, increasing the speed and success rate of on-chain transactions, such as helius and triton.  

### Fees

1.ORE: 10%

2.COAL: With ORE, the COAL fee is 10% due to our on-chain procedure limiting the minimum expense percentage

3.Miners bear the gas and rpc fees themselves.

If you think the fee is too high, feel free to use our public pool
