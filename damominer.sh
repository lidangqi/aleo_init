#!/bin/sh

source "$HOME/.cargo/env"
rm -rf damominer_v1.3.0.tar
rm -rf /root/damominer1.3

echo "开始安装rust"
if [ ! "$(command -v rustc)" ]
    then
        echo "rust没有安装,开始安装rust"
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
            source $HOME/.cargo/env
            echo "rust安装成功!"
    else
            version=`rustc -V`
            echo "rust已安装! ${version}"
fi

echo "下载锄头"

if [ -f /root/damominer1.3/damominer ]
    then
        cd /root/damominer1.3
    else
        mkdir -p /root/damominer1.3
        wget https://github.com/damomine/aleominer/releases/download/v1.3.0/damominer_v1.3.0.tar
        tar -xvf damominer_v1.3.0.tar -C /root/damominer1.3
        chmod +x /root/damominer1.3/damominer
        cd /root/damominer1.3
fi

read -p "请输入您的钱包地址 > " wallet

sed -i "s/aleoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$wallet/g" /root/damominer1.3/run_gpu.sh
sed -i "s/.\/damominer/\/root\/damominer1.3\/damominer/g" /root/damominer1.3/run_gpu.sh

/root/damominer1.3/run_gpu.sh
