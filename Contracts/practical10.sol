// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
=========================================================
PRACTICAL: Delete mapping entry
CONCEPT: Partial storage reset
=========================================================

OBJECTIVE

- Learn how delete works on mappings
- Understand partial storage reset behavior
- Learn how specific user data is cleared
- Understand mapping cleanup implications

---------------------------------------------------------
WHAT HAPPENS WHEN DELETING MAPPING ENTRY?
---------------------------------------------------------

Mappings store values per key.

Example:

balances[user1] => 100
balances[user2] => 500

Using:

delete balances[user1];

ONLY resets user1 value.

Other entries remain unchanged.

---------------------------------------------------------
IMPORTANT UNDERSTANDING
---------------------------------------------------------

delete on mapping:
- resets ONLY selected key
- does NOT remove entire mapping
- resets value to default

---------------------------------------------------------
DEFAULT VALUES
---------------------------------------------------------

uint256 => 0
bool => false
address => address(0)

---------------------------------------------------------
REAL-WORLD USAGE
---------------------------------------------------------

Mapping deletion used for:

- removing balances
- revoking permissions
- resetting user state
- removing approvals
- clearing staking positions

---------------------------------------------------------
AUDITOR FOCUS
---------------------------------------------------------

Auditors inspect:

- Can attacker delete others' data?
- Is cleanup complete?
- Is authorization missing?
- Are stale references left behind?
- Can deletion break accounting?

=========================================================
*/

contract DeleteMappingEntryvul {

    mapping(address => uint256) public balances;

    function setBalance(uint256 _amount) public {
        balances[msg.sender] = _amount;
    }

    function deleteMyBalance() public {
        delete balances[msg.sender];
    }

    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}

/*
=========================================================
EXECUTION FLOW
=========================================================

INITIAL STATE

balances[user] => 0

because uint256 default value is zero.

---------------------------------------------------------

USER A CALLS:
setBalance(100)

RESULT:

balances[userA] = 100

---------------------------------------------------------

USER B CALLS:
setBalance(999)

RESULT:

balances[userB] = 999

---------------------------------------------------------

USER A CALLS:
deleteMyBalance()

EVM ACTIONS:

1. msg.sender identified
2. Mapping slot calculated
3. Value reset to default
4. balances[userA] becomes 0

IMPORTANT:
Only userA entry deleted.

---------------------------------------------------------

FINAL STATE

balances[userA] = 0
balances[userB] = 999

=========================================================
REMIX TESTING
=========================================================

NORMAL FLOW

STEP 1:
Deploy contract

---------------------------------------------------------

STEP 2:
Using Account 1

Call:
setBalance(100)

EXPECTED:
balances(Account1) => 100

---------------------------------------------------------

STEP 3:
Switch to Account 2

Call:
setBalance(500)

EXPECTED:
balances(Account2) => 500

---------------------------------------------------------

STEP 4:
Switch back to Account 1

Call:
deleteMyBalance()

EXPECTED:
balances(Account1) => 0

---------------------------------------------------------

STEP 5:
Check Account 2

EXPECTED:
balances(Account2) still equals 500

OBSERVE:
Only one mapping entry reset.

=========================================================
EDGE CASE TESTS
=========================================================

TEST:
Delete non-existing entry

Call:
deleteMyBalance()

without setting value first.

EXPECTED:
Still equals 0

---------------------------------------------------------

TEST:
Repeated delete calls

EXPECTED:
No error occurs

---------------------------------------------------------

TEST:
Set value after delete

1. setBalance(100)
2. deleteMyBalance()
3. setBalance(777)

EXPECTED:
balances[msg.sender] => 777

=========================================================
IMPORTANT STORAGE UNDERSTANDING
=========================================================

MAPPING STORAGE BEHAVIOR

Mappings use hashed storage locations.

Example:

keccak256(key + slot)

determines storage position.

---------------------------------------------------------

DELETE OPERATION

delete balances[user];

internally behaves similar to:

balances[user] = 0;

for uint256 mappings.

---------------------------------------------------------

IMPORTANT:
Other mapping entries remain untouched.

=========================================================
SECURITY / AUDITOR MINDSET
=========================================================

---------------------------------------------------------
1. PARTIAL RESET SAFETY
---------------------------------------------------------

Current logic safely deletes
ONLY caller's own entry.

Using msg.sender is important.

---------------------------------------------------------
2. DANGEROUS VERSION
---------------------------------------------------------

Example dangerous function:

function deleteUser(address user)

without authorization.

Attackers could erase other users' data.

---------------------------------------------------------
3. ACCOUNTING RISKS
---------------------------------------------------------

Deleting balances incorrectly may:
- break accounting
- bypass checks
- manipulate rewards

Auditors verify:
- total balances remain correct
- cleanup logic safe

---------------------------------------------------------
4. STALE STATE ISSUES
---------------------------------------------------------

Deleting one mapping may not clean:
- related arrays
- indexes
- references

This causes inconsistent protocol state.

=========================================================
ATTACK THINKING
=========================================================

ATTACK SCENARIO

Suppose mapping stores:

- staking balances
- whitelist access
- reward eligibility

Improper deletion may:
- remove user rights
- erase balances
- bypass restrictions

---------------------------------------------------------

ANOTHER RISK

If protocol tracks totals separately:

totalBalance may remain unchanged
after deletion.

Result:
Accounting inconsistency.

=========================================================
MINI CHALLENGE
=========================================================

Modify contract so that:

1. Store bool instead of uint256
2. Use mapping for whitelist system
3. Add removeFromWhitelist() function

BONUS:
Restrict deletion to owner only.

=========================================================
IMPORTANT CONCEPTS LEARNED
=========================================================

- delete resets mapping value to default
- Only targeted key is affected
- Other mapping entries remain unchanged
- Mappings use hashed storage
- delete behaves like assigning default value
- msg.sender protects user-specific data
- Incorrect deletion can break accounting
- Partial cleanup may leave stale state
- Access control is critical
- Auditors inspect deletion logic carefully

=========================================================
*/

// patch code 



contract Whitelist {
    address public owner;

    mapping(address => bool) public whitelist;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function addToWhitelist(address _user) public onlyOwner {
        whitelist[_user] = true;
    }

    function removeFromWhitelist(address _user) public onlyOwner {
        delete whitelist[_user];
    }

    function isWhitelisted(address _user) public view returns (bool) {
        return whitelist[_user];
    }
}



/*
Audit Report----------------------------------------------------------------------------

Title: Centralized Whitelist Management

Severity: Low

Reason: A single privileged account has complete control over whitelist membership.

Location:=======================================================================================
-
Contract: Whitelist
Function: addToWhitelist()
Function: removeFromWhitelist()

Vulnerability Description:

The contract uses a centralized ownership model where a single owner address can arbitrarily add or remove users from the whitelist.

While this behavior may be intended, it introduces a trust assumption that the owner account will remain secure and act honestly.

If the owner's private key is compromised, an attacker can manipulate whitelist membership by adding unauthorized addresses or removing legitimate users.

Impact:============================================================================================

An attacker who gains control of the owner account can:

* Add malicious addresses to the whitelist
* Remove legitimate users from the whitelist
* Disrupt protocol functionality that depends on whitelist permissions
* Circumvent access restrictions enforced elsewhere in the system

Proof of Concept:================================================================================

Deploy the contract.

Owner calls:

addToWhitelist(UserA)

Result:

whitelist[UserA] = true

If the owner's private key becomes compromised, the attacker can call:

removeFromWhitelist(UserA)

or

addToWhitelist(Attacker)

Result:

Whitelist membership is modified successfully.

Root Cause:

Whitelist administration is fully controlled by a single owner address.

The contract does not implement:

* Multi-signature authorization
* Role-based access control
* Timelocks
* Governance mechanisms

Recommendation:==========================================================================

Consider reducing centralization risks by implementing stronger administrative controls such as:

* Multi-signature wallets
* Role-based permissions
* Timelocked whitelist updates
* Governance-controlled access management

Example:

Use OpenZeppelin AccessControl:

bytes32 public constant WHITELIST_ADMIN_ROLE =
keccak256("WHITELIST_ADMIN_ROLE");

Patched Code  =======================================================================================
*/

