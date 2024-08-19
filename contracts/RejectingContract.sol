// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;


interface IStaking {
    function stake() external payable;
    function withdraw(uint256 amount) external;
}

 
contract RejectingContract {
    IStaking public stakingContract;
    address public owner;

    constructor(address _stakingContract) {
        stakingContract = IStaking(_stakingContract);
        owner = msg.sender;
    }

    receive() external payable {
        revert();
    }
    
    function stake() external payable {
        require(msg.sender == owner, "Not the owner");
        stakingContract.stake{value: msg.value}();
    }

    function withdraw(uint256 amount) external {
        require(msg.sender == owner, "Not the owner");
        stakingContract.withdraw(amount);
    }


}
