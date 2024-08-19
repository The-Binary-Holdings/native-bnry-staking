// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


error TransferFailed(); // Custom error thrown when a transfer of BNRY fails
error NeedsMoreThanZero(); // Custom error thrown when the amount of BNRY is zero

/**
 * @title Staking Contract
 * @notice This contract allows users to stake BNRY (native token) and withdraw their staked BNRY with simple mechanisms.
 *         It tracks the total supply of staked BNRY and the total number of stakers.
 * @dev The contract uses ReentrancyGuard from OpenZeppelin to prevent reentrancy attacks.
 */


contract Staking is ReentrancyGuard {
    uint256 private s_totalSupply; // Total amount of BNRY staked in the contract
    uint256 private s_totalNumberStakers; // Total number of unique stakers
    mapping(address => uint256) private s_balances; // Mapping to store the staked balance of each user

    /**
     * @dev Emitted when a user stakes BNRY.
     * @param user The address of the user who staked BNRY
     * @param amount The amount of BNRY staked by the user
     */
    event Staked(address indexed user, uint256 indexed amount);

    /**
     * @dev Emitted when a user withdraws their staked BNRY.
     * @param user The address of the user who withdrew their staked BNRY
     * @param amount The amount of BNRY withdrawn by the user
     */
    event WithdrewStake(address indexed user, uint256 indexed amount);

    /**
     * @notice Deposit BNRY into the contract to stake it.
     * @dev This function uses the `nonReentrant` modifier to prevent reentrancy attacks.
     *      The `moreThanZero` modifier ensures that the staked amount is greater than zero.
     *      If this is the first time the user is staking, they are counted as a new staker.
     */
    function stake() external payable nonReentrant moreThanZero {
        if (s_balances[msg.sender] == 0) {
            s_totalNumberStakers += 1; // Increment the staker count if the user is staking for the first time
        }
        s_totalSupply += msg.value; // Increase the total supply by the staked amount
        s_balances[msg.sender] += msg.value; // Update the user's balance
        emit Staked(msg.sender, msg.value); // Emit the staking event
    }

    /**
     * @notice Withdraw staked BNRY from the contract.
     * @param amount The amount of BNRY to withdraw
     * @dev This function checks that the user has enough staked BNRY to withdraw the specified amount.
     *      It uses the `nonReentrant` modifier to prevent reentrancy attacks.
     */
    function withdraw(uint256 amount) external nonReentrant {
        if (amount > s_balances[msg.sender]) {
            revert NeedsMoreThanZero(); // Revert if the user tries to withdraw more than their balance
        }
        s_totalSupply -= amount; // Decrease the total supply by the withdrawn amount
        s_balances[msg.sender] -= amount; // Update the user's balance
        if (s_balances[msg.sender] == 0) {
            s_totalNumberStakers -= 1; // Decrement the staker count if the user withdraws all their staked BNRY
        }
        (bool success, ) = payable(msg.sender).call{value: amount}(""); // Transfer BNRY to the user
        if (!success) {
            revert TransferFailed(); // Revert if the transfer fails
        }
        emit WithdrewStake(msg.sender, amount); // Emit the withdrawal event
    }

    /**
     * @dev Modifier to ensure that the staked amount is greater than zero.
     *      This helps prevent users from staking zero BNRY.
     */
    modifier moreThanZero() {
        if (msg.value == 0) {
            revert NeedsMoreThanZero(); // Revert if the staked amount is zero
        }
        _;
    }

    /********************/
    /* Getter Functions */
    /********************/

    /**
     * @notice Get the staked balance of a specific user.
     * @param account The address of the user
     * @return The amount of BNRY staked by the user
     */
    function getStaked(address account) external view returns (uint256) {
        return s_balances[account];
    }

    /**
     * @notice Get the total amount of BNRY staked in the contract.
     * @return The total amount of staked BNRY
     */
    function getTotalBalance() external view returns (uint256) {
        return s_totalSupply;
    }

    /**
     * @notice Get the total number of unique stakers.
     * @return The total number of stakers
     */
    function getTotalNumberStakers() external view returns (uint256) {
        return s_totalNumberStakers;
    }
}
   

