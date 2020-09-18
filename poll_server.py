"""
    基于select方法的熊多路复用并发模型
"""
from socket import *
from select import *

HOST = "0.0.0.0"
PORT = 6750
ADDR = (HOST, PORT)

sockfd = socket()
sockfd.bind(ADDR)
sockfd.listen(5)

# 设置io为非阻塞状态
sockfd.setblocking(False)

map_fileno = {}
p = poll()
map_fileno[sockfd.fileno()] = sockfd
p.register(sockfd, POLLIN)

# 循环监控关注的io
while True:
    events = p.poll()
    # 遍历就绪的io列表，分情况讨论 监听套接字和客户端连接套接字
    for fd, event in events:
        if fd == sockfd.fileno():
            connfd, addr = map_fileno[fd].accept()
            print("Connect with ...", addr)

            # 设置io为非阻塞状态
            connfd.setblocking(False)

            # 将连接进来的客户端连接套接字加入关注的io
            # p.register(connfd, POLLIN | POLLOUT)
            p.register(connfd, POLLIN)
            map_fileno[connfd.fileno()] = connfd
        # else:
        #     if event == POLLIN.fileno():
        #         # 某个客户端发送了消息
        #         data = map_fileno[fd].recv(1024).decode()
        #         if not data:
        #             p.unregister(fd)
        #             map_fileno[fd].close()
        #             del map_fileno[fd]
        #             continue
        #         print(data)
        #     elif event == POLLOUT.fileno():
        #         map_fileno[event].send(b"OK")
        else:
            # 某个客户端发送了消息
            data = map_fileno[fd].recv(1024).decode()
            if not data:
                p.unregister(fd)
                map_fileno[fd].close()
                del map_fileno[fd]
                continue
            print(data)
            map_fileno[fd].send(b"OK")
