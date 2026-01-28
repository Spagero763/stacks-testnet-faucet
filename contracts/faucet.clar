;; Faucet contract for Stacks testnet
;; Dispenses tSTX to users with cooldown period

(define-constant FAUCET-AMOUNT u1000000) ;; 1 STX
(define-constant COOLDOWN-BLOCKS u144)   ;; ~24 hours

;; Error codes
(define-constant ERR-COOLDOWN-ACTIVE (err u100))
(define-constant ERR-TRANSFER-FAILED (err u101))

;; Contract owner (faucet fund holder)
(define-constant CONTRACT-OWNER tx-sender)

(define-map last-claim
  { user: principal }
  { block-height: uint }
)

;; Check if user can claim and blocks remaining
(define-read-only (get-claim-status (user principal))
  (match (map-get? last-claim { user: user })
    last-entry
      (let ((blocks-since (- block-height (get block-height last-entry))))
        (if (>= blocks-since COOLDOWN-BLOCKS)
            { can-claim: true, blocks-remaining: u0 }
            { can-claim: false, blocks-remaining: (- COOLDOWN-BLOCKS blocks-since) }
        )
      )
    { can-claim: true, blocks-remaining: u0 }
  )
)

(define-public (claim)
  (let ((caller tx-sender))
    (match (map-get? last-claim { user: caller })
      last-entry
        ;; User has claimed before
        (if (< (- block-height (get block-height last-entry)) COOLDOWN-BLOCKS)
            ERR-COOLDOWN-ACTIVE
            (begin
              (map-set last-claim
                { user: caller }
                { block-height: block-height }
              )
              (as-contract (stx-transfer?
                FAUCET-AMOUNT
                CONTRACT-OWNER
                caller
              ))
            )
        )
      ;; First-time claimer
      (begin
        (map-set last-claim
          { user: caller }
          { block-height: block-height }
        )
        (as-contract (stx-transfer?
          FAUCET-AMOUNT
          CONTRACT-OWNER
          caller
        ))
      )
    )
  )
)
