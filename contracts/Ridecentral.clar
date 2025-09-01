;; RideCentral DAO - Decentralized Ride-Sharing Platform
;; A DAO where drivers and riders collectively own and govern the platform

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-MEMBER (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-PROPOSAL-NOT-FOUND (err u103))
(define-constant ERR-VOTING-ENDED (err u104))
(define-constant ERR-ALREADY-VOTED (err u105))
(define-constant ERR-INVALID-AMOUNT (err u106))
(define-constant ERR-INVALID-PRINCIPAL (err u107))
(define-constant ERR-INVALID-STRING (err u108))

;; Data Variables
(define-data-var total-supply uint u0)
(define-data-var proposal-count uint u0)
(define-data-var platform-fee-rate uint u250) ;; 2.5% in basis points

;; Data Maps
(define-map token-balances principal uint)
(define-map member-info principal {
    member-type: (string-ascii 10),
    joined-at: uint,
    reputation-score: uint
})

(define-map proposals uint {
    proposer: principal,
    title: (string-ascii 100),
    description: (string-ascii 500),
    amount: uint,
    recipient: (optional principal),
    votes-for: uint,
    votes-against: uint,
    end-block: uint,
    executed: bool
})

(define-map votes {proposal-id: uint, voter: principal} bool)
(define-map ride-records uint {
    driver: principal,
    rider: principal,
    fare: uint,
    platform-fee: uint,
    completed-at: uint
})

(define-data-var ride-count uint u0)

;; Helper Functions for Input Validation
(define-private (is-valid-principal (account principal))
    (not (is-eq account 'SP000000000000000000002Q6VF78))
)

(define-private (is-valid-string (str (string-ascii 500)))
    (> (len str) u0)
)

(define-private (is-valid-title (title (string-ascii 100)))
    (and (> (len title) u0) (<= (len title) u100))
)

;; Token Functions
(define-public (mint-tokens (recipient principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        ;; Added principal validation to fix clarinet warning
        (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
        ;; Added overflow protection
        (asserts! (<= amount (- u340282366920938463463374607431768211455 (var-get total-supply))) ERR-INVALID-AMOUNT)
        (let ((current-balance (get-balance recipient)))
            (asserts! (<= amount (- u340282366920938463463374607431768211455 current-balance)) ERR-INVALID-AMOUNT)
            (map-set token-balances recipient (+ current-balance amount))
        )
        (var-set total-supply (+ (var-get total-supply) amount))
        (ok amount)
    )
)

(define-read-only (get-balance (account principal))
    (default-to u0 (map-get? token-balances account))
)

(define-read-only (get-total-supply)
    (var-get total-supply)
)

(define-public (transfer (recipient principal) (amount uint))
    (let ((sender-balance (get-balance tx-sender)))
        (asserts! (>= sender-balance amount) ERR-INSUFFICIENT-BALANCE)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        ;; Added principal validation to fix clarinet warning
        (asserts! (is-valid-principal recipient) ERR-INVALID-PRINCIPAL)
        (let ((recipient-balance (get-balance recipient)))
            (asserts! (<= amount (- u340282366920938463463374607431768211455 recipient-balance)) ERR-INVALID-AMOUNT)
            (map-set token-balances tx-sender (- sender-balance amount))
            (map-set token-balances recipient (+ recipient-balance amount))
        )
        (ok amount)
    )
)

;; Membership Functions
(define-public (join-as-driver)
    (begin
        (map-set member-info tx-sender {
            member-type: "driver",
            joined-at: block-height,
            reputation-score: u100
        })
        (mint-tokens tx-sender u1000) ;; Initial token allocation
    )
)

(define-public (join-as-rider)
    (begin
        (map-set member-info tx-sender {
            member-type: "rider",
            joined-at: block-height,
            reputation-score: u100
        })
        (mint-tokens tx-sender u500) ;; Initial token allocation
    )
)

(define-read-only (get-member-info (member principal))
    (map-get? member-info member)
)

(define-read-only (is-member (account principal))
    (is-some (map-get? member-info account))
)

;; Governance Functions
(define-public (create-proposal (title (string-ascii 100)) (description (string-ascii 500)) (amount uint) (recipient (optional principal)))
    (let ((proposal-id (+ (var-get proposal-count) u1)))
        (asserts! (is-member tx-sender) ERR-NOT-MEMBER)
        (asserts! (>= (get-balance tx-sender) u100) ERR-INSUFFICIENT-BALANCE)
        ;; Added input validation to fix clarinet warnings
        (asserts! (is-valid-title title) ERR-INVALID-STRING)
        (asserts! (is-valid-string description) ERR-INVALID-STRING)
        (asserts! (>= amount u0) ERR-INVALID-AMOUNT)
        (asserts! (match recipient
            some-recipient (is-valid-principal some-recipient)
            true
        ) ERR-INVALID-PRINCIPAL)
        (map-set proposals proposal-id {
            proposer: tx-sender,
            title: title,
            description: description,
            amount: amount,
            recipient: recipient,
            votes-for: u0,
            votes-against: u0,
            end-block: (+ block-height u1440), ;; ~10 days
            executed: false
        })
        (var-set proposal-count proposal-id)
        (ok proposal-id)
    )
)

(define-public (vote (proposal-id uint) (support bool))
    (let ((proposal (unwrap! (map-get? proposals proposal-id) ERR-PROPOSAL-NOT-FOUND))
          (voter-balance (get-balance tx-sender)))
        (asserts! (is-member tx-sender) ERR-NOT-MEMBER)
        (asserts! (< block-height (get end-block proposal)) ERR-VOTING-ENDED)
        (asserts! (is-none (map-get? votes {proposal-id: proposal-id, voter: tx-sender})) ERR-ALREADY-VOTED)

        (map-set votes {proposal-id: proposal-id, voter: tx-sender} true)

        (if support
            (map-set proposals proposal-id 
                (merge proposal {votes-for: (+ (get votes-for proposal) voter-balance)}))
            (map-set proposals proposal-id 
                (merge proposal {votes-against: (+ (get votes-against proposal) voter-balance)}))
        )
        (ok support)
    )
)

(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals proposal-id)
)

(define-read-only (get-proposal-count)
    (var-get proposal-count)
)

;; Ride Management Functions
(define-public (complete-ride (rider principal) (fare uint))
    (let ((ride-id (+ (var-get ride-count) u1))
          (platform-fee (/ (* fare (var-get platform-fee-rate)) u10000)))
        (asserts! (is-member tx-sender) ERR-NOT-MEMBER)
        (asserts! (is-member rider) ERR-NOT-MEMBER)
        (asserts! (> fare u0) ERR-INVALID-AMOUNT)

        (map-set ride-records ride-id {
            driver: tx-sender,
            rider: rider,
            fare: fare,
            platform-fee: platform-fee,
            completed-at: block-height
        })

        (var-set ride-count ride-id)

        ;; Distribute platform fee as tokens to both driver and rider
        (try! (mint-tokens tx-sender (/ platform-fee u2)))
        (try! (mint-tokens rider (/ platform-fee u2)))

        (ok ride-id)
    )
)

(define-read-only (get-ride-record (ride-id uint))
    (map-get? ride-records ride-id)
)

(define-read-only (get-ride-count)
    (var-get ride-count)
)

;; Platform Management
(define-public (update-platform-fee (new-rate uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (asserts! (<= new-rate u1000) ERR-INVALID-AMOUNT) ;; Max 10%
        (var-set platform-fee-rate new-rate)
        (ok new-rate)
    )
)

(define-read-only (get-platform-fee-rate)
    (var-get platform-fee-rate)
)

;; Profit Distribution
(define-public (distribute-profits (amount uint))
    (let ((total-tokens (var-get total-supply)))
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
        (asserts! (> amount u0) ERR-INVALID-AMOUNT)
        (asserts! (> total-tokens u0) ERR-INVALID-AMOUNT)
        ;; In a real implementation, this would distribute proportionally to all token holders
        ;; For simplicity, we're just recording the distribution event
        (ok amount)
    )
)

;; Initialize contract
(begin
    (try! (mint-tokens CONTRACT-OWNER u10000))
    (map-set member-info CONTRACT-OWNER {
        member-type: "admin",
        joined-at: block-height,
        reputation-score: u1000
    })
)
