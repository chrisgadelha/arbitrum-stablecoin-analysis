WITH stablecoin_transfers AS (
    SELECT
        date_trunc('day', evt_block_time)                   AS transfer_date,
        CASE
            WHEN contract_address = 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
                THEN 'USDT'
            WHEN contract_address = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831
                THEN 'USDC'
            WHEN contract_address = 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
                THEN 'USDC.e'
        END                                                 AS stablecoin,
        value / 1e6                                         AS amount_usd
    FROM erc20_arbitrum.evt_Transfer
    WHERE contract_address IN (
        0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,   -- USDT
        0xaf88d065e77c8cC2239327C5EDb3A432268e5831,   -- USDC (native)
        0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8    -- USDC.e (bridged)
    )
    AND evt_block_time >= TIMESTAMP '2023-01-01'
    AND evt_block_time <  TIMESTAMP '2026-03-25'
    -- Exclude mint and burn events (zero address)
    AND "from" != 0x0000000000000000000000000000000000000000
    AND "to"   != 0x0000000000000000000000000000000000000000
)

SELECT
    transfer_date,
    -- Volume by stablecoin
    SUM(CASE WHEN stablecoin = 'USDT'   THEN amount_usd ELSE 0 END)  AS usdt_volume,
    SUM(CASE WHEN stablecoin = 'USDC'   THEN amount_usd ELSE 0 END)  AS usdc_volume,
    SUM(CASE WHEN stablecoin = 'USDC.e' THEN amount_usd ELSE 0 END)  AS usdc_e_volume,
    -- Total volume (all stablecoins combined)
    SUM(amount_usd)                                                    AS total_volume,
    -- 7-day moving average for trend smoothing
    AVG(SUM(amount_usd)) OVER (
        ORDER BY transfer_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                                  AS volume_7d_ma
FROM stablecoin_transfers
GROUP BY transfer_date
ORDER BY transfer_date
