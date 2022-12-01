#!/bin/sh

echo "设置矿机编号"
read -p "请输入矿机编号 > " account_name
export account_name=$account_name
echo "安装必要的工具"
    sudo apt update -y
    sudo apt install curl -y
    sudo apt install git -y
    sudo apt install tmux -y
    sudo apt install htop -y
    sudo apt install nvtop -y

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
echo "创建work目录"
    mkdir -p /root/miner

echo "下载APP"

if [ -f /root/miner/aleo-pool-prover_ubuntu2004_gpu ]
    then
        cd /root/miner
    else
        cd /root/miner && wget https://github.com/lidangqi/hz/raw/master/aleo-pool-prover_ubuntu2004_gpu
fi

echo "修改可执行权限"
    chmod +x /root/miner/aleo-pool-prover_ubuntu2004_gpu


if [ ! "$(command -v rustc)" ]
    then 
        echo "rust没有安装,开始安装rust"
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh  -s -- -y
            source $HOME/.cargo/env
            echo "rust安装成功!"
    else
    # 判断tmux是否已存在
    # 0 = 是   1 = 否
          tmux has-session -t gpu01
          if [ $? != 0 ]
	      then
		    
		    echo "启动miner"
		    tmux new-session -s gpu01 -d
		    tmux new-session -s gpu02 -d
		    tmux new-session -s gpu03 -d
		    tmux new-session -s gpu04 -d
		    tmux new-session -s gpu05 -d
		    tmux new-session -s gpu06 -d
		    sleep 5

		    tmux send-keys -t gpu01 'export CUDA_VISIBLE_DEVICES=0 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu01 > aleo0.log 2>&1' C-m
		    sleep 5
		    tmux send-keys -t gpu02 'export CUDA_VISIBLE_DEVICES=1 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu02 > aleo1.log 2>&1' C-m
		    sleep 5
		    tmux send-keys -t gpu03 'export CUDA_VISIBLE_DEVICES=2 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu03 > aleo2.log 2>&1' C-m
		    sleep 5
		    tmux send-keys -t gpu04 'export CUDA_VISIBLE_DEVICES=3 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu04 > aleo3.log 2>&1' C-m
		    sleep 5
		    tmux send-keys -t gpu05 'export CUDA_VISIBLE_DEVICES=4 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu05 > aleo4.log 2>&1' C-m
	            sleep 5
		    tmux send-keys -t gpu06 'export CUDA_VISIBLE_DEVICES=5 && /root/miner/aleo-pool-prover_ubuntu2004_gpu --account_name $account_name --miner_name gpu06 > aleo5.log 2>&1' C-m
              else
                    echo "tmux 运行中：${Name}"
          fi
fi
