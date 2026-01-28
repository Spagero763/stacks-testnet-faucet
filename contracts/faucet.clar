;; Faucet contract for Stacks testnet
;; Dispenses tSTX to users with cooldown period

(define-constant FAUCET-AMOUNT u1000000) ;; 1 STX
(define-constant COOLDOWN-BLOCKS u144)   ;; ~24 hours

;; Error codes
(define-constant ERR-COOLDOWN-ACTIVE (err u100))

(define-map last-claim
  { user: principal }
  { block-height: uint }
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
              (stx-transfer?
                FAUCET-AMOUNT
                tx-sender
                caller
              )
            )
        )
      ;; First-time claimer
      (begin
        (map-set last-claim
          { user: caller }
          { block-height: block-height }
        )
        (stx-transfer?
          FAUCET-AMOUNT
          tx-sender
          caller
        )
      )
    )
  )
)
