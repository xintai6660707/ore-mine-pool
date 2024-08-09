# ore-mine-pool


ore-mine-pool是为orev2实现的矿池，矿工可以更简单的进行挖矿，相对于ore-cli，更易于使用，更高效

## 交流

[discord](https://discord.gg/DeATb7MS)


## Worker 使用方法

```bash
1. git clone https://github.com/xintai6660707/ore-mine-pool.git
2. cd ore-mine-pool
3. chmod +x start.sh
4. chmod +x ore-mine-pool-linux
5. 修改start.sh中的worker-wallet-address为你的钱包地址，并且确保钱包已经有对应的ore AssociatedToken地址
6. 修改start.sh中的threads为你cpu的线程数
6. 如果没有ore钱包地址，可以使用 ./ore-mine-pool-linux create-associated-token --keypair "你的钱包私钥地址" --priority-fee 20000 创建ore关联账户(你有考虑私钥安全，也可以自己创建)
7. nohup ./start.sh > start.log 2>&1 & //后台启动worker
8. tail -f  worker.log //查看worker日志


暂停任务：
pkill -f start.sh
pkill -f ore-mine-pool
```

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

##### 总计收益提升

总计：最终1.54 * 2 * 2 *2=12.32倍效率提升。(当前无质押奖励，效率提升为6.16倍)

## 费用

onchain-program-fee: 2% (提供最好的bus选择，以及奖励分发功能)

pool-fee: 8%            (我们承担gas费用，以及server端维护)

## 链接

##### ore-mine-pool链上程序地址: [Feei2iwqp9Adcyte1F5XnKzGTFL1VDg4VyiypvoeiJyJ](https://solscan.io/account/Feei2iwqp9Adcyte1F5XnKzGTFL1VDg4VyiypvoeiJyJ)
##### program-fee账户: [链接](https://solscan.io/account/4756i3S8EPsTvKjVvUaCbP9JF8JpjQW7AmXEZnGeZDhp)

##### worker:
[worker0](https://solscan.io/account/H2VLeBDZFXZa591QkGGutTG8cF2RQUS49T2uZZyS5FcX) 使用96核cpu

[worker1](https://solscan.io/account/92Zguk3WKznDU57u3rTJtKsib9vGGCnMxMZ9LyBCWork)使用48核cpu

#####TODO
1、windows版本支持
2、浏览器支持
3、worker挖矿收益订阅
4、多服务端容错，服务异常可切换
5、链上程序输出本次任务提交的hash，方便用户验证没有欺诈行为
6、dune图表