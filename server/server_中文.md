# 服务端

### 谁需要运行ore-mine-pool服务端
大约总算力达到2M H/s以上的矿工，才需要运行ore-mine-pool server。这样你可以建立属于自己的ore挖矿集群。

### 如何运行

```bash
1、创建挖矿钱包，需要使用solana命令,将其放入与挖矿程序同目录下的keypair文件夹下
solana-keygen new --outfile keypair/wallet.json
2、给钱包转入部分sol以支付挖矿gas费用
3、使用ore mine --keypair 钱包文件，来初始化挖矿Proof账户(每个钱包一次即可)
4、后台运行server
nohup ./start.sh > start.log 2>&1 &
5、使用你的woker连接你的server，修改worker启动参数中的 --server-url 为你的server地址
```

### 如何运行 route server
如果你需要多个server，想要轮训他们以便在某个server不工作时，依旧不影响woker计算的话。你可以启动一个route server
```bash

1、当前目录下的server.json文件，server_list中填入你的server地址列表
{
  "list": [
    {
      "key": "public",
      "server_list": [
        "http://public01.oreminepool.top:8080/",
        "http://public02.oreminepool.top:8080/",
        "http://public03.oreminepool.top:8080/",
        "http://public04.oreminepool.top:8080/",
        "http://public05.oreminepool.top:8080/",
        "http://public06.oreminepool.top:8080/"
      ]
    }
  ]
}
2、运行route server，它将读取上面的配置文件
nohup ./ore-mine-pool-linux server --route  --port 8080 >> server.log 2>&1 &
3、修改你的woker启动参数中的 --route-server-url 为你的route server地址。修改--server-url为你定义server列表的key，如上demo为public
4、这样你的woker会先从route server获取最新的服务器列表，然后轮训他们做任务
```


### 安全须知
由于我们是闭源项目，使用server端会读取你的server端存储的挖矿钱包。因此你会有资金安全的担忧。

如果你不信任我们 ->  使用我们公开的矿池，这里仅仅提供钱包地址接收奖励即可

如果你有点信任我们 -> 你可以自建server端，定期补充挖矿钱包少量gas费用即可。

如果你充分信任我们 -> 你可以对钱包进行质押ore来获得质押系数，获得更多挖矿奖励。

### 调优
1、修改--priority-fee 来调整挖矿gas费用支出，它不应该低于13000(在启用--mine--coal的情况下，应该不低于6000)，否则会大幅影响上链成功率。

2、修改--base-jito-tip 来调整jito费用，目前计算规则是 base-jito-tip + 55s后间隔毫秒数 * 2，最大5w。(到达提交阶段后，每秒钟+2000小费)。

3、增加 --dynamic-gas 来支持动态gas，使用此参数后，--priority-fee  和 --base-jito-tip 参数将被覆盖

4、修改--min-difficulty 来调整最低难度要求，低于这个难度的hash，客户端将不再上报。

5、修改--per-bundle-mine-count 将挖矿钱包列表做捆绑，当他设置为3时，会将挖矿钱包每3个作为同一笔交易发送上链。这样当server端有15个钱包时，他们被3个为一组，共5组，这样会降低竞争损失。

6、增加--mine-coal 即可开启同时挖COAL，在第一次启动时，会进行ORE与COAL的proof账户同步。如果你之前ORE挖矿钱包存在质押ORE的情况，账户同步会导致提取你ORE挖矿钱包所有质押的ORE到你的挖矿钱包，你需要在同步后，重新使用ore stake命令质押。

7、钱包数量，至少2个钱包你才能享受到无缝的woker计算(在一个钱包进入提交结果阶段时，另一个在计算阶段)，建议是3个1组，3-5组，不应该超过5组。

8、如果你选择质押，又资金有限，建议使用更少的钱包来集中质押，享受更高的质押系数。维持平均难度28以上。这样你会放弃一些低难度上链(如28以下)，但是28以上会获得更高的质押系数。

9、rpc需要使用进行了sol质押的rpc供应商，以便使用支持[swQoS](https://www.helius.dev/blog/stake-weighted-quality-of-service-everything-you-need-to-know)的rpc服务，增加上链速度与成功率。如helius、triton。

### 费率

1、ORE费用：10%

2、COAL费用：同ORE，由于我们在链上程序限制了最低费用比例，所以COAL费用为10%

3、矿工自行承担gas和rpc费用

如果您觉得收费偏高，欢迎使用我们公开池和质押池，质押池享受费用后105%的收益！
