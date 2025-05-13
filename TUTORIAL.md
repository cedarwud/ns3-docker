
---

## 🔹 TUTORIAL.md  —— 研究流程 & GUI 使用全教學

```markdown
# LEO Satellite Handover + Energy Framework 研究全流程

> **本教學涵蓋**  
> * 下載並編譯 ns-3 + LEO module + Energy Framework  
> * 實作手動 / 自動 handover 策略  
> * 追蹤電池狀態 (SoC / DoD) 與延遲統計  
> * 使用 NetAnim、PyViz、Wireshark 進行可視化與除錯  
> * 兩種鏡像策略：輕量 core 與胖 GUI 版

---

## 1 ⋅ 準備原始碼

```bash
# 宿主機位置假設：~/workspace
git clone https://gitlab.com/nsnam/ns-3-dev.git
git clone https://github.com/leo-sim/ns3-leo.git ns-3-dev/contrib/leo

LEO 模組會自動被 ./ns3 configure 偵測並加入。

2 ⋅ 容器內編譯
## bash
make run          # 先進容器

cd ns-3-dev
./ns3 configure --enable-examples --enable-tests \
                --enable-modules=leo
./ns3 build -j$(nproc)

./ns3 是官方 2024 後新 wrapper，內部使用 CMake；
若仍想用 waf，可 ./waf configure …。

3 ⋅ 撰寫範例：scratch/leo-handover-energy.cc
# cpp
核心步驟（簡化：
Ptr<Node> sat = ... ;
// 1. Energy source
LiIonEnergySourceHelper batt;
batt.Set("InitialEnergyJ", DoubleValue(1e8));
auto battPtr = batt.Install(sat);

// 2. Device energy model
DeviceEnergyModelHelper radio;
radio.Install(netDevice);

// 3. Schedule eclipse  (0=光照, 1=eclipse)
Simulator::Schedule(EclipseStart, &LiIonEnergySource::SetEnergyHarvesterState, battPtr, 0);
Simulator::Schedule(EclipseEnd,   &LiIonEnergySource::SetEnergyHarvesterState, battPtr, 1);

// 4. Handover algorithm
LeoHelper::InstallHandoverController(...)
完整程式請自行加入 traffic generator、CsvTracer 等。

4 ⋅ 離線動畫：NetAnim
## bash
# 1. 產生 XML
./ns3 run "scratch/leo-handover-energy --animFile=leo.xml"

# 2. 若尚未編 NetAnim →
git clone https://gitlab.com/nsnam/netanim.git
cd netanim && cmake -S . -B build && cmake --build build -j$(nproc)

# 3. 播放
./build/NetAnim  ../leo.xml

動畫中可勾選 Energy 圖層顯示殘存電量。

5 ⋅ 線上拓撲：PyViz
## bash
pip install --user cppyy pygobject graphviz pygraphviz
./ns3 run --vis scratch/leo-handover-energy
提示：模擬規模 > 200 節點時 PyViz 會顯示卡頓，建議僅在 debug 使用。

6 ⋅ 封包分析：Wireshark
## bash
dnf install -y wireshark-qt      # 若尚未安裝
./ns3 run "scratch/... --pcap"   # 產生 pcap
wireshark leo-handover-0-0.pcap


7 ⋅ 胖 GUI 版鏡像（可選）
若你想「容器一跑就有 NetAnim + Wireshark」，在 Dockerfile
加上區塊（Team 成員亦可改用 docker build -f Dockerfile.gui）：
## dockerfile
# --- GUI block (adds ~300 MB) ----------------------
RUN git clone --depth 1 https://gitlab.com/nsnam/netanim.git /opt/netanim && \
    cmake -S /opt/netanim -B /opt/netanim/build && \
    cmake --build /opt/netanim/build -j$(nproc) && \
    ln -s /opt/netanim/build/NetAnim /usr/local/bin/NetAnim && \
    dnf install -y wireshark-qt

8 ⋅ 常見問題
症狀	解法
NetAnim Cannot connect to X server
確認啟動容器時帶 -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix；Wayland 請加 QT_QPA_PLATFORM=xcb

Energy 模型顯示 0 J
檢查 eclipse 時段排程是否設錯，或 EnergyHarvester 輸入功率未更新

Handover 時延過高
打開 Wireshark 看 RRC Reconfiguration；可能 satellite mobility 更新太慢或 UE event timer 過長


---

### ⏱ 5 分鐘上手

```bash
# 第 1 分鐘：建置鏡像
make build
# 第 3 分鐘：進容器、編譯 ns-3
make run
cd ns-3-dev && ./ns3 configure && ./ns3 build
# 第 5 分鐘：跑範例 + 看 NetAnim
./ns3 run "scratch/leo-handover-energy --animFile=leo.xml"
NetAnim leo.xml
