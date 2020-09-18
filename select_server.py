"""
    基于select方法的熊多路复用并发模型
"""
from socket import *
from select import select

HOST = "0.0.0.0"
PORT = 6750
ADDR = (HOST, PORT)

sockfd = socket()
sockfd.bind(ADDR)
sockfd.listen(5)

# 设置io为非阻塞状态
sockfd.setblocking(False)

# 将关注的io加入列表
rlist = [sockfd]
wlist = []
xlist = []

# 循环监控关注的io
while True:
    rs, ws, xs = select(rlist, wlist, xlist)
    # 遍历就绪的io列表，分情况讨论 监听套接字和客户端连接套接字
    for r in rs:
        print(rs)
        if r is sockfd:
            connfd, addr = rs[0].accept()
            print("Connect with ...", addr)
            # 将连接进来的客户端连接套接字加入关注的io

            # 设置io为非阻塞状态
            connfd.setblocking(False)

            rs.append(connfd)
        else:
            # 某个客户端发送了消息
            data = r.recv(1024).decode()
            if not data:
                rlist.remove(r)
                r.close()
                continue
            print(data)
            wlist.append(r)

    for w in wlist:
        w.send(b"OK")
        wlist.remove(w)
