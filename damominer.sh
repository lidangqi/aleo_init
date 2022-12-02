#!/bin/sh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y

wget https://github.com/damomine/aleominer/releases/download/v1.3.0/damominer_v1.3.0.tar

mkdir -p /root/damominer1.3

tar -xvf damominer_v1.3.0.tar -C /root/damominer1.3

chmod +x /root/damominer1.3/damominer

read -p "请输入您的钱包地址 > " wallet

sed -i "s/aleoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$wallet/g" /root/damominer1.3/run_gpu.sh

/root/damominer1.3/run_gpu.sh
