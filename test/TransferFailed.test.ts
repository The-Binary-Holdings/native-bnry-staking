import { expect } from "chai";
import { ethers } from "hardhat";
import {  Signer } from "ethers";

describe("Staking Contract - Withdraw Transfer Failed", function () {
    let stakingContract: any;
    let rejectingContract: any;
    let owner: Signer;
    let user: Signer;
    const initialBalance = ethers.parseEther("1.0"); // 1 BNRY
    const withdrawAmount = ethers.parseEther("0.5"); // 0.5 BNRY
   
    beforeEach(async function () {
        const Staking = await ethers.getContractFactory("Staking");
        stakingContract = await Staking.deploy();
       
        [owner] = await ethers.getSigners();

        // Deploy the rejecting contract
        const RejectingContract = await ethers.getContractFactory("RejectingContract");
        rejectingContract = await RejectingContract.deploy(stakingContract.target);
       
        // User stakes before withdrawing
        await rejectingContract.stake({ value: initialBalance });
    });

    it("Should revert with TransferFailed error if transfer fails", async function () {
        // Try to withdraw to a contract that rejects transfers
        await expect(rejectingContract.withdraw(withdrawAmount)).to.be.revertedWithCustomError(stakingContract,"TransferFailed");
    });


});
