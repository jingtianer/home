---
title: BigChain DB的安装与使用
date: 2022-12-5 12:15:37
tags: 
    - BigChain DB
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## step1. 构建一个BigChainDB节点

### 使用All-in-One Docker搭建

- 拉取镜像

```sh
docker pull bigchaindb/bigchaindb:all-in-one
```

- 运行
```sh
docker run \
  --detach \
  --name bigchaindb \
  --publish 9984:9984 \
  --publish 9985:9985 \
  --publish 27017:27017 \
  --publish 26657:26657 \
  --volume $HOME/bigchaindb_docker/mongodb/data/db:/data/db \
  --volume $HOME/bigchaindb_docker/mongodb/data/configdb:/data/configdb \
  --volume $HOME/bigchaindb_docker/tendermint:/tendermint \
  bigchaindb/bigchaindb:all-in-one
```

### 使用Ansible一键脚本搭建

#### 什么是Ansible Playbooks

> Ansible Playbooks offer a repeatable, re-usable, simple configuration management and multi-machine deployment system, one that is well suited to deploying complex applications. If you need to execute a task with Ansible more than once, write a playbook and put it under source control. Then you can use the playbook to push out new configuration or confirm the configuration of remote systems. The playbooks in the ansible-examples repository illustrate many useful techniques. You may want to look at these in another tab as you read the documentation.

- 是一个为了便于多机搭建的工具

#### 安装Ansible Playbooks
```sh
python3 -m pip install --user ansible
```

#### 使用ansible安装BigChainDB

- 配置hosts中的all文件，使用basicconfig
```yaml
# Basic configuration
<HOSTNAME>  ansible_ssh_user=tt ansible_sudo_pass=123456 voting_power=<INT>
```

```sh
docker run -itd -v /root/bigchaindb/bigchaindb-node-ansible:/home/bigchaindb-node-ansible -p 9983:9984  ubuntu /bin/bash
ansible-playbook install.yml -i hosts/all --extra-vars "top_dir=$(pwd)"
# 或者使用
python3 -m ansible playbook install.yml -i hosts/all --extra-vars "top_dir=$(pwd)"
```

- 官网的这个可能用不了，他的原理可能是通过ssh连接进行配置，我们需要后续建立一个ssh
- 后续可以自己搭建ansible Control Node达到多机搭建的作用

### 不使用docker
- [官方教程](http://docs.bigchaindb.com/en/latest/installation/node-setup/set-up-node-software.html)

> 以上三种方法任选其一就可以，第三种方法如果需要一个机器对应一个节点时再考虑。


## step2. 建立网络
### 编写docker compose文件
```yaml
version: '2.1'

services:
  mongodb:
    image: mongo:3.6
    ports:
      - "27017:27017"
    command: mongod
  bigchaindb:
    image: bigchaindb/bigchaindb
    depends_on:
      - mongodb
      - tendermint
    environment:
      BIGCHAINDB_DATABASE_BACKEND: localmongodb
      BIGCHAINDB_DATABASE_HOST: mongodb
      BIGCHAINDB_DATABASE_PORT: 27017
      BIGCHAINDB_SERVER_BIND: 0.0.0.0:9984
      BIGCHAINDB_WSSERVER_HOST: 0.0.0.0
      BIGCHAINDB_WSSERVER_ADVERTISED_HOST: bigchaindb
      BIGCHAINDB_TENDERMINT_HOST: tendermint
      BIGCHAINDB_TENDERMINT_PORT: 26657
    ports:
      - "9984:9984"
      - "9985:9985"
      - "26658:26658"
    healthcheck:
      test: ["CMD", "bash", "-c", "curl http://bigchaindb:9984 && curl http://tendermint:26657/abci_query"]
      interval: 3s
      timeout: 5s
      retries: 3
    #command: 'bigchaindb start'
  tendermint:
    image: tendermint/tendermint:0.22.8
    volumes:
      - ./tmdata:/tendermint
    entrypoint: ''
    ports:
      - "26656:26656"
      - "26657:26657"
    command: sh -c "tendermint init && tendermint node --consensus.create_empty_blocks=false --proxy_app=tcp://bigchaindb:26658"
```

### 使用tendermint生成配置文件
```sh
tendermint testnet
```
- 修改生成的配置文件，写入节点实际ip

### 启动

```sh
docker-compose up -d
```

## step3. 测试
- 使用postman发送测试Post交易
```json
{
  "asset": {
    "data": {
      "msg": "Hello BigchainDB!"
    }
  },
  "id": "4957744b3ac54434b8270f2c854cc1040228c82ea4e72d66d2887a4d3e30b317",
  "inputs": [
    {
      "fulfillment": "pGSAIDE5i63cn4X8T8N1sZ2mGkJD5lNRnBM4PZgI_zvzbr-cgUCy4BR6gKaYT-tdyAGPPpknIqI4JYQQ-p2nCg3_9BfOI-15vzldhyz-j_LZVpqAlRmbTzKS-Q5gs7ZIFaZCA_UD",
      "fulfills": null,
      "owners_before": [
        "4K9sWUMFwTgaDGPfdynrbxWqWS6sWmKbZoTjxLtVUibD"
      ]
    }
  ],
  "metadata": {
    "sequence": 0
  },
  "operation": "CREATE",
  "outputs": [
    {
      "amount": "1",
      "condition": {
        "details": {
          "public_key": "4K9sWUMFwTgaDGPfdynrbxWqWS6sWmKbZoTjxLtVUibD",
          "type": "ed25519-sha-256"
        },
        "uri": "ni:///sha-256;PNYwdxaRaNw60N6LDFzOWO97b8tJeragczakL8PrAPc?fpt=ed25519-sha-256&cost=131072"
      },
      "public_keys": [
        "4K9sWUMFwTgaDGPfdynrbxWqWS6sWmKbZoTjxLtVUibD"
      ]
    }
  ],
  "version": "2.0"
}

```

- 查询交易
```http
http://localhost::9984/api/v1/assets/?search=Hello BigchainDB
```

## step4. bigchaindb_driver

- python的api

### 安装依赖
```sh
pip3 install --upgrade setuptools
sudo apt-get install python3-dev libssl-dev libffi-dev
pip3 install python-rapidjson PyNaCl
```
### 安装driver
```sh
pip3 install bigchaindb_driver
```

### 运行测试代码
```py
# import BigchainDB and create an object
from bigchaindb_driver import BigchainDB
bdb_root_url = 'https://example.com:9984'
bdb = BigchainDB(bdb_root_url)

# generate a keypair
from bigchaindb_driver.crypto import generate_keypair
alice, bob = generate_keypair(), generate_keypair()

# create a digital asset for Alice
game_boy_token = {
    'data': {
        'token_for': {
            'game_boy': {
                'serial_number': 'LR35902'
            }
        },
        'description': 'Time share token. Each token equals one hour of usage.',
    },
}

# prepare the transaction with the digital asset and issue 10 tokens for Bob
prepared_token_tx = bdb.transactions.prepare(
    operation='CREATE',
    signers=alice.public_key,
    recipients=[([bob.public_key], 10)],
    asset=game_boy_token)

# fulfill and send the transaction
fulfilled_token_tx = bdb.transactions.fulfill(
    prepared_token_tx,
    private_keys=alice.private_key)
bdb.transactions.send_commit(fulfilled_token_tx)

# Use the tokens
# create the output and inout for the transaction
transfer_asset = {'id': fulfilled_token_tx['id']}
output_index = 0
output = fulfilled_token_tx['outputs'][output_index]
transfer_input = {'fulfillment': output['condition']['details'],
                  'fulfills': {'output_index': output_index,
                               'transaction_id': transfer_asset['id']},
                  'owners_before': output['public_keys']}

# prepare the transaction and use 3 tokens
prepared_transfer_tx = bdb.transactions.prepare(
    operation='TRANSFER',
    asset=transfer_asset,
    inputs=transfer_input,
    recipients=[([alice.public_key], 3), ([bob.public_key], 7)])

# fulfill and send the transaction
fulfilled_transfer_tx = bdb.transactions.fulfill(
    prepared_transfer_tx,
    private_keys=bob.private_key)
sent_transfer_tx = bdb.transactions.send_commit(fulfilled_transfer_tx)
```