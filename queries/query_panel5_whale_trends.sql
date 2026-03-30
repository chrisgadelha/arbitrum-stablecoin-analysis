WITH stablecoin_transfers AS (
    SELECT
        date_trunc('month', evt_block_time)                 AS transfer_month,
        value / 1e6                                         AS amount_usd
    FROM erc20_arbitrum.evt_Transfer
    WHERE contract_address IN (
        0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,
        0xaf88d065e77c8cC2239327C5EDb3A432268e5831,
        0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8
    )
    AND evt_block_time >= TIMESTAMP '2023-01-01'
    AND evt_block_time <  TIMESTAMP '2026-03-25'
    AND "from" != 0x0000000000000000000000000000000000000000
    AND "to"   != 0x0000000000000000000000000000000000000000
    AND value / 1e6 >= 100000  -- Only $100K+ transfers
)

SELECT
    transfer_month,
    -- Number of whale transfers
    COUNT(*)                                                AS whale_transfers,
    -- Total volume from whales
    SUM(amount_usd)                                         AS whale_volume_usd,
    -- Average whale transfer size
    ROUND(AVG(amount_usd), 2)                               AS avg_whale_transfer,
    -- Median whale transfer (approximation via percentile)
    APPROX_PERCENTILE(amount_usd, 0.5)                      AS median_whale_transfer,
    -- Largest single transfer in the month
    MAX(amount_usd)                                         AS max_single_transfer
FROM stablecoin_transfers
GROUP BY transfer_month
ORDER BY transfer_month
