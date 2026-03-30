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
        evt_tx_hash
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
)

SELECT
    transfer_date,
    -- Transfer count by stablecoin
    COUNT(CASE WHEN stablecoin = 'USDT'   THEN 1 END)      AS usdt_transfers,
    COUNT(CASE WHEN stablecoin = 'USDC'   THEN 1 END)      AS usdc_transfers,
    COUNT(CASE WHEN stablecoin = 'USDC.e' THEN 1 END)      AS usdc_e_transfers,
    -- Total transfer count
    COUNT(*)                                                 AS total_transfers,
    -- Unique transactions (one tx can have multiple transfers)
    COUNT(DISTINCT evt_tx_hash)                              AS unique_transactions,
    -- 7-day moving average for trend smoothing
    AVG(CAST(COUNT(*) AS DOUBLE)) OVER (
        ORDER BY transfer_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    )                                                        AS transfers_7d_ma
FROM stablecoin_transfers
GROUP BY transfer_date
ORDER BY transfer_date
