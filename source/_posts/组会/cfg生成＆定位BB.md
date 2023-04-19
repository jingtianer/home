---
title: CFG生成＆定位BB
date: 2023-2-15 12:15:37
tags: 
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## cfg生成

- 使用afl编译，添加以下参数`-fdump-tree-all`
```sh
export CC='afl-gcc -fdump-tree-all'
export CXX='afl-g++ -fdump-tree-all'
```
- 或使用gcc编译
```sh
export CC='gcc -fdump-tree-all'
export CXX='g++ -fdump-tree-all'
```

- 编译完成后，进入`./bin/named`发现生成了`cfg`文件
```sh
tt@ubuntu:~/Desktop/dnsenv/bind-9.18.1/bin/named$ find *.cfg
builtin.c.011t.cfg
config.c.011t.cfg
control.c.011t.cfg
controlconf.c.011t.cfg
dlz_dlopen_driver.c.011t.cfg
fuzz.c.011t.cfg
log.c.011t.cfg
logconf.c.011t.cfg
main.c.011t.cfg
os.c.011t.cfg
server.c.011t.cfg
statschannel.c.011t.cfg
tkeyconf.c.011t.cfg
transportconf.c.011t.cfg
tsigconf.c.011t.cfg
zoneconf.c.011t.cfg
```


### 对于gcc版本足够高的情况
（我用gcc 11.3.0进行测试），在编译时加入以下参数
```
-fdump-tree-all-graph
```

> 可以直接产生`.dot`文件（graph description language）

```sh
root@tt-surfacepro6:~/tmp# find *.dot
a-test.c.015t.cfg.dot
a-test.c.017t.ompexp.dot
a-test.c.018t.warn-printf.dot
a-test.c.022t.fixup_cfg1.dot
a-test.c.023t.ssa.dot
a-test.c.027t.fixup_cfg2.dot
a-test.c.028t.local-fnsummary1.dot
a-test.c.029t.einline.dot
a-test.c.051t.release_ssa.dot
a-test.c.052t.local-fnsummary2.dot
a-test.c.092t.fixup_cfg3.dot
a-test.c.097t.adjust_alignment.dot
a-test.c.233t.veclower.dot
a-test.c.234t.cplxlower0.dot
a-test.c.236t.switchlower_O0.dot
a-test.c.243t.isel.dot
a-test.c.244t.optimized.dot
```

使用以下命令可以将其转化成图片
```sh
dot -Tpng <文件名> -O
```

#### 依赖
- Graphviz


### gcc版本较低的情况下，对控制流图可视化

- 可以使用`gcc-python-plugin`获取基于gimple的控制流

- 参考[官方](https://gcc-python-plugin.readthedocs.io/en/latest/index.html)教程编译安装`gcc-python-plugin`
- 编写生成图片python的脚本
- 编译时使用该脚本，命令如下

```sh
export CC='gcc -fplugin=/home/tt/Desktop/dnsenv/gcc-python-plugin/python.so -fplugin-arg-python-script=/home/tt/Desktop/dnsenv/gcc-python-plugin/examples/show-gimple.py'
export CXX='g++ -fplugin=/home/tt/Desktop/dnsenv/gcc-python-plugin/python.so -fplugin-arg-python-script=/home/tt/Desktop/dnsenv/gcc-python-plugin/examples/show-gimple.py'
```

- 这个工具有点问题，需要简单修改一下，在修改文件`gccutils/__init__.py`的`invoke_dot`函数为如下内容

```python
def invoke_dot(dot, name='test'):
    from subprocess import Popen, PIPE

    if 1:
        fmt = 'png'
    else:
        # SVG generation seems to work, but am seeing some text-width issues
        # with rendering of the SVG  by eog and firefox on this machine (though
        # not chromium).
        #
        # Looks like X coordinates allocated by graphviz don't contain quite
        # enough space for the <text> elements.
        #
        # Presumably a font selection/font metrics issue
        fmt = 'svg'
    filename = '%s.%s' % (name, fmt)
    p = Popen(['dot', '-T%s' % fmt, '-o', filename],
              stdin=PIPE)
    p.communicate(dot.encode('utf8'))

    #p = Popen(['xdg-open', filename])
    #p.communicate()
```

> 不过这个办法编译过程中还是出现dot崩溃等问题
>

- 在`bin/named`下生成了大量图片，如下图所示
![gcc-py-plugin-show-gimple](https://github.com/jingtianer/home/blob/gh-pages/images/gcc_python_plugin_show_gimple.png?raw=true)

#### 利用gcc-python-plugin分析代码
- 通过阅读`gccutils/__init__.py`下的代码，可以得到知道获取cfg的`edge`, `basic blocks`的方法

1. 首先需要继承`gcc.GimplePass`并实现其中的`execute`函数
```python
class ShowGimple(gcc.GimplePass):
    def execute(self, fun):
        pass
```
2. 在`execute`中，通过`fun.cfg`可以获得函数的控制流图
3. `cfg`对象中的域`basic_blocks`可获得基本块
4. 通过基本块`basic_blocks`的`succs`域可获得每个block后继的`edge`

- 关于其更详细的介绍可以参看[官方文档](https://gcc-python-plugin.readthedocs.io/en/latest/cfg.html)

### 使用[IDA](https://www.idapro.net.cn/chanpin.html?target=home)绘制

- 下载安装ida
- 编译bind
- 用ida对bind二进制反汇编，并可以得到其cfg

## 根据函数定位BB

在`gcc-python-plugin`中，通过获取bb，可以获取到其中用`gcc Gimple`表示的`statement`。其中一类语句为`gcc.GimpleCall`，其中的`fn`域表示该语句所调用的函数。

> 通过以上方法，可以参考`gccutils`和官方的`examples`中的代码实现根据函数定位其所在的BB

## 初步实现

```python
import gcc
import sys
reload(sys)
sys.setdefaultencoding('utf8')

class DnsPlugin(gcc.GimplePass):
    def __init__(self, funcList, name=''):
        super(DnsPlugin, self).__init__(name=name)
        self.funclist = funcList
    def stmt_filter(self, bb):
        filtered_funcs = []
        if isinstance(bb.phi_nodes, list):
            for _, phi in enumerate(bb.phi_nodes):
                # phony function
                expr, _ = phi.args # expr, edge
                funcName = ''
                if isinstance(expr, gcc.Constant):
                    funcName = str(expr)
                elif isinstance(expr, gcc.SsaName):
                    funcName = str(expr.def_stmt)
                if funcName in self.funclist:
                    filtered_funcs.append(funcName)
        if isinstance(bb.gimple, list) and bb.gimple != []:
            for _, stmt in enumerate(bb.gimple):
                if isinstance(stmt, gcc.GimpleCall):
                    funcName = str(stmt.fn)
                    if funcName in self.funclist:
                        filtered_funcs.append(funcName)
        else:
            raise SyntaxError("gimple syntax invalid!")
        return filtered_funcs
    
    def execute(self, fun):
        FUNC, LOOP, BB = 0,0,0
        if fun and fun.cfg:
            self.cfg = fun.cfg
            for block in self.cfg.basic_blocks:
                for edge in block.succs:
                    if self.is_back_edge(edge):
                        LOOP+=1
                FUNCi = len(self.stmt_filter(block))
                if FUNCi > 0:
                    BB+=1
                FUNC += FUNCi
        invoke_dns([FUNC, LOOP, BB], name=fun.decl.name)

    def is_back_edge(self, edge):
        dest_block, src_block = edge.dest, edge.src
        # 图很大的话用bfs更好吧
        self.visited = [False] * len(self.cfg.basic_blocks)
        index_dest, index_src = dest_block.index, src_block.index
        return self.dfs(index_dest, index_src) 
        
    def dfs(self, node, target):
        if node == target:
            return True
        ret = False
        for edge in self.gcc.basic_blocks[node].succs:
            if not self.visited[edge.dest.index]:
                self.visited[edge.dest.index] = True
                ret = ret or self.dfs(edge.dest.index, target)
                if ret:
                    return True
        return ret

ps = DnsPlugin([], name='dnsplugin')
ps.register_after('cfg')

def invoke_dns(data, name):
    from subprocess import Popen, PIPE
    filename = '%s.%s' % (name, "dnsdat")
    p = Popen(['tee', "%s" % filename],
             stdin=PIPE)
    p.communicate(data.encode('utf8'))
```

> 对论文中提到的三个公式`FUNC`,`LOOP`,`BB`进行了统计