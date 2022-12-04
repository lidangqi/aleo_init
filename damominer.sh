#!/bin/sh

echo "判断是否安装锄头"
VERSION=$(curl -sL https://api.github.com/repos/damomine/aleominer/releases | jq -r ".[0].tag_name")
echo "VERSION=$VERSION"

if [ -f /root/damominer_$VERSION/damominer ]
    then
        echo "已经安装过锄头"
        cd /root/damominer_$VERSION
    else
        echo "没有安装锄头,开始下载安装"
        mkdir -p /root/damominer_$VERSION
        if [ -f /root/damominer_$VERSION.tar ]
            then 
               tar -xvf damominer_$VERSION.tar -C /root/damominer_$VERSION
               chmod a+x /root/damominer_$VERSION/damominer
               cd /root/damominer_$VERSION
            else
               wget https://github.com/damomine/aleominer/releases/download/$VERSION/damominer_$VERSION.tar
               tar -xvf damominer_$VERSION.tar -C /root/damominer_$VERSION
               chmod a+x /root/damominer_$VERSION/damominer
               cd /root/damominer_$VERSION
        fi

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

        chmod a+x /root/damominer_$VERSION/damominer

        read -p "请输入您的钱包地址 > " wallet
        
        sleep 8
        
        read -p "请输入机器编号 > " workername
        
        sleep 8

        sed -i "s/aleoxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx/$wallet/g" /root/damominer_$VERSION/run_gpu.sh
        sed -i "s/.\/damominer/\/root\/damominer_$VERSION\/damominer/g" /root/damominer_$VERSION/run_gpu.sh
        sed -i "s/>>/--worker $workername >>/g" /root/damominer_$VERSION/run_gpu.sh
        sed -i "s/asia1/aleo1/g" /root/damominer_$VERSION/run_gpu.sh

fi
sed -i "s/asia1/aleo1/g" /root/damominer_$VERSION/run_gpu.sh

killall damominer
/root/damominer_$VERSION/run_gpu.sh
