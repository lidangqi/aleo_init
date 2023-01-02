# 自启动脚本

export url='https://raw.githubusercontent.com/lidangqi/aleo_init/master' && sh -c "$(curl -kfsSl $url/install.sh)" && source /etc/profile &> /dev/null

使用方式：

使用curl安装damominer：

``` export url='https://githubproxy.allen-li.workers.dev/https://raw.githubusercontent.com/lidangqi/aleo_init/master' && sh -c "$(curl -kfsSl $url/damominer.sh)" && source /etc/profile &> /dev/null ```

备注:安装过程中会提示输入钱包地址,需提前准备好aleo钱包地址
