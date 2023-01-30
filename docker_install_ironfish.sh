#!/bin/bash

# 字体颜色配置
Yellow="\033[33m"
Green="\033[32m"
Red="\033[31m"
Blue="\033[36m"
Font="\033[0m"

# 提示
INFO="[${Green}Info${Font}]"
ERROR="[${Red}Error${Font}]"
TIP="[${Green}Tip${Font}]"

yellow() {
    echo -e "${Yellow} $1 ${Font}"
}

green() {
    echo -e "${Green} $1 ${Font}"
}

red() {
    echo -e "${Red} $1 ${Font}"
}

blue() {
    echo -e "${Blue} $1 ${Font}"
}

check_root() {
    [[ $EUID != 0 ]] && {
        if [ "$LANGUAGE" == "cn" ]; then
            echo -e "${ERROR} 当前非 root 账号, 无法继续操作. 请更换 root 账号或使用 ${Blue}sudo su${Font} 命令获取临时 root 权限 (执行后可能会提示输入当前账号的密码)."
        else
            echo -e "${ERROR} The current non-root account cannot continue to operate. Please change the root account or use the ${Blue}sudo su${Font} command to obtain temporary root privileges (after execution, you may be prompted to enter the password of the current account) "
        fi
    } && exit 1
}

#1
install_docker_ironfish(){
    
    echo "---开始安装docker..."
    sudo apt-get update -y
    sudo apt-get install -y docker.io 
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    echo "docker 安装完成！"
    sleep 2
    echo "---开始安装ironfish..."
    read -p " ---输入您的Graffiti名称:" name
    echo "---当前输入： $name"
    read -r -p "---请确认输入是否正确？ [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---继续安装ironfish..."
            ;;

        *)
            echo "退出安装!"
            exit 1
            ;;
    esac
    echo "---开始拉取ironfish镜像..."
    sudo docker pull ghcr.io/iron-fish/ironfish:latest
    echo "---启动ironfish，docker名为 node"
    sudo docker run -itd --name node --net host --volume /root/.node:/root/.ironfish ghcr.io/iron-fish/ironfish:latest start
    sleep 10
    echo "---开始配置节点..."
    sudo docker exec -it node bash -c "ironfish testnet $name"
    sleep 2
    sudo docker exec -it node bash -c "ironfish config:set blockGraffiti $name"
    sleep 2
    sudo docker exec -it node bash -c "ironfish config:set enableTelemetry true"
    sleep 2
    sudo docker exec -it node bash -c "ironfish wallet:create $name"
    sleep 2
    sudo docker exec -it node bash -c "ironfish wallet:use $name"
    echo "安装完成！"
}

#2
ironfish_status(){
    echo "---开始检查节点状态..."
    sudo docker exec -it node bash -c "ironfish status"
}

#3
ironfish_miner(){
    read -r -p "---请确认节点状态 Connected？ synced？ [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---开始启动挖矿..."
            ;;

        *)
            echo "请等待节点同步后再试！"
            exit 1
            ;;
    esac

    echo "---当前钱包地址为："
    sudo docker exec -it node bash -c "ironfish wallet:address"
    echo "---开始挖矿..."
    echo "---默认连接官方池..."
    read -p "---输入您的钱包地址PulicKey:" key
    sudo docker exec -it node bash -c "ironfish miners:start --pool pool.ironfish.network --address $key"
}

#4
ironfish_wallet(){
    echo "---当前钱包信息："
    sudo docker exec -it node bash -c "ironfish wallet:balance"
    sudo docker exec -it node bash -c "ironfish wallet:notes"
}

#5
ironfish_asset(){
    graffiti_name=$(sudo docker exec -it node bash -c "ironfish config | grep blockGraffiti | awk '{print \$2}'")
    graffiti_name=$(echo $graffiti_name | tr -d '\r " ,')
    echo "涂鸦号: $graffiti_name"
    ACCOUNT_NAME=$(sudo docker exec -it node bash -c "ironfish wallet:which")
    ACCOUNT_NAME=$(echo $ACCOUNT_NAME | tr -d '\r')
    IRON_BALANCE=$(sudo docker exec -it node bash -c "ironfish wallet:balance | grep Balance | awk '{print $NF}'")
    assetId=$(sudo docker exec -it node bash -c "ironfish wallet:balances |grep $graffiti_name | grep -v Account | tail -1 | awk '{print \$2}'")
    assetId=$(echo $assetId | tr -d '\r')
    #graffiti_name=$(ironfish wallet:address | awk '{print $2}' | sed -e 's/,//g')
    echo "---开始操作ironfish asset..."
    while true
    do
    green " ========================================== "
    yellow " 1. 铸造"
    yellow " 2. 燃烧"
    yellow " 3. 发送"
    yellow " 0. 返回"
    green " ========================================== "
    read -r -p " ---请选择操作:" num
    case "$num" in
    1)
        echo "您的涂鸦号: $graffiti_name"
        sudo docker exec -it node bash -c "ironfish wallet:mint --metadata $graffiti_name --name $graffiti_name --amount 10000 --fee 0.00000001 --confirm"
        ;;
    2)  
        echo "您的涂鸦号: $graffiti_name"
        echo "您的涂鸦号assetId: $assetId"
        sudo docker exec -it node bash -c "ironfish wallet:burn --assetId $assetId --amount 100 --fee 0.00000001 --confirm"
        ;;
    3)  
        echo "您的涂鸦号: $graffiti_name"
        echo "您的涂鸦号assetId: $assetId"
        read -p "请输入public address(Enter:官方地址):  " public_address
        if [ -z "$public_address" ]; then
            public_address=dfc2679369551e64e3950e06a88e68466e813c63b100283520045925adbe59ca
        fi
        sudo docker exec -it node bash -c "ironfish wallet:send --to $public_address --assetId $assetId --amount 100 --fee 0.00000001 --confirm"
        ;; 
    0)
        break
        ;;
    esac

    done
}

#6
ironfish_cli(){
    echo "---进入ironfish控制台..."
    sudo docker exec -it node bash 
}

#7
ironfish_restart(){
    echo "---启动node节点，如失败请尝试重新安装..."
    sudo docker start node
}

#8
ironfish_update(){
    
    read -r -p "---更新可能丢失钱包数据，是否继续 [Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "---开始更新..."
            sudo docker pull ghcr.io/iron-fish/ironfish:latest
            echo "---删除旧版节点..."
            sudo docker stop node
            sudo docker rm node
            echo "--旧版本docker节点已删除！"
            sleep 5
            echo "--启动新版本docker节点..."
            sudo docker run -itd --name node --net host --volume /root/.node:/root/.ironfish ghcr.io/iron-fish/ironfish:latest start --upgrade
            echo "---启动成功，升级完成！"
            ;;
        *)
            echo "---停止更新！"
            exit 1
            ;;
    esac

}

ironfish_faucet(){
    echo "水龙头"
    sudo docker exec -it node bash -c "ironfish faucet"
}

ironfish_logs(){
    docker logs node --tail 100
}

#8 功能补充区
main(){
    
    clear

    while true
    do
    green "============================================"
    green "           ironfish 一键安装管理脚本"
    green "                 Allen_Li  2023-01-29"
    green " ==========================================="
    yellow "1. 安装 docker 和 Ironfish"
    yellow "2. 检查 node状态"
    yellow "3. 开始 miner挖矿"
    yellow "4. 查看 Wallet信息"
    yellow "5. 操作 Asset 铸造，燃烧，发送"
    yellow "6. 进入 Ironfish控制台"
    yellow "7. 重启节点"
    yellow "8. 版本更新"
    yellow "9. 水龙头"
    yellow "10. 查看node日志"
    yellow "0. 退出"
    read -r -p " 请选择操作:" num
    case "$num" in
    1)
        install_docker_ironfish
        ;;
    2)
        ironfish_status
        ;;
    3)
        ironfish_miner
        ;;
    4)
        ironfish_wallet
        ;;
    5)
        ironfish_asset
        ;;
    6)
        ironfish_cli
        ;;
    7)
        ironfish_restart
        ;;
    8)
        ironfish_update
        ;;
    9)
        ironfish_faucet
        ;;
    10)
        ironfish_logs
        ;;
    0)
        echo "---退出程序！"
        exit
        ;;
    *)
        echo
        echo -e " ${Error} 请选择正确操作："
        ;;
    esac

    done
}

main
