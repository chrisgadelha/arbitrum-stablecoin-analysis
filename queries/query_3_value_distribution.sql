WITH stablecoin_transfers AS (
    SELECT
        date_trunc('month', evt_block_time)                 AS transfer_month,
        value / 1e6                                         AS amount_usd
    FROM erc20_arbitrum.evt_Transfer
    WHERE contract_address IN (
        0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9,   -- USDT
        0xaf88d065e77c8cC2239327C5EDb3A432268e5831,   -- USDC (native)
        0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8    -- USDC.e (bridged)
    )
    AND evt_block_time >= TIMESTAMP '2023-01-01'
    AND evt_block_time <  TIMESTAMP '2026-03-25'
    AND "from" != 0x0000000000000000000000000000000000000000
    AND "to"   != 0x0000000000000000000000000000000000000000
),

classified AS (
    SELECT
        transfer_month,
        amount_usd,
        CASE
            WHEN amount_usd < 100                           THEN '1_micro_0_100'
            WHEN amount_usd >= 100    AND amount_usd < 1000 THEN '2_small_100_1k'
            WHEN amount_usd >= 1000   AND amount_usd < 10000 THEN '3_medium_1k_10k'
            WHEN amount_usd >= 10000  AND amount_usd < 100000 THEN '4_large_10k_100k'
            WHEN amount_usd >= 100000                       THEN '5_whale_100k_plus'
        END                                                 AS value_bracket
    FROM stablecoin_transfers
    WHERE amount_usd > 0  -- Exclude zero-value transfers
)

SELECT
    transfer_month,
    value_bracket,
    -- How many transfers in this bracket
    COUNT(*)                                                AS transfer_count,
    -- What percentage of total monthly transfers
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY transfer_month),
        2
    )                                                       AS pct_of_monthly_transfers,
    -- Total USD volume in this bracket
    SUM(amount_usd)                                         AS bracket_volume_usd,
    -- What percentage of total monthly volume
    ROUND(
        100.0 * SUM(amount_usd) / SUM(SUM(amount_usd)) OVER (PARTITION BY transfer_month),
        2
    )                                                       AS pct_of_monthly_volume,
    -- Average transfer size in this bracket
    ROUND(AVG(amount_usd), 2)                               AS avg_transfer_usd
FROM classified
GROUP BY transfer_month, value_bracket
ORDER BY transfer_month, value_bracket
