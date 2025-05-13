# ns-3 LEO + Energy Docker Toolchain (Fedora 38)

> **核心設計理念**  
> 1. 以與官方 CI 相同的 Fedora 為核心 → 減少 debug 差異  
> 2. Image 只放 *toolchain* → 小、快、易快取  
> 3. NetAnim / PyViz / Wireshark 等 GUI **依賴已備好**，需要時
>    在容器裡一行 `git clone` 或 `dnf install` 即可使用。

---

## 0 ⋅ 先決條件

* Linux / macOS / Windows 安裝 **Docker Engine**  
  （Windows 請使用 WSL 2 後端；macOS 需開 **XQuartz** 才能顯示 X11）

---

## 1 ⋅ 快速啟動

```bash
git clone https://gitlab.com/your_team/ns3-leo-energy-docker.git
cd ns3-leo-energy-docker

## 一鍵 build + run
make run        # 或 make shell


2. 把 ns-3 原始碼放進來
## bash
# 宿主機下載 (建議與本專案同層)
git clone https://gitlab.com/nsnam/ns-3-dev.git

# LEO 模組 (示例 repo，請換成你的 fork)
git clone https://github.com/leo-sim/ns3-leo.git ns-3-dev/contrib/leo

進容器後：
## bash
cd /workspace/ns-3-dev
./ns3 configure --enable-examples --enable-tests
./ns3 build -j$(nproc)

3 ⋅ 必要 GUI 工具安裝指令（容器內）

工具
NetAnim
安裝指令
git clone https://gitlab.com/nsnam/netanim.git && cd netanim && cmake -S . -B build && cmake --build build -j$(nproc)
執行範例
NetAnim scratch/leo.xml

工具
PyViz
安裝指令
pip install --user cppyy pygobject graphviz pygraphviz
執行範例
./ns3 run --vis examples/visualizer/wifi-ping

工具
Wireshark (Qt)
安裝指令
dnf install -y wireshark-qt
執行範例
wireshark leo-handover.pcap

4 ⋅ 常用 Make 目標
指令	作用
make build	只建置 Docker image
make run	  進入互動容器（若 image 不在就先建）
make clean	刪除 image，釋放空間

5 ⋅ 支援的發行版
Fedora 38（glibc 2.38、GCC 14 preview）

如需 Ubuntu 22.04：把 Dockerfile 首行改成 FROM ubuntu:22.04
並把 dnf 套件名對應到 apt，即可無痛切換。