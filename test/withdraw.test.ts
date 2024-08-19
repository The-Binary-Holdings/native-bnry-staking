import { expect } from "chai";
import { ethers } from "hardhat";
import {  Signer } from "ethers";

describe("Staking Contract - Withdraw Function Tests", function () {
    let stakingContract: any;
    let owner: Signer;
    let user: Signer;
    let anotherUser : Signer;
    const initialBalance = ethers.parseEther("1.0"); // 1 BNRY
    const withdrawAmount = ethers.parseEther("0.5"); // 0.5 BNRY
    const zeroValue = ethers.parseEther("0"); // 0 BNRY

    beforeEach(async function () {
        const Staking = await ethers.getContractFactory("Staking");
        stakingContract = await Staking.deploy();

        [owner, user, anotherUser] = await ethers.getSigners();

        // User stakes before withdrawing
        const userInstance = stakingContract.connect(user);
        await userInstance.stake({ value: initialBalance });
    });

    it("Should allow a user to withdraw BNRY and emit WithdrewStake event", async function () {
        const userInstance = stakingContract.connect(user);

        await expect(userInstance.withdraw(withdrawAmount))
            .to.emit(stakingContract, "WithdrewStake")
            .withArgs(await user.getAddress(), withdrawAmount);

        const stakedBalance = await stakingContract.getStaked(await user.getAddress());
        expect(stakedBalance).to.equal(initialBalance - withdrawAmount);
    });

    it("Should correctly update s_totalSupply after withdrawal", async function () {
        const userInstance = stakingContract.connect(user);

        await userInstance.withdraw(withdrawAmount);
        expect(await stakingContract.getTotalBalance()).to.equal(initialBalance - withdrawAmount);
    });

    it("Should decrease s_totalNumberStakers if user withdraws all BNRY", async function () {
        const userInstance = stakingContract.connect(user);

        // Withdraw full balance
        await userInstance.withdraw(initialBalance);

        expect(await stakingContract.getTotalNumberStakers()).to.equal(0);
        expect(await stakingContract.getStaked(await user.getAddress())).to.equal(zeroValue);
    });

    it("Should revert if user tries to withdraw more than staked amount", async function () {
        const userInstance = stakingContract.connect(user);

        const overdrawAmount = initialBalance + ethers.parseEther("0.1"); // More than staked
        await expect(userInstance.withdraw(overdrawAmount)).to.be.revertedWithCustomError(stakingContract,"NeedsMoreThanZero");
    });

    it("Should handle multiple withdrawals by the same user", async function () {
        const userInstance = stakingContract.connect(user);

        // First withdrawal
        await userInstance.withdraw(withdrawAmount);
        expect(await stakingContract.getStaked(await user.getAddress())).to.equal(initialBalance - withdrawAmount);

        // Second withdrawal of remaining balance
        await userInstance.withdraw(initialBalance - withdrawAmount);
        expect(await stakingContract.getStaked(await user.getAddress())).to.equal(zeroValue);
    });

    it("Should handle withdrawals from multiple users and update s_totalNumberStakers correctly", async function () {
        const userInstance = stakingContract.connect(user);
        const anotherUserInstance = stakingContract.connect(anotherUser);

        // Second user stakes
        await anotherUserInstance.stake({ value: initialBalance });
        expect(await stakingContract.getTotalNumberStakers()).to.equal(2);

        // First user withdraws all
        await userInstance.withdraw(initialBalance);
        expect(await stakingContract.getTotalNumberStakers()).to.equal(1);

        // Second user withdraws all
        await anotherUserInstance.withdraw(initialBalance);
        expect(await stakingContract.getTotalNumberStakers()).to.equal(0);
    });
});
