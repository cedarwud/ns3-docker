# ------------------------------------------------------------
# ns3-leo-energy-docker : Fedora 38 toolchain  (≈ 600 MB)
#   • 適合開發 / CI / 批量跑實驗
#   • 已備 NetAnim / PyViz / Wireshark 的 *編譯依賴*
#     → 進容器後 git-clone & build 即可使用
# ------------------------------------------------------------
  FROM fedora:38

  # ----- 必備編譯工具 & 相依套件 ---------------------------------
  RUN dnf -y update && dnf -y install \
        gcc gcc-c++ clang cmake ninja-build ccache make git \
        python3 python3-pip python3-devel gdb valgrind \
        libxml2-devel libsqlite3x-devel gsl-devel \
        graphviz doxygen \
        qt5-qtbase-devel qt5-qtmultimedia-devel \
        gtk3 pygobject3 \
     && dnf clean all
  
  # ----- 非 root 使用者 (UID 1000) ------------------------------
  RUN useradd -ms /bin/bash ns3
  USER ns3
  WORKDIR /workspace
  
  # ----- 預設互動 shell ----------------------------------------
  ENTRYPOINT ["bash"]
  