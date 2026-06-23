# Basys3 PicoRV32 Calculator

本專題利用 PicoRV32 RISC-V Softcore Processor 建立一個簡易計算器系統，透過 Basys3 FPGA 開發板上的 Switch 與 Button 輸入數值及運算模式，並將結果顯示於 LED 與七段顯示器。

---

## 1. 專題名稱

Basys3 PicoRV32 Calculator

---

## 2. 使用開發板

- Digilent Basys3 FPGA Development Board
- FPGA：Xilinx Artix-7 XC7A35T

---

## 3. 開發工具版本

### FPGA Development

- Vivado 2024.1

### RISC-V Toolchain

- PicoRV32
- RISC-V GNU Toolchain (RV32I)

---

## 4. 專案資料夾結構

```text
basys3-picorv32-calculator
│
├── top.v
├── basys3.xdc
├── firmware.hex
│
├── firmware/
│   ├── firmware.S
│   ├── firmware.c
│   ├── linker.ld
│   ├── firmware.o
│   ├── firmware.elf
│   └── firmware.hex
│
├── README.md
│
└── basys3_picorv32.srcs/
```

---

## 5. 如何產生 Bitstream

1. 開啟 Vivado Project
2. 執行 **Run Synthesis**
3. 執行 **Run Implementation**
4. 執行 **Generate Bitstream**
5. 開啟 **Hardware Manager**
6. 連接 Basys3 FPGA 開發板
7. Program Device 並下載 bitstream

---

## 6. 如何修改 RISC-V 程式

主要程式位於：

```text
firmware/firmware.S
```

修改完成後重新編譯產生：

```text
firmware.hex
```

原先規劃使用：

```verilog
$readmemh("firmware.hex", memory);
```

載入程式至 Instruction Memory。

由於 Vivado 在記憶體初始化時遇到載入問題，因此本專題最終採用直接將 Machine Code 寫入 Verilog ROM 的方式：

```verilog
initial begin
    memory[0] = 32'h100002b7;
    ...
end
```

---

## 7. 如何燒錄至 FPGA

1. 使用 Micro USB 連接 Basys3 開發板
2. 開啟 Vivado Hardware Manager
3. 點選 Auto Connect
4. 選擇 Program Device
5. 載入產生的 .bit 檔
6. 完成燒錄

---

## 8. 操作與測試方式

### 輸入

- SW[3:0]：輸入 A
- SW[7:4]：輸入 B

### 按鈕功能

| 按鈕 | 功能 |
|--------|--------|
| BTNC | 加法 |
| BTNU | 減法 |
| BTNL | 乘法 |
| BTNR | 除法 |
| BTND | A > B 比較 |

### 輸出

- LED：顯示運算結果
- 七段顯示器：顯示十進位結果
- 最左側數位：顯示 A > B 比較結果

---

## 9. 已知問題

1. 原先規劃使用 `$readmemh()` 載入 firmware.hex，但 Vivado 記憶體初始化未成功。
2. 最終改採將 Machine Code 直接寫入 Verilog ROM。
3. 乘法與除法目前使用重複加法與重複減法實作，執行效率較低。

---

## 10. 外部來源與授權說明

### PicoRV32

GitHub：

https://github.com/YosysHQ/picorv32

本專題使用 PicoRV32 開源 RISC-V CPU Core，並完成 FPGA 整合與周邊設計。

### Basys3 FPGA Board

- Digilent Basys3 FPGA Development Board

### 開發工具

- Xilinx Vivado 2024.1

---

## System Architecture

```text
                    +----------------------+
                    | Instruction Memory   |
                    |     firmware.hex     |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |    PicoRV32 CPU      |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |   Address Decoder    |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    | Memory-Mapped I/O    |
                    +----------+-----------+
                               |
     --------------------------------------------------
     |               |              |                |
     v               v              v                v

+---------+    +---------+    +---------+    +------------+
| Switch  |    | Button  |    |   LED   |    | 7-Segment  |
+---------+    +---------+    +---------+    +------------+

 SW[3:0] = A      BTNC = 加法
 SW[7:4] = B      BTNU = 減法
                  BTNL = 乘法
                  BTNR = 除法
                  BTND = A>B比較
```

---

## 功能展示

- PicoRV32 RISC-V Softcore
- Memory-Mapped I/O
- Switch 輸入
- Button 控制運算模式
- LED 顯示結果
- 四位數七段顯示器
- A > B 比較功能

