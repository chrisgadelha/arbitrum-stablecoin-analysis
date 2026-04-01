# Stablecoin Transfer Behavior on Arbitrum (2023–2026)

**Analyzing 3+ years of USDT, USDC, and USDC.e transfer activity on Arbitrum One.**

This project tracks daily volume, transaction frequency, stablecoin composition shifts, and value distribution patterns from January 2023 to March 2026 — covering the full post-Nitro era of Arbitrum's growth.

[![Dashboard](https://img.shields.io/badge/Dune-Dashboard-blue?style=flat&logo=dune)]([https://dune.com/chrisgadelha](https://dune.com/chrisgadelha/stablecoin-behavior-on-arbitrum))
[![Medium](https://img.shields.io/badge/Medium-Article-black?style=flat&logo=medium)]([https://medium.com/@gadelhaweb3](https://medium.com/@gadelhaweb3/3-years-of-stablecoin-transfers-on-arbitrum-what-the-data-actually-reveals-25ed1fb777d3))

---

## Key Findings

**$2.3 trillion** in total stablecoin volume across **955 million transfers** over 1,179 days.

### 1. Ecosystem Growth
Arbitrum's stablecoin activity grew dramatically over the period. Daily transfer volume rose from ~$73M in January 2023 to regular peaks above $5B by late 2025. Daily transaction count grew from ~80K to sustained levels above 2M, reflecting Arbitrum's consolidation as a leading Layer 2.

### 2. The USDC Migration
Circle launched native USDC on Arbitrum in June 2023. The data tracks a clear migration from the bridged version (USDC.e) to the native token throughout 2024. By late 2025, USDC.e volume had nearly disappeared — a sign that major issuers view Arbitrum as a permanent, first-class chain rather than just a bridge destination.

### 3. Pareto Concentration
Transfers under $100 represent ~45% of all transactions but less than 1% of total volume. Whale transfers ($100K+) are less than 1% of transactions but consistently drive 30–40% of all USD volume. The average whale transfer size doubled from ~$200K to over $600K during the analysis period.

### 4. All Anomalies Are Institutional
The anomaly detection system flagged only 5 days where activity exceeded 3x the 30-day average. Every single anomaly was classified as "VOLUME ONLY — Whale/institutional." No retail-driven surge ever reached the 3x threshold. The anomalies align with known market events (SVB collapse in March 2023, institutional movements in July 2024).

---

## Dashboard

**[View the interactive dashboard on Dune →](https://dune.com/chrisgadelha/stablecoin-behavior-on-arbitrum)**

The dashboard contains 6 panels:

| Panel | Title | What It Shows |
|-------|-------|---------------|
| KPIs | Summary Counters | Total volume, transfers, averages, peak day |
| 1 | Daily Volume (USD) | Transfer volume with 7-day moving average |
| 2 | Daily Transaction Count | Transfer frequency with 7-day moving average |
| 3 | Stablecoin Migration | USDC.e → USDC native composition shift |
| 4 | Who Moves the Money? | Volume and count by transfer size bracket |
| 5 | Whale Transfer Trends | $100K+ transfer volume and average size |
| 6 | Anomaly Detection | Days with 3x+ above 30-day average |

---

## Repository Structure

```
├── README.md                 
├── queries/
│   ├── query_1_daily_volume_usd.sql
│   ├── query_2_daily_tx_count.sql
│   ├── query_3_value_distribution.sql
│   ├── query_kpi_summary.sql
│   ├── query_panel3_stablecoin_migration.sql
│   ├── query_panel5_whale_trends.sql
│   └── query_bonus_anomaly_detection.sql

```

---

## Methodology

### Data Source
All queries use the `erc20_arbitrum.evt_Transfer` table on Dune Analytics. This table only logs events from successfully executed transactions — reverted transactions do not emit ERC-20 events, so the dataset contains only confirmed transfers.

### Token Contracts

| Token | Address | Decimals |
|-------|---------|----------|
| USDT | `0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9` | 6 |
| USDC (native) | `0xaf88d065e77c8cC2239327C5EDb3A432268e5831` | 6 |
| USDC.e (bridged) | `0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8` | 6 |

### Filters Applied
- **Period:** January 1, 2023 → March 24, 2026
- **Mint/burn exclusion:** Transfers from or to the zero address (`0x000...000`) are excluded
- **Zero-value exclusion:** Query 3 excludes transfers with $0 value

### Value Brackets (Query 3)

| Bracket | Range | Typical User Profile |
|---------|-------|---------------------|
| Micro | $0 – $100 | Retail, small remittances |
| Small | $100 – $1K | Retail, P2P transfers |
| Medium | $1K – $10K | Small business, active traders |
| Large | $10K – $100K | High-value, institutional |
| Whale | $100K+ | Treasury, funds, OTC desks |

### Anomaly Detection
Days are flagged when daily volume OR transaction count exceeds 3x the trailing 30-day moving average. Anomalies are classified as volume-only (institutional), transfers-only (retail), or both (market-wide).


---

## How to Reproduce

1. Go to [dune.com](https://dune.com) and create a free account
2. Click **New Query** and paste any `.sql` file from the `queries/` folder
3. Click **Run** (queries may take 1–3 minutes due to the 3+ year date range)
4. Save the query and add visualizations


---

## About the Author

**Christian Gadelha**
Arbitrum Ambassador — Brazil | Economist | Military Firefighter

This project combines on-chain data analysis with economic reasoning to explore how stablecoin transfer patterns reveal structural characteristics of a Layer 2 ecosystem. It is part of a broader research agenda applying economic analysis to blockchain data.

- **Dune:** [dune.com/chrisgadelha](https://dune.com/chrisgadelha)
- **Medium:** [medium.com/@gadelhaweb3](https://medium.com/@gadelhaweb3)
- **LinkedIn:** [linkedin.com/in/chrisgadelha](https://linkedin.com/in/christian-gadelha)

