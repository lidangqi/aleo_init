#!/bin/sh

echo "判断是否安装锄头"

if [ -f /root/damominer1.3/damominer ]
    then
        echo "已经安装过锄头"
        cd /root/damominer1.3
    else
        echo "没有安装锄头,开始下载安装"
        mkdir -p /root/damominer1.3
        wget https://video.8090bbs.com/damominer_v1.3.0.tar
        tar -xvf damominer_v1.3.0.tar -C /root/damominer1.3
        chmod a+x /root/damominer1.3/damominer
        cd /root/damominer1.3

        source "$HOME/.cargo/env"
        echo "判断是否安装rust"
        if [ ! "$(command -v rustc)" ]
            then
                echo "rust没有安装,开始安装rust"
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
                    source "$HOME/.cargo/env"
                    echo "rust安装成功!"
            else
                    version=`rustc -V`
                    echo "rust已安装! ${version}"
        fi

        chmod a+x /root/damominer1.3/damominer

        read -p "请输入您的钱包地址 > " wallet
        sleep 15
        
        sed -i "s/aleoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$wallet/g" /root/damominer1.3/run_gpu.sh
        sed -i "s/.\/damominer/\/root\/damominer1.3\/damominer/g" /root/damominer1.3/run_gpu.sh

fi

killall damominer
/root/damominer1.3/run_gpu.sh
