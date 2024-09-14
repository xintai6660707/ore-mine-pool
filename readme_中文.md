# ore-mine-pool


ore-mine-pool是为orev2实现的矿池，矿工可以更简单的进行挖矿，相对于ore-cli，更易于使用，更高效。
我们目前产出约665个/天，占全网产能46%。

## 交流

[discord](https://discord.gg/PjpqgmJkkY)

[dune](https://dune.com/oreminepool/ore-mine-pool-dashboard)

[文档](https://minership.gitbook.io/ore-mine-pool-tutorial)

## Worker 使用方法

```bash
1. git clone https://github.com/xintai6660707/ore-mine-pool.git
2. cd ore-mine-pool
3. chmod +x start.sh
4. chmod +x ore-mine-pool-linux
5. 修改start.sh中的worker-wallet-address为你的钱包地址，确保你的钱包有ORE账户，没有的话买一点点即可自动开通
6. 我们已经支持了同时进行COAL挖矿，确保你收款钱包拥有COAL账户(地址E3yUqBNTZxV8ELvW99oRLC7z4ddbJqqR4NphwrMug9zu)，如果你钱包还有没有COAL账户，购买一点点即可开通COAL账户，将自动开始同时接收COAL奖励。
7. 默认机器名是你主机的hostname，在start.sh ./ore-mine-pool-linux worker 后面添加参数修改 --alias 机器名
8. nohup ./start.sh > start.log 2>&1 & //后台启动worker
9. tail -f  worker.log //查看worker日志


暂停任务：
pkill -f start.sh
pkill -f ore-mine-pool

查看机器在线使用状态：
http://route.oreminepool.top:8080/wallet_stats/钱包地址

监控solana链上ore-mine-pool所有记录:
./ore-mine-pool-linux  monitor   --rpc-ws-url  wss://xxxxxx

仅仅监控你关注的地址的记录:
./ore-mine-pool-linux  monitor   --rpc-ws-url  wss://xxxxxx --monitor-address  your-wallet-address

将记录保存到csv,以便用excel分析
save record as csv ,for excel analysis:
./ore-mine-pool-linux  monitor   --rpc-ws-url  wss://xxxxxx   --csv_mode
```
## qubic 空闲时段，运行 ore-mine-pool的方法
```
先去 https://github.com/xintai6660707/ore-mine-pool/tree/main 下载 ore-mine-pool-linux 和 start.sh
修改start.sh的钱包地址为你的 solana钱包地址，如果没用过 ore，去 https://jup.ag/ 购买一些，0.001或者1美金即可，否则可能没有开通 ore账户
ore-mine-pool支持同时双挖 coal，同样去那里买1美金 coal即可开通账户，不用其他设置自动双挖，且 coal不占用 ore的算力，等于额外增收
cpu如果支持 numa，会自动开启相应数量的进程，多进程同时运行

Qubic.li
1.把 qli-Client、appsettings.json、ore-mine-pool-linux、start.sh 放到一个目录下
2.添加执行权限
sudo chmod+x start.sh
sudo chmod+x ore-mine-pool-linux

3.修改appsettings.json 文件如下
"idleSettings": {
    "command": "./start.sh",
    "arguments": ""
}
4.正常运行qli-Client即可

Rqiner
1.把rqiner、ore-mine-pool-linux、start.sh 放到一个目录下
2.添加执行权限
sudo chmod+x start.sh
sudo chmod+x ore-mine-pool-linux
3.运行rqiner时 加上参数 --idle-command "/root/ore/start.sh"，start.sh 必须是完整的绝对路径
比如 ./rqiner-x86-znver4 -t 32 -i GXKIBGJNGQMIHACWTLHVJSVCDXLCEZAECICMNTVRHGWRXMQKNRIJAPGBLNBO --idle-command "/root/ore/start.sh" --label 7950-1
```
## 新版本0.1.7发布：
新增连接统计，你可以访问http://route.oreminepool.top:8080/wallet_stats/钱包地址 查看你的机器使用状态。例如：http://route.oreminepool.top:8080/wallet_stats/Feei2iwqp9Adcyte1F5XnKzGTFL1VDg4VyiypvoeiJyJ
如果你使用公开池，你需要更新woker。
如果你使用自建server，你需要更新你自己的route server、server、worker。如果使用了自建route server，修改url为自建route server的url地址。否则使用自建server的url地址。

## 新版本0.1.6发布：

自建server只需要增加—mine-coal即可开启同时挖COAL

## 新版本0.1.5发布：

更新客户端和start.sh

绑定核心和使用numa。如果你使用表现不如之前版本，可以先使用0.1.4版本。

## 新版本0.1.3发布：

它只是增加了客户端的稳定性，如果你使用时有稳定性问题，那么你才需要更新。

## 新版本0.1.2发布：

1、增加了bundle批量mine功能，在server端，新增参数--per-bundle-mine-count。这个参数会将挖矿钱包列表做捆绑，当他设置为3时，会将挖矿钱包每3个作为同一笔交易发送上链。这样当server端有15个钱包时，他们被3个为一组，共5组，这样会降低竞争损失。

2、jito小费计算方式更新，修改为--base-jito-tip + 55s后间隔毫秒数 * 2，最大5w。(到达提交阶段后，每秒钟+2000小费)。

## 工作原理
我们运行pool服务端，并且使用多个钱包来获取挖矿任务，Worker定时10s获取一个当前服务端所有任务中，已有难度最低的任务，worker会进行10s的计算，将获取到的难度最高的答案提交，服务端会记录最高难度答案的提交者钱包。在任务55s需要提交时，最高难度的答案会被提交到区块链，同时收取矿工费用。

## 为什么使用ore-mine-pool-worker

##### 更高的计算效率

使用ore-cli计算时，约进行55s挖矿，然后持续1秒-数分钟提交，提交后才能继续挖矿，如每次提交耗时30s(在普通优先费情况下，这很正常)，那么效率只有55/55+30=64%.而使用ore-mine-pool-worker，每次计算10s，提交答案和获取下一个任务仅续不足0.1，效率为10/10+0.1=99%，99/64=1.54倍效率提升

##### 无间隔惩罚

使用ore-cli计算，提交时间在20-数分钟都很常见，orev2有独特的间隔惩罚，获取任务后55s进行计算，之后10s内提交获取满额奖励，10s-70s内提交奖励减半，每多1分钟再进行减半。因此使用ore-cli计算，提交时间在20-数分钟都会有奖励减半的惩罚,甚至数分钟后提交0奖励。而ore-mine-pool-worker只计算结果，我们会使用高优先费+最好的rpc进行提交，保证获取满额奖励，因此收益有2倍左右提升

##### 更好的bus选择

在ore中，存在8个bus(每个bus有1/8的奖励容量)，ore-cli使用随机一个bus提交奖励，但是在bus存在不均衡的现象，如果你随机到的bus奖励为0了，那么就这次提交奖励为0。而ore-mine-pool-worker会选择最好的bus进行提交(链上程序查看最优bus)，保证获取满额奖励。效率提升不好量化暂不统计

##### 质押奖励

orev2中，有质押的矿工提交奖励，会有1-2之间的系数提升，你使用ore-cli提交奖励，因为你质押很少，基本系数无限接近于1，而ore-mine-pool-worker收取的矿工费用，会质押，因此你的收益会随着质押金额提升而提升，最终接近于2。接近于2倍效率提升

##### 无gas费用

ore-cli提交奖励，需要消耗gas费用，在很多情况，会占用你奖励50%以上，而使用ore-mine-pool-worker，gas费用由我们承担。2倍收益提升


##### 更易于维护

我们负责与区块链交互，worder只进行简单的拉任务，计算，提交答案。不需要与繁琐的区块链交互，更易于维护

##### 安全

仅仅只需要提供钱包公钥即可，无任何私钥泄露风险

##### 透明(防欺诈)

我们会将每次任务，最终计算的hash以event方式记录，worker将提供订阅event的功能，可以查看每笔交易的详细信息，包括最终hash，worker钱包地址，金额，难度等。证明您计算出来的高难度hash，一定奖励支付给您，我们没有欺诈行为，不像其他pool那么不透明。

##### 总计收益提升

总计：最终1.54 * 2 * 2 *2=12.32倍效率提升。(当前无质押奖励，效率提升为6.16倍)

## 费用


pool-fee: 13%            (我们承担gas费用，以及server端维护)

## 链接

##### ore-mine-pool链上程序地址: [Feei2iwqp9Adcyte1F5XnKzGTFL1VDg4VyiypvoeiJyJ](https://solscan.io/account/Feei2iwqp9Adcyte1F5XnKzGTFL1VDg4VyiypvoeiJyJ)
##### program-fee账户: [链接](https://solscan.io/account/4756i3S8EPsTvKjVvUaCbP9JF8JpjQW7AmXEZnGeZDhp)


##### TODO

1、windows版本支持(已完成)

2、浏览器支持

3、worker挖矿收益订阅

4、多服务端容错，服务异常可切换(已完成)

5、链上程序输出本次任务提交的hash，方便用户验证没有欺诈行为(已完成)

6、dune图表(已完成)
